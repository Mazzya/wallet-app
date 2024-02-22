import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/globals.dart';
import 'package:qubic_wallet/helpers/show_snackbar.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/stores/application_store.dart';

class TimedController {
  Timer? _fetchTimer;

  final ApplicationStore appStore = getIt<ApplicationStore>();
  final QubicLi _apiService = getIt<QubicLi>();

  TimedController();

  //Fetches data (ticks and contents) from the backend
  fetchData() async {
    try {
      //Fetch the ticks
      debugPrint("Getting tick...");
      int tick = await _apiService.getCurrentTick();
      appStore.currentTick = tick;

      final networkBalances = await _apiService.getNetworkBalances(
          appStore.currentQubicIDs.map((e) => e.publicId).toList());

      final assets = await _apiService.getCurrentAssets(
          appStore.currentQubicIDs.map((e) => e.publicId).toList());

      final transactions = await _apiService.getTransactions(
          appStore.currentQubicIDs.map((e) => e.publicId).toList());

      //await appStore.setAmounts(balances);
      await appStore.setBalancesAndAssets(
          networkBalances, assets); //appStore.setAssets(assets);

      appStore.updateTransactions(transactions);
    } on Exception catch (e) {
      showSnackBar(e.toString().replaceAll("Exception: ", ""));
    }
  }

  //Stops the fetching timer
  stopFetchTimer() {
    if (_fetchTimer == null) {
      return;
    }
    _fetchTimer!.cancel();
  }

  //Stops the fetching timer. Fetches data once. Restarts the fetching timer.
  interruptFetchTimer() async {
    if (_fetchTimer == null) {
      return;
    }
    _fetchTimer!.cancel();

    setupFetchTimer(true);
  }

  setupFetchTimer(bool makeInitialCall) async {
    if (makeInitialCall) {
      await fetchData();
    }
    _fetchTimer = Timer.periodic(
        const Duration(seconds: Config.fetchEverySeconds), (timer) async {
      await fetchData();
    });
  }
}
