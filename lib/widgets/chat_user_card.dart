import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat_app/api/api.dart';
import 'package:we_chat_app/helper/my_date_util.dart';
import 'package:we_chat_app/models/message.dart';

import '../main.dart';
import '../models/chat_user.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // Last message info (if null then it means no message is available)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          // Navigating to chat screen
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChatScreen(
                        user: widget.user,
                      )));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;

            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

            if (list.isNotEmpty) {
              _message = list[0];
            }

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
              title: Text(
                widget.user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
              subtitle: Text(
                _message != null ? _message!.msg : widget.user.about,
                maxLines: 1,
              ),
              trailing: _message == null
                  ? null
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                      ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            MyDateUtil.getFormattedDateTimeForChatUserCard(
                                context: context, time: _message!.sent),
                            style: const TextStyle(color: Colors.redAccent, fontSize: 10),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                        ],
                      )
                      : Text(
                          MyDateUtil.getFormattedDateTimeForChatUserCard(
                              context: context, time: _message!.sent),
                          style: const TextStyle(color: Colors.black54, fontSize: 10),
                        ),
            );
          },
        ));
  }
}
