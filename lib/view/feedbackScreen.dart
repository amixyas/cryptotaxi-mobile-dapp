import 'dart:ui';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cryptotaxi/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_context/one_context.dart';

import '../main.dart';

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({Key? key}) : super(key: key);

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  String feedbacktype = "Other";
  TextEditingController feedback = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Feedback"),
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Leave feedback',style: GoogleFonts.robotoCondensed(fontSize: 40,color: textcolor,fontWeight: FontWeight.bold),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text("Select feedback type:",style: TextStyle(fontWeight: FontWeight.bold,color:textcolor),)),
                        Expanded(
                          child: SizedBox(width: 100,
                            child: DropdownButton(style: TextStyle(fontSize: 14,color: textcolor),isExpanded: true,
                              value: feedbacktype,
                              onChanged: (value) {
                                setState(() {
                                  feedbacktype = value.toString();
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  child: Text("Payment Problem",style: TextStyle(fontSize: 12),),
                                  value: "Payment Problem",
                                ),
                                DropdownMenuItem(
                                  child: Text("Trip Feedback",style: TextStyle(fontSize: 12),),
                                  value: "Trip Feedback",
                                ),
                                DropdownMenuItem(
                                  child: Text("Application Feedback",style: TextStyle(fontSize: 12),),
                                  value: "Application Feedback",
                                ),
                                DropdownMenuItem(
                                  child: Text("Other",style: TextStyle(fontSize: 12),),
                                  value: "Other",
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight:
                                OneContext().mediaQuery.size.height * 0.6),
                        child: TextField(
                          controller: feedback,
                          maxLines: null,
                          minLines: 4,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: "Write the description",
                              hintStyle: TextStyle(color: textcolor)),
                        ),
                      ),
                    ),
                    Text('NOTE: You can add pictures and screenshots in the email application.',style: GoogleFonts.robotoCondensed(fontSize: 14,color: textcolor,fontWeight: FontWeight.bold),),
                    BouncingWidget(
                      duration: Duration(milliseconds: 300),
                      scaleFactor: 2,
                      onPressed: () async {
                        if (feedback.text.isEmpty){    Get.rawSnackbar(
                            message: "Description can not be empty",
                            borderRadius: 20,
                            margin: EdgeInsets.all(5),
                            backgroundColor: Colors.red); return;}else {
                          await Future.delayed(Duration(milliseconds: 300));
                          final Email email = Email(
                            body: feedback.text.trim(),
                            subject: 'FeedBack from ${AuthController.controller.auth!.currentUser!.uid} type : $feedbacktype',
                            recipients: ['k.alilahmar@esi-sba.dz','ilyas.amirat@gmail.com'],
                            isHTML: false,
                          );

                          await FlutterEmailSender.send(email);
                        }
                      },
                      child: Material(
                          color: Colors.green.shade400,
                          elevation: 10,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Submit feedback",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  FontAwesomeIcons.solidPaperPlane,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
