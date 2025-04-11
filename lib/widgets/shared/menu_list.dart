import 'package:bono/widgets/common/item_general.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:bono/widgets/shared/submenu.dart';
import 'package:flutter/material.dart';

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
        // Crear un tag único y consistente para cada elemento
        final heroTag = 'menu_icon_${item.title.replaceAll(" ", "_")}';

        return ItemGeneral(
          icon: item.icon,
          title: item.title,
          subtitle: item.subtitle,
          color: item.color,
          showChevron: item.hasSubmenu,
          heroTag: heroTag,
          onTap: () => _handleItemTap(context, item, heroTag),
        );
      },
    );
  }

  // Modificar el método _handleItemTap para asegurar que los tags de Hero sean consistentes
  void _handleItemTap(BuildContext context, MenuItems item, String heroTag) {
    if (item.hasSubmenu && item.submenuItems != null) {
      // Crear un tag consistente para el Hero basado en el título del elemento
      final consistentHeroTag = 'menu_icon_${item.title.replaceAll(" ", "_")}';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubmenuPage(
            title: item.title,
            items: item.submenuItems!,
            parentHeroTag: consistentHeroTag,
            parentIcon: item.icon,
            parentColor: item.color,
          ),
        ),
      );
    } else {
      // Llamar a la función onItemTap para manejar otros casos
      onItemTap(context, item);
    }
  }
}
