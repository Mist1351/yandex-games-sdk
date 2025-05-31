@tool
class_name EditorYandexGamesSDK extends Control


const SETTING_YANDEX_GAMES_SDK_ENABLED := &"yandex_games_sdk/yandex_sdk_enabled"
const SETTING_YANDEX_GAMES_AUTO_INIT := &"yandex_games_sdk/yandex_sdk_auto_init"
const SETTING_CUSTOM_HEAD_INCLUDE := &"yandex_games_sdk/custom_head_include"


func _ready() -> void:
	%Enable.button_pressed = _get_setting(SETTING_YANDEX_GAMES_SDK_ENABLED, false, TYPE_BOOL)
	%AutoInit.button_pressed = _get_setting(SETTING_YANDEX_GAMES_AUTO_INIT, false, TYPE_BOOL)
	%HeadInclude.text = _get_setting(SETTING_CUSTOM_HEAD_INCLUDE, "", TYPE_STRING)


static func _get_setting(key_:String, default_:Variant, type_:int) -> Variant:
	if !ProjectSettings.has_setting(key_):
		return default_
	
	var value := ProjectSettings.get_setting(key_)
	if typeof(value) == type_:
		return value
	
	return default_


func _save_settings() -> void:
	$Timer.stop()
	ProjectSettings.set_setting(SETTING_YANDEX_GAMES_SDK_ENABLED, %Enable.button_pressed)
	ProjectSettings.set_setting(SETTING_YANDEX_GAMES_AUTO_INIT, %AutoInit.button_pressed)
	print(%HeadInclude.text)
	ProjectSettings.set_setting(SETTING_CUSTOM_HEAD_INCLUDE, %HeadInclude.text)
	
	ProjectSettings.set_as_internal(SETTING_YANDEX_GAMES_SDK_ENABLED, true)
	ProjectSettings.set_as_internal(SETTING_YANDEX_GAMES_AUTO_INIT, true)
	ProjectSettings.set_as_internal(SETTING_CUSTOM_HEAD_INCLUDE, true)
	
	if OK == ProjectSettings.save():
		print("Yandex Games SDK settings saved")
	else:
		printerr("Yandex Games SDK settings saving failed!")


func _on_timer_timeout() -> void:
	_save_settings()


func _on_settings_toggled(toggled_on_:bool) -> void:
	_save_settings()


func _on_head_include_text_changed() -> void:
	$Timer.start(1.0)
