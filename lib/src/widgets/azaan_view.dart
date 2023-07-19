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
            azaanBloc.todayAzaan.prayerTimes != null
                ? Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[
                            800], // Set your desired background color here
                        border: Border.all(
                          color: Colors.black, // Set the border color
                          width: 1.0, // Set the border width
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(0.5), // Set the shadow color
                            spreadRadius: 2, // Set the spread radius
                            blurRadius: 4, // Set the blur radius
                            offset: const Offset(0, 2), // Set the shadow offset
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 15),
                      padding: const EdgeInsets.all(15.0),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Date: ${azaanBloc.todayAzaan.date}",
                              style: const TextStyle(
                                  color: textColor,
                                  fontSize: textSize,
                                  height: 2,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: ListView.builder(
                              itemCount:
                                  azaanBloc.todayAzaan.prayerTimes.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                final entry = azaanBloc
                                    .todayAzaan.prayerTimes.entries
                                    .toList()[index];
                                return Text(
                                  "${entry.key}: ${entry.value}",
                                  style: const TextStyle(
                                      color: textColor,
                                      fontSize: textSize,
                                      height: 1.8,
                                      letterSpacing: 2),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                'Prayer timings showing for ' +
                                    azaanBloc.formInputs.city +
                                    (azaanBloc.formInputs.country != ''
                                        ? ', ${azaanBloc.formInputs.country}'
                                        : '') +
                                    (azaanBloc.formInputs.zipcode != ''
                                        ? ', ${azaanBloc.formInputs.zipcode} '
                                        : ''),
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: textSize - 3,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .grey[800], // Set your desired background color here
                      border: Border.all(
                        color: Colors.black, // Set the border color
                        width: 1.0, // Set the border width
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .withOpacity(0.5), // Set the shadow color
                          spreadRadius: 2, // Set the spread radius
                          blurRadius: 4, // Set the blur radius
                          offset: const Offset(0, 2), // Set the shadow offset
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 15),
                    padding: const EdgeInsets.all(15.0),
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: Text(
                        "Prayer timings not available!",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: textSize + 4,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
            Expanded(flex: 1, child: Container())
          ],
        );
      },
    );
  }
}
