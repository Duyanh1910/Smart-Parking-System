import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_iot_parking_lot_system/feature/widget/loading_lottie.dart';
import '../../../core/helper/history_helper.dart';
import '../../../core/helper/time_formatter.dart';
import '../../../core/theme/app_palette.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HistoryPageState();
  }
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<dynamic>> _futureHistory;
  @override
  void initState() {
    super.initState();
    _futureHistory = HistoryHelper.fetchHistory();
  }
  Future<void> _refresh() async {
    setState(() {
      _futureHistory = HistoryHelper.fetchHistory();
    });
    await _futureHistory;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppPalette.primaryColor, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Lịch sử",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 30),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _futureHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      children: [
                        LoadingLottie(),
                        const SizedBox(height: 12),
                        const Text("Đang tải, vui lòng chờ..."),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Chưa có dữ liệu"));
                }
                final data = snapshot.data!;
                return RefreshIndicator(
                  color: AppPalette.primaryColor,
                  onRefresh: _refresh,
                  child: AnimationLimiter(
                    child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 700),
                          child: SlideAnimation(
                            verticalOffset: 40,
                            curve: Curves.easeOutCubic,
                            child: FadeInAnimation(
                              curve: Curves.easeIn,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blueAccent
                                          .withValues(alpha: 0.15),
                                      child: Icon(
                                        Icons.local_parking,
                                        color: Colors.blueAccent,
                                      ),
                                    ),

                                    title: Text(
                                      "Biển số xe: ${item['plate_id']}",
                                    ),
                                    subtitle: Text(
                                      "Thời gian: ${TimeFormatter.formatDate(item['checkIn_time'])}",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemCount: data.length,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
