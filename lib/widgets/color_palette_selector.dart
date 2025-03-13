import 'package:asr_project/models/enum/color_platte.dart';
import 'package:flutter/material.dart';

class ColorPaletteSelector extends StatefulWidget {
  final ColorPalette colorEnum;
  final Function(ColorPalette) reload;
  final Function(ColorPalette)? onColorSelected;

  const ColorPaletteSelector({
    super.key,
    required this.colorEnum,
    required this.reload,
    this.onColorSelected,
  });

  @override
  State<ColorPaletteSelector> createState() => _ColorPaletteSelectorState();
}

class _ColorPaletteSelectorState extends State<ColorPaletteSelector> {
  final List<ColorPalette> colorEnums = ColorPalette.values;
  late ColorPalette _colorEnum;

  @override
  void initState() {
    super.initState();
    _colorEnum = widget.colorEnum;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: colorEnums.map((colorEnum) {
          bool isSelected = _colorEnum == colorEnum;
          return GestureDetector(
            onTap: () {
              setState(() {
                _colorEnum = colorEnum;
              });
              widget.reload(colorEnum);
              widget.onColorSelected?.call(colorEnum);
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colorEnum.color,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Icon(
                        Icons.done,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
