## A Module for Managing Ads in Yandex Games.
## 
## [b]@version[/b] 1.0.2[br]
## [b]@author[/b] Mist1351[br]
## Provides tools for integrating and managing ad units in your games.[br]
## [br]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-adv[/url]
class_name YandexAdv extends YandexModule


## Emitted when the fullscreen ad is successfully opened.
signal show_fullscreen_opened()
## Emitted when the fullscreen ad is closed. This can occur after the ad has been shown or if it failed to open due to too frequent calls.[br]
## [b]@param[/b] {[bool]} [param was_shown_] — Indicates whether the ad was successfully shown [code]true[/code] or not [code]false[/code].
signal show_fullscreen_closed(was_shown_:bool)
## Emitted when an error occurs while attempting to show the fullscreen ad.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal show_fullscreen_error(error_:String)
## Emitted when the network connection is lost, preventing the fullscreen ad from being shown.
signal show_fullscreen_offline()
## Emitted when the cooldown period for showing a fullscreen ad has expired, indicating that the ad can be called again.
signal show_fullscreen_timeout()
## Emitted when the rewarded video ad is successfully shown on the screen.
signal show_rewarded_video_opened()
## Emitted when the rewarded video ad is closed by the user.
signal show_rewarded_video_closed()
## Emitted when an error occurs during the process of showing the rewarded video ad.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal show_rewarded_video_error(error_:String)
## Emitted when the rewarded video ad impression is counted. This signal indicates that the user has completed watching the ad and should receive their reward.
signal show_rewarded_video_rewarded()
## Emitted when the status of the sticky banner is successfully retrieved.[br]
## [b]@param[/b] {[bool]} [param sticky_adv_is_showing_] — Indicates whether the sticky banner is currently being shown [code]true[/code] or not [code]false[/code].[br]
## [b]@param[/b] {[code]null[/code]|[String]} [param reason_] — Additional information explaining the current status.
signal get_banner_status_succeeded(sticky_adv_is_showing_:bool, reason_:Variant)
## Emitted when retrieving the status of the sticky banner fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal get_banner_status_failed(error_:String)
## Emitted when the sticky banner is successfully shown.[br]
## [b]@param[/b] {[bool]} [param sticky_adv_is_showing_] — Indicates whether the banner is currently being shown [code]true[/code] or not [code]false[/code].[br]
## [b]@param[/b] {[code]null[/code]|[String]} [param reason_] — Additional information explaining the current status.
signal show_banner_succeeded(sticky_adv_is_showing_:bool, reason_:Variant)
## Emitted when the sticky banner fails to show.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal show_banner_failed(error_:String)
## Emitted when the sticky banner is successfully hidden.[br]
## [b]@param[/b] {[bool]} [param sticky_adv_is_showing_] — Indicates whether the banner is still being shown after the hide request ([code]false[/code] if successfully hidden).
signal hide_banner_succeeded(sticky_adv_is_showing_:bool)
## Emitted when the sticky banner fails to hide.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal hide_banner_failed(error_:String)

## Banners are not enabled.
const REASON_ADV_IS_NOT_CONNECTED = "ADV_IS_NOT_CONNECTED"
## Error displaying ads on the Yandex side.
const REASON_UNKNOWN = "UNKNOWN"

## A call rate limiter for managing the frequency of [method show_fullscreen] calls.
var crl_show_fullscreen:YandexUtils.CallRateLimiter = YandexUtils.CallRateLimiter.new(show_fullscreen_timeout, 60 * 1000, 1)


var _banner_reason = null

var _js_on_show_fullscreen_opened := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		show_fullscreen_opened.emit())

var _js_on_show_fullscreen_closed := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		show_fullscreen_closed.emit(args_[0]))

var _js_on_show_fullscreen_error := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		show_fullscreen_error.emit(args_[0]))

var _js_on_show_fullscreen_offline := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		show_fullscreen_offline.emit())


var _js_on_show_rewarded_video_opened := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		show_rewarded_video_opened.emit())

var _js_on_show_rewarded_video_closed := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		show_rewarded_video_closed.emit())

var _js_on_show_rewarded_video_error := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		show_rewarded_video_error.emit(args_[0]))

var _js_on_show_rewarded_video_rewarded := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		show_rewarded_video_rewarded.emit())


func _init(yandex_sdk_:YandexGamesSDK) -> void:
	super(yandex_sdk_)
	
	if null != _yandex_sdk:
		_yandex_sdk._push_crl(crl_show_fullscreen)


## Displays a fullscreen interstitial ad.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal show_fullscreen_opened] — The fullscreen ad is successfully displayed.[br]
## [b]@emits[/b] [signal show_fullscreen_closed] — The ad is closed.[br]
## [b]@emits[/b] [signal show_fullscreen_error] — An error occurs during the process of showing the ad.[br]
## [b]@emits[/b] [signal show_fullscreen_offline] — The ad cannot be displayed due to a lack of network connection.[br]
## [b]@emits[/b] [signal show_fullscreen_timeout] — The cooldown period for calling another fullscreen ad ends.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## YandexSDK.adv.show_fullscreen_closed.connect(func(was_shown_): prints("Yandex adv was_shown:", was_shown_))
## YandexSDK.adv.show_fullscreen()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-adv#full-screen-block[/url]
func show_fullscreen() -> void:
	if !_check_availability(["adv", "showFullscreenAdv"]):
		return
	
	if 0 == crl_show_fullscreen.get_requests_count():
		show_fullscreen_error.emit("Please, don't try to open advertising often than once per " + str(crl_show_fullscreen.get_max_timeout_in_sec()) + " sec")
		return
	
	var callbacks := JavaScriptBridge.create_object("Object")
	callbacks["onClose"] = _js_on_show_fullscreen_closed
	callbacks["onOpen"] = _js_on_show_fullscreen_opened
	callbacks["onError"] = _js_on_show_fullscreen_error
	callbacks["onOffline"] = _js_on_show_fullscreen_offline
	var params := JavaScriptBridge.create_object("Object")
	params["callbacks"] = callbacks
	_yandex_sdk._ysdk.adv.showFullscreenAdv(params)
	
	crl_show_fullscreen.apply()


## Displays a rewarded video ad.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal show_rewarded_video_opened] — The rewarded video is successfully displayed.[br]
## [b]@emits[/b] [signal show_rewarded_video_closed] — The rewarded video is closed by the user.[br]
## [b]@emits[/b] [signal show_rewarded_video_error] — An error occurs during the process of showing the rewarded video.[br]
## [b]@emits[/b] [signal show_rewarded_video_rewarded] — The video ad impression is completed, indicating that the user should receive the reward.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## YandexSDK.adv.show_rewarded_video_rewarded.connect(func(): prints("Yandex rewarded"))
## YandexSDK.adv.show_rewarded_video()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-adv#rewarded-video[/url]
func show_rewarded_video() -> void:
	if !_check_availability(["adv", "showRewardedVideo"]):
		return
	
	var callbacks := JavaScriptBridge.create_object("Object")
	callbacks["onClose"] = _js_on_show_rewarded_video_closed
	callbacks["onOpen"] = _js_on_show_rewarded_video_opened
	callbacks["onError"] = _js_on_show_rewarded_video_error
	callbacks["onRewarded"] = _js_on_show_rewarded_video_rewarded
	var params := JavaScriptBridge.create_object("Object")
	params["callbacks"] = callbacks
	_yandex_sdk._ysdk.adv.showRewardedVideo(params)


## [b]@async[/b][br]
## Checks the status of the sticky banner, including whether it is currently being displayed and the possible reason if it is not.[br]
## [br]
## [color=deep_sky_blue][b]@note:[/b][/color] If the method returned [code]null[/code], you can retrieve the possible reason code using the [method get_banner_reason] method.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal get_banner_status_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal get_banner_status_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexGamesSDK] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if sticky banner is shown; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var is_banner_showing = await YandexSDK.adv.get_banner_status()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-adv#sticky-banner[/url]
func get_banner_status() -> Variant:
	_banner_reason = null
	
	if !_check_availability(["adv", "getBannerAdvStatus"]):
		return null
	
	var result := await Promise.new(_yandex_sdk._ysdk.adv.getBannerAdvStatus()).wait()
	if !result.status:
		get_banner_status_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	var sticky_adv_is_showing = YandexUtils.get_property(result.value[0], ["stickyAdvIsShowing"])
	_banner_reason = YandexUtils.get_property(result.value[0], ["reason"])
	get_banner_status_succeeded.emit(sticky_adv_is_showing, _banner_reason)
	return sticky_adv_is_showing


## [b]@async[/b][br]
## Displays the sticky banner ad.[br]
## [br]
## [color=deep_sky_blue][b]@note:[/b][/color] If the method returned [code]null[/code], you can retrieve the possible reason code using the [method get_banner_reason] method.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal show_banner_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal show_banner_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexGamesSDK] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if sticky banner is shown; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var is_banner_showing = await YandexSDK.adv.show_banner()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-adv#sticky-banner[/url]
func show_banner() -> Variant:
	_banner_reason = null
	
	if !_check_availability(["adv", "showBannerAdv"]):
		return null
	
	var result := await Promise.new(_yandex_sdk._ysdk.adv.showBannerAdv()).wait()
	if !result.status:
		show_banner_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	var sticky_adv_is_showing = YandexUtils.get_property(result.value[0], ["stickyAdvIsShowing"])
	_banner_reason = YandexUtils.get_property(result.value[0], ["reason"])
	show_banner_succeeded.emit(sticky_adv_is_showing, _banner_reason)
	return sticky_adv_is_showing


## [b]@async[/b][br]
## Displays the sticky banner ad.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal hide_banner_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal hide_banner_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexGamesSDK] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if sticky banner is hidden; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var is_banner_showing = await YandexSDK.adv.hide_banner()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-adv#sticky-banner[/url]
func hide_banner() -> Variant:
	if !_check_availability(["adv", "hideBannerAdv"]):
		return null
	
	var result := await Promise.new(_yandex_sdk._ysdk.adv.hideBannerAdv()).wait()
	if !result.status:
		hide_banner_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	var sticky_adv_is_showing = YandexUtils.get_property(result.value[0], ["stickyAdvIsShowing"])
	hide_banner_succeeded.emit(sticky_adv_is_showing)
	return sticky_adv_is_showing


## Retrieve the possible reason after calling the [method get_banner_status] or [method show_banner] methods.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — No error code is available.[br]
## [b]@returns[/b] [constant REASON_ADV_IS_NOT_CONNECTED] — Banners are not enabled.[br]
## [b]@returns[/b] [constant REASON_UNKNOWN] — Error displaying ads on the Yandex side.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var is_banner_showing = await YandexSDK.adv.show_banner()
## var reason = YandexSDK.adv.get_banner_reason()
## [/codeblock]
func get_banner_reason() -> Variant:
	return _banner_reason
