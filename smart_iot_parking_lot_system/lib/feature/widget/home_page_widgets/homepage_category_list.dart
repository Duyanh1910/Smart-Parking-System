import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_iot_parking_lot_system/core/helper/category_list.dart';

import 'homepage_header_category.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const SizedBox(width: 25),
            ...categories.map((item) {
              return Padding(
                padding: EdgeInsets.only(right: 25),
                child: HeaderCategory(
                  icon: item['icons'],
                  title: item['title'],
                  onPressed: () {
                    context.push(item['route']);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
