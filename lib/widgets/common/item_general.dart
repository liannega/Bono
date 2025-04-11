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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: itemColor.withOpacity(0.3),
          highlightColor: itemColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: Row(
              children: [
                // Círculo con icono (con o sin Hero animation)
                _buildIconCircle(itemColor),

                const SizedBox(width: 16),

                // Contenido de texto (título y subtítulo)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
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

                // Flecha a la derecha (opcional)
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

  /// Construye el círculo con el icono, con o sin animación Hero
  Widget _buildIconCircle(Color itemColor) {
    final circleAvatar = CircleAvatar(
      radius: 30,
      backgroundColor: itemColor,
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
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
