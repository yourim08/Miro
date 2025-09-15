import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // FlutterFire CLI
import 'pages/sign_up/sign_up_page.dart'; // ✅ SignUpPage import
import 'pages/main/class_list_page.dart'; // ✅ HomePage import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 195),
              SizedBox(
                width: 113,
                height: 150,
                child: Image.asset('assets/home_logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 76),
              const Text(
                "혼자가 아닌, \n멘토와 함께하는 성장의 여정",
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600, // SemiBold
                  fontSize: 24,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 88),
                child: GoogleSignInButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 361,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () async {
          final userCredential = await _signInWithGoogle();
          if (userCredential != null && mounted) {
            final user = userCredential.user;

            // ------------------------------
            // 🔹 Firestore 회원가입 체크
            final doc = await FirebaseFirestore.instance
                .collection("users")
                .doc(user!.uid)
                .get();

            if (!doc.exists) {
              // ✅ 회원가입 안된 사용자 → 회원가입 페이지
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage(user: user)),
              );
            } else {
              // ✅ 이미 회원가입 완료 → 클래스 목록 페이지
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClassListPage()),
              );
            }
            // ------------------------------
          }
        },

        icon: Image.asset('assets/google_logo.png', height: 24),
        label: const Text(
          "Google로 계속하기",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500, // Medium
            fontSize: 16,
            color: Color.fromARGB(255, 33, 33, 33),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color.fromRGBO(206, 206, 206, 1),
            width: 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}
