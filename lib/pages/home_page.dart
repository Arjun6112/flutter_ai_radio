import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ai_radio/utils/ai_util.dart';
import 'package:velocity_x/velocity_x.dart';

import '../models/radio.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyRadio> radios = [];
  @override
  void initState() {
    super.initState();
    fetchRadios();
  }

  fetchRadios() async {
    final radioJSON = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJSON).radios;
    print(radios);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(),
        body: Stack(
          children: [
            VxAnimatedBox()
                .size(context.screenWidth, context.screenHeight)
                .withGradient(LinearGradient(
                    colors: [AIColors.primaryColor1, AIColors.primaryColor2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight))
                .make(),
            AppBar(
              title: "AI Radio".text.xl4.bold.white.make().shimmer(
                  primaryColor: Vx.purple500,
                  secondaryColor: Color.fromRGBO(134, 239, 172, 1)),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100.0).p12(),
            VxSwiper.builder(
                itemCount: radios.length,
                aspectRatio: 1.0,
                enlargeCenterPage: true,
                itemBuilder: (context, index) {
                  // final rad = radios[index];
                  return VxBox(child: ZStack([]))
                      .bgImage(DecorationImage(
                          image: NetworkImage(
                              "https://www.theknotnews.com/wp-content/uploads/2017/02/Fifty-Shades-Poster.jpg"),
                          fit: BoxFit.cover))
                      .withRounded(value: 60.0)
                      .border(color: Colors.black, width: 2.5)
                      .make()
                      .p16()
                      .centered();
                })
          ],
          fit: StackFit.expand,
        ));
  }
}
