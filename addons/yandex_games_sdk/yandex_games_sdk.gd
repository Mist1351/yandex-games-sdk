## The Main Class for Integrating Yandex Games Features.
##
## [b]@version[/b] 1.0.2[br]
## [b]@author[/b] Mist1351[br]
## [br]
## The core class of the plugin, providing a unified interface for accessing Yandex Games features and tools. This class serves as the central hub for managing game-related functionalities, such as advertisements, leaderboards, player data, device information, and more. It simplifies integration and ensures seamless interaction with the Yandex Games SDK.[br]
## [br]
## [b]@see[/b] modules: [YandexAdv], [YandexDeviceInfo], [YandexFeedback], [YandexFullscreen], [YandexGames], [YandexLeaderboard], [YandexPayments], [YandexPlayer], [YandexShortcut]
## [br]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-about[/url]
class_name YandexGamesSDK extends Node


## Emitted when an internal error occurs in [YandexGamesSDK] (e.g., when [YandexGamesSDK] is not initialized and a method is unavailable).[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal sdk_error(error_:String)
## Emitted when the initialization of [YandexGamesSDK] is successfully completed and the SDK is ready for use.
signal init_succeeded()
## Emitted when the initialization of [YandexGamesSDK] fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal init_failed(error_:String)
## Emitted when the remote configuration flags are successfully retrieved.[br]
## [b]@param[/b] {[Dictionary]} [param flags_] — A dictionary containing the retrieved configuration flags.
signal get_flags_succeeded(flags_:Dictionary)
## Emitted when retrieving the remote configuration flags fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal get_flags_failed(error_:String)
## Emitted when the cooldown period for calling get_flags has ended, indicating that the method is available for use again.
signal get_flags_timeout()
## Emitted under the following conditions:[br]
## [b]    •[/b] displaying of full-screen or rewarded ads;[br]
## [b]    •[/b] opening of purchase windows;[br]
## [b]    •[/b] switching browser tabs;[br]
## [b]    •[/b] minimizing the browser window.[br]
signal game_api_paused()
## Emitted under the following conditions:[br]
## [b]    •[/b] closing of full-screen or rewarded ads;[br]
## [b]    •[/b] closing of purchase windows;[br]
## [b]    •[/b] switching browser tabs;[br]
## [b]    •[/b] maximizing the browser window.[br]
signal game_api_resumed()
## Emitted when the user presses the "Back" button on a TV device.
signal on_history_back_event()
## Emitted when the game window gains focus in an HTML5 environment.
signal on_game_focused()
## Emitted when the game window loses focus in an HTML5 environment.
signal on_game_blurred()


const SDK_VERSION = "1.0.2"


## Module for managing advertisements.
var adv:YandexAdv = null
## Module for accessing device information.
var device_info:YandexDeviceInfo = null
## Module for managing user feedback.
var feedback:YandexFeedback = null
## Module for managing fullscreen mode.
var fullscreen:YandexFullscreen = null
## Module for managing fullscreen mode.
var games:YandexGames = null
## Module for managing leaderboards.
var leaderboard:YandexLeaderboard = null
## Module for managing purchases and the store.
var payments:YandexPayments = null
## Module for managing player data.
var player:YandexPlayer = null
## Module for managing shortcuts.
var shortcut:YandexShortcut = null

## A call rate limiter for managing the frequency of [method get_flags] calls.
var crl_get_flags:YandexUtils.CallRateLimiter = YandexUtils.CallRateLimiter.new(get_flags_timeout, 5 * 60 * 1000, 1)


var _ysdk:JavaScriptObject = null
var _last_sdk_error = null
var _is_gameplay_started := false
var _crl_list:Array[YandexUtils.CallRateLimiter] = []

var _js_on_game_api_paused := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		game_api_paused.emit())

var _js_on_game_api_resumed := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		game_api_resumed.emit())

var _js_on_history_back_callback := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		on_history_back_event.emit())

var _js_on_window_focus_callback := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		on_game_focused.emit())

var _js_on_window_blur_callback := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		on_game_blurred.emit())


func _ready() -> void:
	YandexUtils.init()
	if YandexUtils.has_property(YandexUtils.js_window, ["addEventListener"]):
		YandexUtils.js_window.addEventListener("focus", _js_on_window_focus_callback)
		YandexUtils.js_window.addEventListener("blur", _js_on_window_blur_callback)
	adv = YandexAdv.new(self)
	device_info = YandexDeviceInfo.new(self)
	feedback = YandexFeedback.new(self)
	fullscreen = YandexFullscreen.new(self)
	games = YandexGames.new(self)
	leaderboard = YandexLeaderboard.new(self)
	payments = YandexPayments.new(self)
	player = YandexPlayer.new(self)
	shortcut = YandexShortcut.new(self)
	
	_push_crl(crl_get_flags)
	
	if YandexUtils.has_auto_init():
		await init()
		await player.init()
		await leaderboard.init()
		await payments.init()


func _process(delta_:float) -> void:
	if !is_inited():
		return
	
	for item in _crl_list:
		item.process()


func _push_crl(crl_:YandexUtils.CallRateLimiter) -> void:
	crl_.set_yandex_sdk(self)
	_crl_list.push_back(crl_)


func _emit_sdk_error(error_:String) -> void:
	_last_sdk_error = error_
	sdk_error.emit(error_)


func _reset_sdk_error() -> void:
	_last_sdk_error = null


func _check_availability(property_chain_:Array[String], prefix_:String = "ysdk", obj_:JavaScriptObject = null) -> bool:
	_reset_sdk_error()
	if null == obj_:
		obj_ = _ysdk
	if !is_inited() || !YandexUtils.has_property(obj_, property_chain_):
		_emit_sdk_error(prefix_ + "." + ".".join(property_chain_) + " is not available!")
		return false
	return true


## Checks whether the game window is currently in focus.[br]
## [br]
## It is useful for handling pause mechanics or adjusting game behavior when the player switches tabs.[br]
## [br]
## [b]@returns[/b] [bool] — [code]true[/code] if the game is focused, [code]false[/code] otherwise.[br]
## [b]@see[/b] [signal on_game_focused], [signal on_game_blurred].
func is_game_focused() -> bool:
	return YandexUtils.has_focus()


## Retrieve the possible error emitted with the [signal sdk_error] signal.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — No error is available.[br]
## [b]@returns[/b] [String] — The emitted error message.
func get_last_sdk_error() -> Variant:
	return _last_sdk_error


## [b]@async[/b][br]
## Initialize the [YandexGamesSDK].[br]
## [br]
## [color=gold][b]@warning:[/b][/color] This method must be called once before using other methods of [YandexGamesSDK].[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal init_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal init_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [bool] — [code]true[/code] if [YandexGamesSDK] is initialized; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## var result = await YandexSDK.init()
## if result:
##     prints("YandexSDK is initialized!")
## else:
##     prints("YandexSDK is not initialized!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-about#use[/url]
func init() -> bool:
	_ysdk = null
	
	_reset_sdk_error()
	if !YandexUtils.is_enabled():
		_emit_sdk_error("YandexSDK not available! Enable features \"web\" and \"yandex_sdk\".")
		return false
	
	var ya_games := JavaScriptBridge.get_interface("YaGames")
	if null == ya_games || !YandexUtils.has_property(ya_games, ["init"]):
		_emit_sdk_error("YaGames.init() is not available!")
		return false
	
	var result := await Promise.new(ya_games.init()).wait()
	if result.status:
		_ysdk = result.value[0]
		if YandexUtils.has_property(_ysdk, ["off"]) && YandexUtils.has_property(_ysdk, ["on"]):
			_ysdk.off("game_api_pause", _js_on_game_api_paused)
			_ysdk.on("game_api_pause", _js_on_game_api_paused)
			_ysdk.off("game_api_resume", _js_on_game_api_resumed)
			_ysdk.on("game_api_resume", _js_on_game_api_resumed)
			if YandexUtils.has_property(_ysdk, ["EVENTS", "HISTORY_BACK"]):
				_ysdk.off(_ysdk.EVENTS.HISTORY_BACK, _js_on_history_back_callback)
				_ysdk.on(_ysdk.EVENTS.HISTORY_BACK, _js_on_history_back_callback)
		init_succeeded.emit()
	else:
		init_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
	
	return result.status


## Returns the initialization state of [YandexGamesSDK].[br]
## [br]
## [b]@returns[/b] [bool] — [code]true[/code] if [YandexGamesSDK] is initialized; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## var result = YandexSDK.is_inited()
## if result:
##     prints("YandexSDK is initialized!")
## else:
##     prints("YandexSDK is not initialized!")
## [/codeblock]
func is_inited() -> bool:
	return YandexUtils.is_enabled() && null != _ysdk


## Notifies the Yandex Games SDK that the game has completed loading all resources and is ready to interact with the user.[br]
## [br]
## [color=gold][b]@warning:[/b][/color] Ensure the following conditions are met before calling this method:[br]
## [b]    •[/b] all elements are ready to interact with the player;[br]
## [b]    •[/b] there are no loading screens.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## YandexSDK.game_ready()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-game-events#gameready[/url]
func game_ready() -> void:
	if !_check_availability(["features", "LoadingAPI", "ready"]):
		return
	
	_ysdk.features.LoadingAPI.ready()


## Checks whether the [method game_ready] method has been called to indicate that the game is fully loaded and ready for interaction.[br]
## [br]
## [b]@returns[/b] [bool] — [code]true[/code] if the [method game_ready] method has been called; otherwise, [code]false[/code].[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## YandexSDK.game_ready()
## var result = YandexSDK.is_game_ready()
## if result:
##     prints(Game ready!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-game-events#gameready[/url]
func is_game_ready() -> bool:
	if !_check_availability(["features", "LoadingAPI", "isReady"]):
		return false
	
	return _ysdk.features.LoadingAPI.isReady


## Sends an event to the Yandex Games SDK indicating that gameplay has started or resumed.[br]
## This method should be called in scenarios such as:[br]
## [b]    •[/b] starting a level;[br]
## [b]    •[/b] closing a menu;[br]
## [b]    •[/b] resuming from a pause;[br]
## [b]    •[/b] resuming the game after showing ads;[br]
## [b]    •[/b] returning to the current browser tab.[br]
## [br]
## [color=gold][b]@warning:[/b][/color] Ensure that gameplay begins immediately after calling this method.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## YandexSDK.gameplay_start()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-game-events#ysdkfeaturesgameplayapistart[/url]
func gameplay_start() -> void:
	if !_check_availability(["features", "GameplayAPI", "start"]):
		return
	
	_ysdk.features.GameplayAPI.start()
	_is_gameplay_started = true


## Sends an event to the Yandex Games SDK indicating that gameplay has stopped.[br]
## This method should be called in scenarios such as:[br]
## [b]    •[/b] completing or failing a leve;[br]
## [b]    •[/b] calling up a menu;[br]
## [b]    •[/b] pausing the game;[br]
## [b]    •[/b] showing full-screen or rewarded ads;[br]
## [b]    •[/b] switching to another browser tab.[br]
## [br]
## [color=gold][b]@warning:[/b][/color] Ensure that gameplay stopped immediately after calling this method.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## YandexSDK.gameplay_stop()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-game-events#ysdkfeaturesgameplayapistop[/url]
func gameplay_stop() -> void:
	if !_check_availability(["features", "GameplayAPI", "stop"]):
		return
	
	_ysdk.features.GameplayAPI.stop()
	_is_gameplay_started = false


## Checks whether the [method gameplay_start] method has been called, indicating that gameplay has been marked as started or resumed.[br]
## [br]
## [b]@returns[/b] [bool] — [code]true[/code] if the [method gameplay_start] method has been called; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## YandexSDK.game_ready()
## ...
## # Gameplay stopped
## YandexSDK.gameplay_stop()
## ...
## # Gameplay started
## YandexSDK.gameplay_start()
## var result = YandexSDK.is_gameplay_started()
## if result:
##     prints(Gameplay started!")
## [/codeblock]
func is_gameplay_started() -> bool:
	return _is_gameplay_started


## Sends an [b]EXIT[/b] event to the Yandex Games SDK.[br]
## [br]
## [color=gold][b]@warning:[/b][/color] This event is available only if the game is launched on a TV.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## if YandexSDK.device_info.is_tv():
##     YandexSDK.send_exit_event()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-events#exit-history-back[/url]
func send_exit_event() -> void:
	if !_check_availability(["dispatchEvent"]):
		return
	
	if !_check_availability(["EVENTS", "EXIT"]):
		return
	
	_ysdk.dispatchEvent(_ysdk.EVENTS.EXIT)


## Returns the current server timestamp in milliseconds. The server time is consistent across all devices and cannot be overridden or modified, making it a reliable source compared to the local device time returned by [b]Date.now()[/b].[br]
## This method is protected against potential manipulation by players.[br]
## Call it every time you need to get the current time.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [int] — A timestamp in milliseconds representing the current server time.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var timestamp = YandexSDK.get_server_time()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-server-time#ysdkservertime[/url]
func get_server_time() -> Variant:
	if !_check_availability(["serverTime"]):
		return null
	
	return _ysdk.serverTime()


## [b]@async[/b][br]
## Writing a text string to the clipboard.[br]
## [br]
## [b]@param[/b] {[String]} [param text_] — The text string to be copied to the clipboard.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if the text was successfully copied to the clipboard; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## await YandexSDK.clipboard_write("text")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-params#clipboard[/url]
func clipboard_write(text_:String) -> Variant:
	if !_check_availability(["clipboard", "writeText"]):
		return null
	
	var result := await Promise.new(_ysdk.clipboard.writeText(text_)).wait()
	return result.status


## Get information about the environment the game is run in.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized;[br]
## [b]@returns[/b] [Dictionary] — Game environment variables:
## [codeblock lang=gdscript]
## {
##     # Game data.
##     "app": {
##         # Game ID.
##         "id":String,
##     },
##     # Service internationalization.
##     "i18n": {
##         # Yandex Games interface language in ISO 639-1 format.
##         # For example, "tr" means that the game is currently running under the Yandex Games Turkish interface.
##         # Use this parameter to determine the user's language in the game.
##         "lang":String,
##         # Top-level domain.
##         # For example, "com" means that the game is currently running under the Yandex Games international domain.
##         # When hosting the game on your domain, keep in mind that it must open correctly on any Yandex domain.
##         "tld":String,
##     },
##     # The value of the payload parameter from the game's address.
##     # Optional parameter (it can be null).
##     # For example, in https://yandex.ru/games/app/123?payload=test you can return "test".
##     "payload":String,
## }
## [/codeblock]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.leaderboard.init()
## ...
## var environment = YandexSDK.get_environment()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-environment[/url]
func get_environment() -> Variant:
	if !_check_availability(["environment"]):
		return null
	
	return {
		"app": {
			"id": YandexUtils.get_property(_ysdk.environment, ["app", "id"]),
		},
		"i18n": {
			"lang": YandexUtils.get_property(_ysdk.environment, ["i18n", "lang"]),
			"tld": YandexUtils.get_property(_ysdk.environment, ["i18n", "tld"]),
		},
		"payload": YandexUtils.get_property(_ysdk.environment, ["payload"]),
		
		"browser": {
			"lang": YandexUtils.get_property(_ysdk.environment, ["browser", "lang"]),
		},
		"is_telegram": YandexUtils.get_property(_ysdk.environment, ["isTelegram"]),
	}


## [b]@async[/b][br]
## Downloads an image from the specified URL.[br]
## [br]
## [color=deep_sky_blue][b]@note:[/b][/color] Supported formats: BMP, JPG, KTX, PNG, SVG, TGA, WEBP.[br]
## [br]
## [b]@param[/b] {[String]} [param url_] — The URL of the image to download.[br]
## [b]@param[/b] {[float]} [lb][param scale_][kbd] = 1.0[/kbd][rb] — Scaling factor for SVG images.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — The request failed or the image format is invalid.[br]
## [b]@returns[/b] [ImageTexture] — The downloaded image as a texture.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## var url:String = "http://site.com/image.png"
## await YandexSDK.request_image_by_url(url)
## [/codeblock]
func request_image_by_url(url_:String, scale_:float = 1.0) -> ImageTexture:
	var texture:ImageTexture = null
	var request := HTTPRequest.new()
	add_child(request)
	var _image_load_methods = ["load_png_from_buffer", "load_jpg_from_buffer", "load_webp_from_buffer", "load_svg_from_buffer", "load_bmp_from_buffer", "load_tga_from_buffer", "load_ktx_from_buffer"]
	if OK == request.request(url_):
		var result = await request.request_completed
		var image := Image.new()
		var buffer = result[3]
		for method in _image_load_methods:
			if image.has_method(method):
				if "load_svg_from_buffer" == method:
					if OK == image.call(method, buffer, scale_):
						texture = ImageTexture.create_from_image(image)
						break
				elif OK == image.call(method, buffer):
					texture = ImageTexture.create_from_image(image)
					break
	request.queue_free()
	return texture


## [b]@async[/b][br]
## Retrieves the remote configuration flags (Remote Config) from the Yandex Games SDK. This method returns the current values of the saved flags, allowing you to customize the game's behavior based on the server-provided configuration.[br]
## It is recommended to request flags once during your game's startup.[br]
## [br]
## [color=deep_sky_blue][b]@note:[/b][/color] Flags from the Yandex server can be requested every [code]5 minutes[/code]. Otherwise, a cached configuration of the flags will be returned.[br]
## [color=gold][b]@warning:[/b][/color] To request flags from the Yandex server again, the following is required:[br]
## [b]    •[/b] Add a unique value, for example [code]{"__id": str(YandexSDK.get_server_time())}[/code], to the [param flags_params_] parameter;[br]
## [b]    •[/b] Wait for the timeout period to end (see [signal get_flags_timeout]).[br]
## [br]
## [b]@param[/b] {[YandexGamesSDK.GetFlagsParams]} [lb][param flags_params_][kbd] = null[/kbd][rb] — Flag parameters.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal get_flags_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal get_flags_failed] — The request failed with an error.[br]
## [b]@emits[/b] [signal get_flags_timeout] — The cooldown period for calling another get_flags ends.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexGamesSDK] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [Dictionary] — The values of the saved flags.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var params = YandexSDK.create_flags_params({"__id": str(YandexSDK.get_server_time())})
## params.set_client_feature("level", "10")
## var flags = await YandexSDK.get_flags(params)
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-config[/url]
func get_flags(flags_params_:GetFlagsParams = null) -> Variant:
	if !_check_availability(["getFlags"]):
		return null
	
	var params:JavaScriptObject = JavaScriptBridge.create_object("Array")
	if null != flags_params_:
		params.push(flags_params_.to_javascript_object())
	
	var result := await Promise.new(_ysdk.getFlags.apply(_ysdk, params)).wait()
	if !result.status:
		get_flags_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	crl_get_flags.apply()
	
	var entries = JavaScriptBridge.get_interface("Object").entries(result.value[0])
	var flags = {}
	for i in entries.length:
		flags[entries[i][0]] = entries[i][1]
	
	get_flags_succeeded.emit(flags)
	return flags


## @alias [YandexGamesSDK.GetFlagsParams].
static func create_flags_params(default_flags_:Dictionary = {}, client_features_:Array[Dictionary] = []) -> GetFlagsParams:
	return GetFlagsParams.new(default_flags_, client_features_)


## Helper class for creating parameters for the [method YandexGamesSDK.get_flags] method.
##
## An alias for this class exists: [method YandexGamesSDK.create_flags_params].
class GetFlagsParams:
	## Default flags.[br]
	## [br]
	## Expects key/value pairs with [code]String[/code] type.[br]
	## Pairs where the value is not of type [code]String[/code] will be ignored during the [method YandexGamesSDK.get_flags] call.[br]
	## [br]
	## Example:
	## [codeblock lang=gdscript]
	## YandexSDK.GetFlagsParams.new({
	##     "difficult": "easy",
	##     "coins": str(100),
	## })
	## [/codeblock]
	## @see [method set_default_flag] and [method df].
	var default_flags:Dictionary
	
	## Client features.[br]
	## [br]
	## Expects a [code]Dictionary[/code] with two keys: [code]"name"[/code] and [code]"value"[/code], and values of type [code]String[/code].[br]
	## Dictionaries missing the [code]"name"[/code]/[code]"value"[/code] keys or with values of a type other than [code]String[/code] will be ignored during the [method YandexGamesSDK.get_flags] call.[br]
	## [br]
	## Example:
	## [codeblock lang=gdscript]
	## YandexSDK.GetFlagsParams.new({}, [
	##     {"name": "level", "value": str(100)},
	## ])
	## [/codeblock]
	## @see [method set_client_feature] and [method cf].
	var client_features:Array[Dictionary]
	
	func _init(default_flags_:Dictionary = {}, client_features_:Array[Dictionary] = []) -> void:
		default_flags = default_flags_
		client_features = client_features_
	
	## Replaces/adds the [param value_] under the key [param name_] in [member default_flags].
	func set_default_flag(name_:String, value_:String) -> GetFlagsParams:
		default_flags[name_] = value_
		return self
	
	## @alias [method set_default_flag].
	func df(name_:String, value_:String) -> GetFlagsParams:
		return set_default_flag(name_, value_)
	
	## Replaces/adds a dictionary with [param name_] and [param value_] values to [member client_features].
	func set_client_feature(name_:String, value_:String) -> GetFlagsParams:
		for item in client_features:
			if name_ == item.get("name"):
				item["name"] = name_
				item["value"] = value_
				return self
		
		client_features.push_back({ "name": name_, "value": value_ })
		return self
	
	## @alias [method set_client_feature].
	func cf(name_:String, value_:String) -> GetFlagsParams:
		return set_client_feature(name_, value_)
	
	## Converts the data to a [JavaScriptObject].
	func to_javascript_object() -> JavaScriptObject:
		if !OS.has_feature("web"):
			return null
		
		var object := JavaScriptBridge.create_object("Object")
		var js_json:JavaScriptObject = JavaScriptBridge.get_interface("JSON")
		
		if !default_flags.is_empty():
			var valid_flags := {}
			for key in default_flags:
				var value = default_flags[key]
				if TYPE_STRING == typeof(value):
					valid_flags[key] = value
			if !valid_flags.is_empty():
				object["defaultFlags"] = js_json.parse(JSON.stringify(valid_flags, "", true, true))
		
		if !client_features.is_empty():
			var valid_client_features := []
			for feature in client_features:
				var key = feature.get("name")
				var value = feature.get("value")
				if TYPE_STRING == typeof(key) && TYPE_STRING == typeof(value):
					valid_client_features.push_back({"name": key, "value": value})
			if !valid_client_features.is_empty():
				object["clientFeatures"] = js_json.parse(JSON.stringify(valid_client_features, "", true, true))
		
		return object
