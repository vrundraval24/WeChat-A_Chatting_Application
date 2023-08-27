import 'package:flutter/material.dart';
import 'package:we_chat_app/api/api.dart';
import 'package:we_chat_app/helper/my_date_util.dart';

import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message, required this.prevMsg, required this.isLastMsgFromIdSame});

  final Message message, prevMsg;
  final bool isLastMsgFromIdSame;


  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {


  @override
  Widget build(BuildContext context) {



    return widget.message.fromId == APIs.user.uid
        ? _whiteMessageWithDateTitle()
        : _blackMessageWithDateTitle();
  }

  // Our(Receiver) message
  Widget _whiteMessageWithDateTitle() {
    final bool dateTitle = !MyDateUtil.checkSameDay(
            context: context,
            prevTime: widget.prevMsg.sent,
            time: widget.message.sent) ||
        widget.prevMsg.sent == widget.message.sent;

    return Column(
      children: [
        // Date tile
        Visibility(
          visible: dateTitle,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: mq.height * 0.03, horizontal: mq.width * 0.07),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Divider(
                    color: Colors.black45,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
                  child: Text(
                    MyDateUtil.getDay(
                        context: context, time: widget.message.sent),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black45),
                  ),
                ),
                const Expanded(
                  child: Divider(
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),

        Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 34.0, top: !widget.isLastMsgFromIdSame && !dateTitle ? 9 : 0),
                  child: Text(
                      MyDateUtil.getFormattedDateTime(
                          context: context, time: widget.message.sent),
                      style:
                          const TextStyle(color: Colors.black26, fontSize: 10)),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 7, bottom: 7, right: 24, left: 10),
                    margin: EdgeInsets.only(top: !widget.isLastMsgFromIdSame && !dateTitle ? 10 : 1, bottom: 1, left: 13, right: 13),
                    decoration: BoxDecoration(
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.2), // Shadow color
                        //     spreadRadius: 1, // Spread radius
                        //     blurRadius: 3, // Blur radius
                        //     offset: const Offset(1, 3), // Offset in x and y direction
                        //   ),
                        // ],
                        border: Border.all(
                          color: Colors.black, // Border color
                        ),
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12))),
                    child: Text(widget.message.msg,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 5,
              right: 18,

              // double tick icon
              child: widget.message.read.isNotEmpty
                  ? const Icon(
                      Icons.done_all_rounded,
                      size: 16,
                      color: Colors.green,
                    )
                  : const Icon(
                      Icons.done_rounded,
                      size: 16,
                      color: Colors.black26,
                    ),
            )
          ],
        ),
      ],
    );
  }

  // Other(Sender) message
  Widget _blackMessageWithDateTitle() {
    final bool dateTitle = !MyDateUtil.checkSameDay(
            context: context,
            prevTime: widget.prevMsg.sent,
            time: widget.message.sent) ||
        widget.prevMsg.sent == widget.message.sent;

    // Update read status if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      // log("READ STATUS UPDATED!!!");
    }

    return Column(
      children: [
        // Date tile
        Visibility(
          visible: dateTitle,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: mq.height * 0.03, horizontal: mq.width * 0.07),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Divider(
                    color: Colors.black45,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
                  child: Text(
                    MyDateUtil.getDay(
                        context: context, time: widget.message.sent),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black45),
                  ),
                ),
                const Expanded(
                  child: Divider(
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),

        Row(
          children: [
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                margin: EdgeInsets.only(bottom: 1, top: !widget.isLastMsgFromIdSame && !dateTitle ? 10 : 1, left: 13, right: 13),
                decoration: BoxDecoration(

                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.2), // Shadow color
                    //     spreadRadius: 1, // Spread radius
                    //     blurRadius: 3, // Blur radius
                    //     offset: const Offset(-1, 3), // Offset in x and y direction
                    //   ),
                    // ],

                    border: Border.all(
                      color: Colors.black, // Border color
                    ),
                    color: Colors.black,
                    borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12))),
                child: Text(widget.message.msg,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 34.0, top: !widget.isLastMsgFromIdSame && !dateTitle ? 9 : 0),
              child: Text(
                  MyDateUtil.getFormattedDateTime(
                      context: context, time: widget.message.sent),
                  style: const TextStyle(color: Colors.black26, fontSize: 10)),
            ),
          ],
        ),
      ],
    );
  }
}
