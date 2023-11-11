import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';


class ReservationScreen extends StatefulWidget {
  final String businessID;

  const ReservationScreen({Key? key, required this.businessID}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  late DateTime? selectedDay; // Added instance variable
  late Map<String, List<String>> reservedTimeSlots; // Added instance variable

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now(); // Initialize selectedDay to current day
    reservedTimeSlots = {};
    FirebaseFirestore.instance.collection('reservations').snapshots().listen((snapshot) {
      setState(() {
        reservedTimeSlots = {};
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final day = data['day'] as String?;
          final time = data['time'] as String?;
          if (day != null && time != null) {
            if (!reservedTimeSlots.containsKey(day)) {
              reservedTimeSlots[day] = [];
            }
            reservedTimeSlots[day]!.add(time);
          }
        }
      });
    });// Initialize reservedTimeSlots
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'Reservation',
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('businesses').doc(widget.businessID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final business = snapshot.data!.data() as Map<String, dynamic>?;

          if (business == null) {
            return Center(child: Text('Business not found'));
          }

          final timeSlots = business['timeSlots'] as Map<String, dynamic>?;

          if (timeSlots == null) {
            return Center(child: Text('Time slots not found'));
          }

          final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

          return SizedBox(
            height: 500,
            child: TableCalendar(
              firstDay: DateTime.now().subtract(Duration(days: 365)),
              lastDay: DateTime.now().add(Duration(days: 365)),
              focusedDay: DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                CalendarFormat.week: 'Week',
              },
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, dayOfWeek) {
                  final weekday = weekdays[dayOfWeek.weekday % 7];
                  return Center(
                    child: Text(
                      weekday.substring(0, 3),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Colors.white),
                selectedDecoration: BoxDecoration(
                  color: Color(0xff3E54AC),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                final weekday = weekdays[focusedDay.weekday % 7];
                final times = List<String>.from(timeSlots[weekday] ?? [])..sort();

                // Check if the selected day has already passed
                if (focusedDay.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Invalid Selection'),
                        content: Text('You cannot select a day that has already passed.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                _showTimeSlots(context, weekday, times);
                setState(() {
                  this.selectedDay = focusedDay;
                });
              },
            ),
          );
        },
      ),
    );
  }

  void _reserveTimeSlot(BuildContext context, String day, String time) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController descriptionController = TextEditingController();

        return AlertDialog(
          title: Text('Make Reservation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Selected Time Slot:'),
              SizedBox(height: 8),
              Text('Day: $day'),
              Text('Time: $time'),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String description = descriptionController.text;

                if (description.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Flexible(child: Text('Please enter a description.')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                User? currentUser = FirebaseAuth.instance.currentUser;
                String? userId = currentUser?.uid;

                if (userId == null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('User ID not found. Please log in again.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('reservations').add({
                    'day': day,
                    'time': time,
                    'description': description,
                    'userId': userId,
                  });

                  if (!reservedTimeSlots.containsKey(day)) {
                    reservedTimeSlots[day] = [];
                  }
                  reservedTimeSlots[day]!.add(time);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Reservation Successful'),
                        content: Text('Your reservation for $day at $time has been made.'),
                        actions: [
                          TextButton(
                            onPressed: () { Navigator.pop(context);
                              _navigateToCalendar();},
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } catch (error) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Failed to make a reservation. Please try again later.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Reserve'),
            ),
          ],
        );
      },
    );
  }
  void _navigateToCalendar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationScreen(businessID: widget.businessID),
      ),
    );
  }
  void _showTimeSlots(BuildContext context, String weekday, List<String> times) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Available Time Slots', style: TextStyle(fontSize: 20)),
            ),
            Text('Day: $weekday'),
            SizedBox(height: 16),
            if (times.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: times.length,
                  itemBuilder: (context, index) {
                    final time = times[index];
                    final isReserved = reservedTimeSlots.containsKey(weekday) &&
                        reservedTimeSlots[weekday]!.contains(time);

                    return ListTile(
                      title: Text(time),
                      onTap: isReserved
                          ? null
                          : () => _reserveTimeSlot(context, weekday, time),
                      tileColor: isReserved ? Colors.grey : null,
                    );
                  },
                ),
              ),
            if (times.isEmpty)
              Text('No available time slots for this day.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
