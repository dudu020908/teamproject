import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:crypto/crypto.dart'; // md5 해시

import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CreateWorldcupScreen extends StatefulWidget {
  const CreateWorldcupScreen({super.key});

  @override
  State<CreateWorldcupScreen> createState() => _CreateWorldcupScreenState();
}

class _CreateWorldcupScreenState extends State<CreateWorldcupScreen> {
  // 제목은 필수 입력이 아니지만, 월드컵 title 용으로 남겨둠 (안 쓰면 카테고리 이름 사용)
  final TextEditingController _titleCtl = TextEditingController();
  final TextEditingController _descCtl = TextEditingController();

  // 선택된 카테고리의 "후보 목록"
  // categories/{categoryId}/candidates 의 데이터를 여기로 가져옴
  final List<Map<String, dynamic>> _candidates = [];
  final Set<String> _deletedCandidateIds = <String>{};
  final Set<String> _deletedImagePaths = <String>{};

  // 후보 타입 목록
  final List<String> _allTypes = [
    "감성형",
    "이성형",
    "현실형",
    "이상형",
    "개성형",
    "트렌디형",
    "안정형",
    "자극형",
  ];

  bool _saving = false;
  String? errorMsg;

  String? _selectedCategoryImageUrl;
  double _uploadProgress = 0.0;
  int _uploadedCount = 0;
  int _totalToUpload = 0;

  final ImagePicker _picker = ImagePicker();

  // 선택된 카테고리 정보
  String? _selectedCategoryId;
  String? _selectedCategoryTitle;
  String? _selectedCategoryEmoji;

  // 이미지 압축 (카테고리 후보 추가 시 사용)
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

  // 카테고리 선택 BottomSheet
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
                          final imageUrl = data["imageUrl"];

                          return ListTile(
                            leading: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(title),
                            selected: doc.id == _selectedCategoryId,
                            onTap: () async {
                              // 카테고리 선택
                              setState(() {
                                _selectedCategoryId = doc.id;
                                _selectedCategoryTitle = title;
                                _selectedCategoryEmoji = emoji;
                                _selectedCategoryImageUrl = imageUrl;
                                _candidates.clear();
                              });

                              Navigator.pop(context);

                              // 선택한 카테고리의 후보 로딩
                              await _loadCategoryCandidates(doc.id);
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  tooltip: '카테고리 편집',
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _openEditCategoryDialog(
                                      categoryId: doc.id,
                                      currentTitle: title,
                                      currentEmoji: emoji,
                                      currentImageUrl: imageUrl,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  tooltip: '카테고리 삭제',
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteCategory(doc.id);
                                  },
                                ),
                              ],
                            ),
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

  void _openEditCategoryDialog({
    required String categoryId,
    required String currentTitle,
    required String currentEmoji,
    required String currentImageUrl,
  }) {
    final titleCtl = TextEditingController(text: currentTitle);
    final emojiCtl = TextEditingController(text: currentEmoji);
    XFile? pickedImage;
    String previewUrl = currentImageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("카테고리 수정"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtl,
                      decoration: const InputDecoration(labelText: "카테고리 이름"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emojiCtl,
                      decoration: const InputDecoration(labelText: "이모지 (선택)"),
                    ),
                    const SizedBox(height: 16),
                    if (previewUrl.isNotEmpty || pickedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: pickedImage != null
                            ? (kIsWeb
                                  ? Image.network(
                                      pickedImage!.path,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(pickedImage!.path),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ))
                            : Image.network(
                                previewUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text("이미지 변경"),
                      onPressed: () async {
                        final file = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file != null) {
                          setDialogState(() {
                            pickedImage = file;
                            // 새 이미지 선택하면 기존 URL 미리보기는 안 씀
                            previewUrl = "";
                          });
                        }
                      },
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
                  onPressed: () async {
                    final newTitle = titleCtl.text.trim();
                    if (newTitle.isEmpty) return;

                    final newEmoji = emojiCtl.text.trim().isEmpty
                        ? (currentEmoji.isEmpty ? "✨" : currentEmoji)
                        : emojiCtl.text.trim();

                    String imageUrl = currentImageUrl;

                    if (pickedImage != null) {
                      final bytes = await _compressImage(pickedImage!);
                      final fileName =
                          "categories/${DateTime.now().millisecondsSinceEpoch}.jpg";
                      final ref = FirebaseStorage.instance.ref().child(
                        fileName,
                      );
                      await ref.putData(bytes);
                      imageUrl = await ref.getDownloadURL();
                    }

                    await FirebaseFirestore.instance
                        .collection("categories")
                        .doc(categoryId)
                        .update({
                          "title": newTitle,
                          "emoji": newEmoji,
                          "imageUrl": imageUrl,
                        });

                    // 지금 선택된 카테고리를 수정했다면 로컬 상태도 업데이트
                    if (mounted && _selectedCategoryId == categoryId) {
                      setState(() {
                        _selectedCategoryTitle = newTitle;
                        _selectedCategoryEmoji = newEmoji;
                        _selectedCategoryImageUrl = imageUrl;
                      });
                    }

                    if (context.mounted) Navigator.pop(context);
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

  Future<void> _deleteCategory(String categoryId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("카테고리 삭제"),
          content: const Text("카테고리와 그 안의 후보들이 모두 삭제됩니다. 계속할까요?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("삭제", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    // 후보들 먼저 삭제
    final candSnap = await FirebaseFirestore.instance
        .collection("categories")
        .doc(categoryId)
        .collection("candidates")
        .get();

    for (final doc in candSnap.docs) {
      await doc.reference.delete();
    }

    // 카테고리 삭제
    await FirebaseFirestore.instance
        .collection("categories")
        .doc(categoryId)
        .delete();

    if (!mounted) return;

    // 방금 삭제한 카테고리가 선택 중이었다면 초기화
    if (_selectedCategoryId == categoryId) {
      setState(() {
        _selectedCategoryId = null;
        _selectedCategoryTitle = null;
        _selectedCategoryEmoji = null;
        _selectedCategoryImageUrl = null;
        _candidates.clear();
      });
    }
  }

  // 선택한 카테고리의 후보 불러오기
  // categories/{categoryId}/candidates
  Future<void> _loadCategoryCandidates(String categoryId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("categories")
          .doc(categoryId)
          .collection("candidates")
          .get();

      final List<Map<String, dynamic>> loaded = [];

      for (final doc in snap.docs) {
        final data = doc.data();
        loaded.add({
          "id": doc.id,
          "name": data["name"] ?? data["title"] ?? "제목 없음",
          "imageUrl": data["imageUrl"] ?? "",
          "types": (data["types"] is List)
              ? List<String>.from(data["types"])
              : <String>[],
          "imageHash": data["imageHash"] ?? "",
          "imagePath": data["imagePath"],
          "localBytes": null, // 새로 선택한 이미지(아직 업로드 X)
          "isNew": false, // Firestore에서 온 기존 후보
        });
      }

      setState(() {
        _candidates
          ..clear()
          ..addAll(loaded);
      });
    } catch (e) {
      debugPrint("카테고리 후보 로딩 에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("카테고리 후보를 불러오는 중 오류가 발생했습니다.")),
      );
    }
  }

  // 카테고리 생성 Dialog
  void _openCreateCategoryDialog() {
    final titleCtl = TextEditingController();
    final emojiCtl = TextEditingController();
    XFile? pickedImage;
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
                    TextField(
                      controller: titleCtl,
                      decoration: const InputDecoration(labelText: "카테고리 이름"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emojiCtl,
                      decoration: const InputDecoration(
                        labelText: "이모지 (예: 💘)",
                      ),
                    ),
                    const SizedBox(height: 16),
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
                FilledButton(
                  onPressed: () async {
                    final title = titleCtl.text.trim();
                    if (title.isEmpty) return;

                    final emoji = emojiCtl.text.trim().isEmpty
                        ? "✨"
                        : emojiCtl.text.trim();

                    String imageUrl =
                        "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=80";

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

                    final doc = await FirebaseFirestore.instance
                        .collection("categories")
                        .add({
                          "title": title,
                          "emoji": emoji,
                          "imageUrl": imageUrl,
                          "createdAt": Timestamp.now(),
                        });

                    setState(() {
                      _selectedCategoryId = doc.id;
                      _selectedCategoryTitle = title;
                      _selectedCategoryEmoji = emoji;
                      _selectedCategoryImageUrl = imageUrl;
                      _candidates.clear();
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

  // 카테고리에 후보 추가 (FAB에서 사용)
  void _openAddCandidateDialog() {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("먼저 카테고리를 선택해주세요.")));
      return;
    }

    final nameCtl = TextEditingController();
    XFile? pickedFile;
    final selectedTypes = <String>{};
    String? dialogError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setStateLocal) {
              // 현재 상태 기준으로 에러메시지 다시 계산해주는 함수
              void _updateError() {
                final missingName = nameCtl.text.trim().isEmpty;
                final missingType = selectedTypes.length != 1;
                final missingImage = pickedFile == null;

                String? msg;

                if (missingName && missingType && missingImage) {
                  msg = "후보 이름, 타입, 이미지를 모두 입력/선택해주세요.";
                } else if (missingName && missingType) {
                  msg = "후보 이름과 타입을 입력/선택해주세요.";
                } else if (missingName && missingImage) {
                  msg = "후보 이름과 이미지를 입력/선택해주세요.";
                } else if (missingType && missingImage) {
                  msg = "타입과 이미지를 선택해주세요.";
                } else if (missingName) {
                  msg = "후보 이름을 입력해주세요.";
                } else if (missingType) {
                  msg = "타입을 1개 선택해주세요.";
                } else if (missingImage) {
                  msg = "후보 이미지를 선택해주세요.";
                } else {
                  msg = null; // 모두 OK
                }

                setStateLocal(() {
                  dialogError = msg;
                });
              }

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
                      // 이름 입력
                      TextField(
                        controller: nameCtl,
                        decoration: const InputDecoration(labelText: "후보 이름"),
                        onChanged: (_) {
                          // 입력할 때마다 현재 상태 기준으로 에러 갱신
                          _updateError();
                        },
                      ),
                      const SizedBox(height: 16),
                      // 타입 선택
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "후보 타입 (1개 선택)",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allTypes.map((type) {
                          final selected = selectedTypes.contains(type);
                          return FilterChip(
                            label: Text(type),
                            selected: selected,
                            onSelected: (value) {
                              setStateLocal(() {
                                if (value) {
                                  // ❗ 무조건 1개만 선택
                                  selectedTypes
                                    ..clear()
                                    ..add(type);
                                } else {
                                  selectedTypes.remove(type);
                                }
                                _updateError();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // 이미지 선택
                      OutlinedButton(
                        onPressed: () async {
                          final file = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (file != null) {
                            setStateLocal(() {
                              pickedFile = file;
                            });
                          }
                          _updateError(); // 선택 여부에 따라 에러 갱신
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
                      const SizedBox(height: 12),
                      // 에러 메시지 (Dialog 안에 표시)
                      if (dialogError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            dialogError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // 버튼들
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("취소"),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    // 중복 클릭 방지
                                    setStateLocal(() {
                                      isSubmitting = true;
                                    });

                                    final missingName = nameCtl.text
                                        .trim()
                                        .isEmpty;
                                    final missingType =
                                        selectedTypes.length != 1;
                                    final missingImage = pickedFile == null;

                                    if (missingName ||
                                        missingType ||
                                        missingImage) {
                                      _updateError();
                                      setStateLocal(() => isSubmitting = false);
                                      return;
                                    }

                                    final categoryId = _selectedCategoryId!;
                                    final newName = nameCtl.text.trim();

                                    final Uint8List compressedBytes =
                                        await _compressImage(pickedFile!);
                                    final String newImageHash = md5
                                        .convert(compressedBytes)
                                        .toString();

                                    // 2) 이름 중복 체크 (현재 화면 기준)
                                    final bool nameExists = _candidates.any((
                                      c,
                                    ) {
                                      final existingName =
                                          (c["name"] as String?)?.trim() ?? "";
                                      return existingName == newName;
                                    });

                                    // 3) 이미지 중복 체크 - 현재 화면(_candidates) 기준
                                    final bool imageExistsLocal = _candidates
                                        .any((c) {
                                          final existingHash =
                                              (c["imageHash"] as String?) ?? "";
                                          return existingHash.isNotEmpty &&
                                              existingHash == newImageHash;
                                        });

                                    // 4) 이미지 중복 체크 - Firestore 기준
                                    final dupSnap = await FirebaseFirestore
                                        .instance
                                        .collection("categories")
                                        .doc(categoryId)
                                        .collection("candidates")
                                        .where(
                                          "imageHash",
                                          isEqualTo: newImageHash,
                                        )
                                        .limit(1)
                                        .get();

                                    final bool imageExistsRemote =
                                        dupSnap.docs.isNotEmpty;

                                    if (nameExists ||
                                        imageExistsLocal ||
                                        imageExistsRemote) {
                                      String msg;

                                      if (nameExists &&
                                          (imageExistsLocal ||
                                              imageExistsRemote)) {
                                        msg = "이미 같은 이름과 사진이 있습니다.";
                                      } else if (nameExists) {
                                        msg = "중복된 이름입니다.";
                                      } else {
                                        msg = "중복된 사진입니다.";
                                      }

                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) {
                                            return AlertDialog(
                                              title: const Text("다시 선택해주세용"),
                                              content: Text(msg),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        dialogContext,
                                                      ),
                                                  child: const Text("확인"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      setStateLocal(() => isSubmitting = false);
                                      return;
                                    }
                                    final bytes = await _compressImage(
                                      pickedFile!,
                                    );

                                    setState(() {
                                      _candidates.add({
                                        "id": null, // 새 후보라 아직 없음
                                        "name": newName,
                                        "imageUrl": "", // 아직 업로드 X
                                        "types": selectedTypes.toList(),
                                        "imageHash": newImageHash,
                                        "imagePath": null,
                                        "localBytes": bytes, // 화면에서만 쓰는 이미지
                                        "isNew": true,
                                      });
                                    });

                                    if (context.mounted) Navigator.pop(context);
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

  // 월드컵 저장
  Future<void> _saveWorldcup() async {
    // 카테고리 선택 여부 확인
    if (_selectedCategoryId == null) {
      setState(() => errorMsg = "카테고리를 선택하세요.");
      return;
    }

    setState(() {
      _saving = true;
      errorMsg = null;
      _uploadedCount = 0;
      _totalToUpload = _candidates.length;
    });

    try {
      //후보 목록 Firestore에 항상 동기화 (추가/수정/삭제)
      await _commitCandidatesToFirestore(_selectedCategoryId!);

      if (_candidates.length < 8) {
        setState(() {
          _saving = false;
          errorMsg = "후보를 8명 이상 추가해야 월드컵을 생성할 수 있습니다.";
        });
        return;
      }

      // worldcups 컬렉션에 월드컵 문서 생성
      final worldcupTitle = _titleCtl.text.trim();

      final wcRef = await FirebaseFirestore.instance
          .collection("worldcups")
          .add({
            "title": worldcupTitle.isEmpty
                ? (_selectedCategoryTitle ?? "월드컵")
                : worldcupTitle,
            "description": _descCtl.text.trim(),
            "createdAt": Timestamp.now(),
            "categoryId": _selectedCategoryId,
            "categoryTitle": _selectedCategoryTitle,
            "categoryEmoji": _selectedCategoryEmoji,
            "imageUrl": _selectedCategoryImageUrl,
            "owner": "local_user",
            "source": "user_created",
          });

      final worldcupId = wcRef.id;

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_selectedCategoryTitle ?? '월드컵'} 생성이 완료되었습니다."),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        '/topics',
        arguments: {
          'categoryId': _selectedCategoryId,
          'title': _selectedCategoryTitle ?? "월드컵",
          'emoji': _selectedCategoryEmoji ?? "🏆",
          'worldcupId': worldcupId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        errorMsg = "월드컵 저장 중 오류가 발생했습니다: $e";
      });
    }
  }

  Future<void> _commitCandidatesToFirestore(String categoryId) async {
    final collRef = FirebaseFirestore.instance
        .collection("categories")
        .doc(categoryId)
        .collection("candidates");

    //Storage에서 삭제 예정 파일들 지우기
    for (final path in _deletedImagePaths) {
      try {
        debugPrint("⚡ Storage 파일 삭제: $path");
        await FirebaseStorage.instance.ref().child(path).delete();
      } on FirebaseException catch (e) {
        debugPrint("❌ Storage delete 실패 ($path): ${e.code} / ${e.message}");
      } catch (e) {
        debugPrint("❌ Storage delete 알 수 없는 오류 ($path): $e");
      }
    }
    _deletedImagePaths.clear();

    // 현재 Firestore에 있는 후보들 전체 읽어오기
    final snap = await collRef.get();
    final existingDocs = {for (final doc in snap.docs) doc.id: doc.data()};

    final batch = FirebaseFirestore.instance.batch();
    final currentIds = <String>{}; // 화면(_candidates)에 남아있는 후보들의 id 모음

    //화면 기준으로 추가
    for (final c in _candidates) {
      final String? id = c["id"] as String?;
      final String name = c["name"] as String? ?? "";
      final List<String> types =
          (c["types"] as List?)?.cast<String>() ?? <String>[];
      final Uint8List? localBytes = c["localBytes"] as Uint8List?;
      String? imageUrl = c["imageUrl"] as String?;
      String? imagePath = c["imagePath"] as String?;
      String? imageHash = c["imageHash"] as String?;

      if (id == null) {
        // 새 후보 (아직 Firestore에 없는 애)
        if (localBytes == null) continue;

        final docRef = collRef.doc();
        final storagePath =
            "categories/$categoryId/candidates/${docRef.id}.jpg";
        final storageRef = FirebaseStorage.instance.ref().child(storagePath);
        await storageRef.putData(localBytes);
        final url = await storageRef.getDownloadURL();

        imageHash ??= md5.convert(localBytes).toString();

        batch.set(docRef, {
          "name": name,
          "types": types,
          "imageUrl": url,
          "imagePath": storagePath,
          "imageHash": imageHash,
          "createdAt": Timestamp.now(),
        });
      } else {
        currentIds.add(id);

        final docRef = collRef.doc(id);
        final Map<String, dynamic> updateData = {"name": name, "types": types};

        if (localBytes != null) {
          // 이미지가 수정된 경우
          final storagePath =
              imagePath ?? "categories/$categoryId/candidates/$id.jpg";
          final storageRef = FirebaseStorage.instance.ref().child(storagePath);
          await storageRef.putData(localBytes);
          final url = await storageRef.getDownloadURL();

          final newHash = md5.convert(localBytes).toString();

          updateData["imageUrl"] = url;
          updateData["imagePath"] = storagePath;
          updateData["imageHash"] = newHash;
        }

        if (existingDocs.containsKey(id)) {
          // Firestore에 이미 있던 문서 → update
          batch.update(docRef, updateData);
        } else {
          // Firestore엔 없는데 로컬에만 id 있는 이상 상태 → set으로 생성
          batch.set(docRef, {
            ...updateData,
            "imageUrl": imageUrl,
            "imagePath": imagePath,
            "createdAt": Timestamp.now(),
          });
        }
      }
    }

    // Firestore에는 있는데 화면에는 없는 후보들 → 삭제
    for (final entry in existingDocs.entries) {
      final docId = entry.key;
      if (!currentIds.contains(docId)) {
        debugPrint("🧹 화면에 없는 후보 Firestore 삭제: $docId");
        final docRef = collRef.doc(docId);
        batch.delete(docRef);
      }
    }

    // 삭제 예정 id들 한 번 더 강제 삭제
    for (final id in _deletedCandidateIds) {
      if (!currentIds.contains(id)) {
        debugPrint("배치에서 강제 삭제: $id");
        batch.delete(collRef.doc(id));
      }
    }

    try {
      await batch.commit();
      debugPrint("🔥 Firestore batch commit 성공");
    } on FirebaseException catch (e) {
      debugPrint("❌ Firestore batch commit 실패: ${e.code} / ${e.message}");
    } catch (e) {
      debugPrint("❌ Firestore batch commit 알 수 없는 오류: $e");
    }

    _deletedCandidateIds.clear();
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '이전 화면으로 돌아가기',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("월드컵 생성"),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: DarkModeToggle()),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 카테고리 카드
                _buildCard(
                  child: ListTile(
                    title: const Text("카테고리"),
                    subtitle: Text(
                      _selectedCategoryTitle ?? "카테고리를 선택하세요",
                      style: TextStyle(
                        color: _selectedCategoryTitle == null
                            ? Colors.grey
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: _openCategoryPicker,
                  ),
                ),
                const SizedBox(height: 16),
                // 가운데 영역: 후보 없을 때는 빈 상태, 있을 때는 리스트 (스크롤)
                Expanded(
                  child: _candidates.isEmpty
                      ? Center(child: _emptyCandidatesView())
                      : ListView(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "후보 목록 (${_candidates.length}명)",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._candidates.map(_buildCandidateItem).toList(),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                // 업로드 박스 + 저장 버튼 + 에러 메시지 (하단 고정 느낌)
                if (_saving) _buildUploadingBox(),
                // 월드컵 저장 + 후보 추가 버튼 한 줄로
                Row(
                  children: [
                    // 왼쪽: 월드컵 저장(가득 채우는 버튼)
                    Expanded(
                      child: FilledButton(
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
                    ),
                    const SizedBox(width: 12),
                    // 오른쪽: 후보 추가 + 버튼 (동그란 카드 느낌)
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Material(
                        color: isDark ? Colors.black : Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _saving ? null : _openAddCandidateDialog,
                          child: const Icon(Icons.add, size: 28),
                        ),
                      ),
                    ),
                  ],
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
        ),
      ),
    );
  }

  // 보조 UI 위젯들
  Widget _emptyCandidatesView() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_search, size: 90, color: Colors.black26),
        SizedBox(height: 16),
        Text(
          "선택된 카테고리의 후보가 없습니다.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text(
          "카테고리에 후보를 8명 이상 추가한 뒤 다시 시도해주세요.",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
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

  Widget _buildCandidateItem(Map<String, dynamic> c) {
    final String name = c["name"] ?? "제목 없음";
    final List<String> types = (c["types"] as List?)?.cast<String>() ?? [];

    final String imageUrl = c["imageUrl"] ?? "";
    final Uint8List? localBytes = c["localBytes"] as Uint8List?;

    Widget leading;

    if (localBytes != null) {
      // 아직 업로드 안 된 새/수정 이미지 (메모리에만 있음)
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          localBytes,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    } else if (imageUrl.isNotEmpty) {
      // 기존 DB 이미지
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(width: 56, height: 56, color: Colors.grey[300]),
          errorWidget: (context, url, error) => Container(
            width: 56,
            height: 56,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 24),
          ),
        ),
      );
    } else {
      // 이미지 정보가 전혀 없을 때
      leading = Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.person, size: 28),
      );
    }

    return Card(
      elevation: 2,
      child: ListTile(
        leading: leading,
        title: Text(name),
        subtitle: types.isNotEmpty ? Text(types.join(", ")) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              tooltip: '후보 수정',
              onPressed: () => _openEditCandidateDialog(c),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              tooltip: '후보 삭제',
              onPressed: () => _deleteCandidate(c),
            ),
          ],
        ),
      ),
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
          Text("월드컵 생성 중... ($_uploadedCount / $_totalToUpload)"),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: _uploadProgress),
        ],
      ),
    );
  }

  // 후보 수정 / 삭제 다이얼로그
  void _openEditCandidateDialog(Map<String, dynamic> candidate) {
    if (_selectedCategoryId == null) {
      return;
    }

    final nameCtl = TextEditingController(text: candidate["name"] ?? "");
    XFile? pickedFile;
    String currentImageUrl = candidate["imageUrl"] ?? "";
    final selectedTypes = <String>{
      ...((candidate["types"] as List?)?.cast<String>() ?? []),
    };

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
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
                        "후보 수정",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameCtl,
                        decoration: const InputDecoration(labelText: "이름"),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "타입 선택",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allTypes.map((type) {
                          final selected = selectedTypes.contains(type);
                          return FilterChip(
                            label: Text(type),
                            selected: selected,
                            onSelected: (value) {
                              setStateLocal(() {
                                if (value) {
                                  // 타입 1개만 허용
                                  selectedTypes
                                    ..clear()
                                    ..add(type);
                                } else {
                                  selectedTypes.remove(type);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () async {
                          final file = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (file != null) {
                            setStateLocal(() {
                              pickedFile = file;
                              currentImageUrl = "";
                            });
                          }
                        },
                        child: const Text("이미지 변경"),
                      ),
                      if (pickedFile != null || currentImageUrl.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: pickedFile != null
                              ? (kIsWeb
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
                                      ))
                              : CachedNetworkImage(
                                  imageUrl: currentImageUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300],
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      ),
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
                          FilledButton(
                            onPressed: () async {
                              if (nameCtl.text.trim().isEmpty) return;
                              if (selectedTypes.length != 1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("타입은 1개만 선택해주세요."),
                                  ),
                                );
                                return;
                              }

                              Uint8List? newBytes;
                              if (pickedFile != null) {
                                newBytes = await _compressImage(pickedFile!);
                              }

                              setState(() {
                                candidate["name"] = nameCtl.text.trim();
                                candidate["types"] = selectedTypes.toList();

                                if (newBytes != null) {
                                  final newHash = md5
                                      .convert(newBytes)
                                      .toString();
                                  candidate["localBytes"] = newBytes; // 새 이미지
                                  candidate["imageUrl"] = ""; // 로컬 이미지 우선
                                  candidate["imageHash"] = newHash;
                                }
                                candidate["isNew"] = candidate["id"] == null;
                                // 기존 후보라도 수정됐다는걸 표시하고 싶으면 flag를 하나 더 넣어도 됨 (e.g. "isUpdated": true)
                              });

                              if (context.mounted) Navigator.pop(context);
                            },
                            child: const Text("저장"),
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

  Future<void> _deleteCandidate(Map<String, dynamic> candidate) async {
    final name = candidate["name"] ?? "이 후보";

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("후보 삭제"),
          content: Text("'$name' 후보를 삭제할까요?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("삭제", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final String? id = candidate["id"] as String?;
    final String? imagePath = candidate["imagePath"] as String?;

    if (id != null && id.isNotEmpty) {
      _deletedCandidateIds.add(id);
      debugPrint("삭제 예정 후보 id 추가: $id");
    }
    // Storage 파일 경로 삭제 목록에 추가
    if (imagePath != null && imagePath.isNotEmpty) {
      _deletedImagePaths.add(imagePath);
      debugPrint("삭제 예정 이미지 path 추가: $imagePath");
    }

    setState(() {
      _candidates.remove(candidate);
    });
  }
}
