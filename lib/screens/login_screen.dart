import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _signInWithEmailAndPassword() async {
    try {
      final User? user = (await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      )).user;
      if (user != null) {
        toastification.show(
          context: context,
          title: Text('Login Successful'),
          autoCloseDuration: const Duration(seconds: 5),
        );
      } else {
        toastification.show(
          context: context,
          title: Text('Login Failed'),
          type: ToastificationType.warning,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      toastification.show(
        context: context,
        title: Text(e.toString()),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar sesión")),
      body: Column(
        children: <Widget>[
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: _signInWithEmailAndPassword,
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}