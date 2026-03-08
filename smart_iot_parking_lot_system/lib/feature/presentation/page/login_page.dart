import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_iot_parking_lot_system/core/helper/login_helper.dart';
import '../../../core/theme/app_palette.dart';
import '../../widget/loading_lottie.dart';
import '../../widget/login_page_widgets/login_elevated_button.dart';
import '../../widget/login_page_widgets/login_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void _login() {
    LoginHelper.loginHandle(
      context,
      _userController.text,
      _passwordController.text,
      _formKey,
      _setLoading,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final form = Form(
      key: _formKey,
      child: Center(
        child: Card(
          elevation: 10,
          color: Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Xin chào !",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Vui lòng đăng nhập vào tài khoản của bạn",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                LoginTextField(
                  controller: _userController,
                  hintText: "Username",
                ),
                const SizedBox(height: 20),
                LoginTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  isPassword: true,
                ),
                const SizedBox(height: 15),
                const SizedBox(height: 15),
                LoginElevatedButton(
                  onPressed: () {
                    _login();
                  },
                  text: 'Đăng nhập',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(gradient: AppPalette.gradient),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 300,
                      width: 300,
                      child: LottieBuilder.asset(
                        "assets/lottie/car_lottie.json",
                      ),
                    ),
                    form,
                  ],
                ),
              ),
            ),
            if (_isLoading) ...[
              const Opacity(
                opacity: 0.4,
                child: ModalBarrier(dismissible: true, color: Colors.black),
              ),
              const Center(child: LoadingLottie()),
            ],
          ],
        ),
      ),
    );
  }
}
