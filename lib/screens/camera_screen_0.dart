import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path_util;
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:exif/exif.dart';
import '../screens/photo_list_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _addExifData(String imagePath, Position position) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      Map<String?, IfdTag>? exifData = await readExifFromBytes(bytes);

      if (exifData != null) {
        // GPS 정보를 Map 형태로 추가
        final Map<String, Map<String, String>> gpsData = {
          'GPS GPSLatitudeRef': {'raw': position.latitude >= 0 ? 'N' : 'S'},
          'GPS GPSLatitude': {'raw': position.latitude.abs().toString()},
          'GPS GPSLongitudeRef': {'raw': position.longitude >= 0 ? 'E' : 'W'},
          'GPS GPSLongitude': {'raw': position.longitude.abs().toString()},
        };

        // 기존 EXIF 데이터에 GPS 데이터 추가
        gpsData.forEach((key, value) {
          exifData[key] = value as IfdTag;
        });

        // final updatedBytes = await Exif.writeExifToBytes(bytes, exifData);
        // if (updatedBytes != null) {
        //   await File(imagePath).writeAsBytes(updatedBytes);
        //   print('EXIF 데이터 추가 성공');
        // }
      }
    } catch (e) {
      print('EXIF 데이터 추가 실패: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      // 위치 정보 가져오기
      final position = await _getCurrentLocation();

      final directory = await getExternalStorageDirectory();
      final String folderPath = '${directory?.path}/RecordIt';

      await Directory(folderPath).create(recursive: true);

      final String filePath = path_util.join(
        folderPath,
        'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final image = await _controller.takePicture();
      await image.saveTo(filePath);

      // GPS 정보 추가
      if (position != null) {
        await _addExifData(filePath, position);
      }

      if (!mounted) return;

      // 스낵바 표시 후 사진 목록 화면으로 이동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('사진이 저장되었습니다:\n$filePath\n' +
              (position != null
                  ? 'GPS: ${position.latitude}, ${position.longitude}'
                  : 'GPS 정보 없음')),
          duration: const Duration(seconds: 2),
        ),
      );

      // 사진 목록 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PhotoListScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 촬영에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카메라')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
