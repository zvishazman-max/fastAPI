import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Hitster', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text('Music Timeline Game', style: TextStyle(fontSize: 16, color: Color(0xFF6366F1))),
            const SizedBox(height: 15),
            const Text('Challenge your music knowledge! Listen to songs and place them in chronological order on your timeline.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            const Text('Play with up to 8 friends, discover new music, and compete to build the perfect timeline. First to 10 cards wins!', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF94a3b8))),
            Row(
              children: [

              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                final playerList = ['', ''];
                final List<(String, String)> playlistID = [('להיטים ישראלים שמחים', '34KQnVhvJ5NykF9Qiyhu7i'),('להיטים ישראלים מכל הזמנים', '3UB7bHg8kYOCjR8QL5VfG5'),('להיטים ישראלים שקטים', '61kO2AKik6Izzwz5gj1DSG'),('2000+', '5ETEbkeIT6E95kP0VdX2Hj'), ('שנות ה90 ישראלי','79wRg9wyXISXhX1ldGxMhl'), ('מיקס ישראלי','58QkZVMLek85MgV9zXkdIU'), ('מסיבות ישראלי','7iASxyiMJUD7FSQtaXTIV2'), ('להיטים מכל הזמנים','0C04dRFq1PbRSJu6BWb3Qu'), ('מיקס','4CBHdEfpEXyDI0w86xhkGE')];
                int playlistIDIndex = 0, timeValue = 35, pointValue = 10;
                final List<String>? playersName = await showDialog(
                  context: context,
                  barrierDismissible: true,
                  useRootNavigator: false,
                  barrierColor: const Color(0x95000000),
                  routeSettings: RouteSettings(name: 'popUp'),
                  builder: (BuildContext context) => Dialog(
                    child: StatefulBuilder(
                      builder: (contextStatefulBuilder, setState) {
                        return Container(
                          alignment: Alignment.center,
                          //margin: EdgeInsets.zero,
                          constraints: BoxConstraints(minHeight: 550, maxHeight: 550, minWidth: 290, maxWidth: 290),
                          padding: EdgeInsets.fromLTRB(7, 10, 7, 10),
                          //decoration: BoxDecoration(),
                          child: Flex(
                            direction: Axis.vertical,
                            children: [
                              const Text('Create New Room', style: TextStyle(fontSize: 18)),
                              const Text('Set up your music game', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF94a3b8))),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Form(
                                  key: formKey,
                                  child: ListView.separated(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    itemCount: playerList.length,
                                    itemBuilder: (_, index) => TextFormField(
                                      maxLength: 20,
                                      decoration: InputDecoration(counterText: '', hintText: index == 0 ? 'John' : index == 1 ? 'Dor' : 'Ela'),
                                      onChanged: (String str) => playerList[index]  = str,
                                      validator: (String? value) {
                                        if (value==null || value.isEmpty) {
                                          return 'לא ניתן להשאיר ריק';
                                        }
                                        else if (playerList.where((item) => item == value).length > 1) {
                                          return 'לא ניתן אותו שם';
                                        }
                                        return null;
                                      }
                                    ),
                                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                spacing: 5,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (playerList.length < 8) CircleAvatar(child: TextButton(onPressed: () => setState(() => playerList.add('')), child: Text('+'))),
                                  if (playerList.length > 2) CircleAvatar(child: TextButton(onPressed: () => setState(() => playerList.removeLast()), child: Text('-', style: TextStyle(color: Color(0xFFf44336)))))
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 100, width: 300,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(border: Border.all(color: Color(0xffFFFFFF),width: 3)),
                                child: ListView.separated(
                                  itemCount: playlistID.length,
                                  itemBuilder: (_, index) {
                                    final song = playlistID[index];
                                    return InkWell(onTap: () => setState(() => playlistIDIndex = index), child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: playlistIDIndex == index ? Colors.blueAccent : null), child: Text(song.$1, textAlign: TextAlign.center)));
                                  },
                                  separatorBuilder: (_, index) => const SizedBox(width: 5),
                                )
                              ),
                              const SizedBox(height: 10),
                              Text('Round seconds: $timeValue'),
                              Slider(
                                value: timeValue.toDouble(),
                                min: 5,
                                max: 60,
                                label: 'Round seconds: $timeValue',
                                onChanged: (v) => setState(() => timeValue = v.toInt()),
                                inactiveColor: Color(0xff000000),
                              ),
                              const SizedBox(height: 10),
                              Text('Wining Point: $pointValue'),
                              Slider(
                                value: pointValue.toDouble(),
                                min: 5,
                                max: 20,
                                label: 'Wining Point: $pointValue',
                                onChanged: (v) => setState(() => pointValue = v.toInt()),
                                inactiveColor: Color(0xff000000),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () => (formKey.currentState?.validate()??false) ? Navigator.pop(context, playerList) : null,
                                style: ElevatedButton.styleFrom(minimumSize: const Size(150,40), maximumSize: const Size(150,40), backgroundColor: const Color(0xffFDB95A)),
                                child: Text('CREATE GAME')
                              ),
                            ],
                          )
                        );
                      }
                    ),
                  )
                );
                if (playersName != null) {
                  context.go('/game', extra: {'players': playersName.map((name) => {'name': name, 'hitsters': 2, 'songs': <Map<String, dynamic>>[]}).toList().cast<Map<String, dynamic>>(), 'turnTime': timeValue, 'maxPoints': pointValue, 'playlistID': playlistID[playlistIDIndex].$2});
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(100,45), maximumSize: const Size(100,45), backgroundColor: const Color(0xffFDB95A)),
              child: Text('START')
            )
          ],
        ),
      ),
    );
  }
}
