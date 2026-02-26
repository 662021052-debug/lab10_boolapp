import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddproductPage extends StatefulWidget {
  const AddproductPage({super.key});

  @override
  State<AddproductPage> createState() => _AddproductPageState();
}

class _AddproductPageState extends State<AddproductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> addProduct() async {
    final prefs = await _prefs;
    final token = prefs.getString('token') ?? '';

    final data = jsonEncode({
      'title': titleController.text,
      'author': authorController.text,
      'published_year': int.parse(yearController.text),
    });

    final url = Uri.parse('http://10.0.2.2:3000/api/books');

    try {
      final response = await http.post(
        url,
        body: data,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      debugPrint('Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); // กลับไปหน้า list
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product (${response.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot connect to server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD BOOK', style: TextStyle(letterSpacing: 1.5)),
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF04110A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00FF88), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88).withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'NEW BOOK ENTRY',
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: titleController,
                      decoration: _terminalInput('TITLE'),
                      style: const TextStyle(color: Color(0xFF9CFFCC)),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'กรุณากรอกชื่อหนังสือ'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: authorController,
                      decoration: _terminalInput('AUTHOR'),
                      style: const TextStyle(color: Color(0xFF9CFFCC)),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'กรุณากรอกชื่อผู้เขียน'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: yearController,
                      keyboardType: TextInputType.number,
                      decoration: _terminalInput('PUBLISHED YEAR'),
                      style: const TextStyle(color: Color(0xFF9CFFCC)),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'กรุณากรอกปีที่พิมพ์';
                        final year = int.tryParse(v);
                        if (year == null) return 'ต้องเป็นตัวเลขเท่านั้น';
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF88),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            addProduct();
                          }
                        },
                        child: const Text(
                          'SAVE',
                          style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _terminalInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF00FF88)),
      filled: true,
      fillColor: const Color(0xFF020A06),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00FF88)),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF66FFB2), width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    yearController.dispose();
    super.dispose();
  }
}