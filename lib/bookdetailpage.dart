import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailPage({required this.book, Key? key}) : super(key: key);

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
   bool isStarred = false;
   IconData sharedicon = Icons.share_outlined;
    IconData yessharedicon = Icons.share_outlined;
  
   bool isshared = false;

   bool isbookmarked = false;

   bool isdownloaded = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.book['title'] ?? 'No Title';
    final author = widget.book['authors']?.isNotEmpty ?? false
        ? widget.book['authors'][0]['name']
        : 'Unknown Author';
    final coverUrl = widget.book['formats']['image/jpeg'];
    final subjects = widget.book['subjects']?.join(', ') ?? 'No subjects';
  

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Details",
          style: TextStyle(color: Colors.black,
          fontWeight: FontWeight.bold),
        ),
      
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  color: const Color.fromARGB(255, 255, 255, 255),
            
                
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2 - 100,
                  left: MediaQuery.of(context).size.width * 0.5 - 95,
                  child: Card(
                    elevation: 8,
                    
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),

                    ),
                      
                    child: Container(
                  
                      height: 270,
                      width: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: coverUrl != null
                            ? DecorationImage(
                                image: NetworkImage(coverUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[300],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 40,
                            spreadRadius: 20,
                            
                        

                          )
                        ]
                      ),
                      child: coverUrl == null
                          ? Icon(
                              Icons.book,
                              size: 80,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height:50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              GestureDetector(
                onTap: () {
            setState(() {
              isshared = !isshared;
               // Toggle the icon
            });
          },
                child: Icon(
                  isshared ? Icons.share_outlined : Icons.share,
                  size: 30,
                ),
              ),
              GestureDetector(
                onTap: (){
                    setState(() {
              isStarred = !isStarred;
               // Toggle the icon
            });

                },
                child: Icon(
                  isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 30,
                ),
              ),
              GestureDetector(
                onTap: (){
                    setState(() {
              isbookmarked = !isbookmarked;
               // Toggle the icon
            });

                },
                child: Icon(
                 isbookmarked ? Icons.bookmark :  Icons.bookmark_outline,
                  size: 30,
                ),
              ),
              GestureDetector(
                onTap: (){
                    setState(() {
              isdownloaded = !isdownloaded;
               // Toggle the icon
            });

                },
                child: Icon(
               isdownloaded ? Icons.download_done_rounded :  Icons.download_rounded,
                 size: 30,
                ),
              )

              ],

            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    ' $author',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subjects,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
