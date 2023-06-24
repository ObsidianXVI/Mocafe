part of mocafe.ml;

class IncreaseDrinkPrice extends Action<IncreaseDrinkPriceArgSet> {
  IncreaseDrinkPrice()
      : super(body: (ArgSet argSet, Environment env) {
          argSet as IncreaseDrinkPriceArgSet;
          env as MocafeEnv;
          env.globalState.currentPrice += argSet.cents;
        });
}

class IncreaseDrinkPriceArgSet extends ArgSet {
  final int cents;
  const IncreaseDrinkPriceArgSet.by10()
      : cents = 10,
        super(values: const [10], dimensions: 1);
  const IncreaseDrinkPriceArgSet.by20()
      : cents = 20,
        super(values: const [20], dimensions: 1);
  const IncreaseDrinkPriceArgSet.by30()
      : cents = 30,
        super(values: const [30], dimensions: 1);
  const IncreaseDrinkPriceArgSet.by40()
      : cents = 50,
        super(values: const [50], dimensions: 1);
  const IncreaseDrinkPriceArgSet.by50()
      : cents = 70,
        super(values: const [70], dimensions: 1);
  const IncreaseDrinkPriceArgSet.by100()
      : cents = 100,
        super(values: const [100], dimensions: 1);

  @override
  String toInstanceLabel() {
    return "IncreaseDPArgSet<$cents>";
  }

  @override
  bool equalityComparator(Object other) {
    return other is IncreaseDrinkPriceArgSet;
  }
}

class DecreaseDrinkPrice extends Action<DecreaseDrinkPriceArgSet> {
  DecreaseDrinkPrice()
      : super(body: (ArgSet argSet, Environment env) {
          argSet as DecreaseDrinkPriceArgSet;
          env as MocafeEnv;
          env.globalState.currentPrice -= argSet.cents;
        });
}

class DecreaseDrinkPriceArgSet extends ArgSet {
  final int cents;
  const DecreaseDrinkPriceArgSet.by10()
      : cents = 10,
        super(values: const [10], dimensions: 1);
  const DecreaseDrinkPriceArgSet.by20()
      : cents = 20,
        super(values: const [20], dimensions: 1);
  const DecreaseDrinkPriceArgSet.by30()
      : cents = 30,
        super(values: const [30], dimensions: 1);
  const DecreaseDrinkPriceArgSet.by40()
      : cents = 50,
        super(values: const [50], dimensions: 1);
  const DecreaseDrinkPriceArgSet.by50()
      : cents = 70,
        super(values: const [70], dimensions: 1);
  const DecreaseDrinkPriceArgSet.by100()
      : cents = 100,
        super(values: const [100], dimensions: 1);

  @override
  String toInstanceLabel() {
    return "DecreaseDPArgSet<$cents>";
  }

  @override
  bool equalityComparator(Object other) {
    return other is DecreaseDrinkPriceArgSet;
  }
}
