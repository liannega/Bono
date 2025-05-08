import 'package:flutter/material.dart';

class MenuItems {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? ussdCode;
  final bool hasSubmenu;
  final List<MenuItems>? submenuItems;

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

const List<MenuItems> menuItems = [
  MenuItems(
    title: "Consulta tu saldo y planes contratados",
    subtitle: "Consulta tu saldo y planes contratados, todo a la vez",
    icon: Icons.attach_money,
    color: Colors.blue,
    ussdCode: "*222#",
  ),
  MenuItems(
    title: "Consultar bono",
    subtitle: "Consulta el estado de tu bono",
    icon: Icons.star,
    color: Colors.blue,
    ussdCode: "*222*266#",
  ),
  MenuItems(
    title: "Asterisco 99",
    subtitle: "Llamada con pago revertido",
    icon: Icons.call,
    color: Colors.blue,
    ussdCode: "*99#",
  ),
  MenuItems(
    title: "Gestionar Llamadas",
    subtitle: "Realiza llamadas de manera fácil",
    icon: Icons.call,
    color: Colors.blue,
    hasSubmenu: true,
    submenuItems: [
      MenuItems(
        title: "Asterisco 99",
        subtitle: "Llamada con pago revertido",
        icon: Icons.call,
        color: Colors.blue,
        ussdCode: "*99#",
      ),
      MenuItems(
        title: "Mi número oculto",
        subtitle: "Llama sin mostrar tu número",
        icon: Icons.call,
        color: Colors.blue,
        ussdCode: "#31#",
      ),
      MenuItems(
        title: "Números útiles",
        subtitle: "Ambulancia, Bomberos, Policía, Etc.",
        icon: Icons.call,
        color: Colors.blue,
        hasSubmenu: true,
        submenuItems: [
          MenuItems(
            title: "*2266 - Atención al cliente",
            icon: Icons.call,
            color: Colors.blue,
            ussdCode: "*2266#",
          ),
          MenuItems(
            title: "103 - Línea Antidrogas",
            icon: Icons.call,
            color: Colors.blue,
            ussdCode: "103",
          ),
          MenuItems(
            title: "104 - Ambulancias",
            icon: Icons.call,
            color: Colors.blue,
            ussdCode: "104",
          ),
          MenuItems(
            title: "105 - Bomberos",
            icon: Icons.call,
            color: Colors.blue,
            ussdCode: "105",
          ),
          MenuItems(
            title: "106 - Policía",
            icon: Icons.call,
            color: Colors.blue,
            ussdCode: "106",
          ),
          MenuItems(
            title: "107 - Salvamento Marítimo",
            icon: Icons.call,
            color: Colors.blue,
            ussdCode: "107",
          ),
          MenuItems(
            title: "118 - Cubacel Info",
            icon: Icons.call,
            color: Colors.blue,
            ussdCode: "118",
          ),
        ],
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
        title: "Transferir saldo",
        icon: Icons.send_to_mobile,
        color: Colors.orange,
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
        title: "Planes Combinados",
        subtitle: "Gestiona tu plan combinado de Datos+Voz+SMS",
        icon: Icons.sync,
        color: Colors.blue,
        hasSubmenu: true,
        submenuItems: [
          MenuItems(
            title: "Consultar saldo y planes contratados",
            subtitle: "Consulta tu saldo y planes contratados, todo a la vez",
            icon: Icons.attach_money,
            color: Colors.blue,
            ussdCode: "*222#",
          ),
          MenuItems(
            title: "600 MB + 800 MB solo LTE - \$110 CUP",
            subtitle: "+ 15min VOZ + 20 SMS + 300 MB .cu",
            icon: Icons.sync,
            color: Colors.blue,
            ussdCode: "*133*5*1#",
          ),
          MenuItems(
            title: "1.5 GB + 2 GB solo LTE - \$250 CUP",
            subtitle: "+ 35min VOZ + 40 SMS + 300 MB .cu",
            icon: Icons.sync,
            color: Colors.blue,
            ussdCode: "*133*5*2#",
          ),
          MenuItems(
            title: "3.5 GB + 4.5 GB solo LTE - \$500 CUP",
            subtitle: "+ 75min VOZ + 80 SMS + 300 MB .cu",
            icon: Icons.sync,
            color: Colors.blue,
            ussdCode: "*133*5*3#",
          ),
        ],
      ),
      MenuItems(
        title: "Planes de Datos",
        subtitle: "Gestiona tu plan de datos",
        icon: Icons.data_usage,
        color: Colors.blue,
        hasSubmenu: true,
        submenuItems: [
          MenuItems(
            title: "Megas disponibles",
            subtitle: "Consulta tus megas disponibles",
            icon: Icons.data_usage,
            color: Colors.blue,
            ussdCode: "*222*328#",
          ),
          MenuItems(
            title: "Tarifa por consumo",
            subtitle: "Consumir directo del saldo",
            icon: Icons.trending_up,
            color: Colors.blue,
            hasSubmenu: true,
            submenuItems: [
              MenuItems(
                title: "Habilitar",
                subtitle: null,
                icon: Icons.trending_up,
                color: Colors.blue,
                ussdCode: "*133*1*1#",
              ),
              MenuItems(
                title: "Deshabilitar",
                subtitle: null,
                icon: Icons.trending_up_outlined,
                color: Colors.blue,
                ussdCode: "*133*1*2#",
              ),
            ],
          ),
          MenuItems(
            title: "Bolsa Mensajería - \$25 CUP",
            subtitle: "Paquete de 600 MB sólo para toDus y correo nauta",
            icon: Icons.mail,
            color: Colors.blue,
            ussdCode: "*133*5*3*1#",
          ),
          MenuItems(
            title: "SOLO Líneas USIM con LTE (nuevas)",
            subtitle:
                "Paquetes de internet para usuarios que tienen activado el servicio LTE.",
            icon: Icons.data_usage,
            color: Colors.blue,
            hasSubmenu: true,
            submenuItems: [
              MenuItems(
                title: "Bolsa Diaria - \$25 CUP",
                subtitle: "200 MB (vence en 24h)",
                icon: Icons.data_usage,
                color: Colors.blue,
                ussdCode: "*133*5*3*2*1#",
              ),
              MenuItems(
                title: "1 GB solo LTE - \$100 CUP",
                subtitle: "+300 MB bono .cu",
                icon: Icons.data_usage,
                color: Colors.blue,
                ussdCode: "*133*5*3*2*2#",
              ),
              MenuItems(
                title: "2.5 GB solo LTE - \$200 CUP",
                subtitle: "+300 MB bono .cu",
                icon: Icons.data_usage,
                color: Colors.blue,
                ussdCode: "*133*5*3*2*3#",
              ),
              MenuItems(
                title: "4 GB + 12 GB solo LTE - \$950 CUP",
                subtitle: "+300 MB bono .cu",
                icon: Icons.data_usage,
                color: Colors.blue,
                ussdCode: "*133*5*3*2*4#",
              ),
            ],
          ),
        ],
      ),
      MenuItems(
        title: "Planes de Voz",
        subtitle: "Gestiona tu plan de voz",
        icon: Icons.phone_in_talk,
        color: Colors.blue,
        hasSubmenu: true,
        submenuItems: [
          MenuItems(
            title: "Saldo",
            subtitle: "Consulta el tiempo disponible",
            icon: Icons.phone_in_talk,
            color: Colors.blue,
            ussdCode: "*222*869#",
          ),
          MenuItems(
            title: "5 min",
            subtitle: "Plan de 5 min por \$37.5 CUP (\$7.5 por min)",
            icon: Icons.phone_in_talk,
            color: Colors.blue,
            ussdCode: "*133*3*1#",
          ),
          MenuItems(
            title: "10 min",
            subtitle: "Plan de 10 min por \$72.5 CUP (\$7.25 por min)",
            icon: Icons.phone_in_talk,
            color: Colors.blue,
            ussdCode: "*133*3*2#",
          ),
          MenuItems(
            title: "15 min",
            subtitle: "Plan de 15 min por \$105 CUP (\$7 por min)",
            icon: Icons.phone_in_talk,
            color: Colors.blue,
            ussdCode: "*133*3*3#",
          ),
          MenuItems(
            title: "25 min",
            subtitle: "Plan de 25 min por \$162.5 CUP (\$6.5 por min)",
            icon: Icons.phone_in_talk,
            color: Colors.blue,
            ussdCode: "*133*3*4#",
          ),
          MenuItems(
            title: "40 min",
            subtitle: "Plan de 40 min por \$250 CUP (\$6.25 por min)",
            icon: Icons.phone_in_talk,
            color: Colors.blue,
            ussdCode: "*133*3*5#",
          ),
        ],
      ),
      MenuItems(
        title: "Planes de SMS",
        subtitle: "Gestiona tu plan de SMS",
        icon: Icons.sms,
        color: Colors.blue,
        hasSubmenu: true,
        submenuItems: [
          MenuItems(
            title: "Saldo",
            subtitle: "Consulta los SMS disponibles",
            icon: Icons.sms,
            color: Colors.blue,
            ussdCode: "*222*767#",
          ),
          MenuItems(
            title: "20 sms",
            subtitle: "20 SMS nacionales por \$15 CUP",
            icon: Icons.sms,
            color: Colors.blue,
            ussdCode: "*133*2*1#",
          ),
          MenuItems(
            title: "50 sms",
            subtitle: "50 SMS nacionales por \$30 CUP",
            icon: Icons.sms,
            color: Colors.blue,
            ussdCode: "*133*2*2#",
          ),
          MenuItems(
            title: "90 sms",
            subtitle: "90 SMS nacionales por \$50 CUP",
            icon: Icons.sms,
            color: Colors.blue,
            ussdCode: "*133*2*3#",
          ),
          MenuItems(
            title: "120 sms",
            subtitle: "120 SMS nacionales por \$60 CUP",
            icon: Icons.sms,
            color: Colors.blue,
            ussdCode: "*133*2*4#",
          ),
        ],
      ),
      MenuItems(
        title: "Plan amigos",
        subtitle: "Gestiona tus números amigos",
        icon: Icons.people,
        color: Colors.blue,
        hasSubmenu: true,
        submenuItems: [
          MenuItems(
            title: "Estado",
            subtitle: "Consulta el estado del plan",
            icon: Icons.people,
            color: Colors.blue,
            ussdCode: "*133*4*3#",
          ),
          MenuItems(
            title: "Activar",
            subtitle: "Activa el plan",
            icon: Icons.check_circle,
            color: Colors.blue,
            ussdCode: "*133*4*1#",
          ),
          MenuItems(
            title: "Desactivar",
            subtitle: "Desactiva el plan",
            icon: Icons.cancel,
            color: Colors.blue,
            ussdCode: "*133*4*1#",
          ),
          MenuItems(
            title: "Agregar amigo",
            subtitle: "Agrega el número de un amigo",
            icon: Icons.person_add,
            color: Colors.blue,
            ussdCode: "*133*4*2#",
          ),
          MenuItems(
            title: "Eliminar amigo",
            subtitle: "Elimina el número de un amigo",
            icon: Icons.person_remove,
            color: Colors.blue,
            ussdCode: "*133*4*2#",
          ),
          MenuItems(
            title: "Lista de amigos",
            subtitle: "Consulta tu lista de números amigos",
            icon: Icons.list,
            color: Colors.blue,
            ussdCode: "*133*4*5#",
          ),
        ],
      ),
    ],
  ),
  MenuItems(
    title: "Línea corporativa",
    subtitle: "Consulta el estado tu plan corporativo",
    icon: Icons.attach_money,
    color: Colors.blue,
    ussdCode: "*222*3#",
  ),
];

const List<MenuItems> historyItems = [
  MenuItems(
    title: "Gestionar Llamadas",
    subtitle: "Realiza llamadas de manera fácil",
    icon: Icons.call,
    color: Colors.green,
    hasSubmenu: true,
  ),
  MenuItems(
    title: "Asterisco 99",
    subtitle: "Llamada con pago revertido",
    icon: Icons.call,
    color: Colors.green,
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
