// ignore_for_file: library_private_types_in_public_api

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(child: TicketPage()),
      ),
    );
  }
}

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> with TickerProviderStateMixin {
  late String _formattedTime;
  late String _formattedDateAndTime;

  // Animations
  late final AnimationController _outerCtrl; // outer: 1.00s
  late final AnimationController _innerCtrl; // inner: 0.78s, 0.51s delay
  late final Animation<double> _outerAnim;
  late final Animation<double> _innerAnim;

  // Timing (CSS-like)
  static const int kOuterMs = 1000;
  static const int kInnerMs = 780;
  static const int kDelayMs = 510;

  // Scales (CSS-like, subtle; inner capped at 1.00)
  static const double kOuterBegin = 0.92;
  static const double kOuterEnd   = 1.17;
  static const double kInnerBegin = 0.90;
  static const double kInnerEnd   = 1.00;

  // Colors
  static const Color kOuterColor = Color(0xFFCD530C);
  static const Color kRingColor  = Color(0xFFA83B00);

  @override
  void initState() {
    super.initState();
    _tickTime();

    _outerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kOuterMs),
    )..repeat(reverse: true);
    _outerAnim = CurvedAnimation(parent: _outerCtrl, curve: Curves.easeInOut);

    _innerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kInnerMs),
    );
    Future.delayed(const Duration(milliseconds: kDelayMs), () {
      if (mounted) _innerCtrl.repeat(reverse: true);
    });
    _innerAnim = CurvedAnimation(parent: _innerCtrl, curve: Curves.easeInOut);
  }

  void _tickTime() {
    _formattedTime = DateFormat('h:mm:ss a').format(DateTime.now());
    _formattedDateAndTime =
        DateFormat('MMM dd, yyyy, h:mm a').format(DateTime.now().add(const Duration(hours: 2)));
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(_tickTime);
    });
  }

  @override
  void dispose() {
    _outerCtrl.dispose();
    _innerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Responsive badge size: ~36% of width, clamped to [180, 320]
    double badgeSize = w * 0.36;
    badgeSize = math.max(180, math.min(320, badgeSize));

    // Proportional geometry based on CSS 240px design
    // (inset-8 => 32px, inset-12 => 48px, border-24 => 24px)
    final double ringMargin  = badgeSize * (32 / 240);
    final double whiteMargin = badgeSize * (48 / 240);
    final double ringWidth   = badgeSize * (24 / 240);

    return Column(
      children: [
        AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 12),
              Text(
                'CTtransit',
                style: TextStyle(
                  color: Color(0xFF3C4043),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                'Show operator your ticket',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3C4043),
                ),
              ),
              SizedBox(height: 10),
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

        // Responsive pulsing badge
        PulseBadge(
          size: badgeSize,
          outerAnim: _outerAnim,
          innerAnim: _innerAnim,
          outerColor: kOuterColor,
          ringColor: kRingColor,
          ringWidth: ringWidth,        // responsive
          ringMargin: ringMargin,      // responsive
          whiteMargin: whiteMargin,    // responsive
          logoPath: 'assets/images/logo_3.png',
          logoScale: 0.75,             // % of white-circle diameter
          outerBegin: kOuterBegin,
          outerEnd: kOuterEnd,
          innerBegin: kInnerBegin,
          innerEnd: kInnerEnd,
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.12),

        Text(
          _formattedTime,
          style: TextStyle(
            fontSize: w * 0.155,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF3C4043),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),

        Container(
          margin: EdgeInsets.symmetric(horizontal: w * 0.02),
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: w * 0.05,
          ),
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
                  fontSize: w * 0.062,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3C4043),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              Text(
                'Hartford, New Haven, Stamford, Bristol, Meriden,\nNew Britain, Wallingford, and Waterbury',
                style: TextStyle(
                  fontSize: w * 0.034,
                  color: const Color(0xFF5F6267),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Text(
                "Expires $_formattedDateAndTime",
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF626569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PulseBadge extends StatelessWidget {
  final double size;                 // overall diameter
  final Animation<double> outerAnim; // outer pulse controller
  final Animation<double> innerAnim; // inner pulse controller
  final Color outerColor;            // filled outer circle color
  final Color ringColor;             // ring stroke color
  final double ringWidth;            // ring stroke width (responsive)
  final double ringMargin;           // responsive
  final double whiteMargin;          // responsive
  final String logoPath;             // asset path
  final double logoScale;            // fraction of white circle diameter
  final double outerBegin, outerEnd; // scale range for outer
  final double innerBegin, innerEnd; // scale range for inner

  const PulseBadge({
    super.key,
    required this.size,
    required this.outerAnim,
    required this.innerAnim,
    required this.outerColor,
    required this.ringColor,
    required this.ringWidth,
    required this.ringMargin,
    required this.whiteMargin,
    required this.logoPath,
    this.logoScale = 0.75,
    this.outerBegin = 0.92,
    this.outerEnd = 1.08,
    this.innerBegin = 0.90,
    this.innerEnd = 1.00,
  });

  @override
  Widget build(BuildContext context) {
    final outerScale = Tween(begin: outerBegin, end: outerEnd).animate(outerAnim);
    final innerScale = Tween(begin: innerBegin, end: innerEnd).animate(innerAnim);

    final double whiteDiameter = size - (whiteMargin * 2);
    final double logoSize = whiteDiameter * logoScale;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1) Outer filled circle (pulsing)
          ScaleTransition(
            scale: outerScale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: outerColor.withOpacity(0.95),
              ),
            ),
          ),

          // 2) Inner thick ring (pulsing, capped)
          ScaleTransition(
            scale: innerScale,
            child: Container(
              margin: EdgeInsets.all(ringMargin),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: ringWidth),
              ),
            ),
          ),

          // 3) White inner disk (mask)
          Container(
            margin: EdgeInsets.all(whiteMargin),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),

          // 4) Logo on top
          Image.asset(
            logoPath,
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
