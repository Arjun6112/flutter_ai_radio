import 'dart:convert' show json;

import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:flutter_ai_radio/utils/ai_util.dart';

import '../models/radio.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<MyRadio> radios;
  late MyRadio _selectedRadio;
  late Color _selectedColor;
  bool _isPlaying = false;

  final suggestions = [
    "Play",
    "Stop",
    "Play rock msuic",
    "Play some hip hop",
    "pause",
    "Play pop music"
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setupAlan();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  setupAlan() {
    AlanVoice.addButton(
        "796ab18272982519a47a1c479eb4a2952e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);

    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playMusic(_selectedRadio.url);
        break;

      case "stop":
        _audioPlayer.stop();
        break;

      case "next":
        final index = _selectedRadio.id;

        MyRadio newRadio;

        if (index + 1 > radios.length) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index + 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;

      case "prev":
        final index = _selectedRadio.id;

        MyRadio newRadio;

        if (index - 1 <= 0) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index - 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;
    }
  }

  fetchRadios() async {
    final radioJSON = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJSON).radios;
    _selectedRadio = radios[0];
    _selectedColor = Color(int.parse(radios[0].color));
    // print(radios);
    setState(() {});
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
            child: Container(
                color: _selectedColor ?? AIColors.primaryColor1,
                child: radios != null
                    ? [
                        100.heightBox,
                        "All Channels".text.xl.white.semiBold.make().px16()
                      ].vStack()
                    : const Offstage())),
        body: Stack(
          children: [
            VxAnimatedBox()
                .size(context.screenWidth, context.screenHeight)
                .withGradient(LinearGradient(colors: [
                  AIColors.primaryColor2,
                  _selectedColor,
                ], begin: Alignment.topLeft, end: Alignment.bottomRight))
                .make(),
            AppBar(
              title: "AI Radio".text.xl4.bold.white.make().shimmer(
                  primaryColor: Color.fromARGB(255, 247, 85, 99),
                  secondaryColor: Color.fromARGB(255, 253, 168, 0)),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100.0).p12(),
            radios != null
                ? VxSwiper.builder(
                    itemCount: radios.length,
                    aspectRatio: 1.0,
                    enlargeCenterPage: true,
                    onPageChanged: (index) {
                      _selectedRadio = radios[index];
                      _selectedColor = Vx.randomColor;
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      final rad = radios[index];
                      return VxBox(
                              child: ZStack([
                        Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: VxBox(
                                    child: rad.category.text.uppercase.white
                                        .make()
                                        .px16())
                                .height(40)
                                .black
                                .alignCenter
                                .withRounded(value: 10.0)
                                .make()),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: VStack(
                              [
                                rad.name.text.xl3.white.bold.make(),
                                5.heightBox,
                                rad.tagline.text.sm.white.semiBold.make()
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                            )),
                        Align(
                            alignment: Alignment.center,
                            child: [
                              Icon(
                                CupertinoIcons.play_circle,
                                color: Colors.white,
                              ),
                              10.heightBox,
                              "Double tap to play".text.gray300.make()
                            ].vStack())
                      ]))
                          .clip(Clip.antiAlias)
                          .bgImage(DecorationImage(
                              image: NetworkImage(rad.image),
                              fit: BoxFit.cover))
                          .withRounded(value: 60.0)
                          .border(color: Colors.black, width: 2.5)
                          .make()
                          .onInkDoubleTap(() {
                        _playMusic(rad.url);
                      }).p16();
                    }).centered()
                : Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )),
            Align(
              alignment: Alignment.bottomCenter,
              child: [
                if (_isPlaying)
                  "Playing Now - ${_selectedRadio.name} FM"
                      .text
                      .white
                      .bold
                      .makeCentered(),
                Icon(
                        _isPlaying
                            ? CupertinoIcons.stop_circle
                            : CupertinoIcons.play_circle,
                        color: Colors.white,
                        size: 50.0)
                    .onInkTap(() {
                  if (_isPlaying) {
                    _audioPlayer.stop();
                  } else {
                    _playMusic(_selectedRadio.url);
                  }
                })
              ].vStack(),
            ).pOnly(bottom: context.percentHeight * 12)
          ],
          fit: StackFit.expand,
        ));
  }
}
