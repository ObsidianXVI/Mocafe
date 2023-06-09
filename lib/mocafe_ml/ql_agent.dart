part of mocafe.ml;

class MocafeQLAgent extends QLAgent {
  final MocafeEnv env;
  final List<ArgSet> argSets;
  final List<MocafeState> mocafeStates;

  MocafeQLAgent({required this.env, required super.runConfigs})
      : argSets = env.paramSpace.argSets,
        mocafeStates = env.stateSpace.states.whereType<MocafeState>().toList(),
        super(env: env);

  @override
  ActionResult perform([State? state]) {
    try {
      state ??= MocafeState.current(env);
      state as MocafeState;
      /* if (state.isTerminal || env.envTimestep == runConfigs.maxTimesteps) {
        throw TerminalStateException();
      } */
      if (state.isTerminal) throw TerminalStateException();
      // fetch all available Q-values
      final Map<MocafeQVector, double> qValuesOfState =
          fetchHistoricalQValues(state);
      // find optimal action
      final int comboIndex = qValuesOfState.values.toList().indexOfMaxValue();
      final Action optimalAction =
          qValuesOfState.keys.elementAt(comboIndex).action;
      // apply action-selection policy to pick action
      final Action selectedAction =
          selectEpsilonGreedy<Action>(state.actionsAvailable, optimalAction);
      final bool selectedActionIsRand = selectedAction == optimalAction;

      // fetch all argsets compatible with the chosen action
      final Map<double, ArgSet> argSetQValues = {};
      final List<ArgSet> compatibleArgSets = env.paramSpace.argSets
          .where(selectedAction.isCompatibleWithArgSet)
          .toList();

      // fetch the historical Q-values of each argset
      for (ArgSet argSet in compatibleArgSets) {
        final double historicalQValue =
            fetchHistoricalQValue(state, selectedAction, argSet);
        argSetQValues.addAll({historicalQValue: argSet});
      }

      // pick the argset with the highest Q-value
      final ArgSet optimalArgSet = argSetQValues.values
          .elementAt(argSetQValues.keys.toList().indexOfMaxValue());
      // qValuesOfState.keys.elementAt().argSet;
      final ArgSet selectedArgSet = optimalArgSet;
      // select<ArgSet>(compatibleArgSets, optimalArgSet);
      final bool selectedArgSetIsRand = false;
      // selectedArgSet == optimalArgSet;

      // perform action
      final ActionResult actionResult = env.performAction(
        selectedAction,
        selectedArgSet,
      );

      // observe reward
      final double reward = actionResult.reward;

      // calculate temporal difference
      final MocafeState newState = MocafeState.current(env);
      final double maxFutureValue = computeMaxFutureQValue(newState);
      final double historicalQValue =
          qValuesOfState.values.toList()[comboIndex];
      final double newQValue =
          reward + runConfigs.discountFactor * maxFutureValue;
      final double temporalDifference = newQValue - historicalQValue;

      // compute new Q-value
      final double updatedQValue =
          historicalQValue + runConfigs.learningRate * temporalDifference;

      final MocafeQVector selectedQVector = MocafeQVector(
        mocafeState: state,
        action: selectedAction,
        argSet: selectedArgSet,
      );

      // update Q-value of chosen action and argset in Q-table
      final double previousValueOfQVector = env.lookupQValue(selectedQVector);
      final double updatedValueOfQVector = updatedQValue;
      env.updateQValue(selectedQVector, updatedQValue);

      // report info about this timestep for data collection purposes
      actionResult
        ..selectedQVector = selectedQVector
        ..oldQValueOfSelectedQVect = previousValueOfQVector
        ..newQValueOfSelectedQVect = updatedValueOfQVector
        //..isRandom = (selectedActionIsRand || selectedArgSetIsRand);
        ..isRandom = selectedActionIsRand;
      return actionResult;
    } catch (e) {
      rethrow;
    }
  }

  double fetchHistoricalQValue(
    MocafeState stateIn,
    Action actionToBeTaken,
    ArgSet argSetUsed,
  ) {
/*     final bool has = env.qTable.containsKey(MocafeQVector(
      mocafeState: stateIn,
      action: actionToBeTaken,
      argSet: argSetUsed,
    )); */
    // final MocafeState state = MocafeState.current(env);
    /* final Action action =
        actions.firstWhere((Action a) => a == actionToBeTaken);
    final ArgSet argSet = argSets.firstWhere((ArgSet arg) => arg == argSetUsed); */
    return env.lookupQValue(
      MocafeQVector(
        mocafeState: stateIn,
        action: actionToBeTaken,
        argSet: argSetUsed,
      ),
    );
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
      for (ArgSet argSet
          in argSets.where((argset) => action.isCompatibleWithArgSet(argset))) {
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
  T selectEpsilonGreedy<T>(List<T> possibleChoices, T optimalChoice) {
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
