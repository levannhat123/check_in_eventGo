import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/base/base_view.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_image.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_svg.dart';
import '../../../core/utils/validator.dart';
import '../../../core/widgets/app_elevated_button.dart';
import '../../../core/widgets/showdialog.dart';
import '../../../core/widgets/text_field.dart';
import '../../../core/widgets/text_field_password.dart';
import '../../../injection/injection.dart';
import '../../../routers/router_name.dart';
import '../../view_models/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BaseView(
      padding: false,
      viewModelBuilder: () => getIt<AuthViewModel>(),
      builder: (context, viewModel, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppSizes.size40),
                      bottomRight: Radius.circular(AppSizes.size40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.space60),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(AppImage.logo),
                          radius: AppSizes.size40,
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        Text(
                          AppStrings.loginTitle,
                          style: TextStyle(
                            color: AppColors.brandAccent,
                            fontSize: AppSizes.size24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        Text(
                          AppStrings.loginDescription,
                          style: TextStyle(
                            color: AppColors.brandAccent,
                            fontSize: AppSizes.size12,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.space20),
                  height: MediaQuery.of(context).size.height * 0.70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.size30),
                      topRight: Radius.circular(AppSizes.size30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: emailController,
                          hintText: AppStrings.emailHint,
                          borderColor: Colors.grey.shade300,
                          fillColor: Colors.grey.shade100,
                          validator: Validator.email,
                          suffixIcon: IconButton(
                            onPressed: () {
                              emailController.clear();
                            },
                            icon: SvgPicture.asset(
                              AppSvg.close,
                              width: AppSizes.size24,
                              height: AppSizes.size24,
                              colorFilter: const ColorFilter.mode(
                                Colors.grey,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          focusedBorderColor: AppColors.brandPrimary,
                          enabledBorderColor: Colors.grey.shade300,
                          prefixIcon: const Icon(Icons.email),
                          shadowColor: AppColors.transparent,
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        AppTextFieldPassword(
                          controller: passwordController,
                          hintText: AppStrings.passwordHint,
                          borderColor: Colors.grey.shade300,
                          validator: Validator.password,
                          fillColor: Colors.grey.shade100,
                          focusedBorderColor: AppColors.brandPrimary,
                          enabledBorderColor: Colors.grey.shade300,
                          shadowColor: AppColors.transparent,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {
                                context.push(RouterPath.forgotPassword);
                              },
                              child: const Text(
                                AppStrings.forgotPasswordButton,
                                style: TextStyle(color: AppColors.brandAccent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        viewModel.isLoading
                            ? Center(
                                child: LoadingAnimationWidget.hexagonDots(
                                  color: AppColors.brandAccent,
                                  size: AppSizes.size50,
                                ),
                              )
                            : AppElevatedButton(
                                text: AppStrings.loginButton,
                                borderColor: AppColors.brandAccent,
                                color: AppColors.brandAccent,
                                splashColor: AppColors.transparent,
                                highlightColor: AppColors.white,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await viewModel.login(
                                      emailController.text.trim(),
                                      passwordController.text,
                                    );
                                    if (!context.mounted) return;
                                    if (success) {
                                      await showCustomDialog(
                                        context: context,
                                        title: AppStrings.loginSuccessTitle,
                                        message: AppStrings.loginSuccessMessage,
                                        buttonText: AppStrings.okayButton,
                                        icon: Icons.check_circle,
                                        iconColor: Colors.green,
                                        onPressed: () {
                                          context.go(RouterPath.home);
                                        },
                                      );
                                    } else {
                                      await showCustomDialog(
                                        context: context,
                                        title: AppStrings.loginFailedTitle,
                                        message:
                                            viewModel.errorMessage ??
                                            AppStrings
                                                .wrongEmailOrPasswordMessage,
                                        buttonText: AppStrings.okayButton,
                                        icon: Icons.error,
                                        iconColor: Colors.red,
                                        onPressed: () {},
                                      );
                                    }
                                  }
                                },
                              ),
                        const SizedBox(height: AppSpacing.space20),
                        RichText(
                          text: TextSpan(
                            text: AppStrings.noAccount,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: AppSizes.size14,
                            ),
                            children: [
                              TextSpan(
                                text: AppStrings.signUpButton,
                                style: TextStyle(
                                  color: AppColors.brandAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push(RouterPath.sign_up);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
