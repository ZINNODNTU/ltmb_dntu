import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
class FormBasicDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FormBasicDemoState();
}

class _FormBasicDemoState extends State<FormBasicDemo> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _obscureText = true;
  String? _name;
  String? _email;
  String? _password;
  String? _confirmPassword;
  String? _gender;
  bool _isAgree = false;
  DateTime? _dateOfBirth;

  File? _profileImage;
  final List<String> _cities = [
    "Hà Nội",
    "Hồ Chí Minh",
    "Đà Nẵng",
    "Hải Phòng",
    "Cần Thơ",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form cơ bản")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
          child: Column(
            children: [
              // Image picker tải hình


              FormField<File>(
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn ảnh đại diện';
                  }
                  return null;
                },
                builder: (FormFieldState<File> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ảnh đại diện',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final XFile? image = await showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                title: Text('Chọn nguồn'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.photo_library),
                                      title: Text('Thư viện'),
                                      onTap: () async {
                                        Navigator.pop(
                                          context,
                                          await _picker.pickImage(
                                            source: ImageSource.gallery,
                                          ),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.camera_alt),
                                      title: Text('Máy ảnh'),
                                      onTap: () async {
                                        Navigator.pop(
                                          context,
                                          await _picker.pickImage(
                                            source: ImageSource.camera,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );

                            if (image != null) {
                              setState(() {
                                _profileImage = File(image.path);
                                state.didChange(_profileImage);
                              });
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                color:
                                state.hasError
                                    ? Colors.red
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child:
                            _profileImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.file(
                                _profileImage!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      if (state.hasError)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              state.errorText!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              SizedBox(height: 20),

              TextFormField(
                decoration: InputDecoration(
                  labelText: "Họ và tên",
                  hintText: "Nhập họ và tên của bạn",
                ),
                onSaved: (value) {
                  _name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập họ và tên";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Date picker
              TextFormField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  labelText: "Ngày sinh",
                  hintText: "Chọn ngày sinh của bạn",
                  icon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dateOfBirthController.text =
                        DateFormat("dd/MM/yyyy").format(date);
                    _dateOfBirth = date;
                  }
                },
                onSaved: (value) {
                  _dateOfBirth = DateFormat("dd/MM/yyyy").parse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng chọn ngày sinh";
                  }
                  return null;
                },

              ),

              //
              SizedBox(height: 20),
              // Gender selection radio buttons

              Row(
                children: [
                  Text("Giới tính:"),
                  Radio<String>(
                    value: "Nam",
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                  ),
                  Text("Nam"),
                  Radio<String>(
                    value: "Nữ",
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                  ),
                  Text("Nữ"),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Nhập email của bạn",
                  icon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) {
                  _email = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập email";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Vui lòng nhập email hợp lệ";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  hintText: "Nhập mật khẩu của bạn",
                  icon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                onSaved: (value) {
                  _password = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập mật khẩu";
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Xác nhận mật khẩu",
                  hintText: "Nhập lại mật khẩu của bạn",
                  icon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                onSaved: (value) {
                  _confirmPassword = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập lại mật khẩu";
                  }
                  if (value != _passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Thành phố",
                  hintText: "Chọn thành phố",
                  icon: Icon(Icons.location_city),
                ),
                items: _cities
                    .map((city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                ))
                    .toList(),
                onChanged: (value) {
                  print(value);
                },
                onSaved: (value) {
                  print(value);
                },
                validator: (value) {
                  if (value == null) {
                    return "Vui lòng chọn thành phố";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              //checkbox
              CheckboxListTile(
                title: Text("Đồng ý điều khoản"),
                value: _isAgree,
                onChanged: (value) {
                  setState(() {
                    _isAgree = value!;
                  });
                  print(value);
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),


              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Xin chào $_name")),
                        );
                      }
                    },
                    child: Text("Submit"),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                      setState(() {
                        _name = null;
                        _email = null;
                        _password = null;
                        _confirmPassword = null;
                      });
                    },
                    child: Text("Reset"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );

  }
}