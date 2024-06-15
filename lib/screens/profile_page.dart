import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api_services/api_services.dart';
import 'package:chat/model/chat_user.dart';
import 'package:chat/screens/login_screen.dart';
import 'package:chat/utils/dialogues.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final ChatUserModal user;
  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String? _image;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Profile Page"),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.circular(
                                height * .055,
                              ),
                              child: Image.file(
                                File(_image!),
                                height: height * .055,
                                width: height * .055,
                              ),
                            )
                          : ClipRRect(
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.circular(
                                height * .1,
                              ),
                              child: CachedNetworkImage(
                                height: height * .2,
                                width: height * .2,
                                imageUrl: widget.user.image,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {
                            fnShowBottomSheet();
                          },
                          color: Colors.white,
                          clipBehavior: Clip.antiAlias,
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(widget.user.email),
                const SizedBox(
                  height: 55,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (newValue) => ApiServices.me.name = newValue ?? '',
                    validator: (value) =>
                        value != null && value.isNotEmpty ? null : "Required",
                    initialValue: widget.user.name,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (newValue) =>
                        ApiServices.me.about = newValue ?? '',
                    validator: (value) =>
                        value != null && value.isNotEmpty ? null : "Required",
                    initialValue: widget.user.about,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 55,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ApiServices.updateUserInfo().then((value) =>
                            CustomSnackBar.showSnackBar(
                                context, "successfully updated"));
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Update"),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.edit)
                      ],
                    ))
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              CustomSnackBar.showProgressBar(context);

              await ApiServices.updateActiveStatus(false);
              await ApiServices.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //for hiding progress bar
                  Navigator.pop(context);
                  //for moving to homepage
                  Navigator.pop(context);
                  ApiServices.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                });
              });
            },
            label: const Row(
              children: [
                Text("Logout"),
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.logout),
              ],
            )),
      ),
    );
  }

  fnShowBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * .03,
            bottom: MediaQuery.of(context).size.height * .05,
          ),
          children: [
            const Text(
              "Pick your image",
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _image = image.path;
                      });
                      ApiServices.updateProfilePicture(File(_image!));
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset(
                    "assets/images/gallery.png",
                    height: 100,
                  ),
                ),
                const SizedBox(
                  width: 100,
                ),
                InkWell(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      log("Image path : ${image.path}");

                      setState(() {
                        _image = image.path;
                      });
                      ApiServices.updateProfilePicture(File(_image!));
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset(
                    "assets/images/camera.png",
                    height: 100,
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
