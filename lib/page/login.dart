import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10_boolapp/page/showproduct.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== พื้นหลังธีม Sci-Fi Green Terminal =====
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF020A06), // ดำอมเขียว
              Color(0xFF04130C),
              Color(0xFF020A06),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF04110A).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00FF88), // เขียวนีออน
                    width: 1.5,
                  ),
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
                      // ===== Header =====
                      const Icon(
                        Icons.memory,
                        size: 56,
                        color: Color(0xFF00FF88),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'BOOK ACCESS TERMINAL',
                        style: TextStyle(
                          color: Color(0xFF00FF88),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ===== Username =====
                      TextFormField(
                        controller: usernameController,
                        style: const TextStyle(color: Color(0xFF9CFFCC)),
                        decoration: _terminalInput('USERNAME'),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Required'
                            : null,
                      ),

                      const SizedBox(height: 14),

                      // ===== Password =====
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Color(0xFF9CFFCC)),
                        decoration: _terminalInput('PASSWORD'),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Required'
                            : null,
                      ),

                      const SizedBox(height: 22),

                      // ===== ปุ่ม Login =====
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
                            elevation: 8,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final jsonData = {
                                "username": usernameController.text,
                                "password": passwordController.text,
                              };

                              final url = Uri.parse(
                                "http://10.0.2.2:3000/api/auth/login",
                              );

                              try {
                                final response = await http.post(
                                  url,
                                  headers: {"Content-Type": "application/json"},
                                  body: jsonEncode(jsonData), // ✅ แก้จุดผิด
                                );

                                if (response.statusCode == 200) {
                                  debugPrint(response.body);
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  var userJson = jsonDecode(
                                    response.body,
                                  )["user"];
                                  var tokenJson = jsonDecode(
                                    response.body,
                                  )["accessToken"];
                                  await prefs.setStringList('user', [
                                    userJson['username'],
                                    userJson['tel'],
                                  ]);

                                  await prefs.setString('token', tokenJson);
                                  debugPrint(tokenJson.toString());

                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => const Showproducts(),
                                  ));

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('ACCESS CONFIRMED'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('ACCESS DENIED'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                debugPrint("Error: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('SYSTEM OFFLINE'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'login',
                            style: TextStyle(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ===== ปุ่ม Register =====
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00FF88),
                          side: const BorderSide(color: Color(0xFF00FF88)),
                        ),
                        onPressed: () {},
                        child: const Text('register'),
                      ),
                    ],
                  ),
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
}
