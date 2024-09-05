import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/form_utils.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:nood_food/util/style.dart';
import 'package:nood_food/views/pages/chart/avg_diagram.dart';
import 'package:provider/provider.dart';

class Chart extends StatefulWidget {
  const Chart({super.key});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  final int _thisYear = DateTime.now().year;
  int? _selectedYearIndex;
  final TextEditingController _yearController = TextEditingController();
  late final AuthService _authService;
  late final DBService _dbService;

  @override
  void initState() {
    super.initState();
    _yearController.text = _thisYear.toString();
    _authService = AuthService();
    _dbService = DBService(uid: _authService.userUid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Map<int, double>>.value(
      value: _dbService
          .getCaloriesAvgsForYear(_thisYear - (_selectedYearIndex ?? 0)),
      initialData: const {},
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                enableInteractiveSelection: false,
                controller: _yearController,
                textAlign: TextAlign.center,
                decoration: formDecoration.copyWith(
                  labelText: 'Year',
                ),
                onTap: () async {
                  // Below line stops keyboard from appearing
                  FocusScope.of(context).requestFocus(FocusNode());
                  // Show Year Picker Here
                  showYearSelectorBottomModal();
                },
              ),
            ),
            const AvgDiagram(),
          ],
        ),
      ),
    );
  }

  void showYearSelectorBottomModal() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StyledText.titleLarge('Year'),
            ),
            Flexible(
              flex: 1,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: _selectedYearIndex ?? 0,
                ),
                itemExtent: 100,
                onSelectedItemChanged: (index) => _selectedYearIndex = index,
                children: List.generate(100,
                    (index) => Center(child: Text('${_thisYear - index}'))),
              ),
            ),
            Flexible(
              flex: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    color: Colors.green,
                    onPressed: () {
                      Navigator.pop(context, _selectedYearIndex);
                    },
                    icon: const Icon(Icons.check),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
            )
          ],
        );
      },
    ).then(
      (value) =>
          setState(() => _yearController.text = (_thisYear - value).toString()),
    );
  }
}
