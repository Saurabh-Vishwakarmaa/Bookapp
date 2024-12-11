import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:letsfit/bookdetailpage.dart';

class BookExplorer extends StatefulWidget {
  @override
  _BookExplorerState createState() => _BookExplorerState();
}

class _BookExplorerState extends State<BookExplorer> {
  final String baseUrl = "https://gutendex.com/books";
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> books = [];
  List<String> genres = ["Fiction", "Fantasy", "History", "Science", "Poetry"];
  String? selectedGenre;
  int nextPageToken = 1;
  bool isLoading = false;
  bool hasMore = true;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    fetchBooks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBooks({bool reset = false}) async {
    if (isLoading || !hasMore) return;

    if (reset) {
      setState(() {
        books = [];
        nextPageToken = 1;
        hasMore = true;
      });
    }

    setState(() => isLoading = true);

    try {
      String url = '$baseUrl/?page=$nextPageToken';
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        url += '&search=$searchQuery';
      }
      if (selectedGenre != null) {
        url += '&topic=$selectedGenre';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data['results'] is List) {
          setState(() {
            books.addAll(data['results']);
            nextPageToken++;
            hasMore = data['next'] != null;
          });
        }
      } else {
        throw Exception("Failed to load books: ${response.reasonPhrase}");
      }
    } catch (error) {
      print('Error fetching books: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      fetchBooks();
    }
  }

  void searchBooks() {
    setState(() {
      searchQuery = _searchController.text.trim();
    });
    fetchBooks(reset: true);
  }

  void selectGenre(String genre) {
    setState(() {
      selectedGenre = genre;
    });
    fetchBooks(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search books...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onSubmitted: (_) => searchBooks(),
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
        ),
        backgroundColor: const Color.fromARGB(255, 226, 226, 226),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: searchBooks,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(genre),
                    selected: selectedGenre == genre,
                    onSelected: (_) => selectGenre(genre),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: books.isEmpty && isLoading
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: books.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= books.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final book = books[index];
                      final title = book['title'] ?? 'No Title';
                      final author = book['authors']?.isNotEmpty ?? false
                          ? book['authors'][0]['name']
                          : 'Unknown Author';
                      final coverUrl = book['formats']['image/jpeg'];

                      return GestureDetector(
                        onTap: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailPage(book: book )));

                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: coverUrl != null
                                    ? Image.network(
                                        coverUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.book,
                                          size: 80,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      author,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
