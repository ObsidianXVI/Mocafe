part of mocafe.ml;

class MocafeState extends State {
  final int customerCount;
  final double currentPrice;

  MocafeState({
    required this.currentPrice,
    required this.customerCount,
    required super.actionsAvailable,
    required super.isTerminal,
  }) : super(values: [customerCount, currentPrice], dimensions: 2);

  MocafeState.current(MocafeEnv env)
      : currentPrice = env.globalState.currentPrice,
        customerCount = env.globalState.customerCount,
        super(
          actionsAvailable: env.actionSpace.actions,
          isTerminal: env.envTimestep == 10000,
          dimensions: 2,
          values: [env.globalState.customerCount, env.globalState.currentPrice],
        );

  @override
  bool equalityComparator(Object other) {
    if (other is! MocafeState) {
      return false;
    } else {
      if (customerCount == other.customerCount &&
          currentPrice == other.currentPrice) {
        return true;
      } else {
        return false;
      }
    }
  }
}

class MocafeGlobalState extends GlobalState {
  int customerCount = 0;
  double currentPrice = 0;
  double previousProfit = 0;
}
