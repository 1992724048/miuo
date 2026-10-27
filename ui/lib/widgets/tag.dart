import 'package:material_ui/material_ui.dart';

class Tag extends StatefulWidget {
  const Tag(
    this.label, {
    super.key,
    this.backgroundColor,
    this.textColor,
    this.insets = 3,
    this.radius = 12,
    this.size = 10,
  });

  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double insets;
  final double radius;
  final double size;

  @override
  State<StatefulWidget> createState() => _TagState();
}

class _TagState extends State<Tag> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(widget.insets),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: Text(
        widget.label,
        textAlign: .center,
        style: TextStyle(color: widget.textColor ?? theme.colorScheme.onPrimary, fontSize: widget.size),
      ),
    );
  }
}
