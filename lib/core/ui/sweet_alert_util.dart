import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

/// SweetAlert-style dialogs for the entire app (via QuickAlert).
/// Use this instead of SnackBar, Toast, or raw AlertDialog for user messages.
class SweetAlert {
  SweetAlert._();

  static const _confirmColor = Color(0xFF019934);

  static Future<void> success(
    BuildContext context, {
    String title = 'Success',
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
    bool barrierDismissible = false,
  }) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: title,
      text: message,
      confirmBtnText: confirmText,
      confirmBtnColor: _confirmColor,
      barrierDismissible: barrierDismissible,
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        onConfirm?.call();
      },
    );
  }

  static Future<void> error(
    BuildContext context, {
    String title = 'Error',
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: title,
      text: message,
      confirmBtnText: confirmText,
      confirmBtnColor: Colors.red.shade400,
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        onConfirm?.call();
      },
    );
  }

  static Future<void> warning(
    BuildContext context, {
    String title = 'Warning',
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: title,
      text: message,
      confirmBtnText: confirmText,
      confirmBtnColor: _confirmColor,
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        onConfirm?.call();
      },
    );
  }

  static Future<void> info(
    BuildContext context, {
    String title = 'Info',
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: title,
      text: message,
      confirmBtnText: confirmText,
      confirmBtnColor: _confirmColor,
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        onConfirm?.call();
      },
    );
  }

  static Future<void> confirm(
    BuildContext context, {
    String title = 'Are you sure?',
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
  }) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: title,
      text: message,
      confirmBtnText: confirmText,
      cancelBtnText: cancelText,
      showCancelBtn: true,
      confirmBtnColor: _confirmColor,
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        onConfirm();
      },
      onCancelBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }
}

/// Back-compat alias used by API screens.
void showApiSnackBar(BuildContext context, String message, {bool isError = false}) {
  if (isError) {
    SweetAlert.error(context, message: message);
  } else {
    SweetAlert.success(context, message: message);
  }
}
