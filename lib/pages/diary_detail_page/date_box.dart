import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateBox extends StatelessWidget {
  final DateTime dateTime;
  const DateBox({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            dateTime.year.toString(),
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 80,
          child: Card(
            margin: EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat.MMM().format(dateTime).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    dateTime.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
