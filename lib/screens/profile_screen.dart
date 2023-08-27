import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat_app/api/api.dart';
import 'package:we_chat_app/models/chat_user.dart';
import 'package:we_chat_app/screens/auth/login_screen.dart';

import '../helper/dialogs.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Profile Screen'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // For hiding progress bar
                  Navigator.pop(context);

                  // For moving to home screen (popping out profile screen)
                  Navigator.pop(context);

                  // Jumping to login screen from home screen
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });
            },
            backgroundColor: Colors.redAccent,
            icon: const Icon(Icons.logout),
            label: const Text(
              'Log out',
              style: TextStyle(fontSize: 16),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .10),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: mq.height * .05),
                      child: Stack(children: [
                        _image != null

                            // Local image
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(
                                  File(_image!),
                                  fit: BoxFit.cover,
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                ),
                              )

                            // Image from server
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  imageUrl: widget.user.image,
                                  // placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 0,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            minWidth: 45,
                            height: 45,
                            color: Colors.black,
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ]),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: mq.height * .02),
                      child: Text(
                        widget.user.email,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),

                    // Name input field
                    Padding(
                      padding: EdgeInsets.only(top: mq.height * .05),
                      child: TextFormField(
                        onSaved: (val) => APIs.me.name = val ?? '',
                        validator: (val) => val != null && val.isNotEmpty
                            ? null
                            : 'Required field',
                        initialValue: widget.user.name,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.person),
                            hintText: "Enter your name",
                            labelText: 'Name'),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: mq.height * .02),
                      child: TextFormField(
                        onSaved: (val) => APIs.me.about = val ?? '',
                        validator: (val) => val != null && val.isNotEmpty
                            ? null
                            : 'Required field',
                        initialValue: widget.user.about,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.info_outline),
                            hintText: "eg. Feeling happy!",
                            labelText: 'About'),
                      ),
                    ),

                    // Update button
                    Padding(
                      padding: EdgeInsets.only(top: mq.height * .05),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: const StadiumBorder(),
                            minimumSize:
                                Size(mq.width * .35, mq.height * .055)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // log('inside validator');
                            _formKey.currentState!.save();
                            APIs.updateUserInfo().then((value) {
                              Dialogs.showSnackbar(
                                  context,
                                  "Profile updated successfully.",
                                  Colors.green);
                            });
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text(
                          'Update',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  // Show bottom sheet for selecting profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(21), topRight: Radius.circular(21))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .07),
            children: [
              const Text(
                'Edit profile picture',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: mq.height * .05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          // shape: const CircleBorder(),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(21))),
                          fixedSize: Size(mq.height * .1, mq.height * .1)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePic(File(_image!));

                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/icons/gallery.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          // shape: const CircleBorder(),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(21))),
                          fixedSize: Size(mq.height * .1, mq.height * .1)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera, imageQuality: 80);

                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePic(File(_image!));


                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/icons/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
