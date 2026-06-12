import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/userProfile/domain/address_controller.dart';
import 'package:urban_roots/features/userProfile/presentation/widgets/AddressFormWidget.dart';

class AddressListWidget extends StatelessWidget {
  const AddressListWidget({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    AddressController controller,
    String addressId,
  ) async {
    await SweetAlert.confirm(
      context,
      title: 'Delete Address?',
      message: 'This address will be removed from your account.',
      confirmText: 'Delete',
      onConfirm: () async {
        final ok = await controller.deleteAddress(addressId);
        if (!ok && context.mounted) {
          await SweetAlert.error(
            context,
            message: controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'Could not delete address',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.findOrPut();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF019934)),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved Addresses',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddressFormWidget(
                      onSave: (address) => controller.saveAddress(address),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          if (controller.errorMessage.value.isNotEmpty &&
              controller.addresses.isEmpty)
            ApiStateView(
              status: ApiViewStatus.error,
              errorMessage: controller.errorMessage.value,
              onRetry: controller.loadAddresses,
              child: const SizedBox(),
            )
          else if (controller.addresses.isEmpty)
            ApiStateView(
              status: ApiViewStatus.empty,
              emptyMessage: 'No addresses saved yet',
              child: const SizedBox(),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.addresses.length,
              itemBuilder: (context, index) {
                final address = controller.addresses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: address.isDefault
                        ? Border.all(color: const Color(0xFF019934), width: 1.5)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF019934).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              address.category,
                              style: GoogleFonts.rubik(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF019934),
                              ),
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Default',
                              style: GoogleFonts.rubik(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddressFormWidget(
                                  address: address,
                                  onSave: (updated) =>
                                      controller.saveAddress(updated),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                size: 20, color: Colors.red.shade400),
                            onPressed: () => _confirmDelete(
                              context,
                              controller,
                              address.id,
                            ),
                          ),
                        ],
                      ),
                      if (address.fullName.isNotEmpty)
                        Text(
                          address.fullName,
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (address.phone.isNotEmpty)
                        Text(
                          address.phone,
                          style: GoogleFonts.rubik(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        address.addressLine1,
                        style: GoogleFonts.rubik(fontSize: 13),
                      ),
                      if (address.addressLine2 != null &&
                          address.addressLine2!.isNotEmpty)
                        Text(
                          address.addressLine2!,
                          style: GoogleFonts.rubik(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      Text(
                        '${address.city}, ${address.state} - ${address.pincode}',
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (!address.isDefault && address.id.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                controller.setDefault(address.id),
                            child: const Text('Set as default'),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    });
  }
}
