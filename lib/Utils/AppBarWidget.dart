import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
        color: Theme.of(context).primaryColor,
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top:35.0,left: 20),
              child: SizedBox(
                  width:60,
                  child: Image(
                      image: AssetImage("assets/logo.png"),fit: BoxFit.cover,)),
            )
          ],
        ),
    );
  }
}