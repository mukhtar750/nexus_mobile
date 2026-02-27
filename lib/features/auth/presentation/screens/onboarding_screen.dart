import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Welcome to NEXUS",
      "subtitle":
          "A sensitization and capacity building platform for global non-oil export opportunities.",
      "image": "assets/images/onboarding1.png" // Placeholder
    },
    {
      "title": "Navigate Non-Oil Export Opportunities with ease",
      "subtitle":
          "Register for sensitizing non-oil export opportunities, networking events, and trade fairs directly from the app.",
      "image": "assets/images/onboarding2.png" // Placeholder
    },
    {
      "title": "About NEXUS",
      "subtitle":
          "NEXUS is Nigeria's premier digital platform dedicated to empowering non-oil exporters. In partnership with the Central Bank of Nigeria, we provide comprehensive support, training, and resources to help Nigerian businesses thrive in the global export market. Our mission is to diversify Nigeria's economy by equipping exporters with the tools, knowledge, and opportunities needed to succeed internationally.",
      "image": "assets/images/onboarding3.png" // Placeholder
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Show Logo for the first slide, otherwise use Icon placeholder
                        if (index == 0)
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: Center(
                              child: Image.asset(
                                'assets/images/logo1.png',
                                height: 220,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        else if (index == 1)
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: Image.asset(
                                'assets/images/logo1.png',
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        const SizedBox(height: 40),
                        Text(
                          _pages[index]['title']!,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[index]['subtitle']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Next/Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? "Get Started"
                          : "Next",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
