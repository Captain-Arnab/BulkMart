import 'package:flutter/material.dart';
import 'package:urban_roots/Utils/AppBarWidget.dart';


class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.of(context).size;
    var cellHeight = 50.0;
    var cellWidth = screenSize.width - 40;


    return Scaffold(
        appBar: const AppBarWidget(),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // -- IMAGE with ICON
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const Image(image: AssetImage("assets/logo.png"))),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white),
                        child: const Icon(Icons.edit, color: Colors.black, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // -- Form Fields
                Form(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.person),
                          ),
                          Text("Arnab Som",style: Theme.of(context).textTheme.titleLarge,textAlign: TextAlign.start,),
                          const IconButton(onPressed: null, icon: Icon(Icons.edit, color: Colors.black, size: 20))
                        ],
                      ),
                      const SizedBox(height:10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.email),
                          ),
                          Text("test@gmail.com",style: Theme.of(context).textTheme.titleLarge,textAlign: TextAlign.start,),
                          const IconButton(onPressed: null, icon: Icon(Icons.edit, color: Colors.black, size: 20))
                        ],
                      ),
                      const SizedBox(height:10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.phone),
                          ),
                          Text("+91 9738550132",style: Theme.of(context).textTheme.titleLarge,textAlign: TextAlign.start,),
                          const IconButton(onPressed: null, icon: Icon(Icons.edit, color: Colors.black, size: 20))
                        ],
                      ),
                      const SizedBox(height:10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.fingerprint),
                          ),
                          Text("*****",style: Theme.of(context).textTheme.titleLarge,textAlign: TextAlign.start,),
                          const IconButton(onPressed: null, icon: Icon(Icons.edit, color: Colors.black, size: 20))
                        ],
                      ),
                      const SizedBox(height: 40),
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