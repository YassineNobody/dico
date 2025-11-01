import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dico/providers/dictionary_provider.dart';

class SearchWordInput extends StatefulWidget {
  const SearchWordInput({super.key});

  @override
  State<SearchWordInput> createState() => _SearchWordInputState();
}

class _SearchWordInputState extends State<SearchWordInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final query = _controller.text.trim();
      final provider = context.read<DictionaryProvider>();

      if (query.isEmpty) {
        provider.loadWords();
        setState(() => _isSearching = false);
      } else {
        setState(() => _isSearching = true);
        provider.searchWords(query);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: "Rechercher un mot...",
                border: InputBorder.none,
              ),
            ),
          ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                FocusScope.of(context).unfocus();
              },
            ),
        ],
      ),
    );
  }
}
