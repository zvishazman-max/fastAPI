import 'dart:convert';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hitster/functions/storage.dart' show writeToStorage, readKeyFromStorageAndDecodeMap, deleteAllFromStorage;
import 'package:hitster/widgets/VinylWidget.dart' show VinylOnlyWidget, VinylWidget;
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../widgets/clock.dart';

class GamePage extends StatefulWidget {
  final Map<String,dynamic>? gameData;
  const GamePage({super.key, this.gameData});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Map<String, dynamic> _gameMap = {};
  // {
  //   'players': [
  //     {'name': 'john', 'hitsters': 2, 'songs': <Map<String, dynamic>>[]}, //{'date': DateTime(1991), 'name': 'ככה וככה', 'artist': 'שלום חנוך', 'image': 'https://i.scdn.co/image/ab67616d0000b27316bbc62c44eff222f9646a18'}
  //     {'name': 'mike', 'hitsters': 2, 'songs': <Map<String, dynamic>>[]}, //{'date': DateTime(2018), 'name': 'רואים רחוק, רואים שקוף', 'artist': 'מאיר בנאי', 'image': 'https://i.scdn.co/image/ab67616d0000b273005d3a77d34406562553811a'}
  //     {'name': 'dana', 'hitsters': 2, 'songs': <Map<String, dynamic>>[]}, //{'date': DateTime(1985), 'name': "ככלות הקול והתמונה", 'artist': 'דני בסן', 'image': 'https://i.scdn.co/image/ab67616d0000b273cf10e5a8ed5f7e9a7de00608'}
  //   ],
  //   'turnTime': 30,
  //   'maxPoints': 10,
  // };
  final _player = AudioPlayer();
  List<Map<String, dynamic>> _tracks = [];
  final String _clientId = "1d48a1e3e8d246aabbfe0b8063482238";
  final String _clientSecret = "a87bfb69a9fd4cf2b2979fb8ed773e35";
  String? _roundWinner;
  //final String _playlistId = "3UB7bHg8kYOCjR8QL5VfG5"; //3MwDNASGdAfS0bFGgmkbLC
  int? _turnStatus; // null = begin game | 0 = playing | 1 = confirm turn | 2 = finish turn
  int _turnsIndex = 0, _pickPosition = -1, _playerUsingHitster = -1, _savePickPosition = -1, _tabIndex = 0, _randomNumber = -1; //, _pickHitsterPosition = -1, _lastPickHitsterPosition = -1
  final List<(int, int)> _pickHitster = []; //('pos' , '_playerUsingHitster')
  bool gameEnd = false, loading = true, _startedMusic = false, _addedHitster = false;
  final List<Map<String, dynamic>> players = [], playerSongs = [], _savePlayerSongs = [];
  (List<int>, List<int>, List<int>) _calculate = ([], [], []);

  @override
  void initState() {
    _setGame();
    super.initState();
  }

  @override
  void dispose() {
    //_player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _setGame() async {
    print('widget.gameData: ${widget.gameData}');
    if (widget.gameData == null) {
      _gameMap.addAll(await _getGame());
      //final players = (_gameMap['players'] as List).cast<Map<String, dynamic>>();
      //final songs = (_gameMap['songs'] as List).cast<Map<String, dynamic>>();
      _gameMap['players'] = _gameMap['players'].toList().cast<Map<String, dynamic>>();
      for (var element in _gameMap['players']) {
        element['songs'] = element['songs'].toList().cast<Map<String, dynamic>>();
      }
      print('_gameMap: $_gameMap');
    }
    else {
      print('write to');
      _gameMap.addAll(widget.gameData??{});
      await writeToStorage('game', valueMap: _gameMap);
    }

    print('_gameMap[players]: ${_gameMap['players'].runtimeType}\n${_gameMap['players'] is List<Map<String, dynamic>>}');

    await _initSpotify();
  }

  Future<Map<String, dynamic>> _getGame() async => await readKeyFromStorageAndDecodeMap('game');

  Future<void> _initSpotify() async {
    final token = await _getAppAccessToken(_clientId, _clientSecret);
    if (token != null) {
      await _loadPlaylistTracks(_gameMap['playlistID'], token);
    }
  }

  Future<String?> _getAppAccessToken(String id, String secret) async {
    final credentials = base64Encode(utf8.encode("$id:$secret"));

    final response = await http.post(
      Uri.parse("https://accounts.spotify.com/api/token"),
      headers: {"Authorization": "Basic $credentials", "Content-Type": "application/x-www-form-urlencoded"},
      body: {"grant_type": "client_credentials"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["access_token"];
    } else {
      print("Error getting token: ${response.body}");
      return null;
    }
  }

  Future<void> _loadPlaylistTracks(String playlistId, String accessToken) async {

    try {
      final url = Uri.parse("https://api.spotify.com/v1/playlists/$playlistId/tracks?market=IL"); //&additional_types=preview_url

      final response = await http.get(url, headers: {"Authorization": "Bearer $accessToken"});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data["items"] as List;
        print('items: ${items.length}\n(gameMap[players].length + 1: ${(_gameMap['players']??[]).length + 1}');


        _gameMap['players'].shuffle(Random());
        _turnsIndex = (_gameMap['players'].length);
        print('gameMap: $_gameMap\nturnsIndex: $_turnsIndex');
        items.shuffle(Random());
        _tracks = items.map((item) {
          final t = item["track"];
          //print('t: $t');
          return {
            "name": t["name"],
            "artist": t["artists"][0]["name"],
            "preview": t["preview_url"],
            "image": t["album"]["images"].isNotEmpty ? t["album"]["images"][0]["url"] : null,
            "date": DateTime.tryParse(t["album"]["release_date"])??DateTime.tryParse('${t["album"]["release_date"]}-01-01')??t["album"]["release_date"]??'',
            "id": t["id"],
          };
        }).toList();

        for (int i=0; i < (_gameMap['players']??[]).length + 1; i++) {
          if (_tracks.length > i) _tracks[i]['preview'] = await getPreviewUrl(trackId: items[i]['track']['id']);
          print('_tracks[$i][preview]: ${_tracks[i]['preview']}');
          if (i < (_gameMap['players']??[]).length) _gameMap['players'][i]['songs'].add(_tracks[i]);
        }
        setState(() => loading = false);
      }
      else {
        print("Error getting playlist: ${response.body}");
      }
    }
    catch (e) {
      print('error: $e');
    }
  }

  Future<String?> getPreviewUrl({String? trackId, List<String>? trackIds}) async {
    final url = "https://fast-api-hitster.vercel.app/preview/$trackId"; // http://127.0.0.1:8000

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['preview_url'];
    }
    else {
      print("Preview not found");
      return null;
    }
  }

  Future<void> _loadUrl({required String url}) async => await _player.setUrl(url);

  void _musicPlay(bool stop) {
    if (_player.volume < 0.5) _player.setVolume(0.7);
    if (_player.playing) {
      print('stop: $stop');
      if (stop) {
        _player.stop();
        _player.seek(const Duration(seconds: 0, milliseconds: 0));
      }
      else {
        _player.pause();
      }
    }
    else {
      print('_turnStatus: $_turnStatus');
      if (_turnStatus == 0) _startedMusic = true;
      _player.play();
    }
    setState(() {});
  }

  List<Map<String, dynamic>> playersNotPlaying() {
    final List<Map<String, dynamic>> list = _gameMap['players'].where((player2) => player2['name'] != _gameMap['players'][_turnsIndex%((_gameMap['players']??[]).length)]['name'] && player2['hitsters'] > 0).toList();
    if (list.length == 1) _playerUsingHitster  = _gameMap['players'].indexWhere((user) => user['name'] == list[0]['name']);
    return list;
  }

  void getPreviewUrlY() => getPreviewUrl(trackId: _tracks[_turnsIndex + 1]['id']).then((value) {if (value != null) {_tracks[_turnsIndex + 1]['preview'] = value;} else {_tracks.removeAt(_turnsIndex + 1);getPreviewUrlY();}});

  void _finishTurn(Map<String, dynamic> player) {
    if (_player.playing) _player.stop();
    _startedMusic = false;
    if ((_turnsIndex + 1) < _tracks.length) getPreviewUrlY();
    //if (_pickPosition == -1) _pickPosition = Random().nextInt(player['songs'].length);
    setState(() => _turnStatus = 1);
  }

  @override
  Widget build(BuildContext context) {
    //print('try: ${gameMap['players'][turnsIndex%(gameMap['players']??[]).length]['songs']}');
    final Map<String, dynamic> player = _gameMap.isNotEmpty ? _gameMap['players'][_turnsIndex%(_gameMap['players'].length)] : {};

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          children: [
            Text('${player['name']}'),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              deleteAllFromStorage();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100,40), maximumSize: const Size(100,40), backgroundColor: Colors.red),
            child: Text('Close game')
          ),
          const SizedBox(width: 5),

          // IconButton(
          //   icon: const Icon(Icons.exit_to_app), //⌦⌫⌧
          //   onPressed: () {
          //     deleteAllFromStorage();
          //     context.go('/');
          //   },
          //   tooltip: 'Leave Game',
          // ),
        ],
      ),
      body: LayoutBuilder(
        builder: (_, boxConstraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: gameEnd ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('The Winner is', style: TextStyle(fontSize: 20)),
                  Text('${(_gameMap['players'] as List<Map<String, dynamic>>).where((user) => user['songs'].length == _gameMap['maxPoints']).toList()[0]['name']}', style: TextStyle(fontSize: 30, color: Colors.amber)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      deleteAllFromStorage();
                      context.go('/');
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(100,40), maximumSize: const Size(100,40), backgroundColor: Colors.red),
                    child: Text('Close game')
                  ),
                ],
              ),
            ):
            Column(
              children: [
                Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    (!_startedMusic) ? CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.blueAccent,
                      child: CircleAvatar(
                        radius: 70,
                        child: loading ? const CircularProgressIndicator() : Text(
                          _turnStatus == null ? 'Round\n${_turnsIndex - ((_gameMap['players']??[]).length) + 1}' : _turnStatus == 0 ? 'Press Play' : _turnStatus == 1 ? 'HITSTER TIME' : 'NEXT PLAYER\n${_gameMap['players'][(_turnsIndex+1)%((_gameMap['players']??[]).length)]['name']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xffFFFFFF), fontSize: 22, fontWeight: FontWeight.bold)
                        )
                      )
                    ):
                    TimerWidget(
                      totalTimeInSeconds: _gameMap['turnTime']??60,
                      onTimerEnd: () => _finishTurn(player),
                    ),
                    Expanded(
                      child: Container(
                        height: 150,
                        constraints: BoxConstraints(maxWidth: 220, minWidth: 200),
                        decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 3), borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: ListView.separated(
                          itemCount: (_gameMap['players']??[]).length,
                          itemBuilder: (_, index) {
                            final playerTable = _gameMap['players'][index];
                            final playerSongs = playerTable['name'] == player['name'] ? _savePlayerSongs : playerTable['songs'];
                            return Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(color: index == _turnsIndex%((_gameMap['players']??[]).length) ? const Color(0xff000000) : null, border: Border.all(color: index == _turnsIndex%((_gameMap['players']??[]).length) ?  Color(0xff2196F3) : Color(0x00FFFFFF), width: 1)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 5,
                                    children: [
                                      if (index == _turnsIndex%((_gameMap['players']??[]).length)) Image.network(
                                        'https://raw.githubusercontent.com/zvishazman-max/fastAPI/refs/heads/main/vinyl.png',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.cover,
                                      ),
                                      Text('${playerTable['name']}', style: TextStyle(fontSize: 20)),
                                      CircleAvatar(radius: 10, backgroundColor: Colors.blue, child: Text('${playerTable['hitsters']}', style: TextStyle(fontSize: 14, color: Color(0xffFFFFFF))))
                                    ],
                                  ),

                                  Text('${playerSongs.length + (playerTable['name'] == player['name'] && _turnStatus == 2  && _pickPosition == _savePickPosition ? 1 : 0)}', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xffFFFFFF)))
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (_, index) => const SizedBox(height: 5),
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: 250,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: player['songs'].length,
                    itemBuilder: (_, indexInTracks) {
                      final hiddenSong = _tracks[_turnsIndex];
                      final song = player['songs'][indexInTracks];

                      return SizedBox(
                        width: player['songs'].length == 1 ? boxConstraints.maxWidth - 20 : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: indexInTracks == 0 ? MainAxisAlignment.center : MainAxisAlignment.center,
                          children: [
                            if (indexInTracks == 0 && ((_turnStatus == 0 && _pickPosition != 0) || (_turnStatus == 1 && _playerUsingHitster > -1 && (!_pickHitster.any((p) => p.$1 == 0))  && _pickPosition != 0))) ...{
                              ElevatedButton(
                                onPressed: () {
                                  if (_turnStatus == 0) {
                                    if (_pickPosition >- 1) player['songs'].removeAt(_pickPosition);
                                    player['songs'].insert(0, hiddenSong);
                                    setState(() => _pickPosition = 0);
                                  }
                                  else {
                                    if (_pickPosition > -1) _pickPosition++; //&& (indexInTracks + 1) < _pickPosition
                                    adjustList(useList: _pickHitster, index: 0, add: true);
                                    player['songs'].insert(0, hiddenSong);
                                    _pickHitster.add((0, _playerUsingHitster)); // (indexInTracks + 1)
                                    _gameMap['players'][_playerUsingHitster]['hitsters']--;
                                    if (_gameMap['players'][_playerUsingHitster]['hitsters']==0) _playerUsingHitster = -1;
                                    setState(() {});
                                  }
                                  //print('press: 0\n_pickPosition: $_pickPosition\n_playerUsingHitster: $_playerUsingHitster\n_pickHitster: $_pickHitster');
                                },
                                style: ElevatedButton.styleFrom(minimumSize: const Size(65,40), maximumSize: const Size(65,40)),
                                child: FittedBox(fit: BoxFit.scaleDown, child: Text('Older'))
                              ),
                              const SizedBox(width: 10)
                            },
                            MouseRegion(
                              cursor: (_pickPosition == indexInTracks && _turnStatus == 0) || (_pickHitster.any((p) => p.$1 == indexInTracks) && _turnStatus == 1) ? SystemMouseCursors.click : MouseCursor.defer,
                              child: GestureDetector(
                                onTap: (_pickPosition == indexInTracks && _turnStatus == 0) || (_pickHitster.any((p) => p.$1 == indexInTracks) && _turnStatus == 1) ? () {
                                  if (_turnStatus == 0) {
                                    player['songs'].removeAt(_pickPosition);
                                    setState(() => _pickPosition = -1);
                                  }
                                  else {
                                    player['songs'].removeAt(indexInTracks);
                                    final (int, int) save = _pickHitster.removeAt(_pickHitster.indexWhere((p) => p.$1 == indexInTracks));
                                    _gameMap['players'][save.$2]['hitsters']++;
                                    adjustList(useList: _pickHitster, index: save.$1, add: false);
                                    if (indexInTracks < _pickPosition) _pickPosition--;
                                    setState(() {});
                                  }
                                  //print('remove:\n_pickPosition: $_pickPosition\n_playerUsingHitster: $_playerUsingHitster\n_pickHitster: $_pickHitster');
                                } : null,
                                child: Container(decoration: BoxDecoration(border: Border.all(color: ((_savePickPosition>-1 && indexInTracks == _savePickPosition) ? Colors.yellow : Colors.transparent))), child: VinylWidget(albumImageUrl: song["image"], name: song["name"], date: song['date'], artist: song["artist"], showDetails: (_pickPosition != indexInTracks && (!_pickHitster.any((p) => p.$1 == indexInTracks))) || (_turnStatus == 2 && ((_pickPosition == indexInTracks && indexInTracks == _savePickPosition) || (_pickPosition != _savePickPosition && _pickHitster.any((p) => _calculate.$1.contains(p.$1)) && _calculate.$1[_randomNumber] == _savePickPosition && indexInTracks == _savePickPosition))) , playerName: _pickPosition == indexInTracks ? (true, player['name']) : _pickHitster.indexWhere((p) => p.$1 == indexInTracks) >= 0 ? (false, _gameMap['players'][_pickHitster[_pickHitster.indexWhere((p) => p.$1 == indexInTracks)].$2]['name']) : (false, 'HIT')))
                              ),
                            ),
                            if ((_turnStatus == 0 && (_pickPosition != indexInTracks) && (_pickPosition != (indexInTracks + 1))) || (_turnStatus == 1 && _playerUsingHitster > -1  && (!_pickHitster.any((p) => p.$1 == indexInTracks)) && (!_pickHitster.any((p) => p.$1 == indexInTracks + 1)) && (_pickPosition != indexInTracks) && (_pickPosition != (indexInTracks + 1)))) ...{
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (_turnStatus == 0) {
                                    int rightIndex = (indexInTracks + 1);
                                    if (_pickPosition>-1) {
                                      player['songs'].removeAt(_pickPosition);
                                      if (_pickPosition < rightIndex) rightIndex--;
                                    }

                                    if (_pickPosition<0 && rightIndex == player['songs'].length) {
                                      player['songs'].add(hiddenSong);
                                      setState(() => _pickPosition = rightIndex);
                                    }
                                    else {
                                      player['songs'].insert(rightIndex, hiddenSong);
                                      setState(() => _pickPosition = rightIndex);
                                    }
                                  }
                                  else {
                                    if (_pickPosition > -1 && (indexInTracks + 1) < _pickPosition) _pickPosition++;
                                    adjustList(useList: _pickHitster, index: (indexInTracks + 1), add: true);
                                    _pickHitster.add(((indexInTracks + 1) , _playerUsingHitster));
                                    _gameMap['players'][_playerUsingHitster]['hitsters']--;
                                    if (_gameMap['players'][_playerUsingHitster]['hitsters']==0) _playerUsingHitster = -1;
                                    if (indexInTracks + 1 == player['songs'].length) {
                                      player['songs'].add(hiddenSong);
                                    }
                                    else {
                                      player['songs'].insert((indexInTracks + 1), hiddenSong);
                                    }
                                    setState(() {});
                                  }
                                  //print('press: 0\n_pickPosition: $_pickPosition\n_playerUsingHitster: $_playerUsingHitster\n_pickHitster: $_pickHitster');
                                },
                                style: ElevatedButton.styleFrom(minimumSize: const Size(65,40), maximumSize: const Size(65,40)),
                                child: FittedBox(fit: BoxFit.scaleDown, child: Text(indexInTracks < (player['songs'].length - 1) ? 'Between' : 'Newer'))
                              ),
                            }
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, index) => const SizedBox(width: 10),
                  ),
                ),

                const SizedBox(height: 10),

                if ((_turnStatus == 0 && _pickPosition >-1) || _turnStatus != 0 && (!loading)) ElevatedButton(
                  onPressed: () async {
                    if (_turnStatus == null) {
                      _savePlayerSongs.addAll(List.from((_gameMap['players']??[])[_turnsIndex%((_gameMap['players']??[]).length)]['songs']));
                      print('date: ${_tracks[_turnsIndex]['date']}');
                      _loadUrl(url: _tracks[_turnsIndex]['preview']);
                      setState(() => _turnStatus = 0);
                    }
                    else if (_turnStatus == 0) {
                      _finishTurn(player);
                    }
                    else if (_turnStatus == 1) {
                      print('player[songs]: ${player['songs']}\n_savePlayerSongs: $_savePlayerSongs\n_tracks[_turnsIndex][date].year: ${_tracks[_turnsIndex]['date'].year}');
                      _calculate = findNewYearPositions(B: _savePlayerSongs, C: player['songs'], newYear: _tracks[_turnsIndex]['date'].year);
                      print('_calculate: $_calculate\n_pickPosition: $_pickPosition');
                      if (_calculate.$1.contains(_pickPosition)) {
                        _savePickPosition = _pickPosition;
                        _roundWinner = player['name'];
                        if (player['songs'].length >= _gameMap['maxPoints']) gameEnd = true;
                      }
                      else if (_pickHitster.any((p) => _calculate.$1.contains(p.$1))) {
                        _randomNumber = (_calculate.$1.isEmpty || _calculate.$1.length == 1) ? 0 : _calculate.$1[Random().nextInt(_calculate.$1.length)];
                        print('randomNumber: $_randomNumber');
                        _savePickPosition = _calculate.$1[_randomNumber];
                        print('_pickHitster: $_pickHitster');

                        final int hitsterWinnerPlayerPosition = _pickHitster[_pickHitster.indexWhere((hit) => hit.$1 == _calculate.$1[_randomNumber])].$2;
                        print('_gameMap[players][_hitserWinnerPlayerPosition]: ${_gameMap['players'][hitsterWinnerPlayerPosition]['songs']}');
                        _roundWinner = _gameMap['players'][hitsterWinnerPlayerPosition]['name'];
                        final calculate = findInsertPositions(_gameMap['players'][hitsterWinnerPlayerPosition]['songs'], _tracks[_turnsIndex]['date'].year);
                        print('calculate: $calculate');
                        if (calculate[0] == _gameMap['players'][hitsterWinnerPlayerPosition]['songs'].length) {
                          _gameMap['players'][hitsterWinnerPlayerPosition]['songs'].add(_tracks[_turnsIndex]);
                        }
                        else {
                          _gameMap['players'][hitsterWinnerPlayerPosition]['songs'].insert(calculate[0], _tracks[_turnsIndex]);
                        }

                        if ((_pickHitster.isNotEmpty && (!_calculate.$1.contains(_pickPosition)) && _gameMap['players'][_pickHitster[_pickHitster.indexWhere((hit) => hit.$1 == _calculate.$1[_randomNumber])].$2]['songs'].length >= _gameMap['maxPoints'])) gameEnd = true;
                      }
                      else {
                        print('calculate.3: ${_calculate.$3}');
                        _savePickPosition = _calculate.$3[0];
                        if (_savePickPosition == player['songs'].length) {
                          player['songs'].add(_tracks[_turnsIndex]);
                        }
                        else {
                          player['songs'].insert(_savePickPosition, _tracks[_turnsIndex]);
                        }
                        final int finalNumber = _savePickPosition == (player['songs'].length-1) ? (player['songs'].length-1) : _savePickPosition;
                        if (finalNumber < _pickPosition) _pickPosition++;
                        adjustList(useList: _pickHitster, index: finalNumber, add: true);
                        //_calculate = findNewYearPositions(B: _savePlayerSongs, C: player['songs'], newYear: _tracks[_turnsIndex]['date'].year);
                        //print('new _calculate: $_calculate\n_pickPosition: $_pickPosition');
                      }

                      print('_pickPosition: $_pickPosition\n_pickHitster: $_pickHitster\n_savePickPosition: $_savePickPosition\nplayer[songs].length: ${player['songs'].length}');

                      setState(() => _turnStatus = 2);
                    }
                    else if (_turnStatus == 2) {
                      final bool playerRight = (_savePickPosition != _pickPosition);
                      if ((_savePickPosition > -1) && playerRight && (!_pickHitster.any((p) => p.$1 == _savePickPosition))) {
                        print('check _savePickPosition: $_savePickPosition\n_pickPosition: $_pickPosition\n_pickHitster: $_pickHitster\nlength: ${player['songs'].length}');
                        player['songs'].removeAt(_savePickPosition);
                        adjustList(useList: _pickHitster, index: _savePickPosition, add: false);
                        if (_savePickPosition < _pickPosition) _pickPosition--;
                      }
                      print('_pickHitster 1: $_pickHitster\n_pickPosition: $_pickPosition\nlength: ${player['songs'].length}');
                      if (playerRight) {
                        player['songs'].removeAt(_pickPosition);
                        adjustList(useList: _pickHitster, index: _pickPosition, add: false);
                      }
                      print('_pickHitster 2: $_pickHitster\nlength: ${player['songs'].length}');

                      for (var action in _pickHitster) {
                        player['songs'].removeAt(action.$1);
                        adjustList(useList: _pickHitster, index: action.$1, add: false);
                      }
                      print('after');
                      _turnsIndex++;
                      print('load: ${_tracks[_turnsIndex]}');
                      if (_turnsIndex >= _tracks.length) {
                        gameEnd = true;
                        print('game End');
                      }
                      if (_tracks[_turnsIndex]['preview'] != null) {
                        _addedHitster = false;
                        _playerUsingHitster = -1;
                        _pickHitster.clear();
                        _pickPosition = -1;
                        _savePickPosition = -1;
                        _roundWinner=null;
                        _randomNumber = -1;
                        await _loadUrl(url: _tracks[_turnsIndex]['preview']);
                        _savePlayerSongs.clear();
                        _savePlayerSongs.addAll(List.from((_gameMap['players'] ?? [])[_turnsIndex%((_gameMap['players']??[]).length)]['songs']));

                        print('date: ${_tracks[_turnsIndex]['date']}');
                        setState(() => _turnStatus = 0);
                      }
                      else {
                       print('loading');
                      }
                    }
                    //await writeToStorage('game', valueMap: _gameMap);
                  },
                  child: Text(_turnStatus == null ? 'START GAME' : _turnStatus == 0 ? 'CONFIRM' : _turnStatus == 1 ? 'CONFIRM HITSTER' : 'NEXT TURN')
                ),

                if (_turnStatus == 1 && playersNotPlaying().isNotEmpty) ...{
                  const SizedBox(height: 10),

                  Container(
                    height: 50, width: 300,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(border: Border.all(color: Color(0xffFFFFFF),width: 3)),
                    child: Row(
                      children: playersNotPlaying().map((player2) => Expanded(child: InkWell(onTap: () => setState(() => _playerUsingHitster = _gameMap['players'].indexWhere((user) => user['name'] == player2['name'])), child: Container(alignment: Alignment.center, decoration: BoxDecoration(border: Border(right: BorderSide(color: Color(0xffFFFFFF))), color: _playerUsingHitster > -1 && player2['name'] == _gameMap['players'][_playerUsingHitster]['name'] ? Colors.blueAccent : null), child: Text(player2['name']))))).toList(),
                    )
                  )
                },

                if (_turnStatus == 2)... {
                  const SizedBox(height: 10),
                  Text(_roundWinner != null ? '$_roundWinner Won the Round !!!' : 'No winner For this Round !!!'),
                  const SizedBox(height: 5),
                  if (_pickPosition == _savePickPosition && (!_addedHitster)) ElevatedButton(onPressed: () {player['hitsters']++; setState(() => _addedHitster = true);}, child: Text('add $_roundWinner an hitster'))
                  //VinylWidget(albumImageUrl: _tracks[_turnsIndex]["image"], name: _tracks[_turnsIndex]["name"], date: _tracks[_turnsIndex]['date'], artist: _tracks[_turnsIndex]["artist"], showDetails: true),
                },

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: () => setState(() => _tabIndex = 0), style: ElevatedButton.styleFrom(backgroundColor: _tabIndex == 0 ? Colors.blueAccent : Colors.transparent), child: Text('Players Songs'))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton(onPressed: () => setState(() => _tabIndex = 1), style: ElevatedButton.styleFrom(backgroundColor: _tabIndex == 1 ? Colors.blueAccent : Colors.transparent), child: Text('All songs'))),
                  ],
                ),

                const SizedBox(height: 10),

                _tabIndex ==0 ? SizedBox(
                  height: (_gameMap['players']??[]).length * 130 > 390 ? 390 : (_gameMap['players']??[]).length * 130,
                  child: ListView.separated(
                    itemCount: (_gameMap['players']??[]).length,
                    itemBuilder: (BuildContext context, int playerIndex) {
                      final listPlayer = _gameMap['players'][playerIndex];
                      final listPlayerSongs = (listPlayer['name'] == player['name']) ? _savePlayerSongs : listPlayer['songs'];
                      return  Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: const BoxDecoration(color: Color(0xff1e293b)),
                        child: Column(
                          children: [
                            Text('${listPlayer['name']}'),
                            SizedBox(
                              height: 100,
                              child: ListView.separated(
                                itemCount: listPlayerSongs.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) => MouseRegion(cursor: _turnStatus != 0 ? SystemMouseCursors.click : MouseCursor.defer, child: GestureDetector(onTap: _turnStatus != 0 ? () async {if (_player.playing) {_player.stop();} else {await _player.setUrl(listPlayerSongs[index]['preview']);_player.play();setState(() {});}} : null, child: VinylOnlyWidget(albumImageUrl: listPlayerSongs[index]["image"], name: listPlayerSongs[index]["name"], date: listPlayerSongs[index]['date'], artist: listPlayerSongs[index]["artist"]))),
                                separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 15),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                  ),
                ):
                Container(
                  height: 130,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: const BoxDecoration(color: Color(0xff1e293b)),
                  child: Column(
                    children: [
                      Text('All Songs that played'),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          itemCount: loading ? 0 : _turnsIndex,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) => MouseRegion(cursor: _turnStatus != 0 ? SystemMouseCursors.click : MouseCursor.defer, child: GestureDetector(onTap: _turnStatus != 0 ? () async {if (_player.playing) {_player.stop();} else {await _player.setUrl(_tracks[index]['preview']);_player.play(); setState(() {});}} : null, child: VinylOnlyWidget(albumImageUrl: _tracks[index]["image"], name: _tracks[index]["name"], date: _tracks[index]['date'], artist: _tracks[index]["artist"]))),
                          separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 15),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
      ),
      floatingActionButton: (_turnStatus == 0 || _player.playing) ? CircleAvatar(
        backgroundColor: Color(0xffFFFFFF),
        child: TextButton(
          onLongPress: () => _musicPlay(true),
          onPressed: () => _musicPlay(false),
          child: Text(_player.playing ? '||' : '▶' , style: TextStyle(color: Color(0xff000000), fontWeight: FontWeight.bold)) //_player.playing ? Icons.pause : Icons.play_arrow, color: Color(0xff000000) //♩♪♫♬
        )
      ) : null
    );
  }


  void adjustList({required List<(int, int)> useList, required int index, required bool add}) {
    final List<(int, int)> list = List.from(useList);
    useList.clear();
    useList.addAll(list.map((number) {
      if (number.$1 >= index) return (number.$1 + (add ? 1 : -1), number.$2);
      return (number.$1,number.$2);
    }).toList());
  }

  void adjustListYears({required List<int> useList, required int index, required bool add}) {
    print('adjustListYears add: $add');
    final List<int> list = List.from(useList);
    int addNumber = 1;
    (useList).clear();
    useList.addAll(list.map((number) {
      if (number > index) {
        final int result = (number + (add ? (addNumber) : -addNumber));
        if (list.contains(index)) addNumber = 2;
        return result;
      }
      return number;
    }).toList());
  }

  /// מחזיר:
  /// 1. רשימת אינדקסים של פריטים חדשים נכונים ב־C (שאינם קיימים ב־B והם במיקום חוקי)
  /// 2. רשימת אינדקסים של פריטים חדשים לא נכונים ב־C
  /// 3. רשימת אינדקסים *חוקיים* שבהם מותר להכניס newYear (כולל מקומות שאין בהם כרגע פריט)
  (List<int>, List<int>, List<int>) findNewYearPositions({required List<Map<String, dynamic>> B, required List<Map<String, dynamic>> C, required int newYear}) {
    // שמות מקוריים ב-B לאותה שנה
    final Set<String> bNames = {
      for (var item in B)
        if ((item['date'] as DateTime).year == newYear)
          (item['name'] ?? '').toString()
    };

    // למצוא איפה newYear נכנס בתוך B
    int lastLess = -1;
    int firstGreater = B.length;
    for (int i = 0; i < B.length; i++) {
      final y = (B[i]['date'] as DateTime).year;
      if (y < newYear) lastLess = i;
      if (y > newYear && firstGreater == B.length) {
        firstGreater = i;
      }
    }

    // עכשיו נמפה ל-C (שיכול להיות חסר/לא ממויין)
    int cLastLess = -1;
    int cFirstGreater = C.length;
    for (int i = 0; i < C.length; i++) {
      final y = (C[i]['date'] as DateTime).year;
      if (y <= (lastLess >= 0 ? (B[lastLess]['date'] as DateTime).year : -9999)) {
        cLastLess = i;
      }
      if (y >=
          (firstGreater < B.length
              ? (B[firstGreater]['date'] as DateTime).year
              : 99999) &&
          cFirstGreater == C.length) {
        cFirstGreater = i;
      }
    }

    final Set<int> validSlots = {};
    for (int i = cLastLess + 1; i <= cFirstGreater; i++) {
      validSlots.add(i);
    }

    final List<int> correct = [];
    final List<int> wrong = [];

    for (int i = 0; i < C.length; i++) {
      final item = C[i];
      final y = (item['date'] as DateTime).year;
      if (y != newYear) continue;

      final name = (item['name'] ?? '').toString();
      if (bNames.contains(name)) continue;

      if (validSlots.contains(i)) {
        correct.add(i);
      } else {
        wrong.add(i);
      }
    }

    return (correct, wrong, validSlots.toList()..sort());
  }

  List<int> findInsertPositions(List<Map<String, dynamic>> items, int year) {
    final positions = <int>[];

    for (int i = 0; i <= items.length; i++) {
      final prevYear = (i > 0) ? items[i - 1]['date'].year as int : null;
      final nextYear = (i < items.length) ? items[i]['date'].year as int : null;

      // אם בין prev ל next
      if ((prevYear == null || prevYear <= year) &&
          (nextYear == null || year <= nextYear)) {
        positions.add(i);
      }
    }

    return positions;
  }
}
