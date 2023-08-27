import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat_app/api/api.dart';
import 'package:we_chat_app/models/chat_user.dart';
import 'package:we_chat_app/screens/profile_screen.dart';

import '../main.dart';
import '../widgets/chat_user_card.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    // When search field changes... update the search list
                    onChanged: (val) {
                      _searchList.clear();

                      for (var i in _list) {
                        if (val.isNotEmpty) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    autofocus: true,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.white70)),
                  )
                : const Text('WeChat'),
            actions: [
              IconButton(
                  onPressed: () {
                    _searchList.clear();

                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching ? Icons.clear : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: APIs.me,
                                )));
                  },
                  icon: const Icon(Icons.more_vert))
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.black,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          body: StreamBuilder(
              stream: APIs.getAllUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;

                    _list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];

                    if (_list.isNotEmpty) {
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          return ChatUserCard(
                              user: _isSearching
                                  ? _searchList[index]
                                  : _list[index]);
                          // return Text("Name: ${_list[index]}");
                        },
                        itemCount:
                            _isSearching ? _searchList.length : _list.length,
                        padding: EdgeInsets.only(top: mq.height * .01),
                        physics: const BouncingScrollPhysics(),
                      );
                    } else {
                      return const Center(
                          child: Text(
                        "No connections found!",
                        style: TextStyle(fontSize: 24, color: Colors.red),
                      ));
                    }
                }
              }),
        ),
      ),
    );
  }
}
