import 'dart:ui' as ui;
import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/widgets/logout_button.dart';

class CreateWorldcupScreen extends StatefulWidget {
  const CreateWorldcupScreen({super.key});

  @override
  State<CreateWorldcupScreen> createState() => _CreateWorldcupScreenState();
}

class _CreateWorldcupScreenState extends State<CreateWorldcupScreen> {
  final TextEditingController _titleCtl = TextEditingController();
  final TextEditingController _descCtl = TextEditingController();

  final List<Map<String, dynamic>> _candidates = [];

  bool _saving = false;
  String? errorMsg;

  double _uploadProgress = 0.0;
  int _uploadedCount = 0;
  int _totalToUpload = 0;

  final ImagePicker _picker = ImagePicker();

  // ⭐ 선택된 카테고리 정보(필수!)
  String? _selectedCategoryId;
  String? _selectedCategoryTitle;
  String? _selectedCategoryEmoji;

  // ===========================================================================
  // 후보 추가
  // ===========================================================================
  void _openAddCandidateDialog() {
    final nameCtl = TextEditingController();
    XFile? pickedFile;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: StatefulBuilder(
            builder: (context, setStateLocal) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "후보 추가",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 후보 이름
                      TextField(
                        controller: nameCtl,
                        decoration: const InputDecoration(labelText: "후보 이름"),
                      ),
                      const SizedBox(height: 12),

                      // 갤러리 버튼
                      OutlinedButton(
                        onPressed: () async {
                          final file = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (file != null) {
                            setStateLocal(() => pickedFile = file);
                          }
                        },
                        child: const Text("갤러리에서 선택"),
                      ),

                      // 미리보기
                      if (pickedFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: kIsWeb
                              ? Image.network(
                                  pickedFile!.path,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(pickedFile!.path),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                        ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("취소"),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              if (nameCtl.text.trim().isEmpty ||
                                  pickedFile == null)
                                return;

                              _candidates.add({
                                "name": nameCtl.text.trim(),
                                "file": pickedFile,
                              });

                              setState(() {});
                              Navigator.pop(context);
                            },
                            child: const Text("추가"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 카테고리 선택 BottomSheet
  // ===========================================================================
  void _openCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "카테고리 선택",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("categories")
                        .orderBy("title")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final doc = docs[i];
                          final data = doc.data() as Map<String, dynamic>;
                          final title = data["title"];
                          final emoji = data["emoji"] ?? "✨";

                          return ListTile(
                            leading: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(title),
                            selected: doc.id == _selectedCategoryId,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = doc.id; // 필수 저장
                                _selectedCategoryTitle = title; // UI 표시용
                                _selectedCategoryEmoji = emoji; // UI 표시용
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("새 카테고리 만들기"),
                  onTap: () {
                    Navigator.pop(context);
                    _openCreateCategoryDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 카테고리 생성 Dialog
  // ===========================================================================
  void _openCreateCategoryDialog() {
    final titleCtl = TextEditingController();
    final emojiCtl = TextEditingController();
    XFile? pickedImage; // 갤러리 이미지 저장용

    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("새 카테고리 생성"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 카테고리 이름
                    TextField(
                      controller: titleCtl,
                      decoration: const InputDecoration(labelText: "카테고리 이름"),
                    ),
                    const SizedBox(height: 8),

                    // 이모지 입력
                    TextField(
                      controller: emojiCtl,
                      decoration: const InputDecoration(
                        labelText: "이모지 (예: 💘)",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 갤러리 이미지 선택 버튼
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text("배경 이미지 선택 (선택)"),
                      onPressed: () async {
                        final file = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file != null) {
                          setDialogState(() => pickedImage = file);
                        }
                      },
                    ),

                    // 선택된 이미지 미리보기
                    if (pickedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Image.file(
                          File(pickedImage!.path),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),

                // 생성 버튼
                FilledButton(
                  onPressed: () async {
                    final title = titleCtl.text.trim();
                    if (title.isEmpty) return;

                    final emoji = emojiCtl.text.trim().isEmpty
                        ? "✨"
                        : emojiCtl.text.trim();

                    String imageUrl =
                        "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=80";

                    // 갤러리 사진 선택했으면 Storage 업로드
                    if (pickedImage != null) {
                      final bytes = await pickedImage!.readAsBytes();
                      final fileName =
                          "categories/${DateTime.now().millisecondsSinceEpoch}.jpg";

                      final ref = FirebaseStorage.instance.ref().child(
                        fileName,
                      );

                      await ref.putData(bytes);
                      imageUrl = await ref.getDownloadURL();
                    }

                    // Firestore 저장
                    final doc = await FirebaseFirestore.instance
                        .collection("categories")
                        .add({
                          "title": title,
                          "emoji": emoji,
                          "imageUrl": imageUrl, // 갤러리 이미지 적용됨
                          "createdAt": Timestamp.now(),
                        });

                    // UI 상태 업데이트
                    setState(() {
                      _selectedCategoryId = doc.id;
                      _selectedCategoryTitle = title;
                      _selectedCategoryEmoji = emoji;
                    });

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text("생성"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // (필요하다면)웹 압축 함수 
  // ===========================================================================
  Future<Uint8List> _compressImage(XFile xfile) async {
    if (kIsWeb) {
      return await xfile.readAsBytes();
    }

    final result = await FlutterImageCompress.compressWithFile(
      xfile.path,
      minWidth: 600,
      minHeight: 600,
      quality: 70,
    );

    return result ?? await File(xfile.path).readAsBytes();
  }

  // ===========================================================================
  // Firebase 저장
  // ===========================================================================
  Future<void> _saveWorldcup() async {
    if (_titleCtl.text.trim().isEmpty) {
      setState(() => errorMsg = "제목을 입력하세요.");
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => errorMsg = "카테고리를 선택하세요.");
      return;
    }
    if (_candidates.length < 2) {
      setState(() => errorMsg = "후보는 최소 2명 이상이어야 합니다.");
      return;
    }

    setState(() {
      _saving = true;
      errorMsg = null;
      _uploadedCount = 0;
      _totalToUpload = _candidates.length;
    });

    // Firestore 월드컵 문서 생성
    final wcRef = await FirebaseFirestore.instance.collection("worldcups").add({
      "title": _titleCtl.text.trim(),
      "description": _descCtl.text.trim(),
      "createdAt": Timestamp.now(),

      "categoryId": _selectedCategoryId, 
      "categoryTitle": _selectedCategoryTitle,
      "categoryEmoji": _selectedCategoryEmoji,

      "owner": "local_user",
      "source": "user_created",
    });

    final wcId = wcRef.id;

    // 병렬 업로드
    final futures = <Future>[];

    for (final c in _candidates) {
      futures.add(_uploadSingleCandidate(wcRef, wcId, c));
    }

    await Future.wait(futures);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${_titleCtl.text.trim()} 생성이 완료되었습니다.")),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushNamedAndRemoveUntil(context, "/topics", (route) => false);
    });

    setState(() => _saving = false);
  }

  // 후보 1개 업로드
  Future<void> _uploadSingleCandidate(
    DocumentReference wcRef,
    String wcId,
    Map<String, dynamic> c,
  ) async {
    final XFile xfile = c["file"];

    Uint8List data = await _compressImage(xfile);

    final candId = wcRef.collection("candidates").doc().id;

    final storagePath = "worldcups/$wcId/candidates/$candId.jpg";

    final storageRef = FirebaseStorage.instance.ref().child(storagePath);

    await storageRef.putData(data);

    final url = await storageRef.getDownloadURL();

    await wcRef.collection("candidates").doc(candId).set({
      "name": c["name"],
      "imageUrl": url,
      "imagePath": storagePath,
      "createdAt": Timestamp.now(),
    });

    _uploadedCount++;
    setState(() {
      _uploadProgress = _uploadedCount / _totalToUpload;
    });
  }

  // ===========================================================================
  // UI
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드 대응
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text("월드컵 생성"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

       body: GradientBackground(
        child: Stack(
          children: [
            // 상단 고정 UI
            const LogoutButton(),
            const DarkModeToggle(),

            // 스크롤되는 메인 UI
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 70, // ← 상단의 로그아웃 + 다크모드 버튼 높이 만큼 여백
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    bottom: 200, // 키보드/버튼 영역 확보
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // -----------------------------
                      // 입력 영역 (제목 / 설명 / 카테고리)
                      // -----------------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildCard(
                              child: TextField(
                                controller: _titleCtl,
                                decoration: const InputDecoration(
                                  labelText: "월드컵 제목",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            _buildCard(
                              child: TextField(
                                controller: _descCtl,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: "설명 (선택)",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            _buildCard(
                              child: ListTile(
                                title: const Text("카테고리"),
                                subtitle: Text(
                                  _selectedCategoryTitle ?? "카테고리를 선택하세요",
                                  style: TextStyle(
                                    color: _selectedCategoryTitle == null
                                        ? Colors.grey
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_drop_down),
                                onTap: _openCategoryPicker,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // -----------------------------
                      // 후보 목록 UI
                      // -----------------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _candidates.isEmpty
                            ? _emptyCandidatesView()
                            : Column(
                                children: _candidates
                                    .map(_buildCandidateItem)
                                    .toList(),
                              ),
                      ),

                      const SizedBox(height: 24),

                      // -----------------------------
                      // 저장 버튼 + 업로드 박스 + 에러 메시지
                      // -----------------------------
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        child: Column(
                          children: [
                            if (_saving) _buildUploadingBox(),

                            FilledButton(
                              onPressed: _saving ? null : _saveWorldcup,
                              child: _saving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : const Text("월드컵 저장"),
                            ),

                            if (errorMsg != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  errorMsg!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 상단 고정 UI
            const LogoutButton(),
            const DarkModeToggle(),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddCandidateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ===================================================================
  // 보조 UI 함수
  // ===================================================================
  Widget _emptyCandidatesView() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_search, size: 90, color: Colors.black26),
        SizedBox(height: 16),
        Text(
          "아직 후보가 없습니다.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text("오른쪽 아래 + 버튼으로 후보를 추가하세요!", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  // 후보 1개 아이템
  Widget _buildCandidateItem(Map<String, dynamic> c) {
    final XFile xfile = c["file"];

    final thumb = kIsWeb
        ? Image.network(xfile.path, width: 56, height: 56, fit: BoxFit.cover)
        : Image.file(
            File(xfile.path),
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          );

    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => _openEditCandidateDialog(c), // ← 카드 터치 = 수정
        child: ListTile(
          leading: thumb,
          title: Text(c["name"]),

          // 삭제 버튼
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                _candidates.remove(c);
              });
            },
          ),
        ),
      ),
    );
  }

  // 후보 수정 Dialog
  void _openEditCandidateDialog(Map<String, dynamic> c) {
    final nameCtl = TextEditingController(text: c["name"]);
    XFile? pickedFile = c["file"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            return AlertDialog(
              title: const Text(
                "후보 수정",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              // 스크롤 안정 + 키보드 대응
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtl,
                      decoration: const InputDecoration(labelText: "후보 이름"),
                    ),

                    const SizedBox(height: 12),

                    OutlinedButton(
                      onPressed: () async {
                        final file = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file != null) {
                          setStateLocal(() => pickedFile = file);
                        }
                      },
                      child: const Text("갤러리에서 선택"),
                    ),

                    if (pickedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: kIsWeb
                            ? Image.network(
                                pickedFile!.path,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(pickedFile!.path),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameCtl.text.trim().isEmpty || pickedFile == null)
                      return;

                    setState(() {
                      c["name"] = nameCtl.text.trim();
                      c["file"] = pickedFile;
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("저장"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUploadingBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("이미지 업로드 중... ($_uploadedCount / $_totalToUpload)"),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: _uploadProgress),
        ],
      ),
    );
  }
}
