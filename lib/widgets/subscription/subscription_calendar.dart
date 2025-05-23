import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SubscriptionCalendar extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Set<DateTime> markedDates; // İşaretli günler için

  const SubscriptionCalendar({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    this.markedDates = const {}, // default boş set
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: TextStyle(color: Colors.redAccent),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          // Tarih sadece yıl, ay, gün bazında kontrol ediliyor
          final d = DateTime(date.year, date.month, date.day);
          if (markedDates.contains(d)) {
            return Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple, // Dilediğin renk olabilir
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
