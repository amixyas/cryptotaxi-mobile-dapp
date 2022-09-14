import 'dart:convert';

import 'package:cryptotaxi/controller/wallet_controller.dart';
import 'package:cryptotaxi/view/messages.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';
class SC_Controller extends GetxController{

  static SC_Controller controller = Get.find();

  late Client httpClient;

  late Web3Client ethClient;
  String rpcUrl = 'https://rinkeby.infura.io/v3/3c503b2232794f3a88d5be5cb61cbee1';
  late EthereumAddress contractAddress;
  late String abi;
  late String myAddress;
  DeployedContract? contract;
  late Credentials credentials;
  late ContractFunction getBalanceAmount,requestRide,getRideAddress,passengerArrivation,refund;
  Future<void> getCredentials() async {
    // credentials = await ethClient.credentialsFromPrivateKey(privateKey);
    //  myAddress =  WalletController.controller.account.value;

    credentials =  EthPrivateKey.fromHex("fd5e792599bfd34fb51beb7ac969388142d4e6f722a693a85946d0706bffa7db");
    // var  res = ethClient.getBalance(EthereumAddress.fromHex("0x3c3A2CD27D826753c9446221eCbE33eebe4Ad866"));
    // print("------------- $res");
    myAddress =  credentials.extractAddress().toString();
  }
  Future<void> getDeployedContract() async {

    String abiString = await rootBundle.loadString('assets/abi/CryptoTaxi.json');
    var abiJson = jsonDecode(abiString);
    abi = jsonEncode(abiJson['abi']);
    contractAddress = EthereumAddress.fromHex("0xbEBC8ac316b4E3e8E73AA87C3A2aC16CE38cc0e4");

  }
  Future<void> getContractFunctions() async {

    contract = DeployedContract(ContractAbi.fromJson(abi, "CryptoTaxi"), contractAddress);

    print(contract?.address.hex);
    // var result = contract.function('setData');
    // getBalanceAmount = contract!.function('test');
    requestRide = contract!.function('requestRide');
    getRideAddress = contract!.function('getRideInfo');
    passengerArrivation = contract!.function('passengerArrivation');
    refund = contract!.function('passengerPaymentRefund');
    // withdrawBalance = contract!.function('withdraw');
  }
  Future<void> initialSetup() async {
    print('initilaizing SC CONTROLLER');
    httpClient = Client();
    ethClient = Web3Client(rpcUrl, httpClient);
    await getCredentials();
    await getDeployedContract();
    await getContractFunctions();
    print('DONE initilaizing SC CONTROLLER');

  }
  Future<List<dynamic>> readContract(
      ContractFunction functionName,
      List<dynamic> functionArgs,
      ) async {
    var queryResult = await ethClient.call(
      contract: contract!,
      function: functionName,
      params: functionArgs,
    );
    return queryResult;
  }
  Future<String> writeContract(
      ContractFunction functionName,
      List<dynamic> functionArgs,
      ) async {
    // final provider = EthereumWalletConnectProvider(WalletController.controller.connector);
    // final credentials = WalletConnectEthereumCredentials(provider: provider);
   var tx = await ethClient.sendTransaction(
      credentials,

      Transaction.callContract(
        contract: contract!,
        function: functionName,
        parameters: functionArgs,
      ),
      chainId: 4
    );
   return (tx);
  }
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initialSetup();
  }
}