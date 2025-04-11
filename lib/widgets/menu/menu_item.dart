import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bono/widgets/shared/items.dart';

/// Widget para mostrar un elemento de menú en forma de tarjeta
class MenuItemCard extends StatelessWidget {
  final MenuItems item;
  final String? heroTag;
  final VoidCallback onTap;
  final bool showChevron;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.heroTag,
    required this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: item.color.withOpacity(0.3),
          highlightColor: item.color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: Row(
              children: [
                // Envolver el CircleAvatar en un Hero para la animación
                heroTag != null
                    ? Hero(
                        tag: heroTag!,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            item.icon,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          item.icon,
                          color: Colors.white,
                          size: 30,
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
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      if (item.subtitle != null)
                        Text(
                          item.subtitle!,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey,
                            letterSpacing: -0.3,
                            height: 1.1,
                          ),
                        ),
                    ],
                  ),
                ),
                // Flecha a la derecha para elementos con submenú o navegación adicional
                if (showChevron)
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
  }
}
