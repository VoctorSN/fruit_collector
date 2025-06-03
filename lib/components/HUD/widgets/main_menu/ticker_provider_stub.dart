
// Stub to provide a TickerProvider to the ViewModel without requiring a State.
// Simply delegates the creation of the Ticker to an "empty" TickerProvider.
import 'package:flutter/scheduler.dart';

class TickerProviderStub extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}