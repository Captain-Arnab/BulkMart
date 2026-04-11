import 'package:flutter/material.dart';

class AppSearchBarWidget extends StatelessWidget implements PreferredSizeWidget {

  final String currentCity;

  const AppSearchBarWidget({super.key, required this.currentCity});

  @override
  Size get preferredSize => const Size.fromHeight(170);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 40,),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,color: Colors.white,size: 20,fill: 0.1,),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Text('Location',style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white,fontSize: 14,fontWeight: FontWeight.w100),),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:20,right:20.0),
                    child: Icon(Icons.notifications,color: Colors.white),
                  ),
                ],
              ),
            ),
            Text(currentCity.toUpperCase(),style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20,top: 15),
              child: SizedBox(
                height: 50,
                child: TextField(
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14),
                  onChanged: (value) {
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(Icons.search,size:20,color: Theme.of(context).primaryColor,),
                    hintText: 'Search your products',
                    hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14,color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}