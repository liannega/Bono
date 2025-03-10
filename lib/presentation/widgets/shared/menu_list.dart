// menu_list.dart
import 'package:bono/presentation/widgets/shared/items.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class MenuList extends StatelessWidget {
  final List<MenuItems> items;
  final Function(BuildContext, MenuItems) onItemTap;

  const MenuList({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: GestureDetector(
            onTap: () => onItemTap(context, item),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: item.color,
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      if (item.subtitle != null)
                        Text(
                          item.subtitle!,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                if (item.hasSubmenu)
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.blue,
                    size: 30,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
