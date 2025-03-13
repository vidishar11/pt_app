import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:stmcht/bluetoothProvider/bluetoothSerialCommandsProvider.dart';

class CommandHandler {
  final List<String> dynamicCommands;
  final String addresss;
  final BluetootlSerialProvider bluetoothService;
  final bool run;

  CommandHandler(this.dynamicCommands, this.bluetoothService,this.addresss,this.run);

  Future<void> runPeriodicCommands() async {
    while (run) {
      for (var command in dynamicCommands) {
        if (command.contains("sendMOM")) {
            await bluetoothService.sendCommand(command);
        } else {
          // Delay for non-priority commands
          await Future.delayed(const Duration(milliseconds: 1100));
          await bluetoothService.sendCommand(command);
        }
      }
      // Wait for 2 minutes before the next cycle
      await Future.delayed(Duration(minutes: 2));
    }
  }
}