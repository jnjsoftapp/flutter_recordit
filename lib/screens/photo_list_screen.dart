import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:exif/exif.dart';

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({Key? key}) : super(key: key);

  @override
  PhotoListScreenState createState() => PhotoListScreenState();
}

class PhotoListScreenState extends State<PhotoListScreen> {
  List<PhotoInfo> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final directory = await getExternalStorageDirectory();
      final String folderPath = '${directory?.path}/RecordIt';
      final Directory folder = Directory(folderPath);

      if (await folder.exists()) {
        final List<FileSystemEntity> files = folder.listSync();
        final List<PhotoInfo> photos = [];

        for (var file in files) {
          if (file is File && file.path.toLowerCase().endsWith('.jpg')) {
            final photoInfo = await _getPhotoInfo(file);
            photos.add(photoInfo);
          }
        }

        // 최신 사진이 먼저 보이도록 정렬
        photos.sort((a, b) => b.file.path.compareTo(a.file.path));

        setState(() {
          _photos = photos;
        });

        // 디버그 정보 출력
        for (var photo in photos) {
          print('파일: ${photo.file.path}');
          print('위치: ${photo.latitude}, ${photo.longitude}');
          print('시간: ${photo.dateTime}');
        }
      }
    } catch (e) {
      print('사진 목록 로드 실패: $e');
    }
  }

  Future<PhotoInfo> _getPhotoInfo(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final tags = await readExifFromBytes(bytes);

      String? latitudeRef;
      String? latitude;
      String? longitudeRef;
      String? longitude;
      String? dateTime;

      if (tags != null) {
        // GPS 정보 가져오기
        final latitudeRefTag = tags['GPS GPSLatitudeRef'];
        final latitudeTag = tags['GPS GPSLatitude'];
        final longitudeRefTag = tags['GPS GPSLongitudeRef'];
        final longitudeTag = tags['GPS GPSLongitude'];
        final dateTimeTag = tags['Image DateTime'];

        latitudeRef = latitudeRefTag?.toString();
        latitude = latitudeTag?.toString();
        longitudeRef = longitudeRefTag?.toString();
        longitude = longitudeTag?.toString();
        dateTime = dateTimeTag?.toString();

        // 디버그 정보 출력
        print('EXIF 태그 읽기:');
        print('LatitudeRef: $latitudeRef');
        print('Latitude: $latitude');
        print('LongitudeRef: $longitudeRef');
        print('Longitude: $longitude');
        print('DateTime: $dateTime');
      }

      return PhotoInfo(
        file: file,
        latitudeRef: latitudeRef,
        latitude: latitude,
        longitudeRef: longitudeRef,
        longitude: longitude,
        dateTime: dateTime,
      );
    } catch (e) {
      print('EXIF 데이터 읽기 실패: $e');
      return PhotoInfo(file: file); // 에러 발생 시 기본 정보만 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 목록'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.file(
                    photo.file,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '위치: ${_getLocationText(photo)}',
                            style: const TextStyle(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            '시간: ${_getDateTimeText(photo)}',
                            style: const TextStyle(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 위치 정보 텍스트 반환
  String _getLocationText(PhotoInfo photo) {
    if (photo.latitude != null && photo.longitude != null) {
      return '${photo.latitudeRef ?? ''}${photo.latitude ?? ''}, '
          '${photo.longitudeRef ?? ''}${photo.longitude ?? ''}';
    }
    return '-';
  }

  // 시간 정보 텍스트 반환
  String _getDateTimeText(PhotoInfo photo) {
    return photo.dateTime ?? '-';
  }
}

class PhotoInfo {
  final File file;
  final String? latitudeRef;
  final String? latitude;
  final String? longitudeRef;
  final String? longitude;
  final String? dateTime;

  PhotoInfo({
    required this.file,
    this.latitudeRef,
    this.latitude,
    this.longitudeRef,
    this.longitude,
    this.dateTime,
  });

  String? get formattedLocation {
    if (latitude != null && longitude != null) {
      return '${latitudeRef ?? ''}${latitude ?? ''}, ${longitudeRef ?? ''}${longitude ?? ''}';
    }
    return null;
  }
}
