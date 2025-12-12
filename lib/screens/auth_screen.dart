import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPass = '';
  bool _inProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin) UserImagePicker(),

                          TextFormField(
                            keyboardType: .emailAddress,
                            autocorrect: false,
                            textCapitalization: .none,
                            decoration: InputDecoration(labelText: 'Email'),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please Enter a valid email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            }, // New Learning
                          ),
                          TextFormField(
                            obscureText: true,
                            textCapitalization: .none,
                            decoration: InputDecoration(labelText: 'Password'),
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 chars long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPass = value!;
                            },
                          ),
                          SizedBox(height: 12),
                          Visibility(
                            visible: _inProgress == false,
                            replacement: CircularProgressIndicator(),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                              onPressed: _submit,
                              child: Text(_isLogin ? 'Login' : 'Sign Up'),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _isLogin = !_isLogin;
                              setState(() {});
                            },
                            child: Text(
                              _isLogin
                                  ? 'Create an Account'
                                  : 'I  already have an account.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _inProgress = true;
      setState(() {});
      final isValid = _formKey.currentState!.validate();

      if (!isValid) {
        return;
      } else {
        _formKey.currentState!.save();
      }
      try {
        if (_isLogin) {
          // log users in
          final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPass,
          );
        } else {
          final userCredentials = await _firebase
              .createUserWithEmailAndPassword(
                email: _enteredEmail,
                password: _enteredPass,
              );
          // print(userCredentials);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-user') {
          // Show error message
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed')),
        );
      }
      _inProgress = false;
      setState(() {});
    }
    else{
      return;
    }
  }
}
