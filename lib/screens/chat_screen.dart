import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:we_chat_app/models/chat_user.dart';
import 'package:we_chat_app/widgets/message_card.dart';

import '../api/api.dart';
import '../main.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add this line to register the observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove the observer when the screen is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  // For storing all the messages
  List<Message> _list = [];

  // For handling messages text changes
  final _textController = TextEditingController();

  // For auto scrolling to bottom
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;

                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {

                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent,
                            );
                          });

                          return ListView.builder(
                            controller:
                                _scrollController, // Attach the ScrollController

                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return MessageCard(
                                  message: _list[index],
                                  prevMsg: _list[index],
                                  isLastMsgFromIdSame: _list[index].fromId ==
                                      _list[index].fromId,
                                );
                              }

                              return MessageCard(
                                  message: _list[index],
                                  prevMsg: _list[index - 1],
                                  isLastMsgFromIdSame: _list[index].fromId ==
                                      _list[index - 1].fromId);
                            },
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: const BouncingScrollPhysics(),
                          );
                        } else {
                          return const Center(
                              child: Text(
                            "Say Hi! 👋",
                            style: TextStyle(fontSize: 24),
                          ));
                        }
                    }
                  }),
            ),
            _chatInputField()
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: InkWell(
        onTap: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                imageUrl: widget.user.image,
                // placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    const CircleAvatar(child: Icon(CupertinoIcons.person)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  const Text(
                    "Last seen not available",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _chatInputField() {
    _textController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Colors.black)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.camera_alt)),
                    Expanded(
                        child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                          hintText: 'Type message', border: InputBorder.none),
                    )),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.image)),
                  ],
                ),
              ),
            ),
          ),
          MaterialButton(
            clipBehavior: Clip.hardEdge,
            onPressed: () {
              if (_textController.text.trim().isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text.trim());
                _textController.text = '';
              }
            },
            shape: const CircleBorder(),
            color: Colors.black,
            minWidth: 47,
            height: 50,
            padding:
                const EdgeInsets.only(left: 8, top: 10, right: 5, bottom: 10),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
