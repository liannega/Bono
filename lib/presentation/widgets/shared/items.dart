import 'package:flutter/material.dart';

class MenuItems {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? ussdCode;
  final bool hasSubmenu;
  final List<MenuItems>? submenuItems; // Para elementos con submenú

  const MenuItems({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.ussdCode,
    this.hasSubmenu = false,
    this.submenuItems,
  });
}

// Lista de elementos para la vista principal
const List<MenuItems> menuItems = [
  MenuItems(
    title: "Consulta tu saldo y planes contratados",
    subtitle: "Consulta tu saldo y planes contratados, todo a la vez",
    icon: Icons.attach_money,
    color: Colors.blue,
    ussdCode: "*222#", // Código USSD para consultar saldo
  ),
  MenuItems(
    title: "Consultar bono",
    subtitle: "Consulta el estado de tu bono",
    icon: Icons.star,
    color: Colors.blue,
    ussdCode: "*222*266#", // Código USSD para consultar bono
  ),
  MenuItems(
    title: "Gestionar Llamadas",
    subtitle: "Realiza llamadas de manera fácil",
    icon: Icons.call,
    color: Colors.blue,
    hasSubmenu: true,
    submenuItems: [
      MenuItems(
        title: "Llamada normal",
        icon: Icons.call,
        color: Colors.blue,
        // No tiene código USSD, abrirá el marcador
      ),
      MenuItems(
        title: "Llamada con pago revertido",
        icon: Icons.call,
        color: Colors.blue,
        ussdCode: "*99#",
      ),
    ],
  ),
  MenuItems(
    title: "Gestionar Saldo",
    subtitle: "Gestiona el saldo de tu línea",
    icon: Icons.attach_money,
    color: Colors.blue,
    hasSubmenu: true,
    submenuItems: [
      MenuItems(
        title: "Consultar saldo",
        icon: Icons.account_balance_wallet,
        color: Colors.blue,
        ussdCode: "*222#",
      ),
      MenuItems(
        title: "Recargar",
        icon: Icons.add_card,
        color: Colors.blue,
        // Aquí se abrirá un diálogo para ingresar el código de recarga
      ),
      MenuItems(
        title: "Transferir saldo",
        icon: Icons.send_to_mobile,
        color: Colors.blue,
        // Aquí se abrirá un diálogo para transferir saldo
      ),
    ],
  ),
  MenuItems(
    title: "Gestionar Planes",
    subtitle: "Planes de Datos, Voz, SMS, y Amigo",
    icon: Icons.shopping_cart,
    color: Colors.blue,
    hasSubmenu: true,
    submenuItems: [
      MenuItems(
        title: "Planes de datos",
        icon: Icons.data_usage,
        color: Colors.blue,
        ussdCode: "*133*5*3#", // Código para planes de datos
      ),
      MenuItems(
        title: "Planes de voz",
        icon: Icons.phone_in_talk,
        color: Colors.blue,
        ussdCode: "*133*1#", // Código para planes de voz
      ),
      MenuItems(
        title: "Planes de SMS",
        icon: Icons.sms,
        color: Colors.blue,
        ussdCode: "*133*2#", // Código para planes de SMS
      ),
      MenuItems(
        title: "Planes Amigo",
        icon: Icons.people,
        color: Colors.blue,
        ussdCode: "*133*3#", // Código para planes Amigo
      ),
    ],
  ),
  MenuItems(
    title: "Línea corporativa",
    subtitle: "Consulta el estado tu plan corporativo",
    icon: Icons.attach_money,
    color: Colors.blue,
    ussdCode: "*222*3#", // Código para consultar línea corporativa
  ),
];

// Lista de elementos para la vista de historial (similar a la anterior)
const List<MenuItems> historyItems = [
  MenuItems(
    title: "Gestionar Llamadas",
    subtitle: "Realiza llamadas de manera fácil",
    icon: Icons.call,
    color: Colors.blue,
    hasSubmenu: true,
  ),
  MenuItems(
    title: "Asterisco 99",
    subtitle: "Llamada con pago revertido",
    icon: Icons.call,
    color: Colors.blue,
    ussdCode: "*99#",
  ),
  MenuItems(
    title: "Planes Combinados",
    subtitle: "Gestiona tu plan combinado de Datos+Voz+SMS",
    icon: Icons.sync,
    color: Colors.blue,
    hasSubmenu: true,
  ),
  MenuItems(
    title: "3.5 GB + 4.5 GB solo LTE - \$500 CUP",
    subtitle: "+ 75min VOZ + 80 SMS + 300 MB .cu",
    icon: Icons.sync,
    color: Colors.blue,
    ussdCode: '*133*5*3#',
  ),
  MenuItems(
    title: "Gestionar Planes",
    subtitle: "Planes de Datos, Voz, SMS, y Amigo",
    icon: Icons.shopping_cart,
    color: Colors.blue,
    hasSubmenu: true,
  ),
  MenuItems(
    title: "Gestionar Saldo",
    subtitle: "Gestiona el saldo de tu línea",
    icon: Icons.attach_money,
    color: Colors.blue,
    hasSubmenu: true,
  ),
  MenuItems(
    title: "Recargar",
    subtitle: "Recarga tu línea fácilmente",
    icon: Icons.attach_money,
    color: Colors.blue,
  ),
  MenuItems(
    title: "Activar",
    subtitle: "Activa el plan",
    icon: Icons.check_circle,
    color: Colors.blue,
  ),
];
