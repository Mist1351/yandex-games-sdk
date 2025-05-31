@tool
extends EditorExportPlugin


const SDK_SCRIPT = '<script src="/sdk.js"></script>'
const OPTION_HTML_HEAD_INCLUDE = "html/head_include"


var _export_file_path = null


func _get_name() -> String:
	return "YandexSDK"


func _supports_platform(platform_:EditorExportPlatform) -> bool:
	return platform_ is EditorExportPlatformWeb


func _get_export_options_overrides(platform_:EditorExportPlatform) -> Dictionary:
	var export_options = {}

	if EditorYandexGamesSDK._get_setting(EditorYandexGamesSDK.SETTING_YANDEX_GAMES_SDK_ENABLED, false, TYPE_BOOL):
		export_options[OPTION_HTML_HEAD_INCLUDE] = \
			EditorYandexGamesSDK._get_setting(EditorYandexGamesSDK.SETTING_CUSTOM_HEAD_INCLUDE, "", TYPE_STRING) \
			+ SDK_SCRIPT

	return export_options


func _get_export_features(platform_:EditorExportPlatform, debug_:bool) -> PackedStringArray:
	var features = []

	if EditorYandexGamesSDK._get_setting(EditorYandexGamesSDK.SETTING_YANDEX_GAMES_SDK_ENABLED, false, TYPE_BOOL):
		features.push_back(YandexUtils.FEATURE)

		if EditorYandexGamesSDK._get_setting(EditorYandexGamesSDK.SETTING_YANDEX_GAMES_AUTO_INIT, false, TYPE_BOOL):
			features.push_back(YandexUtils.FEATURE_AUTO_INIT)

	return features
