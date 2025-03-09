## A Module for Retrieving Device Information in Yandex Games.
## 
## [b]@version[/b] 1.0[br]
## [b]@author[/b] Mist1351[br]
## [br]
## Provides simple methods to identify the player's device type, such as mobile, desktop, tablet, or TV.[br]
## [br]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#deviceinfo[/url]
class_name YandexDeviceInfo extends YandexModule


## Represents a mobile device.
const TYPE_MOBILE = "mobile"
## Represents a desktop computer.
const TYPE_DESKTOP = "desktop"
## Represents a tablet device.
const TYPE_TABLET = "tablet"
## Represents a television device.
const TYPE_TV = "tv"


func _init(yandex_sdk_:YandexSDK) -> void:
	super(yandex_sdk_)


## Checks if the user's device is mobile.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if it is a mobile device; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var result = YandexSDK.device_info.is_mobile()
## if result:
##     prints("This is a mobile device!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#deviceinfo[/url]
func is_mobile() -> Variant:
	if !_check_availability(["deviceInfo", "isMobile"]):
		return null
	
	return _yandex_sdk._ysdk.deviceInfo.isMobile()


## Checks if the user's device is desktop.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if it is a desktop; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var result = YandexSDK.device_info.is_desktop()
## if result:
##     prints("This is a desktop!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#deviceinfo[/url]
func is_desktop() -> Variant:
	if !_check_availability(["deviceInfo", "isDesktop"]):
		return null
	
	return _yandex_sdk._ysdk.deviceInfo.isDesktop()


## Checks if the user's device is tablet.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if it is a tablet; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var result = YandexSDK.device_info.is_tablet()
## if result:
##     prints("This is a tablet!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#deviceinfo[/url]
func is_tablet() -> Variant:
	if !_check_availability(["deviceInfo", "isTablet"]):
		return null
	
	return _yandex_sdk._ysdk.deviceInfo.isTablet()


## Checks if the user's device is TV.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if it is a TV; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var result = YandexSDK.device_info.is_tv()
## if result:
##     prints("This is a TV!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#deviceinfo[/url]
func is_tv() -> Variant:
	if !_check_availability(["deviceInfo", "isTV"]):
		return null
	
	return _yandex_sdk._ysdk.deviceInfo.isTV()


## Gets the type of the user's device.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [constant TYPE_MOBILE] — Indicates that the user's device is a mobile device.[br]
## [b]@returns[/b] [constant TYPE_DESKTOP] — Indicates that the user's device is a desktop.[br]
## [b]@returns[/b] [constant TYPE_TABLET] — Indicates that the user's device is a tablet.[br]
## [b]@returns[/b] [constant TYPE_TV] — Indicates that the user's device is a TV.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var device_type = YandexSDK.device_info.get_type()
## match device_type:
##     YandexDeviceInfo.TYPE_MOBILE:
##         prints("This is a mobile device!")
##     YandexDeviceInfo.TYPE_DESKTOP:
##         prints("This is a desktop!")
##     YandexDeviceInfo.TYPE_TABLET:
##         prints("This is a tablet!")
##     YandexDeviceInfo.TYPE_TV:
##         prints("This is a TV!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#deviceinfo[/url]
func get_type() -> Variant:
	if !_check_availability(["deviceInfo", "type"]):
		return null
	
	return _yandex_sdk._ysdk.deviceInfo.type
