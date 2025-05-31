## A Module for Managing Links to Other Games.
## 
## [b]@version[/b] 1.0.3[br]
## [b]@author[/b] Mist1351[br]
## [br]
## Provides functionality to retrieve accurate and platform-compatible links to other games hosted on Yandex Games.[br]
## [br]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-other-games[/url]
class_name YandexGames extends YandexModule


## Emitted when the list of all games is successfully retrieved.[br]
## [b]@param[/b] {[Array][lb][Dictionary][rb]} [param games_] — Array of objects with game information.[br]
## [b]@param[/b] {[String]} [param developer_url_] — Link to the developer's page.
signal get_all_succeeded(games_:Array[Dictionary], developer_url_:String)
## Emitted when retrieving the list of all games fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the failure.
signal get_all_failed(error_:String)
## Emitted when information about a specific game is successfully retrieved.[br]
## [b]@param[/b] {[bool]} [param is_available_] — Indicates if the game is available.[br]
## [b]@param[/b] {[Dictionary]} [param game_] — An object containing information about the game.
signal get_by_id_succeeded(is_available_:bool, game_:Dictionary)
## Emitted when retrieving information about a specific game fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the failure.
signal get_by_id_failed(error_:String)


var _developer_url = null
var _is_available_game = null


func _init(yandex_sdk_:YandexGamesSDK) -> void:
	super(yandex_sdk_)


func _parse_game_js_object(game_:JavaScriptObject) -> Dictionary:
	return {
		"app_id": YandexUtils.get_property(game_, ["appID"]),
		"title": YandexUtils.get_property(game_, ["title"]),
		"url": YandexUtils.get_property(game_, ["url"]),
		"cover_url": YandexUtils.get_property(game_, ["coverURL"]),
		"icon_url": YandexUtils.get_property(game_, ["iconURL"]),
	}


## [b]@async[/b][br]
## Retrieves information about all games available on the current platform and domain. Use this method to obtain a list of your games, along with their details, ensuring compatibility with the user's environment.[br]
## [br]
## [color=deep_sky_blue][b]@note:[/b][/color] To retrieve the value of [b]developer_url[/b] after calling this method, you can use the [method get_developer_url] method.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal get_all_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal get_all_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexGamesSDK] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [Array][[Dictionary]] — Array of objects with game information:
## [codeblock lang=gdscript]
## [
##     {
##         # The game's identifier, as set in the developer console.
##         app_id:String,
##         # The name of the game.
##         title:String,
##         # The link to the game.
##         url:String,
##         # The link to the game's cover image.
##         cover_url:String,
##         # The link to the game's icon.
##         icon_url:String,
##     },
##     ...
## ]
## [/codeblock]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var games = await YandexSDK.games.get_all()
## var developer_url = YandexSDK.games.get_developer_url()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-other-games#get-all-games[/url]
func get_all() -> Variant:
	if !_check_availability(["features", "GamesAPI", "getAllGames"]):
		return null
	
	var result := await Promise.new(_yandex_sdk._ysdk.features.GamesAPI.getAllGames()).wait()
	if !result.status:
		get_all_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	var games:Array[Dictionary] = []
	var js_games = YandexUtils.get_property(result.value[0], ["games"])
	for i in js_games.length:
		var js_game = js_games[i]
		games.push_back(_parse_game_js_object(js_game))
	_developer_url = YandexUtils.get_property(result.value[0], ["developerURL"])
	get_all_succeeded.emit(games, _developer_url)
	return games


## [b]@async[/b][br]
## Retrieves data about a specific game by its appID and checks its availability on the current platform and domain. Use this method to obtain detailed information about the game and ensure it is accessible to the user.[br]
## [br]
## [color=deep_sky_blue][b]@note:[/b][/color] To retrieve the value of [b]is_available[/b] after calling this method, you can use the [method is_available_game] method.[br]
## [br]
## [b]@param[/b] {[String]} [param app_id_] — Game ID from the developer console.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal get_by_id_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal get_by_id_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexGamesSDK] is not initialized;[br]
## [b]    •[/b] The request returned an error;[br]
## [b]    •[/b] The game is unavailable.[br]
## [b]@returns[/b] [Dictionary] — An object containing information about the game:
## [codeblock lang=gdscript]
## {
##     # The game's identifier, as set in the developer console.
##     app_id:String,
##     # The name of the game.
##     title:String,
##     # The link to the game.
##     url:String,
##     # The link to the game's cover image.
##     cover_url:String,
##     # The link to the game's icon.
##     icon_url:String,
## },
## [/codeblock]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var game = await YandexSDK.games.get_by_id(1000)
## var is_available = YandexSDK.games.is_available_game()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-other-games#get-game-by-id[/url]
func get_by_id(app_id_:int) -> Variant:
	if !_check_availability(["features", "GamesAPI", "getGameByID"]):
		return null
	
	var result := await Promise.new(_yandex_sdk._ysdk.features.GamesAPI.getGameByID(app_id_)).wait()
	if !result.status:
		get_by_id_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	_is_available_game = YandexUtils.get_property(result.value[0], ["isAvailable"])
	var js_game = YandexUtils.get_property(result.value[0], ["game"])
	var game = null
	if _is_available_game:
		game = _parse_game_js_object(js_game)
	get_by_id_succeeded.emit(_is_available_game, game)
	return game


## Retrieve the developer url value after calling the [method get_all] method.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — No developer url is available.[br]
## [b]@returns[/b] [String] — Link to the developer's page.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var games = await YandexSDK.games.get_all()
## var developer_url = YandexSDK.games.get_developer_url()
## [/codeblock]
func get_developer_url() -> Variant:
	return _developer_url


## Retrieve the is_available value after calling the [method get_by_id] method.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — No error code is available.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if game is available; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var game = await YandexSDK.games.get_by_id(1000)
## var is_available = YandexSDK.games.is_available_game()
func is_available_game() -> Variant:
	return _is_available_game
