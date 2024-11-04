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