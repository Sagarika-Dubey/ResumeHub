import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../globals.dart';
import '../backButton.dart';

class contact_info_page extends StatefulWidget {
  const contact_info_page({Key? key}) : super(key: key);

  @override
  State<contact_info_page> createState() => _contact_info_pageState();
}

class _contact_info_pageState extends State<contact_info_page> {
  Color MyColor = const Color(0xff0475FF);
  int initialIndex = 0;

  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> contactFormKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController leetcodeController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController address3Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        backgroundColor: MyColor,
        title: const Text("Resume Workspace"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: _width,
              alignment: const Alignment(0, 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: InkWell(
                      splashFactory: InkRipple.splashFactory,
                      splashColor: Colors.white.withOpacity(0.2),
                      onTap: () {
                        setState(() {
                          initialIndex = 0;
                        });
                      },
                      child: Ink(
                        color: MyColor,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Spacer(),
                              const Text(
                                "Contact",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                color: (initialIndex == 0)
                                    ? Colors.yellow
                                    : MyColor,
                                height: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      splashFactory: InkRipple.splashFactory,
                      splashColor: Colors.white.withOpacity(0.2),
                      onTap: () {
                        setState(() {
                          initialIndex = 1;
                        });
                      },
                      child: Ink(
                        color: MyColor,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Spacer(),
                              const Text(
                                "Photo",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                color: (initialIndex == 1)
                                    ? Colors.yellow
                                    : MyColor,
                                height: 2,
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
          Expanded(
            flex: 18,
            child: Container(
              color: const Color(0xffEDEDED),
              child: IndexedStack(
                index: initialIndex,
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          height: _height *
                              0.42, // Increased height to accommodate new fields
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          color: Colors.white,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Form(
                              key: contactFormKey,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Image.asset(
                                          "assets/icons/user.png",
                                          height: _height * 0.048,
                                        ),
                                      ),
                                      SizedBox(width: _width * 0.02),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          controller: nameController,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Enter your Name First...";
                                            }
                                            return null;
                                          },
                                          onSaved: (val) {
                                            setState(() {
                                              Global.name = val;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            hintText: "Name",
                                            label: Text("Name"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Image.asset(
                                          "assets/icons/email.png",
                                          height: _height * 0.048,
                                        ),
                                      ),
                                      SizedBox(width: _width * 0.02),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          controller: emailController,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Enter your Email First...";
                                            }
                                            return null;
                                          },
                                          onSaved: (val) {
                                            setState(() {
                                              Global.email = val;
                                            });
                                          },
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: const InputDecoration(
                                            hintText: "Email",
                                            label: Text("Email"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Image.asset(
                                          "assets/icons/smartphone-call.png",
                                          height: _height * 0.048,
                                        ),
                                      ),
                                      SizedBox(width: _width * 0.02),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          controller: phoneController,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Enter your Phone First...";
                                            }
                                            return null;
                                          },
                                          onSaved: (val) {
                                            setState(() {
                                              Global.phone = val;
                                            });
                                          },
                                          keyboardType: TextInputType.phone,
                                          decoration: const InputDecoration(
                                            hintText: "Phone",
                                            label: Text("Phone"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // LinkedIn URL field
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Icon(
                                          Icons.link,
                                          size: _height * 0.035,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                      SizedBox(width: _width * 0.02),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          controller: linkedinController,
                                          onSaved: (val) {
                                            setState(() {
                                              Global.linkedinUrl = val;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            hintText:
                                                "linkedin.com/in/username",
                                            label: Text("LinkedIn URL"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // LeetCode URL field
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Icon(
                                          Icons.code,
                                          size: _height * 0.035,
                                          color: Colors.orange[800],
                                        ),
                                      ),
                                      SizedBox(width: _width * 0.02),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          controller: leetcodeController,
                                          onSaved: (val) {
                                            setState(() {
                                              Global.leetcodeUrl = val;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            hintText: "leetcode.com/username",
                                            label: Text("LeetCode URL"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: _height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (contactFormKey.currentState!.validate()) {
                                  contactFormKey.currentState!.save();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColor,
                              ),
                              child: const Text("Save",
                                  style: TextStyle(color: Colors.black)),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  contactFormKey.currentState!.reset();

                                  nameController.clear();
                                  emailController.clear();
                                  phoneController.clear();
                                  linkedinController.clear();
                                  leetcodeController.clear();
                                  address1Controller.clear();
                                  address2Controller.clear();
                                  address3Controller.clear();
                                  setState(() {
                                    Global.name = null;
                                    Global.email = null;
                                    Global.phone = null;
                                    Global.linkedinUrl = null;
                                    Global.leetcodeUrl = null;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColor,
                                ),
                                child: const Text("Clear",
                                    style: TextStyle(color: Colors.black))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    height: _height * 0.29,
                    width: _width,
                    margin: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          backgroundImage: (Global.image != null)
                              ? FileImage(Global.image!)
                              : null,
                          radius: 60,
                          backgroundColor: const Color(0xffC4C4C4),
                          child: (Global.image == null)
                              ? const Text(
                                  "ADD",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : const Text(""),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title:
                                    const Text("When You go to pick Image ?"),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      XFile? pickerFile =
                                          await _picker.pickImage(
                                              source: ImageSource.gallery);
                                      setState(() {
                                        Global.image = File(pickerFile!.path);
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MyColor,
                                    ),
                                    child: const Text(
                                      "Gallery",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      XFile? pickerFile =
                                          await _picker.pickImage(
                                              source: ImageSource.camera);
                                      setState(() {
                                        Global.image = File(pickerFile!.path);
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MyColor,
                                    ),
                                    child: const Text(
                                      "Camera",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: MyColor,
                          ),
                          child: const Icon(Icons.add),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
