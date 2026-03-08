import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_iot_parking_lot_system/core/helper/shared_preferences.dart';
import 'package:smart_iot_parking_lot_system/feature/widget/home_page_widgets/custom_appbar.dart';
import 'package:smart_iot_parking_lot_system/feature/widget/home_page_widgets/homepage_searchbar.dart';
import 'package:smart_iot_parking_lot_system/feature/widget/home_page_widgets/hompage_gridview.dart';

import '../../widget/home_page_widgets/custom_homepage_header.dart';
import '../../widget/home_page_widgets/homepage_category_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final String appBarTitle = "Chào mừng trở lại";
  String appBarSubTitle = "";
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadUser() async {
    final username = await SharedPref.getUserName();
    setState(() {
      appBarSubTitle = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              CustomHeader(
                child: Column(
                  children: [
                    CustomAppBar(
                      showBackArrow: false,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appBarTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: Colors.white)),
                          Text(appBarSubTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                      actions: [
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                context.push('/notify');
                              },
                              icon: const Icon(Icons.notifications,
                                  color: Colors.white),
                            ),
                            Positioned(
                              right: 12,
                              top: 9,
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color:
                                  Colors.redAccent.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomSearchBar(),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Danh mục",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const CategoryList(),
                  ],
                ),
              ),
              const CustomGridView(),
            ],
          ),
        ),
    );
  }
}

