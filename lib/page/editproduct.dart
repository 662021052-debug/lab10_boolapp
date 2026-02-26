import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10_boolapp/model/BookModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditproductPage extends StatefulWidget {
  final BookModel book;

  const EditproductPage({super.key, required this.book});

  @override
  State<EditproductPage> createState() => _EditproductPageState();
}

class _EditproductPageState extends State<EditproductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController yearController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.book.title);
    authorController = TextEditingController(text: widget.book.author);
    yearController =
        TextEditingController(text: widget.book.publishedYear.toString());
  }

  Future<void> updateBook() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url =
        Uri.parse('http://10.0.2.2:3000/api/books/${widget.book.id}');

    final body = jsonEncode({
      "title": titleController.text,
      "author": authorController.text,
      "published_year": int.parse(yearController.text),
    });

    final response = await http.put(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // 🔙 กลับไปหน้า List
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกการแก้ไขเรียบร้อย')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('แก้ไขข้อมูลไม่สำเร็จ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT BOOK'),
        backgroundColor: const Color(0xFF020A06),
        foregroundColor: const Color(0xFF00FF88),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF020A06), Color(0xFF04130C), Color(0xFF020A06)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF04110A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00FF88), width: 1.5),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field('TITLE', titleController),
                    const SizedBox(height: 12),
                    _field('AUTHOR', authorController),
                    const SizedBox(height: 12),
                    _field('YEAR', yearController,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF88),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateBook();
                          }
                        },
                        child: const Text('SAVE CHANGES'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF9CFFCC)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF00FF88)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF00FF88)),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF66FFB2), width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอก $label' : null,
    );
  }
}