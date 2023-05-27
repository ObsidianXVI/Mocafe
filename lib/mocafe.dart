library mocafe;

import 'package:markhor/markhor.dart';
import 'package:mocafe/mocafe_ml/mocafe_ml.dart';

bool cafeIsOpen = false;
int customerCount = 0;
double currentPrice = 0;
double previousProfit = 0;

void main(List<String> args) {
  cafeIsOpen = true;
  final MocafeEnv mocafeEnv = MocafeEnv(
    enableDynamicQValueInitialiser: true,
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
    runConfigs: QLRunConfigs(
      learningRate: 0.2,
      learningRateDecay: -0.00005,
      discountFactor: 0.9,
      epsilonValue: 0.8,
      episodes: 10,
      epochs: 1,
    ),
  );

  mocafeEnv.addHook(TimestepHook(
      env: mocafeEnv,
      body: (Environment env) {
        // change the global state
        // decay the learning rate
      }));

  final Observatory observatory =
      Observatory(observatoryConfigs: ObservatoryConfigs());
  final Timeline timeline =
      Timeline(timelineConfigs: TimelineConfigs(liveReport: true));
  timeline.listenOn(observatory);
}

void updateCustomerCount() {
  customerCount = (16 - 2 * currentPrice).round();
}
