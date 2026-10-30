import 'package:material_ui/material_ui.dart';

class RectStyle {
  RectStyle._();

  static final iconButton = IconButton.styleFrom(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
  );

  static final elevatedButton = ElevatedButton.styleFrom(
    elevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
  );
  
}
