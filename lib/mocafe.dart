library mocafe;

import 'dart:async';

bool cafeIsOpen = false;
int customerCount = 0;
double currentPrice = 0;
double previousProfit = 0;

void main(List<String> args) {
  cafeIsOpen = true;
  final Timer timer = Timer.periodic(const Duration(seconds: 3), (timer) {
    if (cafeIsOpen) {
      updateCustomerCount();
      final double profits = customerCount * currentPrice;
      print(profits);
    }
  });
  Future.delayed(const Duration(seconds: 20), (() => cafeIsOpen = false));
}

void updateCustomerCount() {
  customerCount = (16 - 2 * currentPrice).round();
}
