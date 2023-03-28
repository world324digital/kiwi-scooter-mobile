import 'package:Move/Helpers/constant.dart';
import 'package:Move/Helpers/helperUtility.dart';
import 'package:Move/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'Pages/MenuPage/main_menu.dart';

class Video extends StatefulWidget {
  const Video({super.key});

  @override
  State<Video> createState() => _Video();
}

class _Video extends State<Video> {
  VideoPlayerController _controller = VideoPlayerController.asset("");
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), (() async {
      String videoUrl = await getVideo();
      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {
            isLoading = true;
          });
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        });
    }));
  }

  Future<String> getVideo() async {
    FirebaseService service = FirebaseService();
    String _videoUrl = await service.getVideo();
    return _videoUrl;
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget headerSection = Container(
      padding: const EdgeInsets.only(top: 70, bottom: 30),
      child: Row(
        children: [
          Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                      text: 'How to Ride ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Montserrat-SemiBold',
                      ),
                    ),
                    TextSpan(
                      text: ' eScooter',
                      style: TextStyle(
                        color: Color.fromRGBO(52, 202, 52, 1),
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 20,
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ],
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        color: Colors.white,
        child: Scaffold(
          drawer: Drawer(
            child: MainMenu(pageIndex: 3),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: const Color(0xffB5B5B5),
              ),
            ),
            title: Container(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: <TextSpan>[
                  TextSpan(
                    text: 'How to Ride ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Montserrat-SemiBold',
                    ),
                  ),
                  TextSpan(
                    text: ' eScooter',
                    style: TextStyle(
                      color: Color.fromRGBO(52, 202, 52, 1),
                      fontFamily: 'Montserrat-SemiBold',
                      fontSize: 20,
                    ),
                  ),
                ]),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // headerSection,
              SizedBox(
                height: 30,
              ),
              isLoading
                  ? Container(
                      height: HelperUtility.screenHeight(context) * 0.8,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              VideoPlayer(_controller),
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                    playedColor:
                                        ColorConstants.cPrimaryBtnColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: HelperUtility.screenHeight(context) * 0.7,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: ColorConstants.cPrimaryBtnColor,
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        ),
      ),
    );
  }
}
