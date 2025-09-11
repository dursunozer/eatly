import 'package:flutter/material.dart';
import 'dart:ui';

class PillNavItemData {
  final IconData icon; // selected (filled)
  final String label;
  final IconData? outlineIcon; // unselected (outlined)
  const PillNavItemData(this.icon, this.label, {this.outlineIcon});
}

class PillNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PillNavItemData> items;
  final Color selectedColor;
  final Color unselectedBg;
  final Color unselectedIcon;
  final double barWidth;
  final double barHeight;

  const PillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.selectedColor = const Color.fromARGB(255, 242, 252, 219),
    this.unselectedBg = const Color(0x22999999),
    this.unselectedIcon = const Color(0xFFFFFFFF),
    this.barWidth = 325,
    this.barHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: barHeight,
        child: Center(
          child: SizedBox(
            width: () {
              final maxW = MediaQuery.of(context).size.width - 24;
              return barWidth > maxW ? maxW : barWidth;
            }(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          if (i > 0) const SizedBox(width: 5),
                          _Pill(
                            selected: i == currentIndex,
                            icon: items[i].icon,
                            label: items[i].label,
                            selectedColor: selectedColor,
                            unselectedBg: Colors.white.withOpacity(0.18),
                            unselectedIcon: unselectedIcon,
                            onTap: () => onTap(i),
                            outlineIcon: items[i].outlineIcon,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedBg;
  final Color unselectedIcon;
  final IconData? outlineIcon;

  const _Pill({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedBg,
    required this.unselectedIcon,
    this.outlineIcon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: selected ? 12 : 1.75),
        height: 44,
        constraints: selected
            ? const BoxConstraints(minWidth: 92, minHeight: 44)
            : const BoxConstraints.tightFor(width: 44, height: 44),
        decoration: BoxDecoration(
          color: selected ? selectedColor : unselectedBg,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: selected ? 6 : 12),
              child: Icon(
                selected ? icon : (outlineIcon ?? icon),
                size: selected ? 18 : 16,
                color: selected ? Colors.black : Colors.black,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
