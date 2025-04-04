## A class that wraps JavaScript promises in Godot, allowing asynchronous operations to be awaited.
## 
## [b]@version[/b] 1.0.2[br]
## [b]@author[/b] Mist1351[br]
## [b]@inner[/b][br]
## It emits a signal when the operation is settled, either resolved or rejected.[br]
class_name Promise extends RefCounted


## [b]@inner[/b][br]
## Emitted when the promise is either resolved or rejected.[br]
## [b]@param[/b] {[Promise.PromiseResult]} [param result_] — The result of the promise, containing the status ([code]true[/code] for success, [code]false[/code] for failure) and the returned value.
signal settled(result_:PromiseResult)


var _is_settled := false
var _last_result:PromiseResult = null

var _js_on_resolved := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		settled.emit(PromiseResult.new(true, args_)))

var _js_on_rejected := JavaScriptBridge.create_callback(
	func(args_:Array) -> void:
		settled.emit(PromiseResult.new(false, args_)))


## [b]@inner[/b][br]
## Initializes a new Promise wrapper around a JavaScript promise object.[br]
## [br]
## [b]@param[/b] {[JavaScriptObject]} [param object_] — The JavaScript promise object to wrap.
func _init(object_:JavaScriptObject) -> void:
	object_.then(_js_on_resolved).catch(_js_on_rejected)
	settled.connect(
		func(result_:PromiseResult) -> void:
			_js_on_resolved = null
			_js_on_rejected = null
			_is_settled = true
			_last_result = result_,
		CONNECT_ONE_SHOT
	)


## [b]@inner[/b][br]
## Waits for the promise to be settled and returns the result.[br]
## [br]
## [color=deep_sky_blue][b]@note:[/b][/color] If the promise is already settled, it immediately returns the last result.[br]
## [br]
## [b]@returns[/b] [PromiseResult] — The result of the promise.
func wait() -> PromiseResult:
	if _is_settled:
		return _last_result
	return await settled


## A helper class that represents the result of a settled promise.
## 
## [b]@version[/b] 1.0.2[br]
## [b]@author[/b] Mist1351[br]
## [b]@inner[/b]
class PromiseResult:
	## Indicates whether the promise was successfully resolved ([code]true[/code]) or rejected ([code]false[/code]).
	var status:bool
	## The value returned from the resolved or rejected promise.
	var value:Variant
	
	## Initializes a new instance of PromiseResult.[br]
	## [br]
	## [b]@param[/b] {[bool]} [param status_] — Whether the promise was resolved ([code]true[/code]) or rejected ([code]false[/code]).[br]
	## [b]@param[/b] {[Variant]} [param value_] — The result value from the promise.
	func _init(status_:bool, value_:Variant) -> void:
		status = status_
		value = value_
