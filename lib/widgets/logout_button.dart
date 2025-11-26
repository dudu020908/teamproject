import 'package:flutter/material.dart';
import 'package:teamproject/service/local_storage_service.dart';

class LogoutButton extends StatelessWidget {
  final Color? color;

  const LogoutButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = color ?? scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      label: '로그아웃하고 사용자 정보를 초기화',
      child: IconButton(
        tooltip: '로그아웃',
      icon: Icon(Icons.logout, size: 28, color: iconColor),
      onPressed: () async {
        await LocalStorageService.clearUserInfo();
        Navigator.pushReplacementNamed(context, '/userinfo');
      },
      ),
    );
  }
}
