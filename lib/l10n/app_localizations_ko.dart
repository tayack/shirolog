// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '성곽로그';

  @override
  String get home => '홈';

  @override
  String get record => '기록';

  @override
  String get search => '기록 검색';

  @override
  String get mission => '미션';

  @override
  String get settings => '설정';

  @override
  String get loginTitle => '성곽로그';

  @override
  String get loginSubtitle => '공성 기록 앱';

  @override
  String get googleLogin => 'Google로 로그인';

  @override
  String get appleLogin => 'Apple로 로그인';

  @override
  String get guestLogin => '게스트로 시작하기';

  @override
  String get logout => '로그아웃';

  @override
  String get language => '언어';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get recentSummary => '최근 공성 요약';

  @override
  String get visitDate => '방문일';

  @override
  String get memo => '한줄 메모';

  @override
  String get save => '기록 저장하기';

  @override
  String get edit => '내용 편집하기';

  @override
  String get searchCastle => '성 이름 검색';

  @override
  String get alreadyVisited => '이미 방문한 곳입니다. 편집을 원하시면 기록 검색에서 수정해 주세요.';

  @override
  String get achieved => '달성';

  @override
  String get points => '지점';

  @override
  String get guestModeWarning =>
      '⚠️ 게스트 모드: 설정에서 계정을 연동하면 기기 변경 시에도 데이터를 보존할 수 있습니다';

  @override
  String get linkGoogleAccount => 'Google 계정 연동하기';

  @override
  String get linkSuccess => '계정 연동이 완료되었습니다!';

  @override
  String get logoutWarningTitle => '로그아웃 확인';

  @override
  String get logoutWarningContent =>
      '게스트 계정 상태로 로그아웃하면 데이터가 완전히 삭제됩니다. 계정을 연동하여 데이터를 유지하시겠습니까?';

  @override
  String get favoriteMissions => '즐겨찾기';

  @override
  String get inProgressMissions => '도전 중';

  @override
  String get unstartedMissions => '미도전';

  @override
  String get completedMissions => '달성 완료';

  @override
  String get shareTitle => '공성 기록이 저장되었습니다!';

  @override
  String get shareContent => '추억을 SNS에 공유하시겠습니까?';

  @override
  String get shareLater => '나중에';

  @override
  String get shareNow => '공유하기';

  @override
  String get shareTwitter => 'X (Twitter)';

  @override
  String get shareOthers => '기타';

  @override
  String shareText(Object castleName, Object date, Object comment) {
    return '【공성 기록】 $castleName 에 다녀왔습니다! ($date)\n\n$comment\n\n#성곽로그 #성투어 #일본100명성';
  }

  @override
  String get supportDeveloper => '개발자 응원하기';

  @override
  String get supportMessage =>
      '성곽로그를 이용해 주셔서 감사합니다!\n괜찮으시다면 개발자에게 응원(커피 한 잔 후원)을 해주시면 운영에 큰 힘이 됩니다.';

  @override
  String get close => '닫기';

  @override
  String get supportConfirm => '응원하기';

  @override
  String get errorFetchingData => '데이터를 불러오지 못했습니다';

  @override
  String get retry => '재시도';

  @override
  String get totalVisits => '총 공성 수';

  @override
  String get castleUnit => '개 성';

  @override
  String get yearUnit => '년';

  @override
  String get supportApp => '성곽로그 응원하기';

  @override
  String get recentVisits => '최근 방문 기록';

  @override
  String get seeAll => '전체 보기';

  @override
  String get noRecords => '아직 기록이 없습니다.\n성을 탐방하고 기록을 남겨보세요!';

  @override
  String get recommendedContent => '추천 콘텐츠';

  @override
  String get loading => '불러오는 중...';

  @override
  String get newRecord => '새 기록';

  @override
  String get editRecord => '기록 편집';

  @override
  String get selectPrefecture => '도도부현 선택';

  @override
  String get viewRecord => '기록 보기/편집';

  @override
  String get cancelEdit => '편집 취소';

  @override
  String get deleteLog => '기록 삭제';

  @override
  String get deleteConfirm => '정말로 이 기록을 삭제하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get searchCriteria => '검색 조건';

  @override
  String get applying => '적용 중';

  @override
  String get all => '전체';

  @override
  String get searchByCastleName => '성 이름으로 검색';

  @override
  String get exampleCastle => '예: 히메지 성';

  @override
  String get startDate => '시작일';

  @override
  String get endDate => '종료일';

  @override
  String get notSpecified => '지정 없음';

  @override
  String get clearCriteria => '검색 조건 초기화';

  @override
  String get noMatchingRecords => '일치하는 기록을 찾을 수 없습니다.';

  @override
  String get missionAccomplished => '임무 완료';

  @override
  String get missionCompletedMessage => '을(를) 달성했습니다!';

  @override
  String get bravo => '훌륭합니다!';

  @override
  String get missionAccomplishedSharePrefix => '【미션 달성!】\n';

  @override
  String get missionCompletedShareSuffix => '을(를) 제패했습니다!\n\n';
}
