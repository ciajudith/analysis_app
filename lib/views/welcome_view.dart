import 'package:analysis_app/constants/colors.dart';
import 'package:analysis_app/views/scan_qrcode_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.cambridgeBlueColor,
        statusBarColor: AppColors.cambridgeBlueColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: AppColors.cambridgeBlueColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light, // Light or dark text
      ),
    );
    Size size = MediaQuery.sizeOf(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          height: size.height,
          decoration: const BoxDecoration(
            color: AppColors.whiteColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/logo_without_text.svg",
                height: size.height * 0.08,
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Container(
                child: Text(
                  "Scannez, enregistrez, visualisez. Transformez vos données QR en insights percutants!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                    decorationStyle: TextDecorationStyle.solid,
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              SizedBox(
                height: size.height * 0.05,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanQRView(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cambridgeBlueColor,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Commencer le scan ",
                    style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
