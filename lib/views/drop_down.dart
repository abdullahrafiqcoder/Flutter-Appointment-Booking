import 'package:flutter/material.dart';

class DropDown extends StatefulWidget {
  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  final List<Map<String, String>> dropDownListData = [
    {"title": "Morning", "value": "morning"},
    {"title": "Evening", "value": "evening"},
  ];

  DateTime selectedDate = DateTime.now();
  String defaultvalue = "";
  String selectedTime = "";
  String patientName = "";
  String hoveredTime = "";

  // Store booked slots in a map
  final Map<String, Map<String, String>> bookedSlots = {};

  List<String> getTimeSlots(String session) {
    if (session == "morning") {
      return ["09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM", "12:00 PM", "12:30 PM", "1 PM"];
    } else if (session == "evening") {
      return ["06:00 PM", "06:30 PM", "07:00 PM", "07:30 PM", "08:00 PM", "08:30 PM", "09:00 PM"];
    }
    return [];
  }

  bool isTimeSlotBooked(DateTime date, String time) {
    final key = "${defaultvalue}_${date.toLocal()}".split(' ')[0];
    return bookedSlots[key]?.containsKey(time) ?? false;
  }

  void bookTimeSlot(String dateKey, String time, String patientName) {
    if (!bookedSlots.containsKey(dateKey)) {
      bookedSlots[dateKey] = {};
    }
    bookedSlots[dateKey]?[time] = patientName;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = getTimeSlots(defaultvalue);
    final dateKey = "${defaultvalue}_${selectedDate.toLocal()}".split(' ')[0];

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Clinic Booking System",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text("Patient Name", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter patient name',
            ),
            onChanged: (value) {
              setState(() {
                patientName = value;
              });
            },
          ),
          SizedBox(height: 20),

          Text("Select Session", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          DropdownButton<String>(
            value: defaultvalue,
            isExpanded: true,
            items: [
              const DropdownMenuItem(
                child: Text("Select", style: TextStyle(fontSize: 18)),
                value: "",
              ),
              ...dropDownListData.map<DropdownMenuItem<String>>((data) {
                return DropdownMenuItem(
                  child: Text(data['title']!, style: TextStyle(fontSize: 18)),
                  value: data['value'],
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                defaultvalue = value!;
                selectedTime = ""; // Reset selected time when session changes
              });
            },
          ),
          SizedBox(height: 20),

          Text("Select Date", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${selectedDate.toLocal()}".split(' ')[0], style: TextStyle(fontSize: 18)),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          Text("Select Time Slot", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: timeSlots.map((time) {
              final isBooked = isTimeSlotBooked(selectedDate, time);
              return ChoiceChip(
                label: Text(time),
                selected: selectedTime == time,
                onSelected: (bool selected) {
                  if (isBooked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("This time slot is already booked!")),
                    );
                  } else if (selected && patientName.isNotEmpty) {
                    setState(() {
                      selectedTime = time;
                      bookTimeSlot(dateKey, time, patientName);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a patient name.")),
                    );
                  }
                },
                selectedColor: Colors.green,
                backgroundColor: isBooked ? Colors.red : Colors.grey[300],
                labelStyle: TextStyle(
                  color: selectedTime == time || isBooked ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),

          Text("Appointment Report", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: bookedSlots[dateKey]?.entries.map((entry) {
              return Text(
                "Time: ${entry.key} - Patient: ${entry.value}",
                style: TextStyle(
                  fontSize: 20, // Yahan font size barhaya gaya hai
                ),
              );
            }).toList() ?? [Text("No appointments booked")],
          ),

        ],
      ),
    );
  }
}
