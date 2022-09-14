import 'dart:convert';

import 'package:cryptotaxi/view/messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:one_context/one_context.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:walletconnect_secure_storage/walletconnect_secure_storage.dart';
import 'package:web3dart/web3dart.dart';

import '../main.dart';

class WalletController extends GetxController {
  static WalletController controller = Get.find();
  final ethereum = Web3Client(
      'https://rinkeby.infura.io/v3/3c503b2232794f3a88d5be5cb61cbee1',
      Client());
  var account = "".obs;
  var connected = false.obs;
  var url = "".obs;
  Rx<double> balance = 0.0.obs;
  final sessionStorage = WalletConnectSecureStorage();
  late WalletConnect connector;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();

    final session = await sessionStorage.getSession();
    connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      session: session,
      sessionStorage: sessionStorage,
      clientMeta: PeerMeta(
        name: 'Crypto Taxi',
        description: 'Crypto Taxi Mobile App',
        url: 'https://www.walletconnect.org',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );
    if (connector.connected) {
      connector.reconnect();
      WalletController.controller.account.value = session!.accounts[0];
      var res = await WalletController.controller.ethereum.getBalance(
          EthereumAddress.fromHex(WalletController.controller.account.value));
      print(" hemmp $res");
      balance.value = res.getValueInUnit(EtherUnit.ether);
      print(balance.value);
      connected.value = true;
    }

    connector.on('connect', (session) {
      print(session);
      connected.value = true;
    });
    connector.on('session_update', (payload) async {
      print('session update');
      print(payload);
      WalletController.controller.account.value = connector.session.accounts[0];
      var res = await WalletController.controller.ethereum.getBalance(
          EthereumAddress.fromHex(WalletController.controller.account.value));
      print(" hemmp $res");
      balance.value = res.getValueInUnit(EtherUnit.ether);
      print(balance.value);
    });
    connector.on('disconnect', (session) => print(session));
    // final prefs = await SharedPreferences.getInstance();
    // if (prefs.containsKey('session')) {
    //   var s = prefs.getString('session');
    //   var map = json.decode(s!);
    //   connector.session.approve(map);
    //   print("approved");
    //   var session = connector.session;
    //   WalletController.controller.account.value = session.accounts[0];
    //   var res = await WalletController.controller.ethereum.getBalance(
    //       EthereumAddress.fromHex(WalletController.controller.account.value));
    //   print(" hemmp $res");
    //   balance.value = res.getValueInUnit(EtherUnit.ether);
    //   print(balance.value);
    //   connected.value = true;
    // }
  }

  Future updateBalance() async {
    var res = await WalletController.controller.ethereum.getBalance(EthereumAddress.fromHex(WalletController.controller.account.value));
    print(" hemmp $res");
    balance.value = res.getValueInUnit(EtherUnit.ether);
  }
  Future main() async {
    if (!WalletController.controller.connector.connected) {
      try {
        final session = await WalletController.controller.connector.connect(
          chainId: 1337,
          onDisplayUri: (uri) async {
            print(uri);
            WalletController.controller.url.value = uri;
            try {
              await launch(uri);
            } catch (e) {
              if (e.toString().contains("ACTIVITY_NOT_FOUND")) {
                Get.defaultDialog(
                  content: SizedBox(
                    width: OneContext().mediaQuery.size.width * 0.9,
                    child: Center(
                        child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SizedBox(
                              // width: OneContext().mediaQuery.size.width * 0.5,
                              child: Text(
                                "MetaMask App is require for the app to work correctly please istall MetaMask Application and restart the app.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: textcolor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  StoreRedirect.redirect(
                                      androidAppId: "io.metamask",
                                      iOSAppId: "1438144202");
                                  Navigator.of(OneContext().context!,
                                          rootNavigator: true)
                                      .pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text("Close"),
                                ))
                          ],
                        ),
                      ),
                    )),
                  ),
                  barrierDismissible: false,
                );
              }
            }

            // _connectWallet(uri: uri);
          },
        );


        print('Session: $session');
        WalletController.controller.account.value = session.accounts[0];
        var res = await WalletController.controller.ethereum.getBalance(EthereumAddress.fromHex(WalletController.controller.account.value));
        print(" hemmp $res");
        balance.value = res.getValueInUnit(EtherUnit.ether);
        print(balance.value);
      } catch (e) {
        print(e);
      }
    } else {
      print('Already connected');
      // connector.killSession();
    }
  }

  Future<String> sendTransaction(EtherAmount amount) async {
    final provider = EthereumWalletConnectProvider(WalletController.controller.connector,chainId: 4);
    final sender = EthereumAddress.fromHex(connector.session.accounts.first);
    final recv = EthereumAddress.fromHex("0xbEBC8ac316b4E3e8E73AA87C3A2aC16CE38cc0e4");
    var nonce = await ethereum.getTransactionCount(sender);
    print(sender.toString());
    print(recv.toString());
    print(nonce);
    final transaction = Transaction(
      to: recv,
      from: sender,
      gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 2),
      maxGas: 100000,
      nonce: nonce,
      value: amount,
    );

    final credentials = WalletConnectEthereumCredentials(provider: provider);

    // Sign the transaction


    final txBytes = await ethereum.sendTransaction(credentials, transaction, chainId: 4);

    print(txBytes);
    return txBytes;
  }
}
