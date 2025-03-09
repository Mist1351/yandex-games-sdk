## A utility class providing helper functions for working with the Yandex SDK.
##
## [b]@version[/b] 1.0[br]
## [b]@author[/b] Mist1351[br]
## [b]@inner[/b][br]
## This includes checking features, interacting with JavaScript objects, and retrieving properties dynamically.[br]
class_name YandexUtils extends Object


## [b]@inner[/b][br]
## The feature flag for enabling Yandex SDK support.
const FEATURE = "yandex_sdk"
## [b]@inner[/b][br]
## The feature flag for automatic initialization of Yandex SDK.
const FEATURE_AUTO_INIT = "yandex_sdk_auto_init"


## [b]@inner[/b][br]
## JavaScript utility object for interacting with the browser environment.
static var js_utils:JavaScriptObject = null
## [b]@inner[/b][br]
## JavaScript JSON object for parsing and stringifying data.
static var js_json:JavaScriptObject = null


## [b]@inner[/b][br]
## Initializes the utility class by injecting JavaScript functions into the browser environment.[br]
## This method sets up a helper function for safely converting objects to strings.
static func init() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("""
		window.utils = {
			stringify: function(x) {
				try {
					if ((x instanceof Error) && x.message)
						return `${x.message}`
				} catch {}
				return `${x}`
			}
		}
		""")
		js_utils = JavaScriptBridge.get_interface("window").utils
		js_json = JavaScriptBridge.get_interface("JSON")


## [b]@inner[/b][br]
## Checks if automatic initialization of Yandex SDK is enabled.[br]
## [br]
## [b]@returns[/b] [bool] — [code]true[/code] if automatic initialization is enabled; otherwise, [code]false[/code].
static func has_auto_init() -> bool:
	return OS.has_feature(FEATURE_AUTO_INIT)


## [b]@inner[/b][br]
## Checks if the Yandex SDK feature is enabled and running in a web environment.[br]
## [br]
## [b]@returns[/b] [bool] — [code]true[/code] if Yandex SDK is enabled and running in a browser; otherwise, [code]false[/code].
static func is_enabled() -> bool:
	return OS.has_feature(FEATURE) && OS.has_feature("web")


## [b]@inner[/b][br]
## Checks if a given JavaScript object contains a specified property.[br]
## [br]
## [b]@param[/b] {[JavaScriptObject]} [param obj_] — The JavaScript object to check.[br]
## [b]@param[/b] {[Array[String]]} [param property_chain_] — The chain of properties to check in the object.[br]
## [br]
## [b]@returns[/b] [bool] — [code]true[/code] if the property exists; otherwise, [code]false[/code].
static func has_property(obj_:JavaScriptObject, property_chain_:Array[String]) -> bool:
	if null == obj_:
		return false
	
	var obj = obj_
	for property in property_chain_:
		if null == obj || property not in obj:
			return false
		obj = obj[property]
	return true


## [b]@inner[/b][br]
## Retrieves a property from a JavaScript object using a property chain.[br]
## [br]
## [b]@param[/b] {[JavaScriptObject]} [param obj_] — The JavaScript object to retrieve from.[br]
## [b]@param[/b] {[Array[String]]} [param property_chain_] — The chain of properties leading to the desired value.[br]
## [br]
## [b]@returns[/b] [Variant] — The value of the property if found; otherwise, [code]null[/code].
static func get_property(obj_:JavaScriptObject, property_chain_:Array[String]) -> Variant:
	if null == obj_:
		return null
	
	var obj = obj_
	for property in property_chain_:
		if null == obj || property not in obj:
			return null
		obj = obj[property]
	return obj


## A helper class for limiting the rate of API calls based on a timeout mechanism.
## 
## [b]@version[/b] 1.0[br]
## [b]@author[/b] Mist1351[br]
## [b]@inner[/b]
class CallRateLimiter:
	var _timestamp:int = 0
	var _requests_count:int = 0
	var _max_requests_count:int = 0
	var _max_timeout:int = 0
	var _prev_timeout_left:int = 0
	var _signal:Signal
	
	## Initializes the rate limiter with a signal, timeout, and optional request limit.[br]
	## [br]
	## [b]@param[/b] {[Signal]} [param signal_] — The signal to emit when the timeout resets.[br]
	## [b]@param[/b] {[int]} [param max_timeout_] — The maximum timeout in milliseconds.[br]
	## [br]
	## [b]@param[/b] {[int]} [lb][param max_requests_count_][kbd] = 0[/kbd][rb] — The maximum number of requests allowed before throttling.
	func _init(signal_:Signal, max_timeout_:int, max_requests_count_:int = 0) -> void:
		_signal = signal_
		_max_timeout = max_timeout_
		_max_requests_count = max_requests_count_
		_reset()
	
	## Decreases the request count by one, ensuring it does not drop below zero.
	func _decrement_requests_count() -> void:
		_requests_count = maxi(0, _requests_count - 1)
	
	## Resets the request count to the maximum allowed value.
	func _reset() -> void:
		_requests_count = _max_requests_count
	
	## Saves the current timestamp from the Yandex SDK server time.
	func _save_timestamp() -> void:
		var timestamp = YandexSDK.get_server_time()
		if null == timestamp:
			timestamp = 0
		_timestamp = timestamp
	
	## Gets the current number of requests remaining.[br]
	## [br]
	## [b]@returns[/b] [int] — The remaining request count.
	func get_requests_count() -> int:
		return _requests_count
	
	## Gets the remaining cooldown time before requests can be made again.[br]
	## [br]
	## [b]@returns[/b] [int] — The time left in milliseconds.
	func get_timeout_left() -> int:
		var timestamp := YandexSDK.get_server_time()
		if null == timestamp:
			return 0
		
		return clampi(_max_timeout - (timestamp - _timestamp), 0, _max_timeout)
	
	## Gets the remaining cooldown time in seconds.[br]
	## [br]
	## [b]@returns[/b] [float] — The time left in seconds.
	func get_timeout_left_in_sec() -> float:
		return get_timeout_left() / 1000.0
	
	## Gets the maximum timeout duration in seconds.[br]
	## [br]
	## [b]@returns[/b] [float] — The maximum timeout duration in seconds.
	func get_max_timeout_in_sec() -> float:
		return _max_timeout / 1000.0
	
	## Processes the cooldown logic and emits a signal when the timeout resets.
	func process() -> void:
		var current_timeout_left := get_timeout_left()
		if 0 < _prev_timeout_left && 0 == current_timeout_left:
			_reset()
			_signal.emit()
		_prev_timeout_left = current_timeout_left
	
	## Applies the rate limiter by reducing the request count and saving the timestamp if needed.
	func apply() -> void:
		_decrement_requests_count()
		if 0 == get_timeout_left():
			_save_timestamp()
