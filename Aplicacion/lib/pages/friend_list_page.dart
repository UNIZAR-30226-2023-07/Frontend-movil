import 'package:flutter/material.dart';
import '../dialogs/add_friend_dialog.dart';
import '../services/open_dialog.dart';
import '../widgets/circular_border_picture.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircularBorderPicture(),
            title: Row(
              children: const [
                Text(
                  'Amigo falso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            subtitle: Text('perro'),
            trailing: Badge(
              label: Text('1'),
            ),
            onTap: () {},
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        tooltip: 'Añadir amigo',
        onPressed: () {
          openDialog(context, const AddFriendDialog());
        },
        child: const Icon(Icons.add_rounded, size: 30, color: Colors.white,),
      ),
    );
  }
}