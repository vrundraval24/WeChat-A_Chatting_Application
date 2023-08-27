

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

class MyDateUtil {

  static String getFormattedDateTime({required BuildContext context, required String time}) {

    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    // if(now.day == sent.day && now.month == sent.month && now.year == sent.year){
    //   return TimeOfDay.fromDateTime(sent).format(context);
    //
    //   // return 'Tue 22/08/23\n10:42 PM';
    //
    // }else{
    //   // final formattedDate = DateFormat('E  d/MM/yy').format(sent);
    //   final formattedTime = TimeOfDay.fromDateTime(sent).format(context);
    //
    //   // return '$formattedDate\n$formattedTime';
    //   return formattedTime;
    // }

    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);
    return formattedTime;

  }


  static String getFormattedDateTimeForChatUserCard({required BuildContext context, required String time}) {

    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if(now.day == sent.day && now.month == sent.month && now.year == sent.year){
      // if it is today
      final formattedTime = TimeOfDay.fromDateTime(sent).format(context);
      return formattedTime;

    } else if (now.day - 1 == sent.day && now.month == sent.month && now.year == sent.year){
      return 'Yesterday';

    }
    else if (now.day > sent.day &&  sent.day > (now.day - 7) && now.month == sent.month && now.year == sent.year){
      final formattedDate = DateFormat('EEEE').format(sent);
      return formattedDate;
    }
    else{
      final formattedDate = DateFormat('MMM d, y').format(sent);
      return formattedDate;
    }
  }



  static String getDay({required BuildContext context, required String time}) {

    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if(now.day == sent.day && now.month == sent.month && now.year == sent.year){
      return 'Today';

      // return 'Tue 22/08/23\n10:42 PM';
      // return 'Tue 22/08/23';

    } else if (now.day - 1 == sent.day && now.month == sent.month && now.year == sent.year){
      return 'Yesterday';

    }
    else if (now.day > sent.day &&  sent.day > (now.day - 7) && now.month == sent.month && now.year == sent.year){
      final formattedDate = DateFormat('EEEE').format(sent);
      return formattedDate;
    }
    else{
      final formattedDate = DateFormat('MMM d, y').format(sent);
      return formattedDate;
    }

  }

  static bool checkSameDay({required BuildContext context, required String prevTime, required String time}){
    final DateTime prevSent = DateTime.fromMillisecondsSinceEpoch(int.parse(prevTime));
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    if(prevSent.day == sent.day && prevSent.month == sent.month && prevSent.year == sent.year){
      return true;
    }else{
      return false;
    }
  }

}
