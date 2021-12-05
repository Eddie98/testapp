import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneAuthForm extends StatefulWidget {
  const PhoneAuthForm({Key? key}) : super(key: key);

  @override
  _PhoneAuthFormState createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends State<PhoneAuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumber = TextEditingController();

  OutlineInputBorder border = const OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFEFEFEF),
      width: 3.0,
    ),
  );

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Авторизация"),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).primaryColor,
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      drawer: SizedBox(
        width: size.width * 0.7,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: const Text(''),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Лента фотографий'),
                minLeadingWidth: 20.0,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/photos", (route) => false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_sharp),
                title: const Text('Избранные фотографии'),
                minLeadingWidth: 20.0,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/favorite-photos", (route) => false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.post_add_sharp),
                title: const Text('Посты'),
                minLeadingWidth: 20.0,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/posts", (route) => false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Авторизация / Регистрация'),
                minLeadingWidth: 20.0,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/", (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width * 0.8,
                child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: phoneNumber,
                    decoration: InputDecoration(
                      labelText: "Enter Phone",
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      border: border,
                    )),
              ),
              Padding(padding: EdgeInsets.only(bottom: size.height * 0.05)),
              !isLoading
                  ? SizedBox(
                      width: size.width * 0.8,
                      child: OutlinedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _SendSMSWidget(
                                  phoneNumber: phoneNumber.text,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text("Отправить СМС"),
                        style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFFFFFFFF)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF000000),
                            ),
                            side: MaterialStateProperty.all<BorderSide>(
                              BorderSide.none,
                            )),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _SendSMSWidget extends StatelessWidget {
  final String phoneNumber;

  _SendSMSWidget({Key? key, required this.phoneNumber}) : super(key: key);

  String? _enteredOTP;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FirebasePhoneAuthHandler(
        phoneNumber: phoneNumber,
        timeOutDuration: const Duration(seconds: 60),
        onLoginSuccess: (userCredential, autoVerified) async {
          print(autoVerified
              ? "OTP was fetched automatically"
              : "OTP was verified manually");

          print("Login Success UID: ${userCredential.user?.uid}");
        },
        onLoginFailed: (authException) {
          print("An error occurred: ${authException.message}");

          // handle error further if needed
        },
        builder: (context, controller) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Авторизация"),
              backgroundColor: Colors.black,
              actions: controller.codeSent
                  ? [
                      TextButton(
                        child: Text(
                          controller.timerIsActive
                              ? "${controller.timerCount.inSeconds}s"
                              : "RESEND",
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        onPressed: controller.timerIsActive
                            ? null
                            : () async {
                                await controller.sendOTP();
                              },
                      ),
                      const SizedBox(width: 5),
                    ]
                  : null,
            ),
            body: controller.codeSent
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        "We've sent an SMS with a verification code to $phoneNumber",
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        height: controller.timerIsActive ? null : 0,
                        child: Column(
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(height: 50),
                            Text(
                              "Listening for OTP",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Divider(),
                            Text("OR", textAlign: TextAlign.center),
                            Divider(),
                          ],
                        ),
                      ),
                      const Text(
                        "Enter Code Manually",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextField(
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        onChanged: (String v) async {
                          _enteredOTP = v;
                          if (_enteredOTP?.length == 6) {
                            final res =
                                await controller.verifyOTP(otp: _enteredOTP!);
                            // Incorrect OTP
                            if (!res) {
                              print(
                                "Please enter the correct OTP sent to $phoneNumber",
                              );
                            }
                          }
                        },
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 50),
                      Center(
                        child: Text(
                          "Sending OTP",
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  ),
            floatingActionButton: controller.codeSent
                ? FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.check),
                    onPressed: () async {
                      if (_enteredOTP == null || _enteredOTP?.length != 6) {
                        print("Please enter a valid 6 digit OTP");
                      } else {
                        final res =
                            await controller.verifyOTP(otp: _enteredOTP!);
                        if (!res) {
                          print(
                            "Please enter the correct OTP sent to $phoneNumber",
                          );
                        } else {
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/photos", (route) => false);
                        }
                      }
                    },
                  )
                : null,
          );
        },
      ),
    );
  }
}
