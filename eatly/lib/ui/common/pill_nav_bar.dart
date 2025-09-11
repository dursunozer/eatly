import 'package:flutter/material.dart';

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
    this.barWidth = 320,
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
            width: barWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.40),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 0,
                  alignment: WrapAlignment.center,
                  children: List.generate(items.length, (i) {
                    final selected = i == currentIndex;
                    final data = items[i];
                    return _Pill(
                      selected: selected,
                      icon: data.icon,
                      label: data.label,
                      selectedColor: selectedColor,
                      unselectedBg: unselectedBg,
                      unselectedIcon: unselectedIcon,
                      onTap: () => onTap(i),
                    );
                  }),
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
        padding: EdgeInsets.symmetric(horizontal: selected ? 12 : 0),
        height: 42,
        constraints: BoxConstraints(minWidth: selected ? 88 : 40),
        decoration: BoxDecoration(
          color: selected ? selectedColor : unselectedBg,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: selected ? 4 : 12),
              child: Icon(
                selected ? icon : (outlineIcon ?? icon),
                size: 16,
                color: selected ? Colors.black : Colors.white,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}
