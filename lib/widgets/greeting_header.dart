import 'package:flutter/material.dart';
import '../theme.dart';

/// The friendly hello at the top of every dashboard: a time-of-day greeting,
/// the person's first name, and a short message for their role that changes
/// with the time and the day.
///
/// Pass [status] for something live to say instead (e.g. "3 new orders are
/// waiting"); it is shown in place of the friendly message, highlighted.
///
/// Example:
///   GreetingHeader(name: auth.name!, role: 'customer')
class GreetingHeader extends StatelessWidget {
  final String name;
  final String role; // customer | restaurant | rider | admin
  final EdgeInsets padding;
  final String? status;

  /// For tests; defaults to the current time.
  final DateTime? now;

  const GreetingHeader({
    super.key,
    required this.name,
    required this.role,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 16),
    this.status,
    this.now,
  });

  @override
  Widget build(BuildContext context) {
    final time = now ?? DateTime.now();
    final moment = DayMoment.of(time);
    final firstName = name.trim().isEmpty ? null : name.trim().split(RegExp(r'\s+')).first;
    final message = status ?? greetingMessage(role, time);
    final textSec = AppColors.textSecondary(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: moment.color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(moment.icon, size: 15, color: moment.color),
            ),
            const SizedBox(width: 8),
            Text(
              moment.greeting,
              key: const Key('greeting-hello'),
              style: TextStyle(
                color: textSec,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text(
            firstName ?? 'Welcome back',
            key: const Key('greeting-name'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              message,
              key: ValueKey(message),
              style: TextStyle(
                color: status != null ? AppColors.accentText(context) : textSec,
                fontSize: 14.5,
                height: 1.35,
                fontWeight: status != null ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Morning, afternoon, evening, night or the small hours.
class DayMoment {
  final String greeting;
  final IconData icon;
  final Color color;
  final String slot; // morning | afternoon | evening | night | late
  const DayMoment(this.greeting, this.icon, this.color, this.slot);

  static DayMoment of(DateTime time) {
    final hour = time.hour;
    if (hour < 5) {
      return const DayMoment('Up late', Icons.nightlight_round, Color(0xFF8B7CF6), 'late');
    }
    if (hour < 12) {
      return const DayMoment('Good morning', Icons.wb_sunny_rounded, Color(0xFFF59E0B), 'morning');
    }
    if (hour < 17) {
      return const DayMoment('Good afternoon', Icons.light_mode_rounded, Color(0xFFF97316), 'afternoon');
    }
    if (hour < 21) {
      return const DayMoment('Good evening', Icons.wb_twilight_rounded, Color(0xFFEC4899), 'evening');
    }
    return const DayMoment('Good evening', Icons.bedtime_rounded, Color(0xFF6366F1), 'night');
  }
}

const _messages = <String, Map<String, List<String>>>{
  'customer': {
    'morning': [
      'Breakfast is calling. Hausa koko or waakye?',
      'Start the day with something warm and tasty.',
      'Fresh breakfast, brought to your door.',
    ],
    'afternoon': [
      'Lunch break? Let’s find you something good.',
      'Jollof o’clock. What are you craving?',
      'Beat the afternoon slump with a treat.',
    ],
    'evening': [
      'Dinner sorted in a few taps.',
      'Long day? Let someone else cook tonight.',
      'What’s on the menu for dinner?',
    ],
    'night': [
      'Late-night cravings? Some kitchens are still open.',
      'A little something before bed?',
      'Still hungry? Let’s see what’s open.',
    ],
    'late': [
      'Midnight snack? We won’t tell.',
      'Up late and hungry? Let’s see who’s still cooking.',
    ],
  },
  'restaurant': {
    'morning': [
      'The kitchen’s waking up. Let’s get the first orders out.',
      'Fresh start today. Your menu is ready for customers.',
    ],
    'afternoon': [
      'Lunch rush is on. Keep those orders moving.',
      'Busy hands, happy customers. You’re doing great.',
    ],
    'evening': [
      'Dinner time is busy time. You’ve got this.',
      'Evening orders are coming in. Keep the fire going.',
    ],
    'night': [
      'Winding down? Close the kitchen when you’re done for the day.',
      'Great work today. Late orders still count.',
    ],
    'late': [
      'Burning the midnight oil? Close the kitchen when you’re done.',
    ],
  },
  'rider': {
    'morning': [
      'Roads are fresh. Ride safe today.',
      'Morning orders are coming in. Go online to catch them.',
    ],
    'afternoon': [
      'Lunch deliveries are rolling in. Stay hydrated out there.',
      'Every delivery counts. Keep it smooth and safe.',
    ],
    'evening': [
      'Dinner rush is the busiest time. Stay online for more jobs.',
      'Evening roads get busy. Ride safe.',
    ],
    'night': [
      'Riding at night? Stay visible and ride safe.',
      'Late orders pay too. Take breaks when you need them.',
    ],
    'late': [
      'Still on the road? Rest matters too.',
    ],
  },
  'admin': {
    'morning': [
      'Here’s how FindFood is doing this morning.',
      'A fresh day for FindFood. Here’s the overview.',
    ],
    'afternoon': [
      'Here’s how the platform is doing this afternoon.',
      'Lunch rush check-in: here’s the latest.',
    ],
    'evening': [
      'Here’s how today went so far.',
      'Dinner rush is on. Here’s the platform at a glance.',
    ],
    'night': [
      'Wrapping up the day? Here’s where things stand.',
    ],
    'late': [
      'Working late? Here’s a quick look at FindFood.',
    ],
  },
};

/// A friendly line for [role] at [time]. It changes with the time of day and
/// from day to day, but stays the same within one part of a day.
String greetingMessage(String role, DateTime time) {
  final moment = DayMoment.of(time);
  final byRole = _messages[role] ?? _messages['customer']!;
  final options = [...byRole[moment.slot]!];
  final weekend = time.weekday == DateTime.saturday || time.weekday == DateTime.sunday;
  if (role == 'customer' && moment.slot != 'late') {
    if (time.weekday == DateTime.friday) options.add('Happy Friday! You’ve earned something nice.');
    if (weekend) options.add('It’s the weekend. Treat yourself!');
  }
  if (role == 'rider' && weekend && moment.slot != 'late') {
    options.add('Weekends are busy. Great time to be online.');
  }
  final dayOfYear = time.difference(DateTime(time.year)).inDays;
  return options[dayOfYear % options.length];
}
