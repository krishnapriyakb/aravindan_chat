import 'package:chat/api_services/api_services.dart';
import 'package:chat/model/chat_user.dart';
import 'package:chat/screens/profile_page.dart';
import 'package:chat/utils/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUserModal> users = [];
  List<ChatUserModal> searchList = [];

  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    ApiServices.getSelfInfo();
    ApiServices.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message.toString().contains('resume')) {
        ApiServices.updateActiveStatus(true);
      }
      if (message.toString().contains('pause')) {
        ApiServices.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: isSearching
                ? TextFormField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Name ,email"),
                    autofocus: true,
                    onChanged: (value) {
                      searchList.clear();
                      for (var i in users) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          searchList.add(i);
                        }
                        setState(() {
                          searchList;
                        });
                      }
                    },
                  )
                : const Text("HomePage"),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isSearching = !isSearching;
                  });
                },
                icon: Icon(
                  isSearching ? CupertinoIcons.clear_fill : Icons.search,
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ProfilePage(
                            user: ApiServices.me,
                          ),
                        ));
                  },
                  icon: const Icon(Icons.menu_sharp))
            ],
          ),
          body: StreamBuilder(
            stream: ApiServices.getAllusers(),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.done:
                case ConnectionState.active:
                  users = data
                          ?.map(
                            (e) => ChatUserModal.fromJson(
                              e.data(),
                            ),
                          )
                          .toList() ??
                      [];
                  if (users.isNotEmpty) {
                    return ListView.builder(
                      itemCount: isSearching ? searchList.length : users.length,
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          title: isSearching ? searchList[index] : users[index],
                          lastMessage: "",
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("No connection found"),
                    );
                  }
              }
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => fnAddUser(),
            label: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void fnAddUser() {
    String email = '';
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
                Icon(Icons.person_add_alt),
                Text("    Add User"),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => email = value,
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
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }
}
