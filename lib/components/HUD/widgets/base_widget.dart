import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseWidget<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final T? model;
  final Widget? child;
  final Function(T)? onModelReady;
  final Function(T)? onRebuild;

  const BaseWidget({super.key, required this.builder, this.model, this.child, this.onModelReady, this.onRebuild});

  @override
  _BaseWidgetState<T> createState() => _BaseWidgetState<T>();
}

class _BaseWidgetState<T extends ChangeNotifier> extends State<BaseWidget<T>> {
  T? model;

  @override
  void initState() {
    super.initState();

    model = widget.model;
    if (widget.onModelReady != null) {
      widget.onModelReady!(model!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onRebuild != null) widget.onRebuild!(model!);

    return ChangeNotifierProvider<T>(
      create: (context) => model!,
      child: Consumer<T>(builder: widget.builder, child: widget.child),
    );
  }
}
