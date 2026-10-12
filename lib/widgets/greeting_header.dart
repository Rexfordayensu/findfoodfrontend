import 'package:flutter/material.dart';
import '../theme.dart';

/// Time-based greeting + username + a short contextual line tailored to
/// the user's role. Drop this at the top of any dashboard's main page.
///
/// Example:
///   GreetingHeader(name: auth.name!, role: 'customer')
class GreetingHeader extends StatelessWidget {
  final String name;
  final String role; // customer | restaurant | rider | admin
  final EdgeInsets padding;

  const GreetingHeader({
    super.key,
    required this.name,
    required this.role,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 16),
  });

  static String _greetingForHour(int hour) {
    if (hour < 5) return 'Still up';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  static String _subtitleForRole(String role) {
    switch (role) {
      case 'customer':
        return 'What are you eating today?';
      case 'restaurant':
        return "Let's manage today's orders.";
      case 'rider':
        return 'Ready to hit the road?';
      case 'admin':
        return "Here's how the platform is doing.";
      default:
        return 'Welcome back!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = _greetingForHour(hour);
    final firstName = name.trim().isNotEmpty
        ? name.trim().split(' ').first // first name only — feels more personal
        : null;
    final subtitle = _subtitleForRole(role);

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstName != null
                      ? '$greeting, $firstName 👋'
                      : '$greeting 👋',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}