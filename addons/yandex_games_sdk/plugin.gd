@tool
extends EditorPlugin


const AUTOLOAD_NAME = "YandexSDK"
const PANEL_SCENE = preload("panel.tscn")


var _export_plugin:EditorExportPlugin = null
var _panel:Control = null


func _enter_tree() -> void:
	_panel = PANEL_SCENE.instantiate()
	add_control_to_bottom_panel(_panel, "Yandex Games SDK")
	
	_export_plugin = preload("export_plugin.gd").new()
	add_export_plugin(_export_plugin)
	add_autoload_singleton(AUTOLOAD_NAME, "yandex_games_sdk.gd")


func _exit_tree() -> void:
	if null != _panel:
		remove_control_from_bottom_panel(_panel)
		_panel.queue_free()
		_panel = null
	
	if null != _export_plugin:
		remove_autoload_singleton(AUTOLOAD_NAME)
		remove_export_plugin(_export_plugin)
		_export_plugin = null
