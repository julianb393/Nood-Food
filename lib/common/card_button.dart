import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final void Function() onTap;
  final Color? color;
  const CardButton(
      {super.key,
      required this.title,
      this.icon,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          title: Text(title),
          leading: icon == null ? null : Icon(icon),
        ),
      ),
    );
  }
}
