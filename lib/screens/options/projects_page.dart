import 'package:flutter/material.dart';

import '../../globals.dart';
import '../backButton.dart';

class projects_page extends StatefulWidget {
  const projects_page({Key? key}) : super(key: key);

  @override
  State<projects_page> createState() => _projects_pageState();
}

class _projects_pageState extends State<projects_page> {
  Color MyColor = const Color(0xff0475FF);
  var MyTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: const Color(0xff0475FF).withOpacity(0.8),
  );
  var myTextStyleForChackBox = const TextStyle(
    fontSize: 17,
    color: Colors.grey,
  );

  final GlobalKey<FormState> projectFormKey = GlobalKey<FormState>();

  final TextEditingController projectTitleController = TextEditingController();
  final TextEditingController rolesController = TextEditingController();
  final TextEditingController technologyController = TextEditingController();
  final TextEditingController projectDescriptionController =
      TextEditingController();
  final TextEditingController teamSizeController = TextEditingController();

  // List to store multiple technologies
  List<String> technologies = [];

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        backgroundColor: MyColor,
        title: const Text("Projects"),
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
              color: MyColor,
            ),
          ),
          Expanded(
            flex: 18,
            child: Container(
              color: const Color(0xffEDEDED),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(
                          top: 30, bottom: 20, right: 20, left: 20),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: projectFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Project Title", style: MyTextStyle),
                            SizedBox(height: _height * 0.015),
                            TextFormField(
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Enter your Project Title First...";
                                }
                                return null;
                              },
                              onSaved: (val) {
                                setState(() {
                                  Global.projectTitle = val;
                                });
                              },
                              controller: projectTitleController,
                              decoration: const InputDecoration(
                                hintText: "Enter the Project title",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: _height * 0.015),
                            Text("Technologies", style: MyTextStyle),
                            SizedBox(height: _height * 0.015),

                            // Technologies input with Add button
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: technologyController,
                                    decoration: const InputDecoration(
                                      hintText: "Enter a technology",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (technologyController.text.isNotEmpty) {
                                      setState(() {
                                        technologies
                                            .add(technologyController.text);
                                        technologyController.clear();
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColor,
                                  ),
                                  child: const Text("Add",
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),

                            // Display the list of technologies
                            if (technologies.isNotEmpty) ...[
                              SizedBox(height: _height * 0.015),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Added Technologies:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: technologies.length,
                                      itemBuilder: (context, index) {
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: Text(technologies[index]),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  technologies.removeAt(index);
                                                });
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: _height * 0.015),
                            Text("Roles", style: MyTextStyle),
                            SizedBox(height: _height * 0.015),
                            TextFormField(
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Enter your Roles First...";
                                }
                                return null;
                              },
                              onSaved: (val) {
                                setState(() {
                                  Global.projectRoles = val;
                                });
                              },
                              maxLines: 2,
                              controller: rolesController,
                              decoration: const InputDecoration(
                                hintText:
                                    "Organize team members, Code\nanalysis",
                                border: OutlineInputBorder(),
                              ),
                            ),

                            SizedBox(height: _height * 0.015),
                            Text("Project Description", style: MyTextStyle),
                            SizedBox(height: _height * 0.015),
                            TextFormField(
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Enter your Project Description First...";
                                }
                                return null;
                              },
                              onSaved: (val) {
                                setState(() {
                                  Global.projectDescription = val;
                                });
                              },
                              controller: projectDescriptionController,
                              decoration: const InputDecoration(
                                hintText: "Enter Your Project Description",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (projectFormKey.currentState!.validate()) {
                              projectFormKey.currentState!.save();

                              // Save technologies to Global
                              Global.projectTechnologies =
                                  technologies.join(", ");

                              setState(() => Navigator.of(context).pop());
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
                            projectFormKey.currentState!.reset();

                            projectTitleController.clear();
                            rolesController.clear();
                            technologyController.clear();
                            projectDescriptionController.clear();
                            teamSizeController.clear();

                            setState(() {
                              technologies.clear();
                              Global.projectTitle = null;
                              Global.projectRoles = null;
                              Global.projectTechnologies = null;
                              Global.projectDescription = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColor,
                          ),
                          child: const Text("Clear",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
