import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class FileData {
  final String name;
  final String path;

  FileData({required this.name, required this.path});

  factory FileData.fromJson(Map<String, dynamic> jsonDecode) {
    return FileData(
      name: jsonDecode['name'],
      path: jsonDecode['path'],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer audioPlayer = AudioPlayer();
  String musicName = '';
  bool isPlaying = false;
  PlayerState playerState = PlayerState.stopped;
  List audioList = [];
  int musicIndex = 0;
  Duration duration = const Duration();
  Duration position = const Duration();

  @override
  void initState() {
    super.initState();
    loadAudioFile();
  }

  void loadAudioFile() async {
    String filePath = 'json/generate_audio_list.json';
    String jsonString = await rootBundle.loadString(filePath);
    List list = (jsonDecode(jsonString) as List<dynamic>)
        .map((dynamic item) => FileData.fromJson(item))
        .toList();
    setState(() {
      audioList = list;
      audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          musicIndex = musicIndex == audioList.length - 1 ? 0 : musicIndex + 1;
          handleButtonPressed('path', musicIndex);
        });
      });
      audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
        setState(() => playerState = s);
      });
      audioPlayer.onPositionChanged.listen((Duration p) {
        setState(() {
          position = p;
        });
      });
      audioPlayer.onDurationChanged.listen((Duration d) {
        setState(() {
          duration = d;
        });
      });
    });
  }

  void handleButtonPressed(String buttonType, [int? pressedIndex]) async {
    switch (buttonType) {
      case 'path':
        setState(() {
          isPlaying = true;
          musicIndex = pressedIndex!;
          audioPlayer.play(AssetSource(audioList[musicIndex].path));
        });
        break;
      case 'play':
        setState(() {
          isPlaying = true;
          if (playerState == PlayerState.stopped) {
            audioPlayer.play(AssetSource(audioList[musicIndex].path));
          } else {
            audioPlayer.resume();
          }
        });
        break;
      case 'pause':
        setState(() {
          isPlaying = false;
          audioPlayer.pause();
        });
        break;
      case 'previous':
        setState(() {
          isPlaying = true;
          musicIndex = min((musicIndex - 1), 0);
          audioPlayer.play(AssetSource(audioList[musicIndex].path));
        });
        break;
      case 'next':
        setState(() {
          isPlaying = true;
          musicIndex = musicIndex == audioList.length - 1 ? 0 : musicIndex + 1;
          audioPlayer.play(AssetSource(audioList[musicIndex].path));
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.blue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 50),
                  child: Text(musicName, style: const TextStyle(fontSize: 30)),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(
                      '${formatDuration(position)} / ${formatDuration(duration)}',
                      style: const TextStyle(fontSize: 20.0)),
                ),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: LinearProgressIndicator(
                    value: duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0,
                    backgroundColor: Colors.white,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.pink),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    margin: const EdgeInsets.only(right: 30),
                    child: IconButton(
                      iconSize: 70,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () {
                        handleButtonPressed('previous');
                      },
                    ),
                  ),
                  if (!isPlaying)
                    IconButton(
                      iconSize: 70,
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        handleButtonPressed('play');
                      },
                    ),
                  if (isPlaying)
                    IconButton(
                      iconSize: 70,
                      icon: const Icon(Icons.pause),
                      onPressed: () {
                        handleButtonPressed('pause');
                      },
                    ),
                  Container(
                    margin: const EdgeInsets.only(left: 30),
                    child: IconButton(
                      iconSize: 70,
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {
                        handleButtonPressed('next');
                      },
                    ),
                  ),
                ]),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: audioList.length,
              itemBuilder: (context, index) {
                FileData item = audioList[index];
                return ListTile(
                  title: Text(item.name),
                  onTap: () {
                    handleButtonPressed('path', index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String twoDigits(int n) => n > 9 ? '$n' : '0$n';

  String formatDuration(Duration duration) {
    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
