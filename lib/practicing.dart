import 'package:flutter/material.dart';
import 'package:letsfit/api_service.dart';

class _ThebookspagState extends StatefulWidget {
  const _ThebookspagState({super.key});

  @override
  State<_ThebookspagState> createState() => __ThebookspagStateState();
}

class __ThebookspagStateState extends State<_ThebookspagState> {
  int currentPage = 1;
  final ApiService apiService = ApiService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(future:apiService.fetchBooks(page: currentPage),
       builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
          
          
        }
        else if(snapshot.hasError){
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }
        else if(!snapshot.hasData || snapshot.data!.isEmpty){
          return Center(
            child: Text("No books Available"),
          );
        }
        final books =  snapshot.data!;
        return ListView.builder(
          itemCount: books.length,
        
          itemBuilder: (context,index){
          final book = books[index];
          final  title = books['title'] ?? 'No Title';
          final author = book['authors']?.isNotEmpty ?? false ? book['authors'][0]['name'] : 'Unknown Author';
final coverurl = book['formats']['image/jpeg'];
        });
      }),
        

    );
  }
}