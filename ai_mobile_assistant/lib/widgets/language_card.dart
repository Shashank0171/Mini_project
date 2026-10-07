import 'package:flutter/material.dart';
import 'package:ai_mobile_assistant/models/app_language.dart';
import 'package:ai_mobile_assistant/theme/app_theme.dart';

/// Language selection card for the language picker screen.
/// Shows flag, native name, and English name with selected state.
class LanguageCard extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${language.name}. ${language.nativeName}. ${isSelected ? "Selected" : "Tap to select"}',
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.08)
            : AppTheme.surfaceColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                // Flag or symbol
                Text(
                  language.flag,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 20),
                // Language names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        language.nativeName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimary,
                        ),
                      ),
                      if (language.nativeName != language.name) ...[
                        const SizedBox(height: 2),
                        Text(
                          language.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? AppTheme.primaryDark
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Selection indicator
                if (isSelected)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                else
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 2),
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
