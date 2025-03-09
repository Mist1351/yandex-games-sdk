@tool
extends EditorPlugin


const AUTOLOAD_NAME = "YandexSDK"
var _export_plugin:EditorExportPlugin = null


func _enter_tree() -> void:
	_export_plugin = preload("export_plugin.gd").new()
	add_export_plugin(_export_plugin)
	add_autoload_singleton(AUTOLOAD_NAME, "yandex_games_sdk.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	remove_export_plugin(_export_plugin)
	_export_plugin = null
