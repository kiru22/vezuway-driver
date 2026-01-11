import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Índices de tabs: 0=home, 1=packages, 2=routes
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

/// Determina la dirección del slide basándose en los índices
/// true = nueva pantalla viene de la derecha (índice mayor)
/// false = nueva pantalla viene de la izquierda (índice menor)
bool shouldSlideFromRight(int previousIndex, int currentIndex) {
  return currentIndex > previousIndex;
}

/// Mapa de rutas a índices de tab
const tabRouteIndices = <String, int>{
  '/home': 0,
  '/packages': 1,
  '/routes': 2,
};
