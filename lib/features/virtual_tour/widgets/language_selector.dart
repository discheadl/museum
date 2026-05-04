import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/locale_controller.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.controller,
    required this.expanded,
    required this.onToggle,
  });

  final AppLocaleController controller;
  final bool expanded;
  final VoidCallback onToggle;

  static const List<String> _codes = <String>['es', 'en', 'fr'];

  @override
  Widget build(BuildContext context) {
    final String activeCode = controller.locale.languageCode;
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(150),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withAlpha(28)),
          ),
          child: IconButton(
            tooltip: expanded
                ? localizations.text('tour.hideLanguageMenu')
                : localizations.text('tour.showLanguageMenu'),
            onPressed: onToggle,
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: expanded
              ? Padding(
                  key: const ValueKey<String>('tour_language_row'),
                  padding: const EdgeInsets.only(left: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(28)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _codes
                            .map((String code) {
                              final bool isActive = code == activeCode;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => controller.setLanguageCode(code),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFFF4A261)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      code.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: isActive
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
