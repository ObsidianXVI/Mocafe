part of mocafe.ml;

class MocafeEnv extends DevelopmentEnv {
  final QLRunConfigs qlRunConfigs;
  @override
  final MocafeGlobalState globalState = MocafeGlobalState();

  MocafeEnv({
    required super.actionSpace,
    required super.paramSpace,
    required super.stateSpace,
    required super.enableDynamicQValueInitialiser,
    required this.qlRunConfigs,
    super.resourceConfigs,
    super.resourceManager,
    super.dataStore,
    super.networkConfigs,
    super.observatory,
    super.qTableInitialiser,
  }) : super(runConfigs: qlRunConfigs);

  @override
  ActionResult performAction(Action<ArgSet> action, ArgSet argSet) {
    final MocafeState previouState = MocafeState.current(this);
    action.body(action.convertArgSet(argSet), this);
    final MocafeState newState = MocafeState.current(this);
    return ActionResult(
      previouState: previouState,
      actionTaken: action,
      argSetUsed: argSet,
      reward: computeReward(),
      newState: newState,
    );
  }

  double computeReward() =>
      globalState.customerCount * globalState.currentPrice;

  @override
  void advance(EnvReport report) {
    qlRunConfigs.learningRate - qlRunConfigs.learningRateDecay;
    super.advance(report);
  }

  @override
  void reset() {}
}
