import 'package:dico/providers/dictionary_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

MultiProvider buildAppProviders(Widget child) {
  return MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => DictionaryProvider())],
    child: child,
  );
}
