## A Module for Managing In-Game Purchases.
## 
## [b]@version[/b] 1.0.1[br]
## [b]@author[/b] Mist1351[br]
## [br]
## Provides tools for integrating and managing in-game purchases within your game. With this module, you can offer users additional content or features for purchase, such as extra gameplay time, character accessories, or other enhancements.[br]
## [br]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases[/url]
class_name YandexPayments extends YandexModule


## Emitted when the initialization of the [YandexPayments] module is successfully completed, and the module is ready for use.
signal init_succeeded()
## Emitted when the initialization of the [YandexPayments] module fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal init_failed(error_:String)
## Emitted when an in-game purchase is successfully completed.[br]
## [b]@param[/b] {[Dictionary]} [param purchase_] — Purchase details.
signal purchase_succeeded(purchase_:Dictionary)
## Emitted when an in-game purchase fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal purchase_failed(error_:String)
## Emitted when the list of completed and pending purchases is successfully retrieved.[br]
## [b]@param[/b] {[Array][lb][Dictionary][rb]} [param purchases_] — The list of purchases made by the player.
signal get_purchases_succeeded(purchases_:Array[Dictionary])
## Emitted when retrieving the list of purchases fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal get_purchases_failed(error_:String)
## Emitted when the catalog of available products for purchase is successfully retrieved.[br]
## [b]@param[/b] {[Array][lb][Dictionary][rb]} [param products_] — The list of products available to the user.
signal get_catalog_succeeded(products_:Array[Dictionary])
## Emitted when retrieving the product catalog fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal get_catalog_failed(error_:String)
## Emitted when a purchase is successfully consumed, making it available for repurchase.
signal consume_purchase_succeeded()
## Emitted when consuming a purchase fails.[br]
## [b]@param[/b] {[String]} [param error_] — A message describing the reason for the error.
signal consume_purchase_failed(error_:String)


var _payments:JavaScriptObject = null


func _init(yandex_sdk_:YandexSDK) -> void:
	super(yandex_sdk_)


## [b]@async[/b][br]
## Initialize the [YandexPayments].[br]
## [br]
## [color=gold][b]@warning:[/b][/color] This method must be called once before using other methods of [YandexPayments].[br]
## [br]
## [b]@param[/b] {[bool]} [lb][param signed_][kbd] = false[/kbd][rb] — Adds the [b]signature[/b] parameter to the return values of the [method get_purchases] and [method purchase] methods when set to [code]true[/code].[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal init_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal init_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexGamesSDK] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if [YandexPayments] is initialized; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var result = await YandexSDK.payments.init()
## if result:
##     prints("YandexPayments is initialized!")
## else:
##     prints("YandexPayments is not initialized!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases#install[/url]
func init(signed_:bool = false) -> Variant:
	_payments = null
	if !_check_availability(["getPayments"]):
		return null
	
	var params = JavaScriptBridge.create_object("Object")
	params["signed"] = signed_
	
	var result := await Promise.new(_yandex_sdk._ysdk.getPayments(params)).wait()
	if result.status:
		_payments = result.value[0]
		init_succeeded.emit()
	else:
		init_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
	
	return result.status


## Returns the initialization state of [YandexPayments].[br]
## [br]
## [b]@returns[/b] [bool] — [code]true[/code] if [YandexPayments] is initialized; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## ...
## var result = YandexSDK.payments.is_inited()
## if result:
##     prints("YandexPayments is initialized!")
## else:
##     prints("YandexPayments is not initialized!")
## [/codeblock]
func is_inited() -> bool:
	return _is_inited() && null != _payments


## [b]@async[/b][br]
## Activates an in-game purchase, allowing the user to buy a product or service within the game.[br]
## [br]
## [b]@param[/b] {[String]} [lb][param id_][kbd] = false[/kbd][rb] — Product ID.[br]
## [b]@param[/b] {[String]} [lb][param developer_payload_][kbd] = ""[/kbd][rb] — Additional purchase data that you want to send to your server (transferred in the [b]signature[/b] parameter).[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal purchase_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal purchase_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexPayments] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [Dictionary] — Purchase details:
## [codeblock lang=gdscript]
## {
##     # Product ID.
##     "product_id":String,
##     # A token for consuming the purchase.
##     "purchase_token":String,
##     # Additional purchase data.
##     "developer_payload":String,
##     # Purchase data and the signature for player authentication.
##     "signature":String,
## }
## [/codeblock]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.payments.init()
## ...
## var purchase = await YandexSDK.payments.purchase("gold500")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases#payments-purchase[/url]
func purchase(id_:String, developer_payload_:String = "") -> Variant:
	if !_check_availability(["purchase"], "payments", _payments):
		return null
	
	var params := JavaScriptBridge.create_object("Object")
	params["id"] = id_
	developer_payload_ = developer_payload_.strip_edges()
	if !developer_payload_.is_empty():
		params["developerPayload"] = developer_payload_
	
	var result := await Promise.new(_payments.purchase(params)).wait()
	if !result.status:
		purchase_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	var purchase := {
		"product_id": YandexUtils.get_property(result.value[0], ["productID"]),
		"purchase_token": YandexUtils.get_property(result.value[0], ["purchaseToken"]),
		"developer_payload": YandexUtils.get_property(result.value[0], ["developerPayload"]),
		"signature": YandexUtils.get_property(result.value[0], ["signature"]),
	}
	
	purchase_succeeded.emit(purchase)
	return purchase


## [b]@async[/b][br]
## Retrieves a list of purchases the player has already made.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal get_purchases_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal get_purchases_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexPayments] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [Array][lb][Dictionary][rb] — The list of purchases made by the player:
## [codeblock lang=gdscript]
## [
##     {
##         # Product ID.
##         "product_id":String,
##         # A token for consuming the purchase.
##         "purchase_token":String,
##         # Additional purchase data.
##         "developer_payload":String,
##         # Purchase data and the signature for player authentication.
##         "signature":String,
##     },
## ...
## ]
## [/codeblock]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.payments.init()
## ...
## var purchases = await YandexSDK.payments.get_purchases()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases#getpurchases[/url]
func get_purchases() -> Variant:
	if !_check_availability(["getPurchases"], "payments", _payments):
		return null
	
	var result := await Promise.new(_payments.getPurchases()).wait()
	if !result.status:
		get_purchases_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	var signature = YandexUtils.get_property(result.value[0], ["signature"])
	var purchases:Array[Dictionary] = []
	for i in result.value[0].length:
		var item = result.value[0][i]
		purchases.push_back({
			"product_id": YandexUtils.get_property(item, ["productID"]),
			"purchase_token": YandexUtils.get_property(item, ["purchaseToken"]),
			"developer_payload": YandexUtils.get_property(item, ["developerPayload"]),
			"signature": signature,
		})
	
	get_purchases_succeeded.emit(purchases)
	return purchases


## [b]@async[/b][br]
## Retrieves a list of available in-game products.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal get_catalog_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal get_catalog_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code]:[br]
## [b]    •[/b] [YandexPayments] is not initialized;[br]
## [b]    •[/b] The request returned an error.[br]
## [b]@returns[/b] [Array][lb][Dictionary][rb] — The list of products available to the user:
## [codeblock lang=gdscript]
## [
##     {
##         # Product ID.
##         "id":String,
##         # Product name.
##         "title":String,
##         # Product description.
##         "description":String,
##         # Image URL.
##         "image_uri":String,
##         # Product price in <price> <currency code> format.
##         "price":String,
##         # Product price in <price> format.
##         "price_value":String,
##         # Currency code.
##         "price_currency_code":String,
##        # The currency icon address.
##         "price_currency_image":{
##             # A small size icon.
##             "small":String,
##             # A medium size icon.
##             "medium":String,
##             # A vector format icon.
##             "svg":String,
##         },
##     }
## ...
## ]
## [/codeblock]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.payments.init()
## ...
## var products = await YandexSDK.payments.get_catalog()
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases#getcatalog[/url]
func get_catalog() -> Variant:
	if !_check_availability(["getCatalog"], "payments", _payments):
		return null
	
	var result := await Promise.new(_payments.getCatalog()).wait()
	if !result.status:
		get_catalog_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
		return null
	
	var products:Array[Dictionary] = []
	for i in result.value[0].length:
		var item = result.value[0][i]
		var price_currency_image = {}
		if YandexUtils.has_property(item, ["getPriceCurrencyImage"]):
			price_currency_image["small"] = item.getPriceCurrencyImage("small")
			price_currency_image["medium"] = item.getPriceCurrencyImage("medium")
			price_currency_image["svg"] = item.getPriceCurrencyImage("svg")
		
		products.push_back({
			"id": YandexUtils.get_property(item, ["id"]),
			"title": YandexUtils.get_property(item, ["title"]),
			"description": YandexUtils.get_property(item, ["description"]),
			"image_uri": YandexUtils.get_property(item, ["imageURI"]),
			"price": YandexUtils.get_property(item, ["price"]),
			"price_value": YandexUtils.get_property(item, ["priceValue"]),
			"price_currency_code": YandexUtils.get_property(item, ["priceCurrencyCode"]),
			"price_currency_image": price_currency_image,
		})
	
	get_catalog_succeeded.emit(products)
	return products


## [b]@async[/b][br]
## Marks a consumable purchase (e.g., in-game currency) as used.[br]
## [br]
## [color=gold][b]@warning:[/b][/color] This method is not required for non-consumable purchases (e.g., disabling ads), as they are meant to be purchased only once.[br]
## [br]
## [b]@param[/b] {[String]} [param purchase_token_] — A token returned by the [method purchase] and [method get_purchases] methods.[br]
## [br]
## [b]@emits[/b] [signal YandexGamesSDK.sdk_error] — Internal SDK error.[br]
## [b]@emits[/b] [signal consume_purchase_succeeded] — The request was completed successfully.[br]
## [b]@emits[/b] [signal consume_purchase_failed] — The request failed with an error.[br]
## [br]
## [b]@returns[/b] [code]null[/code] — [YandexPayments] is not initialized.[br]
## [b]@returns[/b] [bool] — [code]true[/code] if the purchase is successfully consumed; otherwise, [code]false[/code].[br]
## [br]
## [b]@example[/b]
## [codeblock lang=gdscript]
## await YandexSDK.init()
## await YandexSDK.payments.init()
## ...
## var result = await YandexSDK.payments.consume_purchase()
## if result:
##     prints("Обработка покупки прошла успешно!")
## else:
##     prints("Ошибка при обработке покупки!")
## [/codeblock]
## [b]@see[/b] [url]https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases#consumepurchase[/url]
func consume_purchase(purchase_token_:String) -> Variant:
	if !_check_availability(["consumePurchase"], "payments", _payments):
		return null
	
	var result := await Promise.new(_payments.consumePurchase(purchase_token_)).wait()
	if result.status:
		consume_purchase_succeeded.emit()
	else:
		consume_purchase_failed.emit(YandexUtils.js_utils.stringify(result.value[0]))
	return result.status
