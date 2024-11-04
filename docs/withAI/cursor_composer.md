```prompt
스마트폰에서
- 사진, 음성, 동영상 촬영.녹화
- 사진.음성.동영상 파일 gps 정보 추출(표시)/수정
- 파일 목록 관리(SQLite)
- 파일 전송(지정된 Server)

와 같은 기능의 앱을 만들고 싶어요.
```

```prompt
vscode로 개발하면서 스마트폰으로 안드로이드앱이 잘 실행되는지 확인하려면 어떻게 하나요?
```


VSCode에서 안드로이드 앱을 개발하고 실제 스마트폰에서 테스트하는 방법을 설명해드리겠습니다:

1. 개발 환경 설정
먼저 VSCode에 다음 확장 프로그램들을 설치해야 합니다:
Extension Pack for Java
Kotlin Language
Android iOS Emulator

2. 스마트폰 설정
스마트폰에서 다음과 같은 설정이 필요합니다:

```
1. 설정 → 개발자 옵션 활성화
   - 설정 → 휴대전화 정보 → 소프트웨어 정보 → 빌드번호를 7번 연속 터치
   
2. 설정 → 개발자 옵션에서:
   - USB 디버깅 활성화
   - USB를 통한 설치 허용
```

3. 프로젝트 실행

```sh
# 프로젝트 루트 디렉토리에서:
./gradlew assembleDebug  # 앱 빌드

gradlew.bat assembleDebug # windows
```

4. 실행 방법
1) USB 케이블로 연결하는 경우:

```
1. USB 케이블로 스마트폰과 컴퓨터 연결
2. VSCode에서 F5 키를 누르거나 실행/디버그 메뉴 사용
3. 연결된 디바이스 선택
```

2) 무선으로 연결하는 경우:
```
1. 스마트폰과 컴퓨터가 같은 Wi-Fi 네트워크에 연결
2. 스마트폰을 USB로 한 번 연결
3. 개발자 옵션 → 무선 디버깅 활성화
4. IP 주소와 포트 확인
5. adb connect [IP주소]:[포트번호]
```

5. 문제 해결
디바이스가 인식되지 않을 경우:

```sh
# adb 디바이스 목록 확인
adb devices

# adb 서버 재시작
adb kill-server
adb start-server
```

6. VSCode tasks.json 설정 예시

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build debug",
            "type": "shell",
            "command": "./gradlew assembleDebug",
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
        {
            "label": "install debug",
            "type": "shell",
            "command": "adb install -r ./app/build/outputs/apk/debug/app-debug.apk",
            "dependsOn": ["build debug"]
        }
    ]
}
```

7. launch.json 설정 예시

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "android",
            "request": "launch",
            "name": "Launch App",
            "appSrcRoot": "${workspaceRoot}/app/src/main",
            "apkFile": "${workspaceRoot}/app/build/outputs/apk/debug/app-debug.apk",
            "adbPort": 5037
        }
    ]
}
```

이러한 설정을 마치면 VSCode에서 F5 키를 눌러 앱을 실행하고 디버깅할 수 있습니다. 실시간으로 로그를 확인하려면 VSCode의 디버그 콘솔이나 터미널에서 다음 명령어를 사용할 수 있습니다:


```sh
adb logcat
```

특정 앱의 로그만 보고 싶다면:

```sh
adb logcat --pid=$(adb shell pidof -s com.example.app)
```


## 

사진 촬영은 되는데, 저장 경로를 확인하기가 어렵네요.
내장 메모리에 저장되나요? 저장 경로를 알려주세요.

현재 코드에서는 앱의 임시 디렉토리(getTemporaryDirectory())에 저장되고 있습니다. 이 경로는 앱이 종료되면 삭제될 수 있습니다.
영구적으로 저장하려면 다음과 같이 camera_screen.dart 파일을 수정하여 갤러리에 저장할 수 있습니다:
안드로이드에서의 저장 경로는 다음과 같습니다:
이 경로는 다음과 같이 접근할 수 있습니다:
파일 관리자 앱에서 내부 저장소 > Android > data > com.example.flutter_recordit > files > RecordIt 폴더
또는 PC와 연결했을 때: 내 PC > 휴대폰 > 내부 저장소 > Android > data > com.example.flutter_recordit > files > RecordIt
참고: Android 11(API 30) 이상에서는 보안상의 이유로 /Android/data 폴더에 대한 접근이 제한될 수 있습니다. 이 경우 갤러리 앱에서 접근할 수 있도록 MediaStore API를 사용하는 것이 좋습니다.