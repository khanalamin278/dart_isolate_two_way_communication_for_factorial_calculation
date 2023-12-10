/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

export 'src/dart_isolate_two_way_communication_for_factorial_calculation_base.dart';

import 'dart:async';
import 'dart:isolate';

/*
Revised Practice Question 1: Two-Way Communication for 
Factorial Calculation
Task:
Modify calculateFactorialInIsolate to perform factorial 
calculation in a separate isolate with two-way communication. 
The main isolate can send multiple numbers to the spawned isolate 
and receive the factorial result for each.
 */

class SendingTextCommandsAndReceivedProcessedIsolate {
  final _receivedFromProcessed = ReceivePort();
  late final Stream _broadcastStream;
  SendPort? sendingToTextProcessor;
  bool sendPortInitialized = false;
  Isolate? isolateForTextProcessor;

  SendingTextCommandsAndReceivedProcessedIsolate() {
    _broadcastStream = _receivedFromProcessed.asBroadcastStream();
  }

  Future<dynamic> sendAndReceive(int commandsAndInput) async {
    final completer = Completer();

    isolateForTextProcessor ??=
        await Isolate.spawn(_textProcessPort, _receivedFromProcessed.sendPort);

    StreamSubscription? subscription;
    (sendPortInitialized)
        ? sendingToTextProcessor?.send(commandsAndInput)
        : print('Send Port to text processor has not been initialized yet!');

    subscription = _broadcastStream.listen((message) async {
      print("Message from text processing isolate: $message");

      if (message is SendPort) {
        sendingToTextProcessor = message;
        sendPortInitialized = true;
        sendingToTextProcessor?.send(commandsAndInput);
      }
      if (message is int) {
        completer.complete(message);
        subscription?.cancel();
      }
    });
    return completer.future;
  }

  void shutdown() {
    _receivedFromProcessed.close();
    isolateForTextProcessor?.kill();
    isolateForTextProcessor = null;
  }
}

Future<void> _textProcessPort(SendPort sendBackToMainPort) async {
  final receiveFromMainPort = ReceivePort();
  sendBackToMainPort.send(receiveFromMainPort.sendPort);

  await for (var message in receiveFromMainPort) {
    if (message is int) {
      int sortedArray = calculateFactorial(message);
      sendBackToMainPort.send(sortedArray);
    } else if (message == 'shutdown') {
      receiveFromMainPort.close();
      break;
    }
  }
}

int calculateFactorial(int n) {
  if (n == 0 || n == 1) {
    return 1;
  } else {
    return n * calculateFactorial(n - 1);
  }
}

// processingFunction(int commandsAndInput) async {
//   ReceivePort receivePort = ReceivePort();

//   return await receivePort.first;
// }

setupFactorialIsolate() async {
  return SendingTextCommandsAndReceivedProcessedIsolate();
}
