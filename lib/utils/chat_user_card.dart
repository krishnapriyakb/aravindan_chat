import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api_services/api_services.dart';
import 'package:chat/model/chat_user.dart';
import 'package:chat/model/message_modal.dart';
import 'package:chat/screens/chat_page.dart';
import 'package:chat/screens/profile_page.dart';
import 'package:chat/screens/view_profile.dart';
import 'package:chat/utils/mydate_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({
    super.key,
    required this.title,
    required this.lastMessage,
  });

  final ChatUserModal title;
  final String lastMessage;
  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  MessageModal? messageModal;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: StreamBuilder(
      stream: ApiServices.getLastMessage(widget.title),
      builder: (context, snapshot) {
        final data = snapshot.data?.docs;

        final messages =
            data?.map((e) => MessageModal.fromJson(e.data())).toList() ?? [];
        if (messages.isNotEmpty) messageModal = messages[0];

        return ListTile(
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(
              builder: (context) {
                return ChatPage(
                  user: widget.title,
                );
              },
            ));
          },
          leading: ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.height * .055,
            ),
            child: InkWell(
              onTap: () {
                fnShowProfileImage(context, widget.title);
              },
              child: CachedNetworkImage(
                height: MediaQuery.of(context).size.height * .055,
                width: MediaQuery.of(context).size.height * .055,
                imageUrl: widget.title.image,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          title: Text(widget.title.name),
          subtitle: Text(
            messageModal != null
                ? messageModal!.type == Type.image
                    ? 'image'
                    : messageModal!.type == Type.video
                        ? 'video'
                        : messageModal!.message
                : widget.lastMessage,
            maxLines: 1,
          ),
          trailing: messageModal == null
              ? null
              : messageModal!.message.isEmpty &&
                      messageModal!.frId != ApiServices.user.uid
                  ? Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.green,
                      ),
                    )
                  : Text(
                      MyDateUtil.getaLastMessasgeTime(
                        context: context,
                        time: messageModal!.dlvryTime,
                      ),
                      style: const TextStyle(color: Colors.grey),
                    ),
        );
      },
    ));
  }

  void fnShowProfileImage(BuildContext context, ChatUserModal user) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .35,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(user.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.black.withOpacity(.2),
                      Colors.black,
                    ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ChatPage(user: user),
                                  ));
                            },
                            icon: const Icon(
                              Icons.chat,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ChatPage(user: user),
                                  ));
                            },
                            icon: const Icon(
                              Icons.phone_outlined,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ChatPage(user: user),
                                  ));
                            },
                            icon: const Icon(
                              Icons.video_call_outlined,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        ViewProfile(user: user),
                                  ));
                            },
                            icon: const Icon(
                              Icons.info,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(.2),
                            Colors.black,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
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
