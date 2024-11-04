import fs from 'fs';
import path from 'path';

const createDocStructure = () => {
  // 기본 문서 디렉토리 생성
  const docsPath = path.join(process.cwd(), 'docs');
  
  // 하위 디렉토리 구조
  const directories = [
    'api/youtube',
    'architecture',
    'guides',
    'assets/images'
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
    directories.forEach(dir => {
      const dirPath = path.join(docsPath, dir);
      if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
      }
    });

    // 메인 README.md 파일 생성
    fs.writeFileSync(path.join(docsPath, 'README.md'), mainReadme);

    console.log('문서 구조가 성공적으로 생성되었습니다.');
  } catch (error) {
    console.error('문서 구조 생성 중 오류 발생:', error);
  }
};

createDocStructure();