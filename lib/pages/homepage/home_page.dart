import 'package:babysitterapp/components/bottom_navigation_bar.dart';
import 'package:babysitterapp/pages/chat/chatpage.dart';
import 'package:babysitterapp/pages/homepage/babysitter_card.dart';
import 'package:babysitterapp/pages/homepage/notification_page.dart';
import 'package:babysitterapp/pages/location/babysitter_view_location.dart';
import 'package:babysitterapp/pages/profile/babysitterprofilepage.dart';
import 'package:babysitterapp/pages/settings_page/settings_page.dart';
import 'package:babysitterapp/pages/transaction/transaction_history_page.dart';
import 'package:babysitterapp/styles/colors.dart';
import 'package:babysitterapp/styles/responsive.dart';
import 'package:babysitterapp/styles/size.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // call firestore service
  FirestoreService firestoreService = FirestoreService();
  // get data from firestore using the model
  UserModel? currentUser;

  // load user data
  Future<void> _loadUserData() async {
    final user = await firestoreService.loadUserData();
    setState(() {
      currentUser = user;
    });
  }

  // initiate load
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  final int _unreadNotifications = 4;
  double _minRating = 0.0;
  double _minRate = 0.0;

  List<Map<String, dynamic>> babysitters = [
    {
      'name': 'Emma Gil',
      'rate': 200.0,
      'rating': 4.3,
      'reviews': 90,
      'profileImage': 'assets/images/female1.jpg',
      'liked': false,
    },
    {
      'name': 'Ken Takakura',
      'rate': 200.0,
      'rating': 4.7,
      'reviews': 140,
      'profileImage': 'assets/images/male3.jpg',
      'liked': false,
    },
    {
      'name': 'Granny',
      'rate': 200.0,
      'rating': 4.9,
      'reviews': 404,
      'profileImage': 'assets/images/female2.jpg',
      'liked': false,
    },
  ];

  void _toggleLike(int index) {
    setState(() {
      babysitters[index]['liked'] = !babysitters[index]['liked'];
    });
  }

  List<Map<String, dynamic>> transactions = [
    {
      'date': '2024-11-10',
      'amount': 500.0,
      'babysitterName': 'Emma Gil',
    },
    {
      'date': '2024-11-09',
      'amount': 450.0,
      'babysitterName': 'Ken Takakura',
    },
    {
      'date': '2024-11-08',
      'amount': 300.0,
      'babysitterName': 'Granny',
    },
  ];

  List<Map<String, dynamic>> get filteredBabysitters {
    return babysitters.where((babysitter) {
      return babysitter['rating'] >= _minRating &&
          babysitter['rate'] >= _minRate;
    }).toList();
  }

  List<Widget> _widgetOptions(BuildContext context) => [
        Center(
          child: Text(
            'Home Page',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Center(
          child: Text(
            'Messages',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Center(
          child: Text(
            'Map',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Center(
          child: Text(
            'Profile',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ];

  Widget _buildBabysitterSection(BuildContext context, String title,
      List<Map<String, dynamic>> babysitters) {
    final double screenHeight = sizeConfig.heightSize(context);

    return Container(
      padding: Responsive.getResponsivePadding(context),
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(Responsive.getBorderRadius(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.getNameFontSize(context),
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              IconButton(
                icon: Icon(Icons.filter_list,
                    color: Theme.of(context).colorScheme.secondary),
                onPressed: () {
                  _showFilterDialog(context);
                },
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: babysitters.asMap().entries.map((entry) {
              int index = entry.key;
              var babysitter = entry.value;
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BabysitterProfilePage(
                        babysitterID: 'sample',
                      ),
                    ),
                  );
                },
                child: BabysitterCard(
                  name: babysitter['name'],
                  rate: 'Php ${babysitter['rate']}/hr',
                  rating: babysitter['rating'],
                  reviews: babysitter['reviews'],
                  profileImage: babysitter['profileImage'],
                  heartIcon: IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: babysitter['liked'] ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleLike(index),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = sizeConfig.heightSize(context);

    return currentUser == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Hello, ${currentUser!.name}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: Responsive.getTextFontSize(context) * 1.5,
                ),
              ),
              actions: [
                Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.notifications, color: tertiaryColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationPage(),
                          ),
                        );
                      },
                    ),
                    if (_unreadNotifications > 0)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$_unreadNotifications',
                            style: TextStyle(
                              fontSize: Responsive.getTextFontSize(context),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: Responsive.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.01),
                  _buildBabysitterSection(
                      context, 'Top Rated Babysitters', filteredBabysitters),
                  _buildTransactionSection(
                      context, 'Total Transaction', transactions),
                  _buildAnalyticsSection(context),
                ],
              ),
            ),
            bottomNavigationBar: const BottomNavBar());
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    final double screenHeight = sizeConfig.heightSize(context);

    double averageRating = 0.0;
    double averageRate = 0.0;

    if (filteredBabysitters.isNotEmpty) {
      averageRating = filteredBabysitters
              .map((babysitter) => babysitter['rating'] as double)
              .reduce((a, b) => a + b) /
          filteredBabysitters.length;
      averageRate = filteredBabysitters
              .map((babysitter) => babysitter['rate'] as double)
              .reduce((a, b) => a + b) /
          filteredBabysitters.length;
    }

    return Container(
      padding: Responsive.getResponsivePadding(context),
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(Responsive.getBorderRadius(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics',
                style: TextStyle(
                  fontSize: Responsive.getNameFontSize(context),
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.secondary,
                size: 40.0,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Average Rating: ${averageRating.toStringAsFixed(1)} / 5.0',
            style: TextStyle(
              fontSize: Responsive.getTextFontSize(context),
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Average Rate: Php ${averageRate.toStringAsFixed(2)} / hr',
            style: TextStyle(
              fontSize: Responsive.getTextFontSize(context),
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Total Babysitters: ${filteredBabysitters.length}',
            style: TextStyle(
              fontSize: Responsive.getTextFontSize(context),
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSection(BuildContext context, String title,
      List<Map<String, dynamic>> transactions) {
    final double screenHeight = sizeConfig.heightSize(context);

    // Group transactions by babysitter
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in transactions) {
      final babysitterName = transaction['babysitterName'];
      if (!groupedTransactions.containsKey(babysitterName)) {
        groupedTransactions[babysitterName] = [];
      }
      groupedTransactions[babysitterName]!.add(transaction);
    }

    return Container(
      padding: Responsive.getResponsivePadding(context),
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(Responsive.getBorderRadius(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.getNameFontSize(context),
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          // Display grouped transactions
          Column(
            children: groupedTransactions.entries.map((entry) {
              final babysitterName = entry.key;
              final babysitterTransactions = entry.value;

              return Container(
                margin: EdgeInsets.only(top: screenHeight * 0.01),
                padding: Responsive.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      babysitterName,
                      style: TextStyle(
                        fontSize: Responsive.getTextFontSize(context) * 1.2,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: babysitterTransactions.map((transaction) {
                        return ListTile(
                          title: Text(
                            'Date: ${transaction['date']}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          trailing: Text(
                            'Php ${transaction['amount']}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionHistoryPage(),
                  ),
                );
              },
              child: Text(
                'See All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: Responsive.getTextFontSize(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Babysitters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Minimum Rating:'),
              Slider(
                value: _minRating,
                min: 0.0,
                max: 5.0,
                divisions: 5,
                onChanged: (value) {
                  setState(() {
                    _minRating = value;
                  });
                },
              ),
              const Text('Minimum Rate:'),
              Slider(
                value: _minRate,
                min: 0.0,
                max: 1000.0,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    _minRate = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
