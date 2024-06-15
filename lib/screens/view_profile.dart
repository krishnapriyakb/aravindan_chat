import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api_services/api_services.dart';
import 'package:chat/model/chat_user.dart';
import 'package:chat/screens/login_screen.dart';
import 'package:chat/utils/dialogues.dart';
import 'package:chat/utils/mydate_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ViewProfile extends StatefulWidget {
  final ChatUserModal user;
  const ViewProfile({
    super.key,
    required this.user,
  });

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.user.name,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    ClipRRect(
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
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(widget.user.email),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "About : ",
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(widget.user.about),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Joined on : ",
              style: TextStyle(fontSize: 15),
            ),
            Text(
              MyDateUtil.getaLastMessasgeTime(
                context: context,
                time: widget.user.createdAt,
                showYear: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
