import 'package:flutter/material.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';
import 'package:urban_roots/features/userProfile/presentation/widgets/AddressFormWidget.dart';


class AddressListWidget extends StatefulWidget {
  @override
  _AddressListWidgetState createState() => _AddressListWidgetState();
}

class _AddressListWidgetState extends State<AddressListWidget> {
  List<Address> addresses = [];

  void addAddress(Address address) {
    setState(() {
      addresses.add(address);
    });
  }

  void editAddress(int index, Address updatedAddress) {
    setState(() {
      addresses[index] = updatedAddress;
    });
  }

  void removeAddress(int index) {
    setState(() {
      addresses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Addresses',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddressFormWidget(
                    onSave: addAddress,
                  ),
                );
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true, // Adjust height based on the number of items
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${addresses[index].addressLine1} (${addresses[index].category})'),
              subtitle: Text('Instructions: ${addresses[index].deliveryInstructions != null ? "None" : addresses[index].deliveryInstructions}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddressFormWidget(
                          address: addresses[index],
                          onSave: (updatedAddress) => editAddress(index, updatedAddress),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeAddress(index),
                  ),
                ],
              ),
            );
          },
        ),

      ],
    );
  }
}