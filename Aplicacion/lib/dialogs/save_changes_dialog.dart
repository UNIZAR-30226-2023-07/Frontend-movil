import 'package:flutter/material.dart';
import '../services/open_snack_bar.dart';

class SaveChangesDialog extends StatelessWidget {
  const SaveChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Guardar cambios?'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            openSnackBar(context, const Text('Cambios guardados'));
          },
          child: const Text('Sí'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('No'),
        ),
      ],
    );
  }
}