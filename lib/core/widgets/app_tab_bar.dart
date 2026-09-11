import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Una pestaña de [AppTabBar].
class AppTabItem {
  const AppTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Barra de pestañas inferior: la pestaña activa se muestra como un círculo
/// de color que sobresale de la barra, con la etiqueta en negrita.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.activeColor = AppColors.copper,
  });

  final List<AppTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        // heightFactor: 1 evita que la barra se estire a toda la pantalla.
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          // En pantallas anchas (web) la barra conserva ancho de teléfono.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _TabButton(
                      item: items[i],
                      isSelected: i == currentIndex,
                      activeColor: activeColor,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final AppTabItem item;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 280);
  static const _inactiveColor = Color(0xFF8A9099);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 34,
        highlightShape: BoxShape.circle,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // El hueco de layout es fijo (28 px); el círculo activo se
              // dibuja más grande y desplazado hacia arriba, fuera de la barra.
              SizedBox.square(
                dimension: 28,
                child: OverflowBox(
                  maxWidth: 56,
                  maxHeight: 56,
                  child: AnimatedContainer(
                    duration: _duration,
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 56 : 28,
                    height: isSelected ? 56 : 28,
                    transform: Matrix4.translationValues(
                      0,
                      isSelected ? -18 : 0,
                      0,
                    ),
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? activeColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.surface, width: 4)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 24,
                      color: isSelected ? Colors.white : _inactiveColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: _duration,
                style: DefaultTextStyle.of(context).style.copyWith(
                  fontSize: isSelected ? 12.5 : 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.textPrimary : _inactiveColor,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
