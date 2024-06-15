import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api_services/api_services.dart';
import 'package:chat/model/message_modal.dart';
import 'package:chat/utils/dialogues.dart';
import 'package:chat/utils/mydate_util.dart';
import 'package:chat/utils/view_video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';

class MessageCard extends StatefulWidget {
  const MessageCard(
      {super.key, required this.message, required this.videoPath});
  final MessageModal message;
  final String videoPath;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _controller.play();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = ApiServices.user.uid == widget.message.frId;
    return InkWell(
        onLongPress: () {
          fnBottomsheet(isMe);
        },
        child: isMe ? greenMessage() : blueMessage());
  }

  Widget blueMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 245, 255),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border.all(
                color: Colors.blueGrey,
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.message,
                  )
                : widget.message.type == Type.video
                    ? _controller.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        : const CircularProgressIndicator()
                    : ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.height * .055,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.message,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image,
                            size: 70,
                          ),
                        ),
                      ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            MyDateUtil.getFormattedtime(
              context: context,
              time: widget.message.dlvryTime,
            ),
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        )
      ],
    );
  }

  Widget greenMessage() {
    if (widget.message.message.isEmpty) {
      ApiServices.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Icon(
              Icons.done_all_rounded,
              color: widget.message.message.isNotEmpty
                  ? Colors.blue.shade600
                  : Colors.grey.shade500,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              MyDateUtil.getFormattedtime(
                context: context,
                time: widget.message.dlvryTime,
              ),
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        Flexible(
          child: GestureDetector(
            onTap: () {
              if (widget.message.type == Type.video) {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          VideoApp(videoPath: widget.videoPath),
                    ));
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.blueGrey,
                ),
              ),
              child: widget.message.type == Type.text
                  ? Text(
                      widget.message.message,
                    )
                  : widget.message.type == Type.video
                      ? _controller.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            )
                          : const Text('Loading Video...')
                      : ClipRRect(
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height * .055,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.message.message,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Text('Error: Couldn\'t play video'),
                          ),
                        ),
            ),
          ),
        ),
      ],
    );
  }

  void fnBottomsheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.message.type == Type.image
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      onTap: () async {
                        var response = await Dio().get(widget.message.message,
                            options: Options(responseType: ResponseType.bytes));
                        final result = await ImageGallerySaver.saveImage(
                            Uint8List.fromList(response.data),
                            quality: 60,
                            name: "hello");
                        Navigator.pop(context);
                        CustomSnackBar.showSnackBar(context, "Message copied");
                      },
                      leading: const Icon(
                        Icons.download_outlined,
                        color: Colors.blue,
                      ),
                      title: const Text(
                        "Download image",
                        style: TextStyle(fontSize: 16),
                      ),
                    ))
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.message))
                            .then((value) {
                          Navigator.pop(context);
                          CustomSnackBar.showSnackBar(
                              context, "Message copied");
                        });
                      },
                      leading: const Icon(
                        Icons.copy,
                        color: Colors.blue,
                      ),
                      title: const Text(
                        "Copy text",
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
            if (widget.message.type == Type.text && isMe)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      fnEditMessage();
                    },
                    leading: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    title: const Text(
                      "Edit message",
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
            if (isMe)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListTile(
                    onTap: () async {
                      await ApiServices.deleteMessage(widget.message)
                          .then((value) {
                        Navigator.pop(context);
                        CustomSnackBar.showSnackBar(
                            context, "Deleted successfully");
                      });
                    },
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: const Text(
                      "Delete message",
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: double.maxFinite,
                height: 2,
                color: Colors.grey,
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListTile(
                  leading: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                  ),
                  title: Text(
                    "sent at  : ${MyDateUtil.getMessageTime(context: context, time: widget.message.dlvryTime)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                )),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListTile(
                  leading: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                  ),
                  title: Text(
                    widget.message.message.isEmpty
                        ? "Read at : not read yet"
                        : "Read at : ${MyDateUtil.getMessageTime(context: context, time: widget.message.message)} ",
                    style: const TextStyle(fontSize: 16),
                  ),
                )),
          ],
        );
      },
    );
  }

  void fnEditMessage() {
    String updateMessage = widget.message.message;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.message),
                Text("    Update Message"),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              initialValue: updateMessage,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => updateMessage = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ApiServices.updateMessage(widget.message, updateMessage);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }
}
