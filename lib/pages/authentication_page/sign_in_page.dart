import 'package:asr_project/main.dart';
import 'package:asr_project/pages/authentication_page/sign_up_page.dart';
import 'package:asr_project/services/user_service.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final UserService _userService = UserService();

  final TextEditingController _emailTextEditController =
      TextEditingController();
  final TextEditingController _passwordTextEditController =
      TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  late bool _isSubmit = false;

  @override
  void initState() {
    super.initState();

    _emailTextEditController.addListener(() => setState(() {}));
    _passwordTextEditController.addListener(() => setState(() {}));

    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();

    _emailTextEditController.dispose();
    _passwordTextEditController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
  }

  String? _validateEmail() {
    final String email = _emailTextEditController.text;
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (email.isEmpty) {
      return "Email is required";
    } else if (!emailRegex.hasMatch(email)) {
      return "Please enter email form";
    } else {
      return null;
    }
  }

  String? _validatePassword() {
    // TODO validate password
    final String password = _passwordTextEditController.text;

    if (password.isEmpty) {
      return "Password is required";
    } else {
      return null;
    }
  }

  void _signIn() async {
    setState(() {
      _isSubmit = true;
    });

    if (_validateEmail() == null && _validatePassword() == null) {
      final String email = _emailTextEditController.text;
      final String password = _passwordTextEditController.text;

      try {
        final user = await _userService.login(email, password);

        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          _showErrorDialog("Invalid email or password. Please try again.");
        }
      } catch (e) {
        _showErrorDialog("An error occurred. Please try again.");
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Login Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 32.0,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ASR App",
                      style:
                          Theme.of(context).textTheme.headlineLarge!.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    Text(
                      "Sign in",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
              CustomTextfield(
                label: "Email",
                hintText: "Enter Email",
                iconData: Icons.email,
                keyboardType: TextInputType.emailAddress,
                errorText: _isSubmit ? _validateEmail() : null,
                textEditController: _emailTextEditController,
                focusNode: _emailFocusNode,
              ),
              Column(
                children: [
                  CustomTextfield(
                    label: "Password",
                    hintText: "Enter password",
                    iconData: Icons.password,
                    keyboardType: TextInputType.visiblePassword,
                    errorText: _isSubmit ? _validatePassword() : null,
                    textEditController: _passwordTextEditController,
                    focusNode: _passwordFocusNode,
                    subButton: TextButton(
                        onPressed: () {}, child: Text("reset password")),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: () {
                        _signIn();
                      },
                      child: Text("Sign in"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?"),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                            );
                          },
                          child: Text("Sign up")),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
