import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/azaan_bloc.dart';
import '../utils/color_const.dart';

class AzaanView extends StatelessWidget {
  const AzaanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AzaanBloc>(
      builder: (context, azaanBloc, _) {
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800], // Set your desired background color here
                border: Border.all(
                  color: Colors.black, // Set the border color
                  width: 1.0, // Set the border width
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Set the shadow color
                    spreadRadius: 2, // Set the spread radius
                    blurRadius: 4, // Set the blur radius
                    offset: const Offset(0, 2), // Set the shadow offset
                  ),
                ],
              ),
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date: ${azaanBloc.todayAzaan.date}",
                    style: const TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            azaanBloc.azaanTimeStatus
                ? Text(
                    'Prayer timings showing for ${azaanBloc.formInputs.zipcode}.',
                    style: const TextStyle(color: textColor),
                  )
                : const Text(''),
          ],
        );
      },
    );
  }
}
