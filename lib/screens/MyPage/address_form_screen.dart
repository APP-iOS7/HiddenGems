import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auctioned_work.dart';
import 'package:kpostal/kpostal.dart';
import 'package:flutter/services.dart'; // 전화번호 입력 제한을 위해 추가

class AddressFormScreen extends StatefulWidget {
  final AuctionedWork auctionedWork;

  const AddressFormScreen({super.key, required this.auctionedWork});

  @override
  AddressFormScreenState createState() => AddressFormScreenState();
}

class AddressFormScreenState extends State<AddressFormScreen> {
  String postCode = '';
  String address = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController detailAddressController = TextEditingController();
  final TextEditingController requestController = TextEditingController();
  String selectedRequest = '직접 입력';

  final List<String> requestOptions = [
    '직접 입력',
    '부재시 경비실에 맡겨주세요',
    '문 앞에 놓아주세요',
    '배송 전 연락 부탁드립니다',
    '택배함에 놓아주세요',
  ];

  @override
  void initState() {
    super.initState();

    // 기존 저장된 배송 정보 불러오기
    final auctionedWork = widget.auctionedWork;

    if (auctionedWork.name!.isNotEmpty) {
      nameController.text = auctionedWork.name!;
    }
    if (auctionedWork.phone!.isNotEmpty) {
      phoneController.text = auctionedWork.phone!;
    }
    if (auctionedWork.address!.isNotEmpty) {
      postCode = auctionedWork.address!;
    }
    if (auctionedWork.deliverRequest.isNotEmpty) {
      if (requestOptions.contains(auctionedWork.deliverRequest)) {
        selectedRequest = auctionedWork.deliverRequest;
      } else {
        selectedRequest = '직접 입력';
        requestController.text = auctionedWork.deliverRequest;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('배송지 입력'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 받는 사람 정보
              _buildRecipientSection(),
              const SizedBox(height: 16),
              // 배송지 정보
              _buildAddressSection(),
              const SizedBox(height: 16),
              // 배송 요청사항
              _buildDeliveryRequestSection(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (_validateInputs()) {
                    _saveAddress();
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('저장하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '받는 사람 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '이름',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: const InputDecoration(
            labelText: '연락처',
            hintText: '숫자만 입력해주세요',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '배송지 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow('우편번호', postCode.isEmpty ? '검색해주세요' : postCode),
        const SizedBox(height: 8),
        _buildInfoRow('주소', address.isEmpty ? '검색해주세요' : address),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KpostalView(
                  callback: (Kpostal result) {
                    setState(() {
                      postCode = result.postCode;
                      address = result.address;
                    });
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.search),
          label: const Text('주소 검색하기'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: detailAddressController,
          decoration: const InputDecoration(
            labelText: '상세주소',
            hintText: '상세주소를 입력해주세요',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.home),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryRequestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '배송 요청사항',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField(
          value: selectedRequest,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.delivery_dining),
          ),
          items: requestOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedRequest = newValue!;
              if (newValue != '직접 입력') {
                requestController.text = newValue;
              } else {
                requestController.clear();
              }
            });
          },
        ),
        const SizedBox(height: 12),
        if (selectedRequest == '직접 입력')
          TextField(
            controller: requestController,
            decoration: const InputDecoration(
              labelText: '요청사항 직접 입력',
              hintText: '배송 시 요청사항을 입력해주세요',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
            ),
            maxLines: 2,
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                color: value.contains('검색해주세요') ? Colors.grey : Colors.black),
          ),
        ),
      ],
    );
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty) {
      _showErrorDialog('이름을 입력해주세요.');
      return false;
    }
    if (phoneController.text.isEmpty) {
      _showErrorDialog('연락처를 입력해주세요.');
      return false;
    }
    if (address.isEmpty) {
      _showErrorDialog('주소를 검색해주세요.');
      return false;
    }
    if (detailAddressController.text.isEmpty) {
      _showErrorDialog('상세주소를 입력해주세요.');
      return false;
    }
    return true;
  }

  void _saveAddress() {
    final fullAddress = '$address ${detailAddressController.text}';
    final requestText =
        selectedRequest == '직접 입력' ? requestController.text : selectedRequest;

    debugPrint('저장된 정보:');
    debugPrint('이름: ${nameController.text}');
    debugPrint('연락처: ${phoneController.text}');
    debugPrint('주소: $fullAddress');
    debugPrint('요청사항: $requestText');

    // TODO: 실제 저장 로직 구현
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    detailAddressController.dispose();
    requestController.dispose();
    super.dispose();
  }
}
