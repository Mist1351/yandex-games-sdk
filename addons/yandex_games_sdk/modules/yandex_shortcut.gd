## A Module for Adding Game Shortcuts to the Desktop.
## 
## [b]@version[/b] 1.0.1[br]
## [b]@author[/b] Mist1351[br]
## [br]
## Allows you to prompt the user with a native dialog box to add a shortcut link to your game on their desktop.
## [br]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-shortcut[/url]
class_name YandexShortcut extends YandexModule


## Emitted when the check for the ability to show the prompt is successfully completed.[br]
## [b]@param[/b] {[bool]} [param can_show_] — Indicates whether the prompt can be shown [code]true[/code] or not [code]false[/code].[br]
## [b]@param[/b] {[code]null[/code]|[String]} [param reason_] — Additional information explaining why the prompt can or cannot be shown.
signal can_show_prompt_succeeded(can_show_:bool, reason_:Variant)
## Emitted when the check for the ability to show the prompt fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the failure.
signal can_show_prompt_failed(error_:String)
## Emitted when the prompt is successfully shown and the user has responded.[br]
## [b]@param[/b] {[bool]} [param accepted_] — Indicates whether the user accepted the prompt [code]true[/code] or declined it [code]false[/code].
signal show_prompt_succeeded(accepted_:bool)
## Emitted when showing the prompt fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the failure.
signal show_prompt_failed(error_:String)


var _show_prompt_reason = null


func _init(yandex_sdk_:YandexSDK) -> void:
	super(yandex_sdk_)


## [b]@async[/b][br]
## Checks whether adding a shortcut is available. The availability of this option depends on the platform, internal browser rules, and Yandex Games restrictions. Use this method to determine if the shortcut can be added before attempting to display the prompt.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal can_show_prompt_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal can_show_prompt_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexGamesSDK] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [bool] — Returns [code]true[/code] if adding a shortcut is available; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var can_show = await YandexSDK.shortcut.can_show_prompt()
## if can_show:
##     prints("A shortcut can be added!")
## else:
##     prints("A shortcut cannot be added!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-shortcut#can-add-shortcut[/url]
func can_show_prompt() -> Variant:
	if !_check_availability(["shortcut", "canShowPrompt"]):
		return null
	
	var result := await Promise.new(_yandex_sdk._ysdk.shortcut.canShowPrompt()).wait()
	if !result.status:
		can_show_prompt_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	var can_show = YandexUtils.get_property(result.value[0], ["canShow"])
	can_show_prompt_succeeded.emit(can_show, null)
	return can_show


## [b]@async[/b][br]
## Opens a dialog box to prompt the user to add a shortcut to their desktop. Before calling this method, ensure that adding a shortcut is available by using the [method can_show_prompt] method.[br]
## [br]
## [color=deep_sky_blue][b]@note:[/b][/color] To get the reason after calling this method, use the [method get_show_prompt_reason] method.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal show_prompt_succ] — The request was completed successfully.[br]
## [b]@emits[/b] [signal show_prompt_failed] — The request failed with an error.[br]
## [b]@emits[/b] [signal can_show_prompt_succeeded] — The prompt cannot be shown, providing the reason.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexGamesSDK] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if the user accepted the prompt; [code]false[/code] if the user declined it or it cannot be shown.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var accepted = await YandexSDK.shortcut.show_prompt()
## if accepted:
##     prints("Shortcut added!")
## else:
##     prints("A shortcut cannot be added or the user declined the request! Reason: ", YandexSDK.shortcut.get_show_prompt_reason())
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-shortcut#dialog-add-shortcut[/url]
func show_prompt() -> Variant:
	_show_prompt_reason = null
	
	if !_check_availability(["shortcut", "showPrompt"]):
		return null
	
	var result := await Promise.new(_yandex_sdk._ysdk.shortcut.showPrompt()).wait()
	if !result.status:
		show_prompt_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	var can_show = YandexUtils.get_property(result.value[0], ["canShow"])
	if null != can_show:
		_show_prompt_reason = YandexUtils.get_property(result.value[0], ["reason"])
		can_show_prompt_succeeded.emit(can_show, _show_prompt_reason)
		return can_show
	
	var outcome = YandexUtils.get_property(result.value[0], ["outcome"])
	var accepted = ("accepted" == outcome)
	show_prompt_succeeded.emit(accepted)
	return accepted


## Retrieve the possible reason after calling the [method show_prompt] method.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — No reason is available.[br]
## [b]@returns[/b] [String] — The reason for the last [method show_prompt] call.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var accepted = await YandexSDK.shortcut.show_prompt()
## if !accepted:
##     prints("A shortcut cannot be added or the user declined the request! Reason: ", YandexSDK.shortcut.get_show_prompt_reason())
## [/codeblock]
func get_show_prompt_reason() -> Variant:
	return _show_prompt_reason
