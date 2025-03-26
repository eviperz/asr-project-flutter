import 'package:asr_project/providers/auth_state_provider.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditController =
      TextEditingController();
  final TextEditingController _passwordTextEditController =
      TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false; // Track the loading state
  bool _hasInteractedWithName = false;
  bool _hasInteractedWithEmail = false;
  bool _hasInteractedWithPassword = false;

  late int _stepIndex;

  @override
  void initState() {
    super.initState();
    _stepIndex = 0;

    _nameTextEditingController.addListener(() => setState(() {
          _hasInteractedWithName = true;
        }));
    _emailTextEditController.addListener(() => setState(() {
          _hasInteractedWithEmail = true;
        }));
    _passwordTextEditController.addListener(() => setState(() {
          _hasInteractedWithPassword = true;
        }));

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
      return "Please enter a valid email address";
    } else {
      return null;
    }
  }

  String? _validatePassword() {
    final String password = _passwordTextEditController.text;

    if (password.isEmpty) {
      return "Password is required";
    } else if (password.length < 6) {
      return "Password should be at least 6 characters";
    } else {
      return null;
    }
  }

  bool _isStepValid() {
    if (_stepIndex == 0) {
      return _hasInteractedWithName && _validateName() == null;
    } else if (_stepIndex == 1) {
      return _hasInteractedWithEmail && _validateEmail() == null;
    } else if (_stepIndex == 2) {
      return _hasInteractedWithPassword && _validatePassword() == null;
    }
    return false;
  }

  Future<void> _signUp() async {
    final String name = _nameTextEditingController.text.trim();
    final String email = _emailTextEditController.text.trim();
    final String password = _passwordTextEditController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await ref.read(authState.notifier).signUp(name, email, password);
      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Sign up successful!"),
        ));
        Navigator.pop(context);
      } else {
        // Handle failed sign-up
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Sign up failed, please try again."),
        ));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
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
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Please fill in the required fields correctly!'),
                  ),
                );
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
                          onPressed:
                              _isStepValid() && !_isLoading ? _signUp : null,
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Text('Sign up'),
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
                content: CustomTextfield(
                  label: "Name",
                  hintText: "Enter name",
                  iconData: Icons.person,
                  keyboardType: TextInputType.text,
                  errorText: _hasInteractedWithName ? _validateName() : null,
                  textEditController: _nameTextEditingController,
                  focusNode: _nameFocusNode,
                ),
                isActive: true,
              ),
              Step(
                title: Text("Step 2"),
                content: CustomTextfield(
                  label: "Email",
                  hintText: "Enter email",
                  iconData: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _hasInteractedWithEmail ? _validateEmail() : null,
                  textEditController: _emailTextEditController,
                  focusNode: _emailFocusNode,
                ),
                isActive: _stepIndex > 0,
              ),
              Step(
                title: Text("Step 3"),
                content: CustomTextfield(
                  label: "Password",
                  hintText: "Enter password",
                  iconData: Icons.password,
                  keyboardType: TextInputType.visiblePassword,
                  errorText:
                      _hasInteractedWithPassword ? _validatePassword() : null,
                  textEditController: _passwordTextEditController,
                  focusNode: _passwordFocusNode,
                ),
                isActive: _stepIndex > 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
