import 'package:flutter/material.dart';

class Loader{

 showLoader(BuildContext context){
    AlertDialog alert=AlertDialog(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      content: Center(
        child: Image.asset(
          'assets/loader.gif',
          width:80,// Put your gif into the assets folder
        ),
      ),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }
}