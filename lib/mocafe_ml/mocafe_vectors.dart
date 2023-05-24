part of mocafe.ml;

class MocafeQVector extends QVector {
  final MocafeState mocafeState;
  final Action action;
  final ArgSet argSet;

  MocafeQVector({
    required this.mocafeState,
    required this.action,
    required this.argSet,
  }) : super(
          mocafeState,
          action,
          dimensions: 3,
          values: [mocafeState, action, argSet],
        );
}
