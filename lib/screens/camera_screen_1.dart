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
      final tags = await readExifFromBytes(bytes);

      if (tags != null) {
        // GPS 정보를 도분초 형식으로 변환
        final latDeg = position.latitude.abs().toInt();
        final latMin = (position.latitude.abs() * 60 % 60).toInt();
        final latSec = ((position.latitude.abs() * 3600 % 60) * 1000).toInt();

        final longDeg = position.longitude.abs().toInt();
        final longMin = (position.longitude.abs() * 60 % 60).toInt();
        final longSec = ((position.longitude.abs() * 3600 % 60) * 1000).toInt();

        // 새로운 EXIF 데이터 생성
        Map<String, IfdTag> newTags = {};

        // GPS 태그 추가
        newTags['GPS GPSLatitudeRef'] = IfdTag(
          'GPS GPSLatitudeRef',
          IfdId.gps,
          TagType.ascii,
          [position.latitude >= 0 ? 'N' : 'S'],
        );

        newTags['GPS GPSLatitude'] = IfdTag(
          'GPS GPSLatitude',
          IfdId.gps,
          TagType.rational,
          [
            [latDeg, 1],
            [latMin, 1],
            [latSec, 1000]
          ],
        );

        newTags['GPS GPSLongitudeRef'] = IfdTag(
          'GPS GPSLongitudeRef',
          IfdId.gps,
          TagType.ascii,
          [position.longitude >= 0 ? 'E' : 'W'],
        );

        newTags['GPS GPSLongitude'] = IfdTag(
          'GPS GPSLongitude',
          IfdId.gps,
          TagType.rational,
          [
            [longDeg, 1],
            [longMin, 1],
            [longSec, 1000]
          ],
        );

        // 현재 시간 추가
        final now = DateTime.now();
        final dateTimeStr =
            '${now.year}:${now.month.toString().padLeft(2, '0')}:${now.day.toString().padLeft(2, '0')} '
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

        newTags['DateTime'] = IfdTag(
          'DateTime',
          IfdId.ifd0,
          TagType.ascii,
          [dateTimeStr],
        );

        // EXIF 데이터를 이미지에 쓰기
        final updatedBytes = await writeExifToBytes(bytes, newTags);
        if (updatedBytes != null) {
          await File(imagePath).writeAsBytes(updatedBytes);

          print('EXIF 데이터 추가 성공: $imagePath');
          print('위치: ${position.latitude}, ${position.longitude}');
          print('시간: $dateTimeStr');
        }
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
