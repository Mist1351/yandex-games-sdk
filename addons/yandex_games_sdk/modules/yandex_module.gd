## Base class for all Yandex games modules
## 
## [b]@version[/b] 1.0.3[br]
## [b]@author[/b] Mist1351
class_name YandexModule extends RefCounted


var _yandex_sdk:YandexGamesSDK = null


func _init(yandex_sdk_:YandexGamesSDK) -> void:
	_yandex_sdk = yandex_sdk_


func _is_inited() -> bool:
	return null != _yandex_sdk && _yandex_sdk.is_inited()


func _reset_sdk_error() -> void:
	if null != _yandex_sdk:
		_yandex_sdk._reset_sdk_error()


func _emit_sdk_error(error_:String) -> void:
	if null != _yandex_sdk:
		_yandex_sdk._emit_sdk_error(error_)


func _is_available_method(method_:String) -> bool:
	if !_is_inited() || !YandexUtils.has_property(_yandex_sdk._ysdk, ["isAvailableMethod"]):
		return false
	
	var result := await Promise.new(_yandex_sdk._ysdk.isAvailableMethod(method_)).wait()
	if !result.status:
		return false
	
	return result.value[0]


func _check_availability(property_chain_:Array[String], prefix_:String = "ysdk", obj_:JavaScriptObject = null) -> bool:
	_reset_sdk_error()
	if null == obj_ && null != _yandex_sdk && "ysdk" == prefix_:
		obj_ = _yandex_sdk._ysdk
	if !_is_inited() || !YandexUtils.has_property(obj_, property_chain_):
		_emit_sdk_error(prefix_ + "." + ".".join(property_chain_) + " is not available!")
		return false
	return true
