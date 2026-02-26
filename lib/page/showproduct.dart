import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lab10_boolapp/model/BookModel.dart';
import 'package:http/http.dart' as http;
import 'package:lab10_boolapp/page/addproduct.dart';
import 'package:lab10_boolapp/page/editproduct.dart';
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
                child: CircularProgressIndicator(color: Color(0xFF00FF88)),
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
                : RefreshIndicator(
                    color: const Color(0xFF00FF88),
                    onRefresh: getList,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF04110A).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF00FF88),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FF88)
                                    .withOpacity(0.2),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditproductPage(book: book),
                                ),
                              ).then((_) => getList());
                            },
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
                            trailing: GestureDetector(
                              onTap: () => _confirmDelete(book.id),
                              child: const Icon(
                                Icons.delete_forever,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF88).withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF00FF88),
          foregroundColor: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddproductPage()),
            ).then((_) => getList());
          },
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Future<void> getList() async {
    try {
      setState(() => isLoading = true);

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

        setState(() {
          books =
              list.map<BookModel>((json) => BookModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Exception: $e');
      setState(() => isLoading = false);
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF04110A),
        title: const Text(
          'CONFIRM DELETE',
          style: TextStyle(color: Color(0xFF00FF88)),
        ),
        content: const Text(
          'คุณแน่ใจหรือไม่ว่าต้องการลบข้อมูลนี้?',
          style: TextStyle(color: Color(0xFF9CFFCC)),
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL',
                style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('DELETE',
                style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              Navigator.pop(context);
              await deleteBook(id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteBook(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('http://10.0.2.2:3000/api/books/$id');

      final response = await http.delete(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await getList();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบข้อมูลเรียบร้อย')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบข้อมูลไม่สำเร็จ')),
        );
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้')),
      );
    }
  }
}