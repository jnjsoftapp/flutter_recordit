```prompt
flutter 설치는 완료되었는데, flutter project를 terminal에서 생성하는 명령어가?
```

```sh
flutter create my_app_name
```

여기서 my_app_name은 생성하려는 프로젝트의 이름입니다. 프로젝트 이름은:
소문자로 작성
단어 사이는 언더스코어() 사용
숫자나 특수문자로 시작할 수 없음
프로젝트 생성 후에는:

```sh
cd my_app_name
flutter run
```

위 명령어로 프로젝트 디렉토리로 이동하고 앱을 실행할 수 있습니다.
특정 플랫폼을 지정하여 프로젝트를 생성하려면:

```sh
flutter create --platforms=ios,android my_app_name
```

사용 가능한 플랫폼 옵션:
ios
android
web
windows
macos
linux

```prompt
스마트폰에서 사진, 녹음, 녹화 등을 하고, 그 파일들을 관리하는 flutter app을 만들려고 해요.

- flutter project 폴더에서 개발관련 document들을 저장하는 폴더는 어디에 두는 게 좋은가요?
```

Flutter 프로젝트에서 개발 관련 문서들을 저장하는 폴더 구조에 대해 추천드립니다:

1. 프로젝트 루트 디렉토리에 docs 폴더를 생성하는 것이 일반적입니다:

```md
my_app/
├── android/
├── ios/
├── lib/
├── test/
├── docs/ # 문서 폴더
│ ├── api/ # API 문서
│ ├── architecture/ # 아키텍처 설계 문서
│ ├── assets/ # 문서에 사용되는 이미지 등
│ ├── guides/ # 개발 가이드
│ └── README.md # 문서 메인 페이지
├── pubspec.yaml
└── README.md
```

2. docs 폴더 안에는 문서의 성격에 따라 하위 폴더를 만들어 관리하면 좋습니다:
   api/: API 관련 문서
   architecture/: 앱 구조 설계 문서
   assets/: 문서에 사용되는 이미지나 다이어그램
   guides/: 개발 가이드나 컨벤션 문서
   이렇게 구성하면:
   프로젝트 코드와 문서를 명확히 분리할 수 있습니다
   GitHub 등에서 문서를 쉽게 찾아볼 수 있습니다
   문서도 버전 관리가 가능합니다

```prompt
@Codebase 문서 폴더들을 만들어주세요.
```

네, YouTube Data API 문서를 바탕으로 프로젝트의 문서 폴더 구조를 다음과 같이 생성하겠습니다:

```md
docs/
├── api/ # API 관련 문서
│ ├── youtube/ # YouTube API 관련 문서
│ │ ├── auth.md # 인증 관련 문서
│ │ ├── videos.md # 비디오 관련 API
│ │ ├── playlists.md # 재생목록 관련 API
│ │ └── captions.md # 자막 관련 API
│ └── README.md # API 문서 메인
│
├── architecture/ # 아키텍처 설계 문서
│ ├── system.md # 시스템 구조
│ └── database.md # 데이터베이스 설계
│
├── guides/ # 개발 가이드
│ ├── setup.md # 개발 환경 설정
│ └── conventions.md # 코딩 컨벤션
│
├── assets/ # 문서에 사용되는 이미지 등
│ └── images/ # 이미지 파일들
│
└── README.md # 문서 메인 페이지
```

이 구조는:
API 관련 문서는 api 폴더에 모아둡니다
시스템 설계 문서는 architecture 폴더에 저장합니다
개발자 가이드는 guides 폴더에 정리합니다
문서에 사용되는 이미지는 assets 폴더에 저장합니다
각 폴더에는 README.md 파일을 두어 해당 폴더의 문서 구조를 설명하도록 하겠습니다.

```prompt
실제로 파일, 폴더를 생성해줄 수 있나요?
```

```js
import fs from "fs";
import path from "path";

const createDocStructure = () => {
  // 기본 문서 디렉토리 생성
  const docsPath = path.join(process.cwd(), "docs");

  // 하위 디렉토리 구조
  const directories = [
    "api/youtube",
    "architecture",
    "guides",
    "assets/images",
  ];

  // README 파일 내용
  const mainReadme = `# YouTube 앱 문서
  
이 디렉토리는 YouTube 앱의 개발 관련 문서를 포함합니다.

## 디렉토리 구조
- api/: API 관련 문서
- architecture/: 시스템 설계 문서
- guides/: 개발 가이드
- assets/: 문서에 사용되는 리소스`;

  try {
    // docs 디렉토리 생성
    if (!fs.existsSync(docsPath)) {
      fs.mkdirSync(docsPath);
    }

    // 하위 디렉토리 생성
    directories.forEach((dir) => {
      const dirPath = path.join(docsPath, dir);
      if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
      }
    });

    // 메인 README.md 파일 생성
    fs.writeFileSync(path.join(docsPath, "README.md"), mainReadme);

    console.log("문서 구조가 성공적으로 생성되었습니다.");
  } catch (error) {
    console.error("문서 구조 생성 중 오류 발생:", error);
  }
};

createDocStructure();
```

이 스크립트를 실행하면 다음과 같은 구조가 생성됩니다:

```md
docs/
├── api/
│ └── youtube/
├── architecture/
├── guides/
├── assets/
│ └── images/
└── README.md
```

이 스크립트를 실행하려면:
프로젝트 루트 디렉토리에 scripts 폴더를 만들고
위 코드를 createDocs.js로 저장한 후
터미널에서 다음 명령어를 실행하세요:

```sh
node scripts/createDocs.js
```

필요한 경우 추가 문서 파일이나 하위 디렉토리를 생성하도록 스크립트를 수정할 수 있습니다.
