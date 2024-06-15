import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api_services/api_services.dart';
import 'package:chat/model/chat_user.dart';
import 'package:chat/model/message_modal.dart';
import 'package:chat/screens/view_profile.dart';
import 'package:chat/utils/message_card.dart';
import 'package:chat/utils/mydate_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final ChatUserModal user;
  const ChatPage({
    super.key,
    required this.user,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<MessageModal> messages = [];

  final _textEditingController = TextEditingController();
  bool _isUploading = false;

  String selectedFilePath = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: appBar(),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: ApiServices.getAllMesssages(widget.user),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs;
                  // log("Data : ${jsonEncode(data![0].data())}");
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.done:
                    case ConnectionState.active:
                      messages = data
                              ?.map(
                                (e) => MessageModal.fromJson(
                                  e.data(),
                                ),
                              )
                              .toList() ??
                          [];
                      if (messages.isNotEmpty) {
                        return ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          clipBehavior: Clip.antiAlias,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {},
                              child: MessageCard(
                                message: messages[index],
                                videoPath: selectedFilePath,
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "Say hai ... ☻",
                            style: TextStyle(fontSize: 25),
                          ),
                        );
                      }
                  }
                },
              ),
            ),
            if (_isUploading)
              const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 5,
                    ),
                    child: CircularProgressIndicator(),
                  )),
            chatInput(),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ViewProfile(user: widget.user),
            ));
      },
      child: StreamBuilder(
        stream: ApiServices.getUsersInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;

          final list = data
                  ?.map(
                    (e) => ChatUserModal.fromJson(e.data()),
                  )
                  .toList() ??
              [];
          return Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.height * .055,
                ),
                child: CachedNetworkImage(
                  height: MediaQuery.of(context).size.height * .055,
                  width: MediaQuery.of(context).size.height * .055,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? "Online"
                            : MyDateUtil.getaLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive,
                              )
                        : MyDateUtil.getaLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive,
                          ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 10,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.emoji_emotions,
                      size: 25,
                    ),
                  ),
                  Expanded(
                      child: TextFormField(
                    controller: _textEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type something...",
                    ),
                  )),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images = await picker.pickMultipleMedia(
                        imageQuality: 70,
                      );
                      for (var i in images) {
                        log("Image path : ${i.path}");
                        selectedFilePath = i.path;
                        setState(() => _isUploading = true);
                        await ApiServices.sendVideo(widget.user, File(i.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      size: 25,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 70,
                      );
                      if (image != null) {
                        log("Image path : ${image.path}");
                        setState(() => _isUploading = true);
                        await ApiServices.sendImage(
                            widget.user, File(image.path));
                        setState(() => _isUploading = false);
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 25,
                    ),
                  )
                ],
              ),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green.shade300),
              shape: const WidgetStatePropertyAll(
                CircleBorder(side: BorderSide.none),
              ),
              minimumSize: const WidgetStatePropertyAll(
                Size(50, 50),
              ),
            ),
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                ApiServices.sendMessages(
                    widget.user, _textEditingController.text, Type.text);
                _textEditingController.clear();
              }
            },
            child: const Icon(
              Icons.send,
              size: 25,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
