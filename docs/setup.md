```sh
cd C:\JnJ-soft\Playground\flutter
flutter create --platforms=ios,android,web flutter_recordit
cd flutter_recordit
```

```sh
github -e pushRepo -n flutter_recordit -u jnjsoftapp
```

```sh
node scripts/createDocs.js
```

## JDK 17
https://coding-is-fun.tistory.com/15

https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html

1. 시스템 환경 변수 편집 > 시스템 변수 > 새로 만들기(W)... 

    변수 이름: JAVA_HOME, 변수 값: C:\Program Files\Java\jdk-17

2. 시스템 환경 변수 편집 > 시스템 변수 > Path 선택 > 편집(I)... > 새로 만들기

    변수 값: %JAVA_HOME%\bin


## gradle

[Gradle 공식 사이트](https://gradle.org/releases/)에서 최신 버전 다운로드
다운로드 받은 zip 파일을 C:\Gradle과 같은 경로에 압축 해제
3. 시스템 환경 변수 설정:
GRADLE_HOME: C:\Gradle\gradle-7.4.2 (버전에 맞게 수정)
Path에 %GRADLE_HOME%\bin 추가


```sh
# 프로젝트 루트 디렉토리에서
gradle wrapper
```


ADB(Android Debug Bridge)가 시스템 환경 변수에 설정되어 있지 않아서 발생하는 문제입니다. 다음과 같이 해결할 수 있습니다:
환경 변수 설정
Windows의 시스템 환경 변수 Path에 Android SDK platform-tools 경로를 추가:
또는 전체 경로로 adb 명령어를 실행:
```sh
C:\Users\user\AppData\Local\Android\Sdk\platform-tools\adb.exe
```

안드로이드 기기가 목록에 표시되지 않네요. 다음 단계를 확인해보세요:
1. 스마트폰 설정 확인
개발자 옵션이 활성화되어 있는지 확인
USB 디버깅이 켜져 있는지 확인
2. USB 연결 확인

```sh
   # 연결된 안드로이드 기기 목록 확인
   adb devices
```

3. USB 연결 모드 확인
스마트폰을 USB로 연결했을 때 나타나는 알림을 확인
"파일 전송" 또는 "USB 디버깅" 모드로 설정
4. 드라이버 설치 확인
삼성 스마트폰의 경우 Samsung USB Driver 설치
Windows 장치 관리자에서 기기가 제대로 인식되는지 확인
5. adb 서버 재시작

```sh
   adb kill-server
   adb start-server
```

이후 다시 실행:

```sh
flutter run
```

또는 특정 디바이스를 지정해서 실행:

```sh
flutter run -d <device-id>
```