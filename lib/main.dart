// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
     // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: TicketPage(),
        ),
      ),
    );
  }
}

class TicketPage extends StatefulWidget {
  const TicketPage({Key? key});

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  late String _formattedTime;
  late String _formattedDateAndTime;
  double borderWidth = 15.0;
  bool increasing = true;

  @override
  void initState() {
    super.initState();
    updateTime();
    startBreathingEffect();
  }

  void updateTime() {
    _formattedTime = DateFormat('h:mm:ss a').format(DateTime.now());
    _formattedDateAndTime =
        DateFormat('MMM dd, yyyy, h:mm a').format(DateTime.now().add(const Duration(hours: 2)));
    setState(() {});
    Future.delayed(const Duration(seconds: 1), updateTime);
  }

  void startBreathingEffect() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (increasing) {
          borderWidth += 1.5;
        } else {
          borderWidth -= 1.5;
        }
        if (borderWidth >= 18.0) {
          increasing = false;
        } else if (borderWidth <= 15.0) {
          increasing = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12), // Add space before CTtransit
              Text(
                'CTtransit',
                style: TextStyle(
                  color: Color(0xFF3C4043),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 0), // Add space between CTtransit and Show operator your ticket
              Text(
                'Show operator your ticket',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3C4043),
                ),
              ),
              SizedBox(height: 10)
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.11),
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedCircle(borderWidth: borderWidth),
            const CircleOverlay(),
            const LogoImage(),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
        Text(
          _formattedTime ?? '',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.155,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF3C4043),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Container(
          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02,
              horizontal: MediaQuery.of(context).size.width * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adult 2 Hour - Local Service',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.062,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3C4043),
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              Text(
                'Hartford, New Haven, Stamford, Bristol, Meriden,\nNew Britain, Wallingford, and Waterbury',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.034,
                  color: const Color(0xFF5F6267),
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Text(
                "Expires $_formattedDateAndTime",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.042,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF626569),
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AnimatedCircle extends StatelessWidget {
  final double borderWidth;

  const AnimatedCircle({Key? key, required this.borderWidth});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width * 0.3, MediaQuery.of(context).size.width * 0.3),
      painter: CirclePainter(borderWidth: borderWidth),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double borderWidth;

  CirclePainter({required this.borderWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF143663)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    Paint extendingBorder = Paint()
      ..color = const Color(0xFF143663)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 + borderWidth / 2, extendingBorder);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CircleOverlay extends StatelessWidget {
  const CircleOverlay({Key? key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.width * 0.2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}

class LogoImage extends StatelessWidget {
  const LogoImage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo_3.png',
          width: MediaQuery.of(context).size.width * 0.2, // Adjust the width as needed
          height: MediaQuery.of(context).size.width * 0.2, // Adjust the height as needed
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
