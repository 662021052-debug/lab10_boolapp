import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lab10_boolapp/model/BookModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Showproducts extends StatefulWidget {
  const Showproducts({super.key});

  @override
  State<Showproducts> createState() => _ShowproductsState();
}

class _ShowproductsState extends State<Showproducts> {
  List<BookModel> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BOOK DATABASE',
          style: TextStyle(letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF020A06),
        foregroundColor: const Color(0xFF00FF88),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF020A06),
              Color(0xFF04130C),
              Color(0xFF020A06),
            ],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00FF88),
                ),
              )
            : books.isEmpty
                ? const Center(
                    child: Text(
                      'NO DATA FOUND',
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        letterSpacing: 1.5,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF04110A).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF00FF88),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF88).withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.menu_book,
                            color: Color(0xFF00FF88),
                          ),
                          title: Text(
                            book.title,
                            style: const TextStyle(
                              color: Color(0xFF9CFFCC),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${book.author} • ${book.publishedYear}',
                            style: const TextStyle(
                              color: Color(0xFF66FFB2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Future<void> getList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('http://10.0.2.2:3000/api/books');

      final response = await http.get(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded is List ? decoded : decoded['payload'];

        debugPrint(response.body);

        setState(() {
          books =
              list.map<BookModel>((json) => BookModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        debugPrint('Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Exception: $e');
      setState(() => isLoading = false);
    }
  }
}
