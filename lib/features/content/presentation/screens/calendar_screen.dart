import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../notifiers/content_notifier.dart';
import '../../domain/models/content_post.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Future.microtask(() {
      ref.read(contentNotifierProvider.notifier).loadPosts();
    });
  }

  List<ContentPost> _getEventsForDay(List<ContentPost> allPosts, DateTime day) {
    return allPosts.where((post) {
      if (post.scheduledAt == null) return false;
      final localDate = post.scheduledAt!.toLocal();
      return isSameDay(localDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contentNotifierProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allPosts = state.posts;
    final selectedEvents = _selectedDay != null 
        ? _getEventsForDay(allPosts, _selectedDay!)
        : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Content Calendar')),
      body: Column(
        children: [
          TableCalendar<ContentPost>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) => _getEventsForDay(allPosts, day),
            calendarFormat: CalendarFormat.month,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox();
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.map((e) {
                      Color color = Colors.blue;
                      if (e.status == 'published') color = Colors.green;
                      if (e.status == 'failed' || e.status == 'reconnect_required') color = Colors.red;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        width: 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: selectedEvents.isEmpty
              ? const Center(child: Text('No posts scheduled for this day.'))
              : ListView.builder(
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    final post = selectedEvents[index];
                    return ListTile(
                      title: Text(post.caption),
                      subtitle: Text('${post.platform} - ${post.status} at ${post.scheduledAt?.toLocal()}'),
                      onTap: () {
                         // Open post details/editor
                      },
                    );
                  },
                ),
          )
        ],
      ),
    );
  }
}
