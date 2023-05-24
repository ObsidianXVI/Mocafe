part of mocafe.ml;

class MocafeQLAgent extends QLAgent {
  final MocafeEnv env;
  final List<ArgSet> argSets;
  final List<MocafeState> mocafeStates;

  /// Key is a 3-dimensional vector (stateIndex, actionIndex, argSetIndex),
  /// which will be called a [MocafeQVector] henceforth.
  /// Respective value is the Q-value for that MocafeQVector.
  /// As such, a 3-dimensional Q-table is implemented.
  final Map<MocafeQVector, double> qTable;

  MocafeQLAgent({required this.env, required super.runConfigs})
      : argSets = env.paramSpace.argSets,
        qTable = env.initialiseQTable(),
        mocafeStates = env.stateSpace.states.whereType<MocafeState>().toList(),
        super(env: env);

  @override
  ActionResult perform([State? state]) {
    state ??= MocafeState.current(env);
    state as MocafeState;
    if (state.isTerminal) throw TerminalStateException();
    // fetch all available Q-values
    final Map<MocafeQVector, double> qValuesOfState =
        fetchHistoricalQValues(state);

    // select action
    final int comboIndex = qValuesOfState.values.toList().indexOfMaxValue();
    final Action optimalAction =
        qValuesOfState.keys.toList()[comboIndex].action;
    final Action selectedAction =
        select<Action>(state.actionsAvailable, optimalAction);
    final bool selectedActionIsRand = selectedAction == optimalAction;

    // select arg
    final ArgSet optimalArgSet =
        qValuesOfState.keys.toList()[comboIndex].argSet;
    final ArgSet selectedArgSet = select<ArgSet>(argSets, optimalArgSet);
    final bool selectedArgSetIsRand = selectedArgSet == optimalArgSet;

    // perform action
    final ActionResult actionResult = env.performAction(
      selectedAction,
      selectedArgSet,
    );
    final double reward = actionResult.reward;

    // calculate temporal difference
    final MocafeState newState = MocafeState.current(env);
    final double maxFutureValue = computeMaxFutureQValue(newState);
    final double historicalQValue = qValuesOfState.values.toList()[comboIndex];
    final double newQValue =
        reward + runConfigs.discountFactor * maxFutureValue;
    final double temporalDifference = newQValue - historicalQValue;

    // update q value in table
    final double updatedQValue =
        historicalQValue + runConfigs.learningRate * temporalDifference;

    final MocafeQVector selectedQVector = MocafeQVector(
      mocafeState: state,
      action: selectedAction,
      argSet: selectedArgSet,
    );

    final double previousValueOfQVector = qTable[selectedQVector] ?? 0;
    final double updatedValueOfQVector = updatedQValue;
    qTable[selectedQVector] = updatedQValue;

    // complete the info about the action taken
    actionResult
      ..selectedQVector = selectedQVector
      ..oldQValueOfSelectedQVect = previousValueOfQVector
      ..newQValueOfSelectedQVect = updatedValueOfQVector
      ..isRandom = (selectedActionIsRand || selectedArgSetIsRand);
    return actionResult;
  }

  double fetchHistoricalQValue(
    MocafeState stateIn,
    Action actionToBeTaken,
    ArgSet argSetUsed,
  ) {
    /* print(qTable.entries
        .where((e) => e.value > 0)
        .map((e) => "${e.key.toVectorStr()}\n${e.value}\n")
        .join()); */
    final bool has = qTable.containsKey(MocafeQVector(
      mocafeState: stateIn,
      action: actionToBeTaken,
      argSet: argSetUsed,
    ));
    final MocafeState state = MocafeState.current(env);
    final Action action =
        actions.firstWhere((Action a) => a == actionToBeTaken);
    final ArgSet argSet = argSets.firstWhere((ArgSet arg) => arg == argSetUsed);
    final MocafeQVector qTableKey = MocafeQVector(
      mocafeState: state,
      action: action,
      argSet: argSet,
    );
    if (qTable.containsKey(qTableKey)) {
      return qTable[qTableKey]!;
    } else {
      qTable[qTableKey] = 0;
      return 0;
    }
  }

  double computeMaxFutureQValue(MocafeState newState) {
    final Map<MocafeQVector, double> qValuesOfState =
        fetchHistoricalQValues(newState);
    final double maxQValue = qValuesOfState.values.toList().reduce(math.max);
    return maxQValue;
  }

  Map<MocafeQVector, double> fetchHistoricalQValues(MocafeState state) {
    final Map<MocafeQVector, double> qValuesOfState = {};
    for (Action action in state.actionsAvailable) {
      for (ArgSet argSet in argSets) {
        qValuesOfState[MocafeQVector(
          mocafeState: state,
          action: action,
          argSet: argSet,
        )] = fetchHistoricalQValue(state, action, argSet);
      }
    }
    return qValuesOfState;
  }

  /// This method defines the action selection policy. Set [runConfigs.epsilonValue] to 1
  /// to obtain ε-greedy/optimal policy. A higher epsilon value favours exploitation
  /// over exploration.
  T select<T>(List<T> possibleChoices, T optimalChoice) {
    final math.Random random = math.Random();
    if (random.nextDouble() > runConfigs.epsilonValue) {
      return possibleChoices[random.nextInt(possibleChoices.length)];
    } else {
      return optimalChoice;
    }
  }
}

extension ListUtils on List<double> {
  int indexOfMaxValue() {
    final double maxValue = reduce(math.max);
    return indexWhere((double value) => value == maxValue);
  }
}
