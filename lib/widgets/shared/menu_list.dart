import 'package:bono/widgets/shared/items.dart';
import 'package:bono/widgets/shared/submenu.dart';
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
        // Crear un tag único para cada elemento
        final heroTag = 'menu_icon_${item.title.replaceAll(" ", "_")}';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () => _handleItemTap(context, item, heroTag),
              borderRadius: BorderRadius.circular(12),
              splashColor: item.color.withOpacity(0.3),
              highlightColor: item.color.withOpacity(0.1),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: Row(
                  children: [
                    // Envolver el CircleAvatar en un Hero para la animación
                    Hero(
                      tag: heroTag,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: item.color,
                        child: Icon(
                          item.icon,
                          color: Colors.white,
                          size: 30,
                        ),
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
            ),
          ),
        );
      },
    );
  }

  void _handleItemTap(BuildContext context, MenuItems item, String heroTag) {
    if (item.hasSubmenu && item.submenuItems != null) {
      // Navegar al submenú con el heroTag y el icono del elemento padre
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubmenuPage(
            title: item.title,
            items: item.submenuItems!,
            parentHeroTag: heroTag,
            parentIcon: item.icon, // Pasar el icono del elemento padre
            parentColor: item.color, // Pasar el color del elemento padre
          ),
        ),
      );
    } else {
      // Llamar a la función onItemTap para manejar otros casos
      onItemTap(context, item);
    }
  }
}
