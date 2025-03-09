class_name TestNode extends Node


signal signal_emitted(what_:Signal, args_:Array)
signal test_done(test_name_:String, is_ok_:bool)
signal all_tests_done()
signal test_error(message_:String)
signal test_print(message_:String)


var test_passed:int = 0
var test_failed:int = 0


func _print_message(message_:String, is_error_:bool = false) -> void:
	if is_error_:
		printerr(message_)
		test_error.emit(message_)
	else:
		print(message_)
		test_print.emit(message_)


func _check_signal_emitting(what_signal_, args_:Array, wait_timeout_:float) -> bool:
	var timer := Timer.new()
	add_child(timer)
	timer.start(wait_timeout_)
	timer.timeout.connect(func():signal_emitted.emit(null, []))
	var result = await signal_emitted
	timer.stop()
	timer.queue_free()
	
	var wait_emmiting = (null != what_signal_)
	
	if wait_emmiting:
		if null == result[0]:
			assert_inline(false, "Expected signal \"%s\" does not emmited." % what_signal_.get_name())
			return false
		if !assert_inline(what_signal_ == result[0], "Expected signal \"%s\" does not match the emitted signal \"%s\"." % [what_signal_.get_name(), result[0].get_name()]): return false
		if !assert_inline(args_.size() == result[1].size(), "Number of arguments does not match."): return false
		for i in result[1].size():
			var expected = args_[i]
			var actual = result[1][i]
			if !assert_inline(expected == actual, "Argument mismatch at index %s: expected %s, got %s" % [i, str(expected), str(actual)]): return false
	else:
		if !assert_inline(what_signal_ == result[0], "No signals were expected, but the signal \"%s\" was emitted." % ["" if null == result[0] else result[0].get_name()]): return false
	
	return true


func run_test(test_:Callable, signals_:Array[Signal] = []) -> void:
	var signals_callable_count:Array[int] = []
	for s in signals_:
		signals_callable_count.push_back(s.get_connections().size())
	
	var is_test_failed:bool = (false == await test_.call())
	if is_test_failed:
		_print_message("[FAILED] %s" % test_.get_method(), true)
		test_failed += 1
	else:
		_print_message("[PASSED] %s" % test_.get_method())
		test_passed += 1
	test_done.emit(test_.get_method(), !is_test_failed)
	
	for i in signals_.size():
		clear_signal_connection(signals_[i], signals_callable_count[i])


func clear_signal_connection(signal_:Signal, skip_count_:int = 0) -> void:
	var connections := signal_.get_connections()
	for i in range(skip_count_, connections.size()):
		signal_.disconnect(connections[i].callable)


func assert_inline(condition_:bool, message_:String = "") -> bool:
	if !condition_:
		push_error(message_)
		test_error.emit(message_)
	return condition_


func check_signal_emitted(what_signal_, args_:Array, wait_timeout_:float = 2.0) -> bool:
	return await _check_signal_emitting(what_signal_, args_, wait_timeout_)


func check_no_signal_emitted(wait_timeout_:float = 1.0) -> bool:
	return await _check_signal_emitting(null, [], wait_timeout_)


func execute_all_tests() -> void:
	await run_test(test_before_init, [YandexSDK.sdk_error])
	await run_test(test_init, [YandexSDK.init_succeeded, YandexSDK.init_failed])
	await run_test(test_game_ready)
	await run_test(test_gameplay)
	await run_test(test_after_init, [YandexSDK.sdk_error])
	_print_message("passed: %d" % test_passed)
	_print_message("failed: %d" % test_failed)
	all_tests_done.emit()


func test_before_init():
	YandexSDK.sdk_error.connect(func(error_:String):signal_emitted.emit.call_deferred(YandexSDK.sdk_error, [error_]))
	# YandexSDK
	YandexSDK.game_ready()
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.features.LoadingAPI.ready is not available!"]): return false
	if !assert_inline(false == YandexSDK.is_game_ready(), "Game ready state should be false before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.features.LoadingAPI.isReady is not available!"]): return false
	YandexSDK.gameplay_start()
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.features.GameplayAPI.start is not available!"]): return false
	YandexSDK.gameplay_stop()
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.features.GameplayAPI.stop is not available!"]): return false
	YandexSDK.send_exit_event()
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.dispatchEvent is not available!"]): return false
	if !assert_inline(null == YandexSDK.get_server_time(), "Server time should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.serverTime is not available!"]): return false
	if !assert_inline(null == await YandexSDK.clipboard_write("text"), "Clipboard write should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.clipboard.writeText is not available!"]): return false
	if !assert_inline(null == YandexSDK.get_environment(), "Environment should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.environment is not available!"]): return false
	if !assert_inline(null == await YandexSDK.get_flags(), "Get flags should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.getFlags is not available!"]): return false
	
	# YandexAdv
	YandexSDK.adv.show_fullscreen()
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.adv.showFullscreenAdv is not available!"]): return false
	YandexSDK.adv.show_rewarded_video()
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.adv.showRewardedVideo is not available!"]): return false
	if !assert_inline(null == await YandexSDK.adv.get_banner_status(), "Banner status should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.adv.getBannerAdvStatus is not available!"]): return false
	if !assert_inline(null == await YandexSDK.adv.show_banner(), "Show banner should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.adv.showBannerAdv is not available!"]): return false
	if !assert_inline(null == await YandexSDK.adv.hide_banner(), "Hide banner should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.adv.hideBannerAdv is not available!"]): return false
	if !assert_inline(null == YandexSDK.adv.get_banner_reason(), "Get banner reason should return null before initialization."): return false
	
	# YandexDeviceInfo
	if !assert_inline(null == YandexSDK.device_info.is_mobile(), "is_mobile should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.deviceInfo.isMobile is not available!"]): return false
	if !assert_inline(null == YandexSDK.device_info.is_desktop(), "is_desktop should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.deviceInfo.isDesktop is not available!"]): return false
	if !assert_inline(null == YandexSDK.device_info.is_tablet(), "is_tablet should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.deviceInfo.isTablet is not available!"]): return false
	if !assert_inline(null == YandexSDK.device_info.is_tv(), "is_tv should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.deviceInfo.isTV is not available!"]): return false
	if !assert_inline(null == YandexSDK.device_info.get_type(), "get_type should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.deviceInfo.type is not available!"]): return false
	
	# YandexFeedback
	if !assert_inline(null == await YandexSDK.feedback.can_review(), "can_review should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.feedback.canReview is not available!"]): return false
	if !assert_inline(null == await YandexSDK.feedback.request_review(), "request_review should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.feedback.requestReview is not available!"]): return false
	if !assert_inline(null == YandexSDK.feedback.get_can_review_reason(), "get_can_review_reason should return null before initialization."): return false
	
	# YandexFullscreen
	if !assert_inline(null == await YandexSDK.fullscreen.enter(), "enter should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.screen.fullscreen.request is not available!"]): return false
	if !assert_inline(null == await YandexSDK.fullscreen.exit(), "exit should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.screen.fullscreen.exit is not available!"]): return false
	if !assert_inline(null == YandexSDK.fullscreen.is_fullscreen(), "is_fullscreen should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.screen.fullscreen.status is not available!"]): return false
	
	# YandexGames
	if !assert_inline(null == await YandexSDK.games.get_all(), "get_all should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.features.GamesAPI.getAllGames is not available!"]): return false
	if !assert_inline(null == await YandexSDK.games.get_by_id(1), "get_by_id should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.features.GamesAPI.getGameByID is not available!"]): return false
	if !assert_inline(null == YandexSDK.games.get_developer_url(), "get_developer_url should return null before initialization."): return false
	if !assert_inline(null == YandexSDK.games.is_available_game(), "is_available_game should return null before initialization."): return false
	
	# YandexLeaderboard
	if !assert_inline(null == await YandexSDK.leaderboard.init(), "init should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.getLeaderboards is not available!"]): return false
	if !assert_inline(false == YandexSDK.leaderboard.is_inited(), "is_inited should return false before initialization."): return false
	if !assert_inline(null == await YandexSDK.leaderboard.get_description("test"), "get_description should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["leaderboard.getLeaderboardDescription is not available!"]): return false
	if !assert_inline(null == await YandexSDK.leaderboard.set_score("test", 1), "set_score should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["leaderboard.setLeaderboardScore is not available!"]): return false
	if !assert_inline(null == await YandexSDK.leaderboard.get_player_entry("test"), "get_player_entry should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["leaderboard.getLeaderboardPlayerEntry is not available!"]): return false
	if !assert_inline(null == await YandexSDK.leaderboard.get_entries("test"), "get_entries should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["leaderboard.getLeaderboardEntries is not available!"]): return false
	if !assert_inline(null == YandexSDK.leaderboard.get_player_entry_code(), "get_player_entry_code should return null before initialization."): return false
	
	# YandexPayments
	if !assert_inline(null == await YandexSDK.payments.init(), "init should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.getPayments is not available!"]): return false
	if !assert_inline(false == YandexSDK.payments.is_inited(), "is_inited should return false before initialization."): return false
	if !assert_inline(null == await YandexSDK.payments.purchase("1"), "purchase should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["payments.purchase is not available!"]): return false
	if !assert_inline(null == await YandexSDK.payments.get_purchases(), "get_purchases should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["payments.getPurchases is not available!"]): return false
	if !assert_inline(null == await YandexSDK.payments.get_catalog(), "get_catalog should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["payments.getCatalog is not available!"]): return false
	if !assert_inline(null == await YandexSDK.payments.consume_purchase("1"), "consume_purchase should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["payments.consumePurchase is not available!"]): return false
	
	# YandexPlayer
	if !assert_inline(null == await YandexSDK.player.init(), "init should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.getPlayer is not available!"]): return false
	if !assert_inline(false == YandexSDK.player.is_inited(), "is_inited should return false before initialization."): return false
	if !assert_inline(null == await YandexSDK.player.open_auth_dialog(), "open_auth_dialog should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.auth.openAuthDialog is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_mode(), "get_mode should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getMode is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.is_authorized(), "is_authorized should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getMode is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.get_ids_per_game(), "get_ids_per_game should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getIDsPerGame is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_name(), "get_name should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getName is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_photo(), "get_photo should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getPhoto is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_paying_status(), "get_paying_status should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getPayingStatus is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_id(), "get_id should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getID is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_unique_id(), "get_unique_id should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getUniqueID is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_signature(), "get_signature should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.signature is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.set_data({}), "set_data should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.setData is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.get_data([]), "get_data should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getData is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.set_stats({}), "set_stats should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.setStats is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.increment_stats({}), "increment_stats should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.incrementStats is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.get_stats(), "get_stats should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getStats is not available!"]): return false
	
	# YandexShortcut
	if !assert_inline(null == await YandexSDK.shortcut.can_show_prompt(), "can_show_prompt should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.shortcut.canShowPrompt is not available!"]): return false
	if !assert_inline(null == await YandexSDK.shortcut.show_prompt(), "show_prompt should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["ysdk.shortcut.showPrompt is not available!"]): return false
	if !assert_inline(null == YandexSDK.shortcut.get_show_prompt_reason(), "get_show_prompt_reason should return null before initialization."): return false


func test_after_init():
	YandexSDK.sdk_error.connect(func(error_:String):signal_emitted.emit.call_deferred(YandexSDK.sdk_error, [error_]))
	# YandexSDK
	YandexSDK.game_ready()
	if !await check_no_signal_emitted(): return false
	if !assert_inline(true == YandexSDK.is_game_ready(), "is_game_ready should return true after calling game_ready."): return false
	if !await check_no_signal_emitted(): return false
	YandexSDK.gameplay_start()
	if !await check_no_signal_emitted(): return false
	YandexSDK.gameplay_stop()
	if !await check_no_signal_emitted(): return false
	YandexSDK.send_exit_event()
	if !await check_no_signal_emitted(): return false
	if !assert_inline(null != YandexSDK.get_server_time(), "get_server_time should return a valid timestamp."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([true, false].has(await YandexSDK.clipboard_write("text")), "clipboard_write should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline(null != YandexSDK.get_environment(), "get_environment should return a valid environment object."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline(null != await YandexSDK.get_flags(), "get_flags should return a valid dictionary of flags."): return false
	if !await check_no_signal_emitted(): return false
	
	# YandexAdv
	if !assert_inline([true, false].has(await YandexSDK.adv.get_banner_status()), "get_banner_status should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([true, false].has(await YandexSDK.adv.show_banner()), "show_banner should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([true, false].has(await YandexSDK.adv.hide_banner()), "hide_banner should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([null,
						YandexAdv.REASON_ADV_IS_NOT_CONNECTED,
						YandexAdv.REASON_UNKNOWN].has(YandexSDK.adv.get_banner_reason()), "get_banner_reason should return null, REASON_ADV_IS_NOT_CONNECTED, or REASON_UNKNOWN."): return false
	
	# YandexDeviceInfo
	if !assert_inline([true, false].has(YandexSDK.device_info.is_mobile()), "is_mobile should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([true, false].has(YandexSDK.device_info.is_desktop()), "is_desktop should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([true, false].has(YandexSDK.device_info.is_tablet()), "is_tablet should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([true, false].has(YandexSDK.device_info.is_tv()), "is_tv should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([YandexDeviceInfo.TYPE_MOBILE,
						YandexDeviceInfo.TYPE_DESKTOP,
						YandexDeviceInfo.TYPE_TABLET,
						YandexDeviceInfo.TYPE_TV].has(YandexSDK.device_info.get_type()), "get_type should return TYPE_MOBILE, TYPE_DESKTOP, TYPE_TABLET, or TYPE_TV."): return false
	if !await check_no_signal_emitted(): return false
	
	# YandexFeedback
	if !assert_inline([true, false].has(await YandexSDK.feedback.can_review()), "can_review should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([true, false].has(await YandexSDK.feedback.request_review()), "request_review should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([null,
						YandexFeedback.REASON_NO_AUTH,
						YandexFeedback.REASON_GAME_RATED,
						YandexFeedback.REASON_REVIEW_ALREADY_REQUESTED,
						YandexFeedback.REASON_REVIEW_WAS_REQUESTED,
						YandexFeedback.REASON_UNKNOWN].has(YandexSDK.feedback.get_can_review_reason()), "get_can_review_reason should return null or a valid reason constant."): return false
	
	# YandexFullscreen
	if !assert_inline([true, false].has(await YandexSDK.fullscreen.enter()), "enter should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([true, false].has(await YandexSDK.fullscreen.exit()), "exit should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([true, false].has(YandexSDK.fullscreen.is_fullscreen()), "is_fullscreen should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	
	# YandexGames
	if !assert_inline(TYPE_DICTIONARY != typeof(await YandexSDK.games.get_all()), "get_all should return a dictionary."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([TYPE_NIL, TYPE_DICTIONARY].has(typeof(await YandexSDK.games.get_by_id(1))), "get_by_id should return nil or a dictionary."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([TYPE_NIL, TYPE_STRING].has(typeof(YandexSDK.games.get_developer_url())), "get_developer_url should return nil or a string."): return false
	if !assert_inline([null, true, false].has(YandexSDK.games.is_available_game()), "is_available_game should return nil, true or false."): return false
	
	# YandexLeaderboard
	if !assert_inline(false == YandexSDK.leaderboard.is_inited(), "is_inited should return false before initialization."): return false
	if !assert_inline(null == await YandexSDK.leaderboard.get_description("test"), "get_description should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["leaderboard.getLeaderboardDescription is not available!"]): return false
	if !assert_inline(null == await YandexSDK.leaderboard.set_score("test", 1), "set_score should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["leaderboard.setLeaderboardScore is not available!"]): return false
	if !assert_inline(null == await YandexSDK.leaderboard.get_player_entry("test"), "get_player_entry should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["leaderboard.getLeaderboardPlayerEntry is not available!"]): return false
	if !assert_inline(null == await YandexSDK.leaderboard.get_entries("test"), "get_entries should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["leaderboard.getLeaderboardEntries is not available!"]): return false
	if !assert_inline(null == YandexSDK.leaderboard.get_player_entry_code(), "get_player_entry_code should return null before initialization."): return false
	
	# YandexPayments
	if !assert_inline(false == YandexSDK.payments.is_inited(), "is_inited should return false before initialization."): return false
	if !assert_inline(null == await YandexSDK.payments.purchase("1"), "purchase should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["payments.purchase is not available!"]): return false
	if !assert_inline(null == await YandexSDK.payments.get_purchases(), "get_purchases should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["payments.getPurchases is not available!"]): return false
	if !assert_inline(null == await YandexSDK.payments.get_catalog(), "get_catalog should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["payments.getCatalog is not available!"]): return false
	if !assert_inline(null == await YandexSDK.payments.consume_purchase("1"), "consume_purchase should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["payments.consumePurchase is not available!"]): return false
	
	# YandexPlayer
	if !assert_inline(false == YandexSDK.player.is_inited(), "is_inited should return false before initialization."): return false
	if !assert_inline(null == await YandexSDK.player.open_auth_dialog(), "open_auth_dialog should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["YandexPlayer is not initialized!"]): return false
	if !assert_inline(null == YandexSDK.player.get_mode(), "get_mode should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getMode is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.is_authorized(), "is_authorized should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getMode is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.get_ids_per_game(), "get_ids_per_game should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getIDsPerGame is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_name(), "get_name should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getName is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_photo(), "get_photo should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getPhoto is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_paying_status(), "get_paying_status should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getPayingStatus is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_id(), "get_id should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getID is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_unique_id(), "get_unique_id should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getUniqueID is not available!"]): return false
	if !assert_inline(null == YandexSDK.player.get_signature(), "get_signature should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.signature is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.set_data({}), "set_data should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.setData is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.get_data([]), "get_data should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getData is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.set_stats({}), "set_stats should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.setStats is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.increment_stats({}), "increment_stats should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.incrementStats is not available!"]): return false
	if !assert_inline(null == await YandexSDK.player.get_stats(), "get_stats should return null before initialization."): return false
	if !await check_signal_emitted(YandexSDK.sdk_error, ["player.getStats is not available!"]): return false
	
	# YandexShortcut
	if !assert_inline([true, false].has(await YandexSDK.shortcut.can_show_prompt()), "can_show_prompt should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([true, false].has(await YandexSDK.shortcut.show_prompt()), "show_prompt should return true or false."): return false
	if !await check_no_signal_emitted(): return false
	if !assert_inline([TYPE_NIL, TYPE_STRING].has(typeof(YandexSDK.shortcut.get_show_prompt_reason())), "get_show_prompt_reason should return nil or a string."): return false


func test_init():
	YandexSDK.init_succeeded.connect(func():signal_emitted.emit.call_deferred(YandexSDK.init_succeeded, []))
	YandexSDK.init_failed.connect(func():signal_emitted.emit.call_deferred(YandexSDK.init_failed, []))
	if !assert_inline(false == YandexSDK.is_inited(), "YandexSDK is already initialized before calling init."): return false
	if !assert_inline(true == await YandexSDK.init(), "YandexSDK initialization failed. Ensure all required settings are properly configured."): return false
	if !await check_signal_emitted(YandexSDK.init_succeeded, []): return false
	if !assert_inline(true == YandexSDK.is_inited(), "YandexSDK initialization state is invalid after calling init."): return false


func test_game_ready():
	if !assert_inline(false == YandexSDK.is_game_ready(), "Game is incorrectly marked as ready before calling game_ready()."): return false
	YandexSDK.game_ready()
	if !assert_inline(true == YandexSDK.is_game_ready(), "Game is not marked as ready after calling game_ready()."): return false


func test_gameplay():
	if !assert_inline(false == YandexSDK.is_gameplay_started(), "Gameplay is incorrectly marked as started before calling gameplay_start()."): return false
	YandexSDK.gameplay_start()
	if !assert_inline(true == YandexSDK.is_gameplay_started(), "Gameplay is not marked as started after calling gameplay_start()."): return false
	YandexSDK.gameplay_stop()
	if !assert_inline(false == YandexSDK.is_gameplay_started(), "Gameplay is incorrectly marked as started after calling gameplay_stop()."): return false
