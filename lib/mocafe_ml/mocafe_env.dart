part of mocafe.ml;

class MocafeEnv extends DevelopmentEnv {
  @override
  final MocafeGlobalState globalState = MocafeGlobalState();

  MocafeEnv({
    required super.actionSpace,
    required super.paramSpace,
    required super.runConfigs,
    required super.stateSpace,
    super.resourceConfigs,
    super.resourceManager,
    super.dataStore,
    super.networkConfigs,
    super.observatory,
  });

  @override
  Map<MocafeQVector, double> initialiseQTable() {
    Map<MocafeQVector, double> qTable = {};
    for (MocafeState state in stateSpace.states as List<MocafeState>) {
      for (Action action in actionSpace.actions) {
        for (ArgSet argSet in paramSpace.argSets) {
          qTable[MocafeQVector(
            mocafeState: state,
            action: action,
            argSet: argSet,
          )] = 0;
        }
      }
    }
    return qTable;
  }

  @override
  ActionResult performAction(Action<ArgSet> action, ArgSet argSet) {
    final MocafeState previouState = MocafeState.current(this);
    //print(argSet.toInstanceLabel());
    action.body(action.convertArgSet(argSet));
    final MocafeState newState = MocafeState.current(this);
    return ActionResult(
      previouState: previouState,
      actionTaken: action,
      argSetUsed: argSet,
      reward: computeReward(),
      newState: newState,
    );
  }

  double computeReward() => globalState.customerCount * currentPrice;

  @override
  void reset() {}
}
