import 'dart:ui';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String)? onSearch;
  final String placeholder;
  final Color? backgroundColor;


  const SearchBarWidget({
    super.key,
    this.onSearch,
    this.placeholder = "Search city...",
    this.backgroundColor,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            blurRadius: 25,
            spreadRadius: 1,
            color: const Color.fromRGBO(255, 255, 255, 0.2),
          )
        ]
            : [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 6),
            color: const Color.fromRGBO(0, 0, 0, 0.12),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: const Color.fromRGBO(0, 0, 0, 0.15),
              border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.25),
              ),
            ),
            child: TextField(
              onTap: () => setState(() => _isFocused = true),
              onTapOutside: (_) => setState(() => _isFocused = false),
              onSubmitted: (value) => widget.onSearch?.call(value),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: 12, right: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.search, size: 20, color: Colors.white),
                ),
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  color: const Color.fromRGBO(255, 255, 255, 0.7),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
