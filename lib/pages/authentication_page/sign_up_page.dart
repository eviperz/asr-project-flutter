import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditController =
      TextEditingController();
  final TextEditingController _passwordTextEditController =
      TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  late int _stepIndex;

  @override
  void initState() {
    super.initState();
    _stepIndex = 0;

    _nameTextEditingController.addListener(() => setState(() {}));
    _emailTextEditController.addListener(() => setState(() {}));
    _passwordTextEditController.addListener(() => setState(() {}));

    _nameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();

    _nameTextEditingController.dispose();
    _emailTextEditController.dispose();
    _passwordTextEditController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
  }

  String? _validateName() {
    final String name = _nameTextEditingController.text.trim();
    if (name.isEmpty) {
      return "Name is required";
    } else {
      return null;
    }
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

  bool _isStepValid() {
    if (_stepIndex == 0) {
      return _validateName() == null;
    } else if (_stepIndex == 1) {
      return _validateEmail() == null;
    } else if (_stepIndex == 2) {
      return _validatePassword() == null;
    }
    return false;
  }

  void _signUp() {
    // TODO Sign up
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Stepper(
            currentStep: _stepIndex,
            onStepTapped: (value) {
              if (_stepIndex >= value) {
                setState(() {
                  _stepIndex = value;
                });
              }
            },
            onStepCancel: () {
              if (_stepIndex > 0) {
                setState(() {
                  _stepIndex -= 1;
                });
              }
            },
            onStepContinue: () {
              if (_isStepValid()) {
                setState(() {
                  _stepIndex += 1;
                });
              }
            },
            controlsBuilder: (context, details) {
              return Row(
                spacing: 8.0,
                children: [
                  _stepIndex != 2
                      ? ElevatedButton(
                          onPressed:
                              _isStepValid() ? details.onStepContinue : null,
                          child: Text('Continue'),
                        )
                      : ElevatedButton(
                          onPressed: _isStepValid() ? _signUp : null,
                          child: Text('Sign up'),
                        ),
                  if (_stepIndex != 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text('Back'),
                    ),
                ],
              );
            },
            steps: [
              Step(
                title: Text("Step 1"),
                content: SizedBox(
                  height: 110,
                  child: CustomTextfield(
                    label: "Name",
                    hintText: "Enter name",
                    iconData: Icons.person,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _validateName(),
                    textEditController: _nameTextEditingController,
                    focusNode: _nameFocusNode,
                  ),
                ),
                isActive: true,
              ),
              Step(
                title: Text("Step 2"),
                content: SizedBox(
                  height: 110,
                  child: CustomTextfield(
                    label: "Email",
                    hintText: "Enter email",
                    iconData: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _validateEmail(),
                    textEditController: _emailTextEditController,
                    focusNode: _emailFocusNode,
                  ),
                ),
                isActive: _stepIndex > 0,
              ),
              Step(
                title: Text("Step 3"),
                content: SizedBox(
                  height: 110,
                  child: CustomTextfield(
                    label: "Password",
                    hintText: "Enter password",
                    iconData: Icons.password,
                    keyboardType: TextInputType.visiblePassword,
                    errorText: _validatePassword(),
                    textEditController: _passwordTextEditController,
                    focusNode: _passwordFocusNode,
                  ),
                ),
                isActive: _stepIndex > 1,
              ),
            ]),
      ),
    );
  }
}
