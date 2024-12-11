import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';

class ApiService {
  final String baseUrl = "https://gutendex.com/books";

  Future<Map<String, dynamic>> fetchBooks({int page = 1, String? genre}) async {
    String url = '$baseUrl/?page=$page';
    if (genre != null) {
      url += '&topic=$genre';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is Map<String, dynamic> && data['results'] is List) {
        return {
          'books': data['results'],
          'nextPageToken': page + 1,
          'hasMore': data['next'] != null,
        };
      } else {
        throw Exception("Unexpected response format");
      }
    } else {
      throw Exception("Failed to load books: ${response.reasonPhrase}");
    }
  }
}

class BooksApp extends StatefulWidget {
  @override
  _BooksAppState createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> books = [];
  int nextPageToken = 1;
  bool isLoading = false;
  bool hasMore = true;
  String? selectedGenre;
  String? searchQuery;

  List<String> genres = ["fiction", "drama", "poetry", "adventure", "history"];

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

  void fetchBooks({bool reset = false}) async {
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
      final response = await apiService.fetchBooks(
        page: nextPageToken,
        genre: selectedGenre,
      );
      setState(() {
        books.addAll(response['books']);
        nextPageToken = response['nextPageToken'];
        hasMore = response['hasMore'];
      });
    } catch (error) {
      print('Error fetching books: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchBooks();
    }
  }

  void searchBooks() {
    setState(() {
      selectedGenre = null;
      searchQuery = _searchController.text.trim();
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
          ),
          onSubmitted: (_) => searchBooks(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedGenre = genre);
                    fetchBooks(reset: true);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selectedGenre == genre
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      genre,
                      style: TextStyle(
                        color: selectedGenre == genre
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
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

                      return Card(
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
                      );
                    },
                  ),
          ),
          if (isLoading && books.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
