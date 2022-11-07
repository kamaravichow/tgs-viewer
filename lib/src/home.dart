import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<XFile> _list = [];

  PageController _pageController = PageController();
  late TabController _tabController;
  bool _dragging = false;

  @override
  // init
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _pageController.jumpToPage(_tabController.index);
    });
    _pageController.addListener(() {
      if (_pageController.page == _pageController.initialPage) {
        _tabController.animateTo(0);
      } else {
        _tabController.animateTo(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    File? file = _list.isNotEmpty ? File(_list[0].path) : null;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: SizedBox.shrink(),
        bottom: TabBar(
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Colors.white,
          controller: _tabController,
          tabs: [
            Tab(text: 'File'),
            Tab(text: 'Preview'),
          ],
        ),
      ),
      body: Container(
          color: Colors.black,
          child: PageView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(50),
                height: double.infinity,
                // dashed border
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white54,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropTarget(
                  onDragDone: (detail) {
                    // json mime
                    if (detail.files.single.name.contains('.json') ||
                        detail.files.single.name.contains('.zip') ||
                        detail.files.single.name.contains('.tgs')) {
                      debugPrint(detail.files.single.path);
                      _pageController.jumpToPage(1);
                      setState(() {
                        _list.clear();
                        _list.addAll(detail.files);
                      });
                    } else {
                      debugPrint('Mime : ${detail.files.single.mimeType}');
                      // snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          content: Text('Invalid file type'),
                        ),
                      );
                    }
                  },
                  onDragEntered: (detail) {
                    setState(() {
                      _dragging = true;
                    });
                  },
                  onDragExited: (detail) {
                    setState(() {
                      _dragging = false;
                    });
                  },
                  child: Container(
                      height: 200,
                      width: 200,
                      color: _dragging
                          ? Colors.blue.withOpacity(0.4)
                          : Colors.black26,
                      child: const Center(
                          child: Text("Drop TGS file or .tgs bundle here",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20)))),
                ),
              ),
              Container(
                height: double.infinity,
                width: double.infinity,
                padding: const EdgeInsets.all(100),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                margin: const EdgeInsets.all(50),
                child: FutureBuilder(
                    future: _list.isNotEmpty ? file!.readAsBytes() : null,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && _list.isNotEmpty) {
                        return Lottie.memory(snapshot.data as Uint8List);
                      } else {
                        return Container(
                          height: 200,
                          width: 200,
                          child: const Center(
                            child: Text(
                              'No file selected',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
            ],
          )),
    );
  }
}
