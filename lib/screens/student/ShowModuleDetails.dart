import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:video_player/video_player.dart';

import '../../utils/Course.dart';

class ShowModuleDetail extends StatefulWidget {
  final Module module;
  const ShowModuleDetail({Key? key, required this.module}) : super(key: key);

  @override
  State<ShowModuleDetail> createState() => _ShowModuleDetailState();
}

class _ShowModuleDetailState extends State<ShowModuleDetail> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    var module = widget.module;
    return Scaffold(
      appBar: AppBar(
        title: Text("Module Detail"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(module.moduleName,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  module.moduleDescription,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Materials",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),
            buildMaterialList(module.materials),
          ],
        ),
      ),
    );
  }

  Widget buildMaterialList(List<CourseMaterial>? materials) {
    if (materials == null || materials.isEmpty) {
      return Text("No materials available.");
    }

    return Column(
      children:
          materials.map((material) => buildMaterialItem(material)).toList(),
    );
  }

  Widget buildMaterialItem(CourseMaterial material) {
    if (material.materialType == "video") {
      return Card(
          child: Column(children: <Widget>[
        Column(
          children: <Widget>[
            ExpandableVideo(material: material),
          ],
        ),
      ]));
    } else if (material.materialType == "pdf") {
      // return buildPdfViewer(material.materialUrl);
      return Card(
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                ExpandablePdf(material: material),
              ],
            ),
          ],
        ),
      );
    } else {
      return Text("Unsupported material type: ${material.materialType}");
    }
  }
}

class ExpandablePdf extends StatefulWidget {
  final CourseMaterial material;

  const ExpandablePdf({Key? key, required this.material}) : super(key: key);

  @override
  _ExpandablePdfState createState() => _ExpandablePdfState();
}

class _ExpandablePdfState extends State<ExpandablePdf> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.picture_as_pdf),
          title: Text(widget.material.materialName),
          trailing: IconButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            icon: isExpanded
                ? Icon(Icons.keyboard_arrow_up_outlined)
                : Icon(Icons.keyboard_arrow_down_outlined),
          ),
        ),
        isExpanded
            ? Container(
                height: 500,
                child: buildPdfViewer(
                    "https://ncu.rcnpv.com.tw/Uploads/20131231103232738561744.pdf"))
            : Container(),
      ],
    );
  }

  Widget buildPdfViewer(String pdfUrl) {
    return PDFViewerFromUrl(url: pdfUrl);
  }
}

class PDFViewerFromUrl extends StatefulWidget {
  const PDFViewerFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<PDFViewerFromUrl> createState() => _PDFViewerFromUrlState();
}

class _PDFViewerFromUrlState extends State<PDFViewerFromUrl> {
  late PDFViewController _pdfController;
  int currentPage = 0;
  int maxPages = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (_) {}, // Absorb vertical gestures
            child: PDF(
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              onViewCreated: (controller) async {
                _pdfController = controller;
                maxPages = (await _pdfController.getPageCount())!;
                print("MAX : $maxPages");
              },
              pageFling: true,
              onPageChanged: (int? current, int? total) {
                maxPages = total! - 1;
                print('Current page: $current, Total pages: $total');
              },
            ).cachedFromUrl(widget.url),
          ),
        ),
        buildNavigationButtons(),
      ],
    );
  }

  Widget buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            if (currentPage > 0) {
              setState(() {
                currentPage -= 1;
                _pdfController.setPage(currentPage);
              });
            }
          },
        ),
        Text('Page ${currentPage + 1}'),
        IconButton(
          icon: Icon(Icons.keyboard_arrow_right),
          onPressed: () {
            // You need to determine the total number of pages
            // and handle the boundary case accordingly.
            // For simplicity, I'm assuming total pages as 5 here.
            if (currentPage < maxPages) {
              setState(() {
                currentPage += 1;
                _pdfController.setPage(currentPage);
              });
            }
          },
        ),
      ],
    );
  }
}

class ExpandableVideo extends StatefulWidget {
  final CourseMaterial material;

  const ExpandableVideo({Key? key, required this.material}) : super(key: key);

  @override
  _ExpandableVideoState createState() => _ExpandableVideoState();
}

class _ExpandableVideoState extends State<ExpandableVideo> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.video_camera_back),
          title: Text(widget.material.materialName),
          trailing: IconButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              icon: isExpanded
                  ? Icon(Icons.keyboard_arrow_up_outlined)
                  : Icon(Icons.keyboard_arrow_down_outlined)),
        ),
        isExpanded
            ? _BumbleBeeRemoteVideo(vidUrl: widget.material.materialUrl)
            : Container(),
      ],
    );
  }
}

class _BumbleBeeRemoteVideo extends StatefulWidget {
  final String vidUrl;
  const _BumbleBeeRemoteVideo({Key? key, required this.vidUrl})
      : super(key: key);
  @override
  _BumbleBeeRemoteVideoState createState() => _BumbleBeeRemoteVideoState();
}

class _BumbleBeeRemoteVideoState extends State<_BumbleBeeRemoteVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.vidUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
