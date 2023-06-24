library mocafe;

import 'package:markhor/markhor.dart';
import 'package:mocafe/mocafe_ml/mocafe_ml.dart';

bool cafeIsOpen = false;

void main(List<String> args) {
  cafeIsOpen = true;

  // Set up logging via Observatory, Timeline
  final Observatory observatory =
      Observatory(observatoryConfigs: ObservatoryConfigs());
  final Timeline timeline = Timeline(
    timelineConfigs: TimelineConfigs(
      liveReport: true,
      monitoredAttr: {
        'prevStat': (EnvReport report) => report.actionResult.previouState,
        'prevAct': (EnvReport report) => report.actionResult.actionTaken,
        'prevArg': (EnvReport report) => report.actionResult.argSetUsed,
        'obtRewd': (EnvReport report) => report.rewardObtained,
        'oldQVal': (EnvReport report) => report.oldQValueOfSelectedQVect,
        'newQVal': (EnvReport report) => report.newQValueOfSelectedQVect,
        'randAct': (EnvReport report) => report.isRandom,
      },
    ),
  );
  timeline.listenOn(observatory);

  // Configure the environment
  final MocafeEnv mocafeEnv = MocafeEnv(
      enableDynamicQValueInitialiser: true,
      observatory: observatory,
      actionSpace: ActionSpace(actions: [
        IncreaseDrinkPrice(),
        DecreaseDrinkPrice(),
      ]),
      paramSpace: ParamSpace(argSets: [
        IncreaseDrinkPriceArgSet.by10(),
        IncreaseDrinkPriceArgSet.by20(),
        IncreaseDrinkPriceArgSet.by30(),
        IncreaseDrinkPriceArgSet.by40(),
        IncreaseDrinkPriceArgSet.by50(),
        IncreaseDrinkPriceArgSet.by100(),
        DecreaseDrinkPriceArgSet.by10(),
        DecreaseDrinkPriceArgSet.by20(),
        DecreaseDrinkPriceArgSet.by30(),
        DecreaseDrinkPriceArgSet.by40(),
        DecreaseDrinkPriceArgSet.by50(),
        DecreaseDrinkPriceArgSet.by100(),
      ]),
      stateSpace: StateSpace(states: []),
      qlRunConfigs: QLRunConfigs(
        learningRate: 0.2,
        learningRateDecay: -0.00005,
        discountFactor: 0.9,
        epsilonValue: 0.8,
        episodes: 10,
        epochs: 1,
      ))
    ..globalState.currentPrice = 5
    ..globalState.customerCount = 6;

  // Configure hooks
  mocafeEnv.addHook(
    TimestepHook(
      env: mocafeEnv,
      body: (Environment env) {
        env as MocafeEnv;

        // calculate the profits made
        env.globalState.previousProfit =
            env.globalState.customerCount * env.globalState.currentPrice;
        // refresh the consumer count based on the demand curve
        env.globalState.customerCount =
            (16 - 2 * env.globalState.currentPrice).round();
      },
    ),
  );

  // Initialise the agent
  final MocafeQLAgent qlAgent = MocafeQLAgent(
    env: mocafeEnv,
    runConfigs: mocafeEnv.qlRunConfigs,
  );

  qlAgent.run(MocafeState.current(mocafeEnv));
}
