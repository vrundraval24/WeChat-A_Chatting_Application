import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg, Color clr) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: clr,
      ),
    );
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
