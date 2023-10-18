import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zerone_pay/util/Globals.dart';

class DisputeFilterScreen extends StatefulWidget {
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final String selectedDeadlineDate;
  final String selectedStatus;
  final String selectedDisputeId;
  final Function(String, String, String, String, String)
      onSubmit; // Updated callback function

  DisputeFilterScreen({
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.selectedStatus,
    required this.selectedDisputeId,
    required this.selectedDeadlineDate,
    required this.onSubmit,
  });

  @override
  _DisputeFilterScreenState createState() => _DisputeFilterScreenState();
}

class _DisputeFilterScreenState extends State<DisputeFilterScreen> {
  late DateTime startDate;
  late DateTime endDate;
  late DateTime deadlineDate;
  late String status;
  late String disputeId;

  late String stringStartDate = '';
  late String stringEndDate = '';
  late String stringDeadlineDate = '';

  @override
  void initState() {
    super.initState();
    startDate = widget.selectedStartDate;
    endDate = widget.selectedEndDate;
    deadlineDate = widget.selectedEndDate;
    status = widget.selectedStatus;
    disputeId = widget.selectedDisputeId;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        stringStartDate = DateFormat('dd-MM-yyyy').format(picked);
        stringStartDate = stringStartDate.toString().split(' ')[0];
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
        stringEndDate = DateFormat('dd-MM-yyyy').format(picked);
        stringEndDate = stringEndDate.toString().split(' ')[0];
      });
    }
  }

  Future<void> _selectDeadLineDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: deadlineDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != deadlineDate) {
      setState(() {
        deadlineDate = picked;
        stringDeadlineDate = DateFormat('dd-MM-yyyy').format(picked);
        stringDeadlineDate = stringDeadlineDate.toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context); // This will navigate back to the previous screen
          },
        ),
        title: const Text(
          'Filter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24, // Update this value to change the title size
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date From',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      GestureDetector(
                        onTap: () => _selectStartDate(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 130, // Increase the width as desired
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(
                                stringStartDate.isNotEmpty
                                    ? stringStartDate
                                    : "Choose date",
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Add some space between the two columns
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date To',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      GestureDetector(
                        onTap: () => _selectEndDate(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 130, // Increase the width as desired
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(
                                stringEndDate.isNotEmpty
                                    ? stringEndDate
                                    : "Choose date",
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              'Status Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              value: status,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    status = newValue;
                  });
                }
              },
              items: <String>['All', 'OPEN', 'CLOSED', 'WON', 'LOST' ]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Transaction ID',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: Colors.white, // Set the background color to white
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                    color: Colors.grey), // Set the border color to grey
              ),
              child: TextFormField(
                initialValue: disputeId,

                onChanged: (newValue) {
                  setState(() {
                    disputeId = newValue;
                  });
                },
                enabled: stringStartDate.isEmpty ||
                    stringEndDate.isEmpty,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  fillColor: Colors.grey,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Deadline Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            GestureDetector(
              onTap: () {
                if(stringEndDate.isEmpty && stringStartDate.isEmpty && disputeId.isEmpty){
                  _selectDeadLineDate(context);
                }else{
                  Globals.showToast(context, 'Not editable ');
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 130, // Increase the width as desired
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Text(
                      stringDeadlineDate.isNotEmpty
                          ? stringDeadlineDate
                          : "Choose date",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      stringStartDate = '';
                      stringEndDate = '';
                      status = 'All';
                      disputeId = '';
                      stringDeadlineDate = '';
                    });
                  },
                  child: Text('Clear'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.onSubmit(stringStartDate, stringEndDate, status,
                        disputeId, stringDeadlineDate);
                    Navigator.pop(context); // Close the filter screen
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
