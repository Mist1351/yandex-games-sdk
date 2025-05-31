## A Module for Managing Game Ratings and Reviews.
## 
## [b]@version[/b] 1.0.3[br]
## [b]@author[/b] Mist1351[br]
## [br]
## Allows you to prompt users to rate your game and leave a comment through a pop-up window that overlays the app background.[br]
## [br]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-review[/url]
class_name YandexFeedback extends YandexModule


## Emitted when the check for whether the user can leave a review is successfully completed.[br]
## [b]@param[/b] {[bool]} [param status_] — Indicates if the user can leave a review [code]true[/code] or not [code]false[/code].[br]
## [b]@param[/b] {[code]null[/code]|[String]} [param reason_] — A message describing the reason for the failure.
signal can_review_succeeded(status_:bool, reason_:Variant)
## Emitted when the check for whether the user can leave a review fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the failure.
signal can_review_failed(error_:String)
## Emitted when a review request is successfully handled.[br]
## [b]@param[/b] {[bool]} [param feedback_sent_] — Indicates whether the user has submitted feedback [code]true[/code] or declined the request [code]false[/code].
signal request_review_succeeded(feedback_sent_:bool)
## Emitted when the review request fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the failure.
signal request_review_failed(error_:String)


## The user is logged out.
const REASON_NO_AUTH = "NO_AUTH"
## The user has already rated the game.
const REASON_GAME_RATED = "GAME_RATED"
## The request has already been sent, not awaiting the user's action.
const REASON_REVIEW_ALREADY_REQUESTED = "REVIEW_ALREADY_REQUESTED"
## The request has already been sent, the user has taken action by either rating your game or closing the popup.
const REASON_REVIEW_WAS_REQUESTED = "REVIEW_WAS_REQUESTED"
## The request couldn't be sent, an error occurred on the Yandex side.
const REASON_UNKNOWN = "UNKNOWN"


var _can_review_reason = null


func _init(yandex_sdk_:YandexGamesSDK) -> void:
	super(yandex_sdk_)


## [b]@async[/b][br]
## Checks whether the option to request a game rating is available. Use this method to determine if a rating request can be made for the current user.[br]
## [br]
## [color=deep_sky_blue][b]@note:[/b][/color] To get the reason after calling this method, use the [method get_can_review_reason] method.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal can_review_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal can_review_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if requesting a rating is possible; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## var result = await YandexSDK.leaderboard.init()
## ...
## var result = await YandexSDK.feedback.can_review()
## if result:
##     prints("A rating can be requested!")
## else:
##     prints("A rating cannot be requested! Reason:", YandexSDK.feedback.get_can_review_reason())
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-review#can-review[/url]
func can_review() -> Variant:
	_can_review_reason = null
	if !_check_availability(["feedback", "canReview"]):
		return null
	
	var status := false
	var result := await Promise.new(_yandex_sdk._ysdk.feedback.canReview()).wait()
	if result.status:
		status = result.value[0].value
		_can_review_reason = YandexUtils.get_property(result.value[0], ["reason"])
		can_review_succeeded.emit(status, _can_review_reason)
	else:
		can_review_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
	
	return status


## [b]@async[/b][br]
## Sends a request to the user to rate the game. This method displays a pop-up window where the user can leave a rating or close the prompt. The rating request can only be made once per session. Before calling this method, ensure that a rating can be requested by using the [method can_review] method.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal request_review_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal request_review_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if the user submitted feedback; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## var result = await YandexSDK.leaderboard.init()
## ...
## var result = await YandexSDK.feedback.can_review()
## if result:
##     await YandexSDK.feedback.request_review()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-review#request-review[/url]
func request_review() -> Variant:
	if !_check_availability(["feedback", "requestReview"]):
		return null
	
	var feedback_sent := false
	var result := await Promise.new(_yandex_sdk._ysdk.feedback.requestReview()).wait()
	if result.status:
		feedback_sent = result.value[0].feedbackSent
		request_review_succeeded.emit(feedback_sent)
	else:
		request_review_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
	
	return feedback_sent


## Retrieve the possible reason after calling the [method can_review] method.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — No reason is available.[br]
## [b]@returns[/b] [constant REASON_NO_AUTH] — The user is logged out.[br]
## [b]@returns[/b] [constant REASON_GAME_RATED] — The user has already rated the game.[br]
## [b]@returns[/b] [constant REASON_REVIEW_ALREADY_REQUESTED] — The request has already been sent, not awaiting the user's action.[br]
## [b]@returns[/b] [constant REASON_REVIEW_WAS_REQUESTED] — The request has already been sent, the user has taken action by either rating your game or closing the popup.[br]
## [b]@returns[/b] [constant REASON_UNKNOWN] — The request couldn't be sent, an error occurred on the Yandex side.[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var result = await YandexSDK.feedback.can_review()
## if !result:
##    prints("A rating cannot be requested! Reason:", YandexSDK.feedback.get_can_review_reason())
## [/codeblock]
func get_can_review_reason() -> Variant:
	return _can_review_reason
