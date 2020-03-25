import 'package:flutter/cupertino.dart';

class O2OLocalizations {
  O2OLocalizations(this.locale);

  final Locale locale;

  static O2OLocalizations of(BuildContext context) {
    return Localizations.of<O2OLocalizations>(context, O2OLocalizations);
  }

  static const Iterable<String> supportedLanguages = ['en', 'ja'];

  static const Iterable<Locale> supportedLocales = [
    const Locale('en', ''),
    const Locale('ja', ''),
  ];

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'O2O',
      'splash_msg': 'O2O App\nB 版',
      'home_navigation_1': '作業一覧',
      'home_navigation_2': '対応履歴',
      'home_navigation_1_title': '発送時間帯別の作業一覧',
      'home_navigation_2_title': '対応履歴',
      'error_order_data': '注文情報が取得できません。\n電波の良いところで再度お試しください。',
      'no_time_order_data': '現在対応必要な注文はありません。',
      'txt_reload': '再読み込みする',
      'refresh_order_list': '注文情報を更新する',
      'app_info': '短時間配送支援アプリ　B版\nココカラファイン花窪西店　01',
      'txt_error_code': 'エラーコード',
      'hint_contact_us': '改善しない場合は上記の番号を管理者にお問い合わください。\nお問い合わ先： xxx-xxxx-xxxx',
      'txt_order_number': '注文番号',
      'txt_picking': 'ピッキング',
      'txt_picece': '個',
      'txt_order_required_delivery_preparation': '発送進備が必要な注文',
      'txt_completed_picking': 'ピッキング末完了',
      'txt_order_list': '注文一覧',
      'txt_start': '開始する',
      'txt_cancel': 'キャンセル',
      'txt_start_picking': 'ピッキング作業を開始します。',
      'msg_start_picking': 'この注文のステータスを「作業中」に変更して作業を開始しますか？',
      'warning_other_device_is_picking': 'この注文は他の方が作業中です。\n発送準備を開始しますか？',
      'msg_scan_barcode': 'バーコードをカメラで読み取ってください。',
      'msg_scan_barcode_extended': 'バーコードをカメラで読み取ってください。\n読み取りが成功しまと、\n対象の商品情報が表示されます。',
      'txt_settings': '設定',
      'txt_report_storage': '欠品を報告する',
      'txt_insert_code_manually': 'JANコードを手入力',
      'title_insert_code_manually': 'JANコードを手入力してください。',
      'txt_entry_jan_code': 'JANコードを登録する',
      'txt_scanned_product': '読み取り末完了の商品',
      'txt_scan_completed_product': '読み取りが末完了した商品',
      'txt_jan_code': 'JANコード',
      'txt_category_name': 'カテゴリー名',
      'txt_submit_and_next': '登録して次へ',
      'txt_product_scanned': '以下の商品をスキャンしました',
      'txt_all_products_picking_done': '全ての商品のピッキングが完了しました！',
      'txt_proceed_to_shipping_preparation': 'この注文の発送準備に進む',
      'txt_select_next_step': '次に行う作業を選択してください。',
      'txt_provide_missing_info': 'この注文の欠品情報を行う',
      'txt_pick_another_order': '他の注文のピッキングをする',
      'txt_shipping_preparation': '発送準備',
      'txt_shipping_plan': '発送予定',
      'txt_start_shipping_preparation': '発送準備を開始します。',
      'txt_packing_step_1': 'レジ打ち\n価格修正',
      'txt_packing_step_2': 'レシート\n番号入力',
      'txt_packing_step_3': 'ラベル\n準備',
      'txt_packing_step_4': 'QRコード\n読み取り',
      'txt_packing_step_5': 'ラベル\n記入',
      'msg_packing_step_1': 'レジに商品を通して、\n商品価格をEC価格に修正して\n登録してください。',
      'msg_packing_step_2': '出てきだレシートを記載されている\n４桁のレシート番号を\n入力してください。',
      'msg_packing_step_3': '商品を袋に詰め、荷札QRコードの\n印刷されたラベルを袋の数ぶん\n準備してください。',
      'msg_packing_step_4': '荷札QRコードを\nカメラで読み取って下さい。',
      'msg_packing_step_5': 'ラベルに「①発送予定時間」、\n「②出荷番号記」、「③個数/個口数」を\n記入してください。',
      'txt_product_list': '商品一覧',
      'txt_go_to_receipt_number_insertion': 'レシート番号入力へ進む',
      'txt_total_amount_of_money': '合計金額',
      'txt_tax_included': '税込',
      'txt_go_back': '前に戻る',
      'txt_go_to_label_preparation': 'ラベル準備へ進む',
      'txt_go_to_qr_code_scanner': 'QRコード読み取りへ進む',
      'txt_go_to_add_label': 'ラベル記入へ進む',
      'txt_complete_shipping': '発送準備を完了する',
      'txt_qr_scanned_labeled_count': '読み取った荷札QRコード',
      'txt_see_list': '一覧を見る',
      'txt_scanned_1_qr_code': '一つのQRコードをスキャンしました。',
      'txt_shipping_plan_time': '発送予定時間',
      'txt_shipping_number': '出荷番号',
      'txt_delivery_number': '配送番号',
      'txt_baggage_number': '荷物番号',
      'txt_quantity': '個数',
      'txt_number_of_pieces': '個口数',
      'txt_comment': 'コメント',
      'txt_confirm_shipping_preparation_completion': '発送準備の完了を確認',
      'msg_confirm_shipping_preparation_completion': 'ラベルに「発送準備時間」、「荷物管理番号」、'
          '\n「個口数」が記入されていることを\n確認してください。'
          '\n\n発送準備の完了した商品はドライバーが集荷に同いますので、所定の場所に\n保管してください。',
      'txt_done': '完了する',
      'txt_cancal_packing': 'パッキング作業を中断して作業一覧に戻りますか？',
      'msg_cancal_packing': 'それまでの作業は途中保存されず\n作業を途中から\n再開することができません。',
      'txt_return_to_the_list': '一覧に戻る',
      'txt_see_order_list': '注文商品一覧を見る',
      'txt_confirm': '確認',
      'txt_delete_selected_qr_codes': '選択したQRコードを削除する',
      'msg_delete_selected_qrcodes': '以下のQRコードを削除します。\nよろしですか？',
      'msg_delete_primary_qrcodes': '以下のQRコードを削除すると\n出荷番号個口数が変更になるので\n配送ラベルの修正が必要になります。\n\nよろしですか？',
      'msg_delete_qrcodes': '以下のQRコードを削除すると\n個口数が変更になるので\n配送ラベルの修正が必要になります。\n\nよろしですか？',
      'txt_qrcode_number': 'QRコードナンバー',
      'txt_return_to_previous_step': '一つ前の作業に戻ります',
      'msg_return_to_previous_step': '現在行っている作業の状態は\n保存されません。\n前の作業に戻ってよろしですか？',
      'txt_ok': 'OK',
      'txt_product_count': '商品点数',
      'txt_shipping_preparation_complete': '発送準備完了',
      'txt_shipping_done': '発送済み',
      'txt_missing': '欠品',
      'txt_return_to_order_list': 'ピッキング作業を中断して\n作業一覧に戻りますか？',
      'msg_return_to_order_list': 'これまでの作業を途中保存されていますので、作業を途中から再会できます。',
      'txt_select_product_to_check_missing_info': '欠品報告する商品を全て選択して下さい。',
      'txt_confirm_missing_info': '欠品報告内容の確認',
      'msg_confirm_missing_info': '以下の商品の欠品の報告します。'
          '\n欠品が報告されと、欠品商品を含む注文自体がキャンセルとなります。'
          '\n本当によろしですか？',
      'txt_return': '戻る',
      'txt_order_quantity': '注文数',
      'txt_baggage_management_number': '荷物管理番号',
      'txt_stockout_time': '報告時間',
      'txt_history_details': '対応履歴詳細',
      'txt_order_info': '注文情報',
      'txt_picking_completion_time': 'ピッキング完了時間',
      'txt_used_device_name': '対応デバイス名',
      'txt_shipping_time': '発送時間',
      'txt_shipping_time_of_the_day': '発送時刻',
      'txt_picking_info': 'ピッキング情報',
      'txt_shipping_preparation_info': '発送準備情報',
      'txt_receipt_number': 'レシート番号',
      'txt_modify_receipt_number': 'レシート番号を修正する',
      'txt_add_qr_code': 'QRコードを追加する',
      'txt_remove_qr_code': 'QRコードを削除する',
      'txt_input_receipt_number': '4桁のレシート番号を入力して下さい',
      'txt_update_receipt_number': 'レシート番号を更新する',
      'txt_receipt_number_updated': 'レシート番号を更新しました。',
      'txt_confirm_change': '修正完了確認',
      'msg_confirm_change': '発送準備の完了した商品はドライバーが集荷に伺いますので、'
          '追加した分の商品を合わせて所定の場所に保管して下さい。',
      'txt_complete_shipping_preparation': '発送準備を完了する',
      'msg_primary_qr_code_delete': '以下のQRコードを削除すると荷物管理番号が変更になるのでラベルの修正が必要になります。',
      'msg_qr_code_delete': '以下のQRコードを削除します。\nよろしいですか？',
      'hint_search_order': '注文番号を入力してを検索',
      'txt_recent_search_history': '最近の検索履歴',
      'txt_required_picking_order': 'ピッキングが必要な注文',
      'txt_total_product_count': '合計商品点数',
      'txt_concept_of_label': 'ラベルの数の考え方',
      'txt_check_qr_code_to_delete': '読み取ったQRコードを削除する場合、対象のコードにチェックをつけてください。',
      'error_msg_cannot_get_data': 'データが取得できません。\n電波の良いところで再度お試し下さい。',
      'error_msg_no_data': '現在対応が必要な注文はありません。',
      'txt_contact_us_part_1': '改善したい場合は以下の番号に\n電話でお問い合わせ下さい。\n\n'
          '①の番号につながらない場合は\n②にお問い合わせて下さい。\n',
      'txt_contact_us_part_2': '問い合わせ先①：　xxx-xxxx-xxxx',
      'txt_contact_us_part_3': '問い合わせ先②：　xxx-xxxx-xxxx',
      'txt_contact_us_part_4': '\nお電話で以下の番号をお伝え下さい。\n-imei-',
      'txt_read_barcode': 'バーコード読取',
      'txt_read_qrcode': 'QR読取',
      'msg_read_barcode': 'バーコードにカメラをかざしてください。読み取りが成功しますと、'
          'そのバーコードの商品を含む注文の対応履歴が表示されます。',
      'msg_read_qrcode': '荷札QRコードにカメラをかざしてください。読み取りが成功しますと、'
          'そのQRコードに紐づいたの注文の対応履歴が表示されます。',
      'hint_search_by_barcode': 'JANコードを入力して対応履歴を検索',
      'hint_search_by_qrcode': '荷物番号を入力して対応履歴を検索',
      'txt_work_finishing_time': '作業完了時刻',
      'warning_update_label_info': '赤字の部分が変更されていますので、既に配送ラベルを記載していた場合、赤字の部分を修正して下さい。',
    },
    'ja': {
      'title': 'O2O',
      'splash_msg': 'O2O App\nB 版',
      'home_navigation_1': '作業一覧',
      'home_navigation_2': '対応履歴',
      'home_navigation_1_title': '発送時間帯別の作業一覧',
      'home_navigation_2_title': '対応履歴',
      'error_order_data': '注文情報が取得できません。\n電波の良いところで再度お試しください。',
      'no_time_order_data': '現在対応必要な注文はありません',
      'txt_reload': '再読み込みする',
      'refresh_order_list': '注文リストを更新する',
      'app_info': '短時間配送支援アプリ　B版\nココカラファイン花窪西店　01',
      'txt_error_code': 'エラーコード',
      'hint_contact_us': '改善しない場合は上記の番号を管理者にお問い合わください。\nお問い合わ先： xxx-xxxx-xxxx',
      'txt_order_number': '注文番号',
      'txt_picking': 'ピッキング',
      'txt_picece': '個',
      'txt_order_required_delivery_preparation': '発送進備が必要な注文',
      'txt_completed_picking': 'ピッキング末完了',
      'txt_order_list': '注文一覧',
      'txt_start': '開始する',
      'txt_cancel': 'キャンセル',
      'txt_start_picking': 'ピッキング作業を開始します。',
      'msg_start_picking': 'この注文のステータスを「作業中」に変更して作業を開始しますか？',
      'warning_other_device_is_picking': 'この注文は他の方が作業中です。\n発送準備を開始しますか？',
      'msg_scan_barcode': 'バーコードをカメラで読み取ってください。',
      'msg_scan_barcode_extended': 'バーコードをカメラで読み取ってください。\n読み取りが成功しまと、\n対象の商品情報が表示されます。',
      'txt_settings': '設定',
      'txt_report_storage': '欠品を報告する',
      'txt_insert_code_manually': 'JANコードを手入力',
      'title_insert_code_manually': 'JANコードを手入力してください。',
      'txt_entry_jan_code': 'JANコードを登録する',
      'txt_scanned_product': '読み取り末完了の商品',
      'txt_scan_completed_product': '読み取りが末完了した商品',
      'txt_jan_code': 'JANコード',
      'txt_category_name': 'カテゴリー名',
      'txt_submit_and_next': '登録して次へ',
      'txt_product_scanned': '以下の商品をスキャンしました',
      'txt_all_products_picking_done': '全ての商品のピッキングが完了しました！',
      'txt_proceed_to_shipping_preparation': 'この注文の発送準備に進む',
      'txt_select_next_step': '次に行う作業を選択してください。',
      'txt_provide_missing_info': 'この注文の欠品情報を行う',
      'txt_pick_another_order': '他の注文のピッキングをする',
      'txt_shipping_preparation': '発送準備',
      'txt_shipping_plan': '発送予定',
      'txt_start_shipping_preparation': '発送準備を開始します。',
      'txt_packing_step_1': 'レジ打ち\n価格修正',
      'txt_packing_step_2': 'レシート\n番号入力',
      'txt_packing_step_3': 'ラベル\n準備',
      'txt_packing_step_4': 'QRコード\n読み取り',
      'txt_packing_step_5': 'ラベル\n記入',
      'msg_packing_step_1': 'レジに商品を通して、\n商品価格をEC価格に修正して\n登録してください。',
      'msg_packing_step_2': '出てきだレシートを記載されている\n４桁のレシート番号を\n入力してください。',
      'msg_packing_step_3': '商品を袋に詰め、荷札QRコードの\n印刷されたラベルを袋の数ぶん\n準備してください。',
      'msg_packing_step_4': '荷札QRコードを\nカメラで読み取って下さい。',
      'msg_packing_step_5': 'ラベルに「①発送予定時間」、\n「②出荷番号記」、「③個数/個口数」を\n記入してください。',
      'txt_product_list': '商品一覧',
      'txt_go_to_receipt_number_insertion': 'レシート番号入力へ進む',
      'txt_total_amount_of_money': '合計金額',
      'txt_tax_included': '税込',
      'txt_go_back': '前に戻る',
      'txt_go_to_label_preparation': 'ラベル準備へ進む',
      'txt_go_to_qr_code_scanner': 'QRコード読み取りへ進む',
      'txt_go_to_add_label': 'ラベル記入へ進む',
      'txt_complete_shipping': '発送準備を完了する',
      'txt_qr_scanned_labeled_count': '読み取った荷札QRコード',
      'txt_see_list': '一覧を見る',
      'txt_scanned_1_qr_code': '一つのQRコードをスキャンしました。',
      'txt_shipping_plan_time': '発送予定時間',
      'txt_shipping_number': '出荷番号',
      'txt_delivery_number': '配送番号',
      'txt_baggage_number': '荷物番号',
      'txt_quantity': '個数',
      'txt_number_of_pieces': '告口数',
      'txt_comment': 'コメント',
      'txt_confirm_shipping_preparation_completion': '発送準備の完了を確認',
      'msg_confirm_shipping_preparation_completion': 'ラベルに「発送準備時間」、「荷物管理番号」、'
          '\n「個口数」が記入されていることを\n確認してください。'
          '\n\n発送準備の完了した商品はドライバーが集荷に同いますので、所定の場所に\n保管してください。',
      'txt_done': '完了する',
      'txt_cancal_packing': 'パッキング作業を中断して作業一覧に戻りますか？',
      'msg_cancal_packing': 'それまでの作業は途中保存されず\n作業を途中から\n再開することができません。',
      'txt_return_to_the_list': '一覧に戻る',
      'txt_see_order_list': '注文商品一覧を見る',
      'txt_confirm': '確認',
      'txt_delete_selected_qr_codes': '選択したQRコードを削除する',
      'msg_delete_selected_qrcodes': '以下のQRコードを削除します。\nよろしですか？',
      'txt_qrcode_number': 'QRコードナンバー',
      'txt_return_to_previous_step': '一つ前の作業に戻ります',
      'msg_return_to_previous_step': '現在行っている作業の状態は\n保存されません。\n前の作業に戻ってよろしですか？',
      'txt_ok': 'OK',
      'txt_product_count': '商品点数',
      'txt_shipping_preparation_complete': '発送準備完了',
      'txt_shipping_done': '発送済み',
      'txt_missing': '欠品',
      'txt_return_to_order_list': 'ピッキング作業を中断して\n作業一覧に戻りますか？',
      'msg_return_to_order_list': 'これまでの作業を途中保存されていますので、作業を途中から再会できます。',
      'txt_select_product_to_check_missing_info': '欠品報告する商品を全て選択して下さい。',
      'txt_confirm_missing_info': '欠品報告内容の確認',
      'msg_confirm_missing_info': '以下の商品の欠品の報告します。'
          '\n欠品が報告されと、欠品商品を含む注文自体がキャンセルとなります。'
          '\n本当によろしですか？',
      'txt_return': '戻る',
      'txt_order_quantity': '注文数',
      'txt_baggage_management_number': '荷物管理番号',
      'txt_stockout_time': '報告時間',
      'txt_history_details': '対応履歴詳細',
      'txt_order_info': '注文情報',
      'txt_picking_completion_time': 'ピッキング完了時間',
      'txt_used_device_name': '対応デバイス名',
      'txt_shipping_time': '発送時間',
      'txt_shipping_time_of_the_day': '発送時刻',
      'txt_picking_info': 'ピッキング情報',
      'txt_shipping_preparation_info': '発送準備情報',
      'txt_receipt_number': 'レシート番号',
      'txt_modify_receipt_number': 'レシート番号を修正する',
      'txt_add_qr_code': 'QRコードを追加する',
      'txt_remove_qr_code': 'QRコードを削除する',
      'txt_input_receipt_number': '4桁のレシート番号を入力して下さい',
      'txt_update_receipt_number': 'レシート番号を更新する',
      'txt_receipt_number_updated': 'レシート番号を更新しました。',
      'txt_confirm_change': '修正完了確認',
      'msg_confirm_change': '発送準備の完了した商品はドライバーが集荷に伺いますので、'
          '追加した分の商品を合わせて所定の場所に保管して下さい。',
      'txt_complete_shipping_preparation': '発送準備を完了する',
      'msg_primary_qr_code_delete': '以下のQRコードを削除すると荷物管理番号が変更になるのでラベルの修正が必要になります。',
      'msg_qr_code_delete': '以下のQRコードを削除します。\nよろしいですか？',
      'hint_search_order': '注文番号を入力してを検索',
      'txt_recent_search_history': '最近の検索履歴',
      'txt_required_picking_order': 'ピッキングが必要な注文',
      'txt_concept_of_label': 'ラベルの数の考え方',
      'txt_check_qr_code_to_delete': '読み取ったQRコードを削除する場合、対象のコードにチェックをつけてください。',
      'error_msg_cannot_get_data': 'データが取得できません。\n電波の良いところで再度お試し下さい。',
      'error_msg_no_data': '現在対応が必要な注文はありません。',
      'txt_contact_us_part_1': '改善したい場合は以下の番号に\n電話でお問い合わせ下さい。\n\n'
          '①の番号につながらない場合は\n②にお問い合わせて下さい。\n',
      'txt_contact_us_part_2': '問い合わせ先①：　xxx-xxxx-xxxx',
      'txt_contact_us_part_3': '問い合わせ先②：　xxx-xxxx-xxxx',
      'txt_contact_us_part_4': '\nお電話で以下の番号をお伝え下さい。\n-imei-',
      'txt_read_barcode': 'バーコード読取',
      'txt_read_qrcode': 'QR読取',
      'msg_read_barcode': 'バーコードにカメラをかざしてください。読み取りが成功しますと、'
          'そのバーコードの商品を含む注文の対応履歴が表示されます。',
      'msg_read_qrcode': '荷札QRコードにカメラをかざしてください。読み取りが成功しますと、'
          'そのQRコードに紐づいたの注文の対応履歴が表示されます。',
      'hint_search_by_barcode': 'JANコードを入力して対応履歴を検索',
      'hint_search_by_qrcode': '荷物番号を入力して対応履歴を検索',
      'txt_work_finishing_time': '作業完了時刻',
      'warning_update_label_info': '赤字の部分が変更されていますので、既に配送ラベルを記載していた場合、赤字の部分を修正して下さい。',
    },
  };

  String _getLocalizedValue(String key) {
    return _localizedValues[locale.languageCode][key];
  }

  String get title => _getLocalizedValue('title');
  String get splashMsg => _getLocalizedValue('splash_msg');
  String get homeNavigation1 => _getLocalizedValue('home_navigation_1');
  String get homeNavigation2 => _getLocalizedValue('home_navigation_2');
  String get homeNavigation1Title => _getLocalizedValue('home_navigation_1_title');
  String get homeNavigation2Title => _getLocalizedValue('home_navigation_2_title');
  String get errorOrderData => _getLocalizedValue('error_order_data');
  String get noTimeOrderData => _getLocalizedValue('no_time_order_data');
  String get txtReload => _getLocalizedValue('txt_reload');
  String get refreshOrderList => _getLocalizedValue('refresh_order_list');
  String get appInfo => _getLocalizedValue('app_info');
  String get txtErrorCode => _getLocalizedValue('txt_error_code');
  String get hintContactUs => _getLocalizedValue('hint_contact_us');
  String get txtOrderNumber => _getLocalizedValue('txt_order_number');
  String get txtPicking => _getLocalizedValue('txt_picking');
  String get txtPiece => _getLocalizedValue('txt_picece');
  String get txtOrderRequiredDeliveryPreparation => _getLocalizedValue('txt_order_required_delivery_preparation');
  String get txtCompletedPicking => _getLocalizedValue('txt_completed_picking');
  String get txtOrderList => _getLocalizedValue('txt_order_list');
  String get txtStart => _getLocalizedValue('txt_start');
  String get txtCancel => _getLocalizedValue('txt_cancel');
  String get txtStartPicking => _getLocalizedValue('txt_start_picking');
  String get msgStartPicking => _getLocalizedValue('msg_start_picking');
  String get warningOtherDeviceIsPicking => _getLocalizedValue('warning_other_device_is_picking');
  String get msgScanBarcode => _getLocalizedValue('msg_scan_barcode');
  String get msgScanBarcodeExtended => _getLocalizedValue('msg_scan_barcode_extended');
  String get txtSettings => _getLocalizedValue('txt_settings');
  String get txtReportStorage => _getLocalizedValue('txt_report_storage');
  String get txtInsertCodeManually => _getLocalizedValue('txt_insert_code_manually');
  String get titleInsertCodeManually => _getLocalizedValue('title_insert_code_manually');
  String get txtEntryJANCode => _getLocalizedValue('txt_entry_jan_code');
  String get txtScannedProduct => _getLocalizedValue('txt_scanned_product');
  String get txtScanCompletedProduct => _getLocalizedValue('txt_scan_completed_product');
  String get txtJanCode => _getLocalizedValue('txt_jan_code');
  String get txtCategoryName => _getLocalizedValue('txt_category_name');
  String get txtSubmitAndNext => _getLocalizedValue('txt_submit_and_next');
  String get txtProductScanned => _getLocalizedValue('txt_product_scanned');
  String get txtAllProductsPickingDone => _getLocalizedValue('txt_all_products_picking_done');
  String get txtSelectNextStep => _getLocalizedValue('txt_select_next_step');
  String get txtProvideMissingInfo => _getLocalizedValue('txt_provide_missing_info');
  String get txtPickAnotherOrder => _getLocalizedValue('txt_pick_another_order');
  String get txtProceedToShippingPreparation => _getLocalizedValue('txt_proceed_to_shipping_preparation');
  String get txtShippingPreparation => _getLocalizedValue('txt_shipping_preparation');
  String get txtShippingPlan => _getLocalizedValue('txt_shipping_plan');
  String get txtStartShippingPreparation => _getLocalizedValue('txt_start_shipping_preparation');
  String get txtPackingStep1 => _getLocalizedValue('txt_packing_step_1');
  String get txtPackingStep2 => _getLocalizedValue('txt_packing_step_2');
  String get txtPackingStep3 => _getLocalizedValue('txt_packing_step_3');
  String get txtPackingStep4 => _getLocalizedValue('txt_packing_step_4');
  String get txtPackingStep5 => _getLocalizedValue('txt_packing_step_5');
  String get msgPackingStep1 => _getLocalizedValue('msg_packing_step_1');
  String get msgPackingStep2 => _getLocalizedValue('msg_packing_step_2');
  String get msgPackingStep3 => _getLocalizedValue('msg_packing_step_3');
  String get msgPackingStep4 => _getLocalizedValue('msg_packing_step_4');
  String get msgPackingStep5 => _getLocalizedValue('msg_packing_step_5');
  String get txtProductList => _getLocalizedValue('txt_product_list');
  String get txtGoToReceiptNumberInsertion => _getLocalizedValue('txt_go_to_receipt_number_insertion');
  String get txtTotalAmountOfMoney => _getLocalizedValue('txt_total_amount_of_money');
  String get txtTaxIncluded => _getLocalizedValue('txt_tax_included');
  String get txtGoBack => _getLocalizedValue('txt_go_back');
  String get txtGoToLabelPreparation => _getLocalizedValue('txt_go_to_label_preparation');
  String get txtGoToQrCodeScanner => _getLocalizedValue('txt_go_to_qr_code_scanner');
  String get txtGoToAddLabel => _getLocalizedValue('txt_go_to_add_label');
  String get txtCompleteShipping => _getLocalizedValue('txt_complete_shipping');
  String get txtQRScannedLabeledCount => _getLocalizedValue('txt_qr_scanned_labeled_count');
  String get txtSeeList => _getLocalizedValue('txt_see_list');
  String get txtScanned1QRCode => _getLocalizedValue('txt_scanned_1_qr_code');
  String get txtShippingPlanTime => _getLocalizedValue('txt_shipping_plan_time');
  String get txtShippingNumber => _getLocalizedValue('txt_shipping_number');
  String get txtDeliveryNumber => _getLocalizedValue('txt_delivery_number');
  String get txtBaggageNumber => _getLocalizedValue('txt_baggage_number');
  String get txtQuantity => _getLocalizedValue('txt_quantity');
  String get txtNumberOfPieces => _getLocalizedValue('txt_number_of_pieces');
  String get txtComment => _getLocalizedValue('txt_comment');
  String get txtConfirmShippingPreparationCompletion => _getLocalizedValue('txt_confirm_shipping_preparation_completion');
  String get msgConfirmShippingPreparationCompletion => _getLocalizedValue('msg_confirm_shipping_preparation_completion');
  String get txtDone => _getLocalizedValue('txt_done');
  String get txtCancelPacking => _getLocalizedValue('txt_cancal_packing');
  String get msgCancelPacking => _getLocalizedValue('msg_cancal_packing');
  String get txtReturnToTheList => _getLocalizedValue('txt_return_to_the_list');
  String get txtSeeOrderList => _getLocalizedValue('txt_see_order_list');
  String get txtConfirm => _getLocalizedValue('txt_confirm');
  String get txtDeleteSelectedQrCodes => _getLocalizedValue('txt_delete_selected_qr_codes');
  String get msgDeleteSelectedQrCodes => _getLocalizedValue('msg_delete_selected_qrcodes');
  String get msgDeletePrimaryQrCodes => _getLocalizedValue('msg_delete_primary_qrcodes');
  String get msgDeleteQrCodes => _getLocalizedValue('msg_delete_qrcodes');
  String get txtQrCodeNumber => _getLocalizedValue('txt_qrcode_number');
  String get txtReturnToPreviousStep => _getLocalizedValue('txt_return_to_previous_step');
  String get msgReturnToPreviousStep => _getLocalizedValue('msg_return_to_previous_step');
  String get txtOk => _getLocalizedValue('txt_ok');
  String get txtProductCount => _getLocalizedValue('txt_product_count');
  String get txtShippingPreparationComplete => _getLocalizedValue('txt_shipping_preparation_complete');
  String get txtShippingDone => _getLocalizedValue('txt_shipping_done');
  String get txtMissing => _getLocalizedValue('txt_missing');
  String get txtReturnToOrderList => _getLocalizedValue('txt_return_to_order_list');
  String get msgReturnToOrderList => _getLocalizedValue('msg_return_to_order_list');
  String get txtSelectProductToCheckMissingInfo => _getLocalizedValue('txt_select_product_to_check_missing_info');
  String get txtConfirmMissingInfo => _getLocalizedValue('txt_confirm_missing_info');
  String get msgConfirmMissingInfo => _getLocalizedValue('msg_confirm_missing_info');
  String get txtReturn => _getLocalizedValue('txt_return');
  String get txtOrderQuantity => _getLocalizedValue('txt_order_quantity');
  String get txtBaggageManagementNumber => _getLocalizedValue('txt_baggage_management_number');
  String get txtStockoutTime => _getLocalizedValue('txt_stockout_time');
  String get txtHistoryDetails => _getLocalizedValue('txt_history_details');
  String get txtOrderInfo => _getLocalizedValue('txt_order_info');
  String get txtPickingCompletionTime => _getLocalizedValue('txt_picking_completion_time');
  String get txtUsedDeviceName => _getLocalizedValue('txt_used_device_name');
  String get txtShippingTime => _getLocalizedValue('txt_shipping_time');
  String get txtShippingTimeOfTheDay => _getLocalizedValue('txt_shipping_time_of_the_day');
  String get txtPickingInfo => _getLocalizedValue('txt_picking_info');
  String get txtShippingPreparationInfo => _getLocalizedValue('txt_shipping_preparation_info');
  String get txtReceiptNumber => _getLocalizedValue('txt_receipt_number');
  String get txtModifyReceiptNumber => _getLocalizedValue('txt_modify_receipt_number');
  String get txtAddQrCode => _getLocalizedValue('txt_add_qr_code');
  String get txtRemoveQrCode => _getLocalizedValue('txt_remove_qr_code');
  String get txtInputReceiptNumber => _getLocalizedValue('txt_input_receipt_number');
  String get txtUpdateReceiptNumber => _getLocalizedValue('txt_update_receipt_number');
  String get txtReceiptNumberUpdated => _getLocalizedValue('txt_receipt_number_updated');
  String get txtConfirmChange => _getLocalizedValue('txt_confirm_change');
  String get msgConfirmChange => _getLocalizedValue('msg_confirm_change');
  String get txtCompleteShippingPreparation => _getLocalizedValue('txt_complete_shipping_preparation');
  String get msgPrimaryQrCodeDelete => _getLocalizedValue('msg_primary_qr_code_delete');
  String get msgQrCodeDelete => _getLocalizedValue('msg_qr_code_delete');
  String get hintSearchOrder => _getLocalizedValue('hint_search_order');
  String get txtRecentSearchHistory => _getLocalizedValue('txt_recent_search_history');
  String get txtRequiredPickingOrder => _getLocalizedValue('txt_required_picking_order');
  String get txtTotalProductCount => _getLocalizedValue('txt_total_product_count');
  String get txtConceptOfLabel => _getLocalizedValue('txt_concept_of_label');
  String get txtCheckQrCodeToDelete => _getLocalizedValue('txt_check_qr_code_to_delete');
  String get errorMsgCannotGetData => _getLocalizedValue('error_msg_cannot_get_data');
  String get errorMsgNoData => _getLocalizedValue('error_msg_no_data');
  String get txtContactUsPart1 => _getLocalizedValue('txt_contact_us_part_1');
  String get txtContactUsPart2 => _getLocalizedValue('txt_contact_us_part_2');
  String get txtContactUsPart3 => _getLocalizedValue('txt_contact_us_part_3');
  String get txtContactUsPart4 => _getLocalizedValue('txt_contact_us_part_4');
  String get txtReadBarcode => _getLocalizedValue('txt_read_barcode');
  String get txtReadQRCode => _getLocalizedValue('txt_read_qrcode');
  String get msgReadBarcode => _getLocalizedValue('msg_read_barcode');
  String get msgReadQRCode => _getLocalizedValue('msg_read_qrcode');
  String get hintSearchByBarcode => _getLocalizedValue('hint_search_by_barcode');
  String get hintSearchByQrCode => _getLocalizedValue('hint_search_by_qrcode');
  String get txtWorkFinishingTime => _getLocalizedValue('txt_work_finishing_time');
  String get warningUpdateLabelInfo => _getLocalizedValue('warning_update_label_info');
}