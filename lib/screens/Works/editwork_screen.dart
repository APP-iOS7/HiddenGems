
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';

class EditWorkScreen extends StatefulWidget {
  final Work work;

  const EditWorkScreen({super.key, required this.work});

  @override
  _EditWorkScreenState createState() => _EditWorkScreenState();
}

class _EditWorkScreenState extends State<EditWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _minPriceController;
  late TextEditingController _imageUrlController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.work.title);
    _descriptionController =
        TextEditingController(text: widget.work.description);
    _minPriceController =
        TextEditingController(text: widget.work.minPrice.toString());
    _imageUrlController =
        TextEditingController(text: widget.work.workPhotoURL);
    _imageUrl = widget.work.workPhotoURL;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minPriceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageUrl = null; // 로컬 이미지를 선택하면 URL 초기화
        _imageUrlController.clear();
      });
    }
  }

  void _updateWork(WorkProvider workProvider) async {
    if (!_formKey.currentState!.validate()) return;

    String updatedTitle = _titleController.text;
    String updatedDescription = _descriptionController.text;
    double updatedMinPrice =
        double.tryParse(_minPriceController.text) ?? widget.work.minPrice;

    String finalImageUrl = _imageUrl ?? widget.work.workPhotoURL;

    Work updatedWork = widget.work.copyWith(
      title: updatedTitle,
      description: updatedDescription,
      minPrice: updatedMinPrice,
      workPhotoURL: finalImageUrl,
    );

    await workProvider.updateWork(updatedWork);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("작품 수정 완료")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context, listen: false);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("작품 수정"),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "작품 제목",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "작품 사진",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _imageUrl!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    "유효하지 않은 URL입니다.",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );
                              },
                            ),
                          )
                        : _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        size: 50, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      "이미지를 선택하세요",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                  SizedBox(height: 10),

                  // 갤러리에서 이미지 선택 버튼
                  GestureDetector(
                    onTap: () {
                      _pickImage;
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      //margin: EdgeInsets.only(bottom: 50, left: 16, right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      alignment: Alignment.center,
                      child: Text(
                        "갤러리에서 이미지 선택",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // 이미지 URL 입력 필드
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      labelText: "이미지 URL 입력",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _imageUrl = value.isNotEmpty ? value : null;
                        _selectedImage = null; // URL을 입력하면 로컬 이미지 초기화
                      });
                    },
                  ),

                  SizedBox(height: 12),
                  Text(
                    "작품 설명",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "경매 시작 금액 (₩)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _minPriceController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            _updateWork(workProvider);
          },
          child: Container(
            width: double.infinity,
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 12),
            margin: EdgeInsets.only(bottom: 50, left: 16, right: 16),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              "저장하기",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ));
  }
}
