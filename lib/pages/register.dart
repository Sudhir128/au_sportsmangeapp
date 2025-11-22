
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/pages/Register.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient supabase = SupabaseClient(
  'https://aiadfhpajrtlxjiypkuk.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpYWRmaHBhanJ0bHhqaXlwa3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTkwMTQ2NjcsImV4cCI6MjAxNDU5MDY2N30.7XfE2XuXcueNRp8nbgXN52z3CYvpe7PeVXf4pB_V8t8',
);

class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _signUpLoading = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late TextEditingController _rollnoController;
  late TextEditingController _mobilenumberController;
  GlobalKey<FormState> _formkey = GlobalKey();
  String selectChoice = 'Public';
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _rollnoController = TextEditingController();
    _mobilenumberController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _rollnoController.dispose();
    _mobilenumberController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final isValid = _formkey.currentState?.validate();
    if (isValid != true) {
      return;
    }
    setState(() {
      _signUpLoading = true;
    });
    try {
      final response = await supabase.from('user').upsert([
        {
          'name': _nameController.text,
          'email': _emailController.text,
          'rollnumber': _rollnoController.text,
          'password': _passwordController.text,
          'mobilenumber': _mobilenumberController.text,
        }
      ]);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sucessfully signUp'),
        backgroundColor: Colors.blueAccent,
      ));
      _navigateToLoginPage();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('signUp Failed'),
        backgroundColor: Colors.redAccent,
      ));
    }
    setState(() {
      _signUpLoading = false;
    });
  }

  void _navigateToLoginPage() {
    Future.delayed(Duration(seconds: 1));
    (Navigator.of(context).pop(
      MaterialPageRoute(
        builder: (_) => Login(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 450,
        height: 900,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/images/student.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Form(
          key: _formkey,
          child: Scaffold(
            backgroundColor: Color(0xFF03498B).withOpacity(0.20),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.only(left: 50, right: 260, top: 130),
                        child: Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 32,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 0.04,
                            ),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(
                            left: 150,
                            right: 280,
                            top: 130,
                          ),
                          child: Text(
                            '|',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 0.04,
                            ),
                          )),
                      Container(
                        padding: EdgeInsets.only(
                          left: 170,
                          right: 120,
                          top: 130,
                        ),
                        child: Text(
                          'Signup',
                          style: TextStyle(
                            color: Colors.blue[500],
                            fontSize: 32,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 0.04,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.25,
                              right: 25,
                              left: 25),
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'name should not be empty';
                                  }
                                  final isValid =
                                      RegExp(r'^[a-z A-Z]+$').hasMatch(value);
                                  if (!isValid) {
                                    return '3 - 24 long with alphabet and underscore';
                                  }
                                  return null;
                                },
                                controller: _nameController,
                                decoration: InputDecoration(
                                    fillColor:
                                        Colors.transparent.withOpacity(0.10),
                                    filled: true,
                                    labelText: ' Name',
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30))),
                                keyboardType: TextInputType.name,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'email should not be empty';
                                    }
                                    final isValid = RegExp(
                                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                        .hasMatch(value);
                                    if (!isValid) {
                                      return 'enter valid email';
                                    }
                                    return null;
                                  },
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                      fillColor:
                                          Colors.transparent.withOpacity(0.10),
                                      filled: true,
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                  keyboardType: TextInputType.emailAddress),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'rollno should not be empty';
                                    }
                                    return null;
                                  },
                                  controller: _rollnoController,
                                  decoration: InputDecoration(
                                      fillColor:
                                          Colors.transparent.withOpacity(0.10),
                                      filled: true,
                                      labelText: 'roll no',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                  keyboardType: TextInputType.number),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'mobile number should not be empty';
                                    }
                                    final isValid = RegExp(
                                            r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
                                        .hasMatch(value);
                                    if (!isValid) {
                                      return 'enter valid phone number';
                                    }
                                    return null;
                                  },
                                  controller: _mobilenumberController,
                                  decoration: InputDecoration(
                                      fillColor:
                                          Colors.transparent.withOpacity(0.10),
                                      filled: true,
                                      labelText: 'mobile number',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                  keyboardType: TextInputType.phone),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'password should not be empty';
                                  }
                                  if (value.length < 8) {
                                    return "Password must be at least 8 characters long";
                                  }
                                  if (!value.contains(RegExp(r'[A-Z]'))) {
                                    return "Password must contain at least one uppercase letter";
                                  }
                                  if (!value.contains(RegExp(r'[a-z]'))) {
                                    return "Password must contain at least one lowercase letter";
                                  }
                                  if (!value.contains(RegExp(r'[0-9]'))) {
                                    return "Password must contain at least one numeric character";
                                  }
                                  if (!value.contains(
                                      RegExp(r'[!@#\$%^&*()<>?/|}{~:]'))) {
                                    return "Password must contain at least one special character";
                                  }

                                  return null;
                                },
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    fillColor:
                                        Colors.transparent.withOpacity(0.10),
                                    filled: true,
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30))),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'confirm password should not be empty';
                                  }
                                  return null;
                                },
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    fillColor:
                                        Colors.transparent.withOpacity(0.10),
                                    filled: true,
                                    labelText: 'confirm Password',
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30))),
                              ),
                              _signUpLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        margin: EdgeInsets.all(25),
                                        child: SizedBox(
                                          width: 230,
                                          height: 60,
                                          child: ElevatedButton(
                                            onPressed:
                                                _signUpLoading ? null : _signUp,
                                            style: ButtonStyle(
                                              overlayColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                                  if (states.contains(
                                                      MaterialState.pressed))
                                                    return Colors.blue;
                                                  return null;
                                                },
                                              ),
                                            ),
                                            child: const Text(
                                              'Sign up',
                                              style: TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              TextButton(
                                  child:
                                      Text('Already have an account? Login '),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  onPressed: () {
                                    _navigateToLoginPage();
                                  })
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

