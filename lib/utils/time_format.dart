/// "Just now", "5 min ago", "3 h ago", "Yesterday", or a short date.
String relativeTime(DateTime at, DateTime now) {
  final diff = now.difference(at);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24 && at.day == now.day) return '${diff.inHours} h ago';
  final yesterday = now.subtract(const Duration(days: 1));
  if (at.year == yesterday.year && at.month == yesterday.month && at.day == yesterday.day) {
    return 'Yesterday';
  }
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${at.day} ${months[at.month - 1]}';
}
