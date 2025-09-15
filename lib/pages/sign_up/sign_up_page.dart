import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miro/pages/main/class_list_page.dart';

class SignUpPage extends StatefulWidget {
  final User user;
  const SignUpPage({super.key, required this.user});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int _step = 1;

  // 입력값 저장
  String? _selectedGrade;
  String? _selectedClass;
  String? _studentNumber;
  String? _nickname;

  final _numberController = TextEditingController();
  final _nicknameController = TextEditingController();

  final List<String> grades = ["1학년", "2학년", "3학년"];
  final List<String> classes = ["1반", "2반", "3반", "4반", "5반", "6반"];

  Future<bool> _isDuplicateStudent() async {
    final query = await FirebaseFirestore.instance
        .collection("users")
        .where("grade", isEqualTo: _selectedGrade)
        .where("class", isEqualTo: _selectedClass)
        .where("number", isEqualTo: _studentNumber)
        .get();

    return query.docs.isNotEmpty; // 이미 존재하면 true
  }

  Future<void> _saveToFirestore() async {
    final user = widget.user;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "uid": user.uid,
      "name": user.displayName,
      "email": user.email,
      "grade": _selectedGrade,
      "class": _selectedClass,
      "number": _studentNumber,
      "nickname": _nickname,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _step == 1 ? _buildStep1() : _buildStep2(),
      ),
    );
  }

  // 1단계: 학년, 반, 번호 입력
  Widget _buildStep1() {
    const double boxWidth = 361;
    const Color defaultBorderColor = Color(0xFFCECECE);
    const Color focusedBorderColor = Color(0xFF424242);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 36.0),
          child: Text(
            "학교 정보를 입력해주세요",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),

        // 학년
        const Text("학년", style: TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          width: boxWidth,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: defaultBorderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedGrade,
            hint: const Text("학년을 선택해주세요"),
            dropdownColor: Colors.white,
            decoration: const InputDecoration(border: InputBorder.none),
            items: grades.map((grade) {
              return DropdownMenuItem(value: grade, child: Text(grade));
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedGrade = value);
            },
          ),
        ),

        const SizedBox(height: 20),

        // 반
        const Text("반", style: TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          width: boxWidth,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: defaultBorderColor),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedClass,
            hint: const Text("반을 선택해주세요"),
            dropdownColor: Colors.white,
            decoration: const InputDecoration(border: InputBorder.none),
            items: classes.map((cls) {
              return DropdownMenuItem(value: cls, child: Text(cls));
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedClass = value);
            },
          ),
        ),

        const SizedBox(height: 20),

        // 번호
        const Text("번호", style: TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        SizedBox(
          width: boxWidth,
          height: 56,
          child: TextField(
            controller: _numberController,
            decoration: InputDecoration(
              hintText: "번호를 입력해주세요",
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: defaultBorderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: focusedBorderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ),

        // 버튼 (하단 70px 위)
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: SizedBox(
                width: 361,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6DEDC2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (_selectedGrade != null &&
                        _selectedClass != null &&
                        _numberController.text.isNotEmpty) {
                      _studentNumber = _numberController.text;

                      bool isDuplicate = await _isDuplicateStudent();
                      if (isDuplicate) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("이미 같은 학년/반/번호가 존재합니다."),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _step = 2;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("모든 항목을 입력해주세요.")),
                      );
                    }
                  },
                  child: const Text(
                    "다음",
                    style: TextStyle(
                      color: Color.fromARGB(255, 33, 33, 33),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2단계: 닉네임 입력
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("닉네임 입력", style: TextStyle(fontSize: 18)),
        TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(
            labelText: "닉네임",
            border: OutlineInputBorder(),
          ),
        ),

        // 버튼 (하단 70px 위)
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: SizedBox(
                width: 361,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6DEDC2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (_nicknameController.text.isNotEmpty) {
                      _nickname = _nicknameController.text;
                      await _saveToFirestore();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClassListPage(),
                          ),
                          (route) => false,
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("닉네임을 입력해주세요.")),
                      );
                    }
                  },
                  child: const Text(
                    "완료",
                    style: TextStyle(
                      color: Color.fromARGB(255, 33, 33, 33),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
