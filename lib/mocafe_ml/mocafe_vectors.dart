part of mocafe.ml;

class MocafeQVector extends QVector3D {
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
          argSet,
          values: [mocafeState, action, argSet],
        );
}
