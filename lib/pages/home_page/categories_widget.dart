import 'package:asr_project/models/diary.dart';
import 'package:flutter/material.dart';

class CategoriesWidget extends StatefulWidget {
  final String name;
  final List<Diary> diaries;

  const CategoriesWidget({
    super.key,
    required this.name,
    required this.diaries,
  });

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  late bool _isOpen;

  @override
  void initState() {
    _isOpen = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.tertiary,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    widget.name,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Theme.of(context).primaryColor),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isOpen = !_isOpen;
                    });
                  },
                  icon: _isOpen
                      ? Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Theme.of(context).primaryColor,
                        )
                      : Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                ),
              ],
            ),
          ),
          if (_isOpen)
            Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      itemCount: widget.diaries.length,
                      itemBuilder: (context, index) {
                        final Diary diary = widget.diaries[index];
                        return Card(
                          child: ListTile(
                            onTap: () => Navigator.pushNamed(
                              context,
                              "/diary/detail",
                              arguments: diary.id,
                            ),
                            leading: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Theme.of(context).colorScheme.primary),
                              child: Icon(
                                Icons.note,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            title: Text(diary.title),
                            subtitle: Text("Subtitle"),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(4.0),
                    child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, "/diary/create"),
                        style: TextButton.styleFrom(
                          fixedSize: Size(double.infinity, 40),
                          padding: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Row(
                          spacing: 8.0,
                          children: [
                            Icon(
                              Icons.add,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              "Add diary",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
