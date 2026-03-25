// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '城池日志';

  @override
  String get home => '首页';

  @override
  String get record => '记录';

  @override
  String get search => '查询记录';

  @override
  String get mission => '任务';

  @override
  String get settings => '设置';

  @override
  String get loginTitle => '城池日志';

  @override
  String get loginSubtitle => '登城记录应用';

  @override
  String get googleLogin => '使用 Google 登录';

  @override
  String get appleLogin => '使用 Apple 登录';

  @override
  String get guestLogin => '以访客身份开始';

  @override
  String get logout => '退出登录';

  @override
  String get language => '语言';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get recentSummary => '最近登城摘要';

  @override
  String get visitDate => '访问日期';

  @override
  String get memo => '备忘录';

  @override
  String get save => '保存记录';

  @override
  String get edit => '编辑内容';

  @override
  String get searchCastle => '搜索城池名称';

  @override
  String get alreadyVisited => '已经访问过。如果需要编辑，请从记录查询中进行编辑。';

  @override
  String get achieved => '达成';

  @override
  String get points => '地点';

  @override
  String get guestModeWarning => '⚠️ 访客模式：在设置中关联账号，更换设备也能保存数据';

  @override
  String get linkGoogleAccount => '关联 Google 账号';

  @override
  String get linkSuccess => '账号关联成功！';

  @override
  String get logoutWarningTitle => '确认退出';

  @override
  String get logoutWarningContent => '在访客状态下退出，数据将完全丢失。是否先关联账号以备份数据？';

  @override
  String get favoriteMissions => '收藏';

  @override
  String get inProgressMissions => '进行中';

  @override
  String get unstartedMissions => '未开始';

  @override
  String get completedMissions => '已达成';

  @override
  String get shareTitle => '登城记录已保存！';

  @override
  String get shareContent => '要分享到社交媒体吗？';

  @override
  String get shareLater => '稍后';

  @override
  String get shareNow => '立即分享';

  @override
  String get shareTwitter => 'X (Twitter)';

  @override
  String get shareOthers => '其他';

  @override
  String shareText(Object castleName, Object date, Object comment) {
    return '【登城记录】我去了 $castleName！ ($date)\n\n$comment\n\n#城池日志 #攻城 #日本100名城';
  }

  @override
  String get supportDeveloper => '赞助开发者';

  @override
  String get supportMessage =>
      '感谢您使用城池日志！\n如果您愿意，可以通过赞助（Buy Me a Coffee）来支持开发者。这对维持应用的运行非常有帮助！';

  @override
  String get close => '关闭';

  @override
  String get supportConfirm => '赞助';

  @override
  String get errorFetchingData => '获取数据失败';

  @override
  String get retry => '重试';

  @override
  String get totalVisits => '总登城数';

  @override
  String get castleUnit => '座城';

  @override
  String get yearUnit => '年';

  @override
  String get supportApp => '支持城池日志';

  @override
  String get recentVisits => '最近访问记录';

  @override
  String get seeAll => '查看全部';

  @override
  String get noRecords => '还没有记录。\n让我们去探索城池吧！';

  @override
  String get recommendedContent => '推荐内容';

  @override
  String get loading => '加载中...';

  @override
  String get newRecord => '新记录';

  @override
  String get editRecord => '编辑记录';

  @override
  String get selectPrefecture => '选择都道府县';

  @override
  String get viewRecord => '查看/编辑记录';

  @override
  String get cancelEdit => '取消编辑';

  @override
  String get deleteLog => '删除记录';

  @override
  String get deleteConfirm => '确定要删除这条记录吗？';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get searchCriteria => '搜索条件';

  @override
  String get applying => '应用中';

  @override
  String get all => '全部';

  @override
  String get searchByCastleName => '按城池名称搜索';

  @override
  String get exampleCastle => '例如：姬路城';

  @override
  String get startDate => '开始日期';

  @override
  String get endDate => '结束日期';

  @override
  String get notSpecified => '未指定';

  @override
  String get clearCriteria => '清除搜索条件';

  @override
  String get noMatchingRecords => '未找到符合条件的记录。';

  @override
  String get missionAccomplished => '任务完成';

  @override
  String get missionCompletedMessage => ' 已达成！';

  @override
  String get bravo => '太棒了！';

  @override
  String get missionAccomplishedSharePrefix => '【任务达成！】\n';

  @override
  String get missionCompletedShareSuffix => ' 已完成！\n\n';
}
