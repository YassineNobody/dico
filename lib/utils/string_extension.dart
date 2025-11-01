extension StringCasingExtension on String {
  String capitalizeFirst() {
    final trimmed = trimLeft();
    if (trimmed.isEmpty) return this;

    final first = trimmed[0];
    final isLatin = RegExp(r'[A-Za-z]').hasMatch(first);
    if (!isLatin) return this;

    return first.toUpperCase() + trimmed.substring(1);
  }
}
