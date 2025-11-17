import 'package:flutter/material.dart';
import 'package:teamproject/service/local_storage_service.dart';

class LogoutButton extends StatelessWidget {
  final Color? color;

  const LogoutButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor =
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.black87);

    return Positioned(
      top: 16,
      left: 16, 
      child: IconButton(
        icon: Icon(Icons.logout, size: 28, color: iconColor),
        onPressed: () async {
          await LocalStorageService.clearUserInfo();
          Navigator.pushReplacementNamed(context, '/userinfo');
        },
      ),
    );
  }
}
