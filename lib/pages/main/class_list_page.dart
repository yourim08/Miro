import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ClassListPage extends StatelessWidget {
  const ClassListPage({super.key});

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("로그아웃 완료! 다시 로그인하세요.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("클래스 목록"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(context),
            tooltip: "로그아웃",
          ),
        ],
      ),
      body: Center(child: Text("환영합니다!", style: const TextStyle(fontSize: 24))),
    );
  }
}
