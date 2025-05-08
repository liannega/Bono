//TODO arrelaste el el item general y el home page acuardate de darselo a V0

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget general reutilizable para mostrar ítems en toda la aplicación
/// Puede ser usado en menús, listas, submenús, etc.
class ItemGeneral extends StatelessWidget {
  /// Icono a mostrar en el ítem
  final IconData icon;

  /// Título principal del ítem
  final String title;

  /// Subtítulo opcional del ítem
  final String? subtitle;

  /// Color del ítem (círculo del icono)
  /// Si no se proporciona, se usa azul por defecto
  final Color? color;

  /// Indica si se debe mostrar una flecha a la derecha
  final bool showChevron;

  /// Función que se ejecuta al tocar el ítem
  final VoidCallback onTap;

  /// Tag para animación Hero (opcional)
  final String? heroTag;

  const ItemGeneral({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.showChevron = false,
    required this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? Colors.blue;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: itemColor.withOpacity(0.2),
          highlightColor: itemColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                // Círculo con icono (con o sin Hero animation)
                _buildIconCircle(itemColor, isLightMode),

                const SizedBox(width: 12),

                // Contenido de texto (título y subtítulo)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          letterSpacing: -0.3,
                          height: 1.1,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Text(
                            subtitle!,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey,
                              letterSpacing: -0.2,
                              height: 1.1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Flecha a la derecha (opcional)
                if (showChevron)
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.blue,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el círculo con el icono, con o sin animación Hero
  Widget _buildIconCircle(Color itemColor, bool isLightMode) {
    final circleAvatar = Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: itemColor,
        shape: BoxShape.circle,
        boxShadow: isLightMode
            ? [
                BoxShadow(
                  color: itemColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 25,
      ),
    );

    // Si hay un heroTag, envolver en Hero para animación
    if (heroTag != null) {
      // Normalizar el heroTag para asegurar consistencia
      // Usar el título directamente para que sea consistente en toda la navegación
      final normalizedTag = heroTag!.contains('menu_icon_')
          ? heroTag!
          : 'menu_icon_${title.replaceAll(" ", "_")}';

      return Hero(
        tag: normalizedTag,
        child: circleAvatar,
      );
    }

    return circleAvatar;
  }
}
