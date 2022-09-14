import 'package:cryptotaxi/main.dart';
import 'package:cryptotaxi/view/firstUseScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      decoration: PageDecoration(
        titleTextStyle: GoogleFonts.lato(
           fontWeight: FontWeight.bold,color: textcolor,fontSize: 22,

        ),bodyTextStyle: TextStyle(color: textcolor,fontSize: 16)
      ),
      title: "Welcome to CryptoTaxi",
      body:
          "Crypto Taxi is a secure ride hailing mobile app. your data are stored safely in Blockchain",
      image: Center(
        child: Image.asset("assets/images/logoApp.png",   width: 200,fit: BoxFit.contain,),
      ),
    ),
    PageViewModel(
      decoration: PageDecoration(
          titleTextStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,color: textcolor,fontSize: 22,

          ),bodyTextStyle: TextStyle(color: textcolor,fontSize: 16)
      ),
      title: "Your Data Privacy Preserving",
      body:
          "Blockchain is a technology that can provide data protection due to the use of an immutable distributed ledger and the adoption of several cryptographic techniques.",
      image: Center(
        child: Image.asset(
          "assets/images/privacy.png",
          fit: BoxFit.fitWidth,width: 150,
        ),
      ),
    ),PageViewModel(
      decoration: PageDecoration(
          titleTextStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,color: textcolor,fontSize: 22,

          ),bodyTextStyle: TextStyle(color: textcolor,fontSize: 16)
      ),
      title: "Direct & Secure Payment With Cryptocurrencies",
      body:
          "A cryptocurrency payment gateway is a payment processor for digital currencies, similar to the payment processors, gateways, and acquiring bank credit cards use. Cryptocurrency gateways enable you to accept digital payments and receive fiat currency immediately in exchange.",
      image: Center(
        child: Image.asset(
          "assets/images/Ethereum.png",
          fit: BoxFit.fitWidth,width: 250,
        ),
      ),
    ),PageViewModel(
      decoration: PageDecoration(
          titleTextStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,color: textcolor,fontSize: 22,

          ),bodyTextStyle: TextStyle(color: textcolor,fontSize: 16)
      ),
      title: "Less Extra Fees",
      body:
      "Unlike other services that take more than 20% of the ride cost as fees, our service just takes 10%",
      image: Center(
        child: Image.asset(
          "assets/images/fees.png",
          fit: BoxFit.fitWidth,width: 220,
        ),
      ),
    ),PageViewModel(
      decoration: PageDecoration(
          titleTextStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,color: textcolor,fontSize: 22,

          ),bodyTextStyle: TextStyle(color: textcolor,fontSize: 16)
      ),
      title: "Fair & Guaranteed Payment",
      body:
      "Our service follows a specific pattern in order to ensure payment to the driver. When the trip is confirmed by both parties, the driver and the passenger, the ride cost is transferred from the passenger's wallet to CryptoTaxi smart contract, and then when the ride is completed, the amount will be transferred to the driver's wallet",
      image: Center(
        child: Image.network(
          "https://www.secureplatformfunding.com/wp-content/uploads/2016/06/Secure-Platform-Funding-Payment-Guarantee.png",
          fit: BoxFit.fitWidth,width: 180,
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(

        pages: listPagesViewModel,
        showBackButton: false,
        showSkipButton: true,
        skip: const Text("Skip"),
        next: const Icon(FontAwesomeIcons.arrowRightLong),
        done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: Colors.blueAccent,
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0))),
        onDone: () {
          Get.to(() => FirstUse());
          // When done button is press
        },
      ),
    );
  }
}
