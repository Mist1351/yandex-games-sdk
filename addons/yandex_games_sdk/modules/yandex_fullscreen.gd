## A Module for Managing Fullscreen Browser Mode.
## 
## [b]@version[/b] 1.0.1[br]
## [b]@author[/b] Mist1351[br]
## [br]
## Provides functionality for interacting with the browser's fullscreen mode.[br]
## [br]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#screen.fullscreen[/url]
class_name YandexFullscreen extends YandexModule


## Emitted when entering fullscreen mode is successful.
signal enter_succeeded()
## Emitted when entering fullscreen mode fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the failure.
signal enter_failed(error_:String)
## Emitted when exiting fullscreen mode is successful.
signal exit_succeeded()
## Emitted when exiting fullscreen mode fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the failure.
signal exit_failed(error_:String)


func _init(yandex_sdk_:YandexSDK) -> void:
	super(yandex_sdk_)


## [b]@async[/b][br]
## Activates fullscreen mode for the game.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal enter_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal enter_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if fullscreen mode was successfully activated; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## var result = await YandexSDK.leaderboard.init()
## ...
## await YandexSDK.fullscreen.enter()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#screen.fullscreen[/url]
func enter() -> Variant:
	if !_check_availability(["screen", "fullscreen", "request"]):
		return null
	
	var result := await Promise.new(_yandex_sdk._ysdk.screen.fullscreen.request()).wait()
	if !result.status:
		enter_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return false
	
	enter_succeeded.emit()
	return true


## [b]@async[/b][br]
## Exits fullscreen mode.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal exit_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal exit_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if fullscreen mode was successfully exited; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## var result = await YandexSDK.leaderboard.init()
## ...
## await YandexSDK.fullscreen.exit()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#screen.fullscreen[/url]
func exit() -> Variant:
	if !_check_availability(["screen", "fullscreen", "exit"]):
		return null
	
	var result := await Promise.new(_yandex_sdk._ysdk.screen.fullscreen.exit()).wait()
	if !result.status:
		exit_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return false
	
	exit_succeeded.emit()
	return true


## Checks whether the game is currently in fullscreen mode.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if the game is in fullscreen mode; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## var result = await YandexSDK.leaderboard.init()
## ...
## var is_fullscreen = YandexSDK.fullscreen.is_fullscreen()
## if is_fullscreen:
##     prints("The game is in fullscreen mode!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#screen.fullscreen[/url]
func is_fullscreen() -> Variant:
	if !_check_availability(["screen", "fullscreen", "status"]):
		return null
	
	if !_check_availability(["screen", "fullscreen", "STATUS_ON"]):
		return null
	
	return _yandex_sdk._ysdk.screen.fullscreen.STATUS_ON == _yandex_sdk._ysdk.screen.fullscreen.status
