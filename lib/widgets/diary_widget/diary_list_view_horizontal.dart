import 'package:asr_project/models/diary.dart';
import 'package:asr_project/widgets/diary_widget/diary_card.dart';
import 'package:flutter/material.dart';

class DiaryListViewHorizontal extends StatelessWidget {
  final String title;
  final List diaryList;

  const DiaryListViewHorizontal({
    super.key,
    required this.title,
    required this.diaryList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(spacing: 8.0, children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            )
          ]),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: diaryList.length,
            itemBuilder: (context, index) {
              Diary diary = diaryList[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: DiaryCard(
                  diary: diary,
                  width: 250,
                  // height: 100,
                ),
              );
            },
          ),
        ),
        // Row(
        //   children: [
        //     ElevatedButton(
        //       onPressed: () {},
        //       child: Text(
        //         "Recently",
        //       ),
        //     ),
        //   ],
        // )
      ],
    );
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
    //       child: Row(
    //         spacing: 10,
    //         children: [
    //           Text(
    //             title,
    //             style: Theme.of(context).textTheme.headlineMedium,
    //           ),
    //           if (subtitle != null)
    //             Text(
    //               subtitle!,
    //               style: Theme.of(context).textTheme.labelLarge,
    //             ),
    //         ],
    //       ),
    //     ),
    //     SizedBox(
    //       height: 200,
    //       child: diaryList.isEmpty
    //           ? Padding(
    //               padding: const EdgeInsets.only(top: 8.0),
    //               child: Container(
    //                 decoration: BoxDecoration(
    //                   border: Border.all(
    //                     color: Colors.white12,
    //                     width: 2.0,
    //                   ),
    //                   borderRadius: BorderRadius.circular(8.0),
    //                 ),
    //                 child: Center(
    //                   child: Text(
    //                     "No Diaries",
    //                   ),
    //                 ),
    //               ),
    //             )
    //           : ListView.builder(
    //               scrollDirection: Axis.horizontal,
    //               itemCount: diaryList.length,
    //               itemBuilder: (context, index) {
    //                 Diary diary = diaryList[index];
    //                 return DiaryCard(
    //                   diary: diary,
    //                   width: 300,
    //                   height: 150,
    //                 );
    //               },
    //             ),
    //     ),
    //   ],
    // );
  }
}
