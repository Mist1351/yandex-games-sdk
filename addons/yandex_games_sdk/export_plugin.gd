@tool
extends EditorExportPlugin


const SDK_SCRIPT = '<script src="/sdk.js"></script>'

var _export_file_path = null


func _get_name() -> String:
	return "YandexSDK"


func _export_begin(features_:PackedStringArray, is_debug_:bool, path_:String, flags_:int) -> void:
	if features_.has(YandexUtils.FEATURE):
		_export_file_path = path_
	else:
		_export_file_path = null


func _export_end() -> void:
	if null != _export_file_path:
		var file := FileAccess.open(_export_file_path, FileAccess.READ)
		if null == file:
			printerr("Failed to open: ", _export_file_path)
			return
		
		var html := file.get_as_text()
		file.close()
		
		var pos := html.find("</head>")
		if -1 == pos:
			printerr("Tag \"</head>\" not found!")
			return
		
		html = html.insert(pos, SDK_SCRIPT)
		
		file = FileAccess.open(_export_file_path, FileAccess.WRITE)
		file.store_string(html)
		file.close()
		
		_export_file_path = null
