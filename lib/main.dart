import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyPageView(),
    );
  }
}

class MyPageView extends StatefulWidget {
  const MyPageView({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MyPageViewState createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  final PageController _pageController = PageController();
  final int _maxPage = 2; // Set the maximum page count here
  int _currentPage = 0;
  bool _isSoundOn = true;
  bool _isTimerRunning = false; // Added variable to track timer state

  late List<Timer> _timers;
  late List<int> _countdowns;
  late List<bool> _isTimerPaused;
  late List<String> _pageTitles;
  late List<String> _pageSubTitles;

  @override
  void initState() {
    super.initState();
    _initializeTimers();
  }

  void _initializeTimers() {
    _timers =
        List.generate(_maxPage + 1, (index) => Timer(Duration.zero, () {}));
    _countdowns = List.generate(_maxPage + 1, (index) => 30);
    _isTimerPaused = List.generate(_maxPage + 1, (index) => false);

    _pageSubTitles = [
      'It\'s Simple: eat slowly for ten minutes, rest for five, then finish your meal',
      'Take a five-minutes break to check in on your level of fullness',
      'You can eat until you feel full'
    ];
    _pageTitles = ['Time to eat mindfully', 'Break Time', 'Finish your meal'];
    // Do not start the countdown for the first page automatically
  }

  void startCountdown(int pageIndex) {
    _timers[pageIndex].cancel();
    _timers[pageIndex] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerPaused[pageIndex]) {
        setState(() {
          if (_countdowns[pageIndex] > 0) {
            _countdowns[pageIndex]--;
          } else {
            _timers[pageIndex].cancel();
            _moveToNextPage();
          }
        });
      }
    });

    // Change the title and subtitle when the countdown starts
    setState(() {
      if (pageIndex == 0) {
        _pageTitles[pageIndex] = 'Nom Nom';
        _pageSubTitles[pageIndex] =
            'You have 10 minutes to eat before the pause. Focus on eating slowly';
      }
      _isTimerRunning = true;
    });
  }

  void _moveToNextPage() {
    setState(() {
      if (_currentPage < _maxPage) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
        // Do not automatically start the countdown for the new page
        // Reset the countdown for the new page
        _countdowns[_currentPage] = 30;
        _isTimerRunning =
            false; // Reset timer state when moving to the next page
      }
    });
  }

  void toggleTimerPause(int pageIndex) {
    setState(() {
      _isTimerPaused[pageIndex] = !_isTimerPaused[pageIndex];
    });
  }

  void toggleSound() {
    setState(() {
      _isSoundOn = !_isSoundOn;
    });
    // Add logic here to handle sound turning on/off
  }

  void nextPage() {
    if (_currentPage < _maxPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      setState(() {
        _currentPage++;
        // Reset the countdown for the new page
        _countdowns[_currentPage] = 30;
        _isTimerRunning =
            false; // Reset timer state when moving to the next page
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff272338),
      appBar: AppBar(
        backgroundColor: const Color(0xff272338),
        leading: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        title: const Text(
          'Mindful Meal Timer',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Dot Indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _maxPage + 1,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 18.0 : 12.0,
                  height: _currentPage == index ? 18.0 : 12.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                buildPage(0),
                buildPage(1),
                buildPage(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage(int pageIndex) {
    String pauseButtonText = _isTimerRunning ? 'PAUSE' : 'START';
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          _pageTitles[pageIndex],
          style: const TextStyle(fontSize: 26, color: Colors.white),
        ),
        Text(
          _pageSubTitles[pageIndex],
          style: const TextStyle(fontSize: 18, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 290.0,
              width: 290.0,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 320.0, // Adjust the size as needed
                      height: 320.0, // Adjust the size as needed
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white10,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 240.0, // Adjust the size as needed
                      height: 240.0, // Adjust the size as needed
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        value: 1 - (_countdowns[pageIndex] / 30.0),
                        strokeWidth: 10.0,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '00 :  ${_countdowns[pageIndex]} ',
                          style: const TextStyle(
                              fontSize: 26,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          "minutes remaining",
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              activeColor: Colors.green,
              value: _isSoundOn,
              onChanged: (value) {
                toggleSound();
              },
            ),
            const Text(
              'Sound On:',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 330.0,
          height: 60.0,
          child: ElevatedButton(
            onPressed: () {
              if (_isTimerRunning) {
                // If the timer is running, pause it
                toggleTimerPause(_currentPage);
              } else {
                // If the timer is not running, start it
                startCountdown(_currentPage);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[200],
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              pauseButtonText,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 330.0,
          height: 60.0,
          child: ElevatedButton(
            onPressed: nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'LET\'S STOP I\'M FULL NOW',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }
}
