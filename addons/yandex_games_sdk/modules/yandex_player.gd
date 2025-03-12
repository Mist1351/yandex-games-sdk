## A Module for Managing Player Data and Game State.
## 
## [b]@version[/b] 1.0.1[br]
## [b]@author[/b] Mist1351[br]
## [br]
## Provides tools to save and manage the player's game state data, such as completed levels, experience, or in-game purchases, directly on the Yandex server. It also provides access to user profile information, like the player's name, enabling a more personalized gaming experience.[br]
## [br]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases[/url]
class_name YandexPlayer extends YandexModule


## Emitted when the initialization of the [YandexPlayer] module is successfully completed, and the module is ready for use.
signal init_succeeded()
## Emitted when the initialization of the [YandexPlayer] module fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal init_failed(error_:String)
## Emitted when the player's game-specific IDs are successfully retrieved.[br]
## [b]@param[/b] {[Array][lb][Dictionary][rb]} [param ids_per_game_] — A user IDs for all of the developer's games in which they have explicitly granted access to their personal data.
signal get_ids_per_game_succeeded(ids_per_game_:Array[Dictionary])
## Emitted when retrieving the player's game-specific IDs fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal get_ids_per_game_failed(error_:String)
## Emitted when the player's game state data is successfully saved.[br]
## [b]@param[/b] {[bool]} [param was_saved_] — Indicates the data was saved or not.
signal set_data_succeeded(was_saved_:bool)
## Emitted when saving the player's game state data fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal set_data_failed(error_:String)
## Emitted when the cooldown period for calling the [method set_data] method has ended, indicating that the method is ready to be called again.
signal set_data_timeout()
## Emitted when the player's game state data is successfully retrieved.[br]
## [b]@param[/b] {[Dictionary]} [param data_] — In-game user data stored in the Yandex database.
signal get_data_succeeded(data_:Dictionary)
## Emitted when retrieving the player's game state data fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal get_data_failed(error_:String)
## Emitted when the cooldown period for calling the [method get_data] method has ended, indicating that the method is ready to be called again.
signal get_data_timeout()
## Emitted when the player's game statistics are successfully saved.
signal set_stats_succeeded()
## Emitted when saving the player's game statistics fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal set_stats_failed(error_:String)
## Emitted when the cooldown period for calling the [method set_stats] method has ended, indicating that the method is ready to be called again.
signal set_stats_timeout()
## Emitted when the player's game statistics are successfully incremented.[br]
## [b]@param[/b] {[Dictionary]} [param data_] — Dictionary contains modified and added key-value pairs.
signal increment_stats_succeeded(data_:Dictionary)
## Emitted when incrementing the player's game statistics fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal increment_stats_failed(error_:String)
## Emitted when the cooldown period for calling the [method increment_stats] method has ended, indicating that the method is ready to be called again.
signal increment_stats_timeout()
## Emitted when the player's game statistics are successfully retrieved.[br]
## [b]@param[/b] {[Dictionary]} [param data_] — Dictionary contains key-value pairs.
signal get_stats_succeeded(data_:Dictionary)
## Emitted when retrieving the player's game statistics fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal get_stats_failed(error_:String)
## Emitted when the cooldown period for calling the [method get_stats] method has ended, indicating that the method is ready to be called again.
signal get_stats_timeout()
## Emitted when the authorization dialog is successfully handled.[br]
## [b]@param[/b] {[bool]} [param is_authenticated_] — Indicates whether the player successfully authenticated [code]true[/code] or not [code]false[/code].
signal open_auth_dialog_closed(is_authenticated_:bool)

## Small photo size.
const PHOTO_SIZE_SMALL = "small"
## Medium photo size.
const PHOTO_SIZE_MEDIUM = "medium"
## Large photo size.
const PHOTO_SIZE_LARGE = "large"

## The user purchased the portal currency for more than ₽500 in the last month.
const PAYING_STATUS_PAYING = "paying"
## The user purchased the portal currency with real money at least once in the last year.
const PAYING_STATUS_PARTIALLY_PAYING = "partially_paying"
## The user didn't purchase the portal currency with real money in the last year.
const PAYING_STATUS_NOT_PAYING = "not_paying"
## The user is not from the Russian Federation or didn't give their consent to share this information with the developer.
const PAYING_STATUS_UNKNOWN = "unknown"

## A call rate limiter for managing the frequency of [method set_data] calls.
var crl_set_data:YandexUtils.CallRateLimiter = YandexUtils.CallRateLimiter.new(set_data_timeout, 5 * 60 * 1000, 100)
## A call rate limiter for managing the frequency of [method get_data] calls.
var crl_get_data:YandexUtils.CallRateLimiter = YandexUtils.CallRateLimiter.new(get_data_timeout, 5 * 60 * 1000, 100)
## A call rate limiter for managing the frequency of [method set_stats] calls.
var crl_set_stats:YandexUtils.CallRateLimiter = YandexUtils.CallRateLimiter.new(set_stats_timeout, 60 * 1000, 60)
## A call rate limiter for managing the frequency of [method get_stats] calls.
var crl_get_stats:YandexUtils.CallRateLimiter = YandexUtils.CallRateLimiter.new(get_stats_timeout, 60 * 1000, 60)
## A call rate limiter for managing the frequency of [method increment_stats] calls.
var crl_increment_stats:YandexUtils.CallRateLimiter = YandexUtils.CallRateLimiter.new(increment_stats_timeout, 60 * 1000, 60)


var _player:JavaScriptObject = null
var _string_data = null


func _init(yandex_sdk_:YandexSDK) -> void:
	super(yandex_sdk_)
	
	if null != _yandex_sdk:
		_yandex_sdk._crl_list.push_back(crl_set_data)
		_yandex_sdk._crl_list.push_back(crl_get_data)
		_yandex_sdk._crl_list.push_back(crl_set_stats)
		_yandex_sdk._crl_list.push_back(crl_get_stats)
		_yandex_sdk._crl_list.push_back(crl_increment_stats)


func _stringify_data(data_:Variant) -> String:
	return JSON.stringify(data_, "", false, true)


## [b]@async[/b][br]
## Initialize the [YandexPlayer].[br]
## [br]
## [b]@param[/b] {[bool]} [lb][param scopes_][kbd] = true[/kbd][rb] — Defines whether the dialog box requesting access to the user's username and profile picture should be displayed:[br]
## [b]    •[/b] [code]true[/code] — Displays a dialog box to the authorized user requesting access to their username and profile picture. If access is denied, only the user ID is returned;[br]
## [b]    •[/b] [code]false[/code] — The dialog box is not displayed, and only the user ID is returned.[br]
## [b]@param[/b] {[bool]} [lb][param signed_][kbd] = false[/kbd][rb] — Enables/Disables the signature value returned by the [method get_signature] method.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal init_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal init_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if [YandexPlayer] is initialized; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var result = await YandexSDK.player.init()
## if result:
##     prints("YandexPlayer is initialized!")
## else:
##     prints("YandexPlayer is not initialized!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#getplayer[/url]
func init(scopes_:bool = true, signed_:bool = false) -> Variant:
	_player = null
	if !_check_availability(["getPlayer"]):
		return null
	
	var params = JavaScriptBridge.create_object("Object")
	params["scopes"] = scopes_
	params["signed"] = signed_
	
	var result := await Promise.new(_yandex_sdk._ysdk.getPlayer(params)).wait()
	if result.status:
		_player = result.value[0]
		init_succeeded.emit()
	else:
		init_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
	
	return result.status


## Returns the initialization state of [YandexPlayer].[br]
## [br]
## [b]@returns[/b] [bool] — [code]true[/code] if [YandexPlayer] is initialized; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var result = YandexSDK.player.is_inited()
## if result:
##     prints("YandexPlayer is initialized!")
## else:
##     prints("YandexPlayer is not initialized!")
## [/codeblock]
func is_inited() -> bool:
	return _is_inited() && null != _player


## [b]@async[/b][br]
## Opens the authorization dialog for the player. Use this method to prompt the player to log in if they are not already authenticated.[br]
## [br]
## To determine if the user is authorized, use [method is_authorized] or [method get_mode].[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal open_auth_dialog_closed] — The authorization dialog is closed, regardless of whether the player authenticated or not.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexPlayer] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if the user successfully authorized; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var result = await YandexSDK.player.open_auth_dialog()
## if result:
##     prints("User authorization was successful!")
## else:
##     prints("An error occurred during user authorization!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#open-auth-dialog[/url]
func open_auth_dialog() -> Variant:
	if !_check_availability(["auth", "openAuthDialog"]):
		return null
	
	if !is_inited():
		_emit_sdk_error("YandexPlayer is not initialized!")
		return null
	
	if is_authorized():
		open_auth_dialog_closed.emit(true)
		return true
	
	var result := await Promise.new(_yandex_sdk._ysdk.auth.openAuthDialog()).wait()
	open_auth_dialog_closed.emit(result.status)
	return result.status


## Returns the user authorization status.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexPlayer] is not initialized.[br]
## [b]@returns[/b] [code]"lite"[/code] — Indicates that the user is authorized.[br]
## [b]@returns[/b] [code]""[/code] — Indicates that the user is not authorized.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var mode = YandexSDK.player.get_mode()
## if "" == mode:
##     prints("User is authorized!")
## else:
##     prints("User is not authorized!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#verifying-authorization[/url]
func get_mode() -> Variant:
	if !_check_availability(["getMode"], "player", _player):
		return null
	
	return _player.getMode()


## Returns the user authorization status.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexPlayer] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if the user is authorized; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var is_authorized = YandexSDK.player.is_authorized()
## if is_authorized:
##     prints("User is authorized!")
## else:
##     prints("User is not authorized!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#verifying-authorization[/url]
func is_authorized() -> Variant:
	var mode = get_mode()
	if null == mode:
		return null
	
	return "" == mode


## [b]@async[/b][br]
## Return the user IDs for all of the developer's games.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal get_ids_per_game_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal get_ids_per_game_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexPlayer] is not initialized;[br]
## [b]    •[/b] The user is not authorized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [Array][lb][Dictionary][rb] — The user IDs for all of the developer's games:
## [codeblock lang=gdscript]
## {
##     "app_id":String,
##     "user_id":String,
## }
## [/codeblock]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var ids_per_game = await YandexSDK.player.get_ids_per_game()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#profile-data[/url]
func get_ids_per_game() -> Variant:
	if !_check_availability(["getIDsPerGame"], "player", _player):
		return null
	
	if !(await _is_available_method("player.getIDsPerGame")):
		get_ids_per_game_failed.emit("User doesn't have permission to call player.getIDsPerGame()!")
		return null
	
	var result := await Promise.new(_player.getIDsPerGame()).wait()
	if !result.status:
		get_ids_per_game_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	var ids_per_game:Array[Dictionary] = []
	for i in result.value[0].length:
		var item = result.value[0][i]
		ids_per_game.push_back({
			"app_id": YandexUtils.get_property(item, ["appID"]),
			"user_id": YandexUtils.get_property(item, ["userID"]),
		})
	get_ids_per_game_succeeded.emit(ids_per_game)
	return ids_per_game


## Returns the user's name.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexPlayer] is not initialized.[br]
## [b]@returns[/b] [String] — The user's name.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var name = YandexSDK.player.get_name()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#profile-data[/url]
func get_name() -> Variant:
	if !_check_availability(["getName"], "player", _player):
		return null
	
	return _player.getName()


## Returns the URL of the user's profile picture.[br]
## [br]
## [b]@param[/b] {[String]} [param size_] — The size of the user's profile picture. Can be one of the following constants: [constant PHOTO_SIZE_SMALL], [constant PHOTO_SIZE_MEDIUM], or [constant PHOTO_SIZE_LARGE].[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexPlayer] is not initialized;[br]
## [b]    •[/b] The value of [param size_] is not one of the constants [constant PHOTO_SIZE_SMALL], [constant PHOTO_SIZE_MEDIUM], or [constant PHOTO_SIZE_LARGE].[br]
## [b]@returns[/b] [String] — The URL of the user's profile picture.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var photo_small = YandexSDK.player.get_photo()
## var photo_medium = YandexSDK.player.get_photo(YandexPlayer.PHOTO_SIZE_MEDIUM)
## var photo_large = YandexSDK.player.get_photo("large")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#profile-data[/url]
func get_photo(size_:String = PHOTO_SIZE_SMALL) -> Variant:
	if !_check_availability(["getPhoto"], "player", _player):
		return null
	
	if size_ not in [PHOTO_SIZE_SMALL, PHOTO_SIZE_MEDIUM, PHOTO_SIZE_LARGE]:
		return null
	
	return _player.getPhoto(size_)


## Returns the four possible values depending on the user's purchase frequency and amount.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexPlayer] is not initialized.[br]
## [b]@returns[/b] [constant PAYING_STATUS_PAYING] — The user purchased the portal currency for more than ₽500 in the last month.[br]
## [b]@returns[/b] [constant PAYING_STATUS_PARTIALLY_PAYING] — The user purchased the portal currency with real money at least once in the last year.[br]
## [b]@returns[/b] [constant PAYING_STATUS_NOT_PAYING] — The user didn't purchase the portal currency with real money in the last year.[br]
## [b]@returns[/b] [constant PAYING_STATUS_UNKNOWN] — The user is not from the Russian Federation or didn't give their consent to share this information with the developer.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var paying_status = YandexSDK.player.get_paying_status()
## if paying_status == PAYING_STATUS_PAYING || paying_status === PAYING_STATUS_PARTIALLY_PAYING:
##     # Offer in-app goods at startup or instead of ads.
##     pass
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#profile-data[/url]
func get_paying_status() -> Variant:
	if !_check_availability(["getPayingStatus"], "player", _player):
		return null
	
	return _player.getPayingStatus()


## Returns the user's ID.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexPlayer] is not initialized.[br]
## [b]@returns[/b] [String] — The user's ID.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var user_id = YandexSDK.player.get_id()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#profile-data[/url]
## @deprecated: Use the [method get_unique_id] method instead. The value of this method may differ from the [method get_unique_id] method.
func get_id() -> Variant:
	if !_check_availability(["getID"], "player", _player):
		return null
	
	return _player.getID()


## Returns the user's permanent unique ID.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexPlayer] is not initialized.[br]
## [b]@returns[/b] [String] — The user's permanent unique ID.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var user_id = YandexSDK.player.get_unique_id()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#profile-data[/url]
func get_unique_id() -> Variant:
	if !_check_availability(["getUniqueID"], "player", _player):
		return null
	
	return _player.getUniqueID()


## Returns signature.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexPlayer] is not initialized;[br]
## [b]    •[/b] [YandexPlayer] is initialized with the [code]signed_[/code] parameter set to [code]false[/code].[br]
## [b]@returns[/b] [String] — Signature value.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var signature = YandexSDK.player.get_signature()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#profile-data[/url]
func get_signature() -> Variant:
	if !_check_availability(["signature"], "player", _player):
		return null
	
	return YandexUtils.get_property(_player, ["signature"])


## [b]@async[/b][br]
## Saves the user data.[br]
## [br]
## [color=gold][b]@warning:[/b][/color] [b]100[/b] requests in [b]5 minutes[/b].[br]
## [color=gold][b]@warning:[/b][/color] The maximum data size must not exceed [b]200 KB[/b].[br]
## [br]
## [b]@param[/b] {[Dictionary]} [param data_] — An dictionary containing key-value pairs.[br]
## [b]@param[/b] {[bool]} [lb][param flush_][kbd] = false[/kbd][rb] — Determines the order for sending data. If the value is [code]true[/code], the data is immediately sent to the server. If it's [code]false[/code] (default), the request to send data is queued.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal set_data_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal set_data_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexPlayer] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if the user data was saved successfully; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var result = await YandexSDK.player.set_data({"coins": 1000}, true)
## if result:
##     prints("Data saved successfully!")
## else:
##     prints("Error saving data!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#ingame-data[/url]
func set_data(data_:Dictionary, flush_:bool = false) -> Variant:
	if !_check_availability(["setData"], "player", _player):
		return null
	
	var string_data := _stringify_data(data_)
	if _string_data == string_data:
		set_data_succeeded.emit(true)
		return true
	
	_string_data = string_data
	
	var js_data:JavaScriptObject = YandexUtils.js_json.parse(string_data)
	
	var result := await Promise.new(_player.setData(js_data, flush_)).wait()
	if !result.status:
		set_data_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return false
	
	if flush_:
		crl_set_data.apply()
	
	set_data_succeeded.emit(result.value[0])
	return result.value[0]


## [b]@async[/b][br]
## Returns in-game user data stored in the Yandex database.[br]
## [br]
## [color=gold][b]@warning:[/b][/color] [b]100[/b] requests in [b]5 minutes[/b].[br]
## [br]
## [b]@param[/b] {[Array][lb][String][rb]} [param keys_] — The list of keys to return. If the keys parameter is empty array, the method returns all in-game user data.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal get_data_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal get_data_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexPlayer] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [Dictionary] — A dictionary containing key-value pairs.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var data = await YandexSDK.player.get_data(["coins"])
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#ingame-data[/url]
func get_data(keys_:Array[String] = []) -> Variant:
	if !_check_availability(["getData"], "player", _player):
		return null
	
	var params:JavaScriptObject = JavaScriptBridge.create_object("Array")
	if !keys_.is_empty():
		params.push(YandexUtils.js_json.parse(_stringify_data(keys_)))
	
	var result := await Promise.new(_player.getData.apply(_player, params)).wait()
	if !result.status:
		get_data_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	crl_get_data.apply()
	
	var data:Dictionary = JSON.parse_string(YandexUtils.js_json.stringify(result.value[0]))
	get_data_succeeded.emit(data)
	return data


## [b]@async[/b][br]
## Saves the user numeric data.[br]
## [br]
## [color=gold][b]@warning:[/b][/color] [b]60[/b] requests per [b]1 minute[/b].[br]
## [color=gold][b]@warning:[/b][/color] The maximum data size must not exceed [b]10 KB[/b].[br]
## [br]
## [b]@param[/b] {[Dictionary]} [param stats_] — An dictionary containing key-value pairs, where each value must be a number.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal set_stats_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal set_stats_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexPlayer] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if the user's numeric data was saved successfully; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var result = await YandexSDK.player.set_stats({"coins": 10})
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#ingame-data[/url]
func set_stats(stats_:Dictionary) -> Variant:
	if !_check_availability(["setStats"], "player", _player):
		return null
	
	var filtered_stats:Dictionary = {}
	for key in stats_:
		var value = stats_[key]
		if TYPE_INT == typeof(value) || TYPE_FLOAT == typeof(value):
			filtered_stats[key] = value
	
	var js_stats:JavaScriptObject = YandexUtils.js_json.parse(_stringify_data(filtered_stats))
	var result := await Promise.new(_player.setStats(js_stats)).wait()
	if !result.status:
		set_stats_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return false
	
	crl_set_stats.apply()
	
	set_stats_succeeded.emit()
	return true


## [b]@async[/b][br]
## Saves the user's numeric data.[br]
## [br]
## [color=gold][b]@warning:[/b][/color] [b]60[/b] requests per [b]1 minute[/b].[br]
## [color=gold][b]@warning:[/b][/color] The maximum data size must not exceed [b]10 KB[/b].[br]
## [br]
## [b]@param[/b] {[Dictionary]} [param increments_] — An object containing key-value pairs, where each value must be a number.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal increment_stats_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal increment_stats_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexPlayer] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [Dictionary] — A dictionary containing modified and added key-value pairs:
## [codeblock lang=gdscript]
## {
##     # Modified data.
##     stats:Dictionary,
##     # Added keys.
##     new_keys:Array[String],
## }
## [/codeblock]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var data = await YandexSDK.player.increment_stats({"coins": 1})
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#ingame-data[/url]
func increment_stats(increments_:Dictionary) -> Variant:
	if !_check_availability(["incrementStats"], "player", _player):
		return null
	
	var filtered_stats_increments:Dictionary = {}
	for key in increments_:
		var value = increments_[key]
		if TYPE_INT == typeof(value) || TYPE_FLOAT == typeof(value):
			filtered_stats_increments[key] = value
	
	var js_increments:JavaScriptObject = YandexUtils.js_json.parse(_stringify_data(filtered_stats_increments))
	var result := await Promise.new(_player.incrementStats(js_increments)).wait()
	if !result.status:
		increment_stats_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	crl_increment_stats.apply()
	
	var tmp_data:Dictionary = JSON.parse_string(YandexUtils.js_json.stringify(result.value[0]))
	var data:Dictionary = {
		"stats": tmp_data.get("stats"),
		"new_keys": tmp_data.get("newKeys"),
	}
	increment_stats_succeeded.emit(data)
	return data


## [b]@async[/b][br]
## Returns the user's numeric data.[br]
## [br]
## [color=gold][b]@warning:[/b][/color] [b]60[/b] requests per [b]1 minute[/b].[br]
## [br]
## [b]@param[/b] {[Array][lb][String][rb]} [param keys_] — The list of keys to return. If the keys parameter is empty array, the method returns all in-game user data.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal get_stats_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal get_stats_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexPlayer] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [Dictionary] — A dictionary containing key-value pairs.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.player.init()
## ...
## var data = await YandexSDK.player.get_stats(["coins"])
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-player#ingame-data[/url]
func get_stats(keys_:Array[String] = []) -> Variant:
	if !_check_availability(["getStats"], "player", _player):
		return null
	
	var params:JavaScriptObject = JavaScriptBridge.create_object("Array")
	if !keys_.is_empty():
		params.push(YandexUtils.js_json.parse(_stringify_data(keys_)))
	
	var result := await Promise.new(_player.getStats.apply(_player, params)).wait()
	if !result.status:
		get_stats_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	crl_get_stats.apply()
	
	var data:Dictionary = JSON.parse_string(YandexUtils.js_json.stringify(result.value[0]))
	get_stats_succeeded.emit(data)
	return data
