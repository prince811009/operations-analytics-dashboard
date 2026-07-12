import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final bool isCollapsed;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onToggleCollapse;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onItemSelected,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: isCollapsed ? 88 : 240,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 14 : 24,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment:
            isCollapsed ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              if (!isCollapsed)
                const Text(
                  'Operations',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              IconButton(
                tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                onPressed: onToggleCollapse,
                icon: Icon(
                  isCollapsed
                      ? Icons.keyboard_double_arrow_right
                      : Icons.keyboard_double_arrow_left,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _menu(
            index: 0,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
          ),
          _menu(
            index: 1,
            icon: Icons.table_chart_outlined,
            title: 'Data Explorer',
          ),
          _menu(
            index: 2,
            icon: Icons.storage_outlined,
            title: 'SQL Query',
          ),
          _menu(
            index: 3,
            icon: Icons.show_chart,
            title: 'Forecast',
          ),
          _menu(
            index: 4,
            icon: Icons.description_outlined,
            title: 'Reports',
          ),
          const Spacer(),
          if (!isCollapsed)
            const Text(
              'Operations Analytics',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
        ],
      ),
    );
  }

  Widget _menu({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = selectedIndex == index;

    return Tooltip(
      message: isCollapsed ? title : '',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onItemSelected(index),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 14 : 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEFF6FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : Colors.black54,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}