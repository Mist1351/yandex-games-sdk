extends Control


@onready var log_output:RichTextLabel = $VSplitContainer/LogOutput


func _ready() -> void:
	logs(["[i]Yandex Games SDK v", YandexSDK.SDK_VERSION, "[/i]"])
	
	#region Sdk
	YandexSDK.sdk_error.connect(_on_sdk_error)
	YandexSDK.init_succeeded.connect(_on_init_succeeded)
	YandexSDK.init_failed.connect(_on_init_failed)
	YandexSDK.get_flags_succeeded.connect(_on_get_flags_succeeded)
	YandexSDK.get_flags_failed.connect(_on_get_flags_failed)
	YandexSDK.get_flags_timeout.connect(_on_get_flags_timeout)
	YandexSDK.game_api_paused.connect(_on_game_api_paused)
	YandexSDK.game_api_resumed.connect(_on_game_api_resumed)
	YandexSDK.on_history_back_event.connect(_on_history_back_event)
	#endregion
	
	#region Adv
	YandexSDK.adv.show_fullscreen_opened.connect(_on_adv_show_fullscreen_opened)
	YandexSDK.adv.show_fullscreen_closed.connect(_on_adv_show_fullscreen_closed)
	YandexSDK.adv.show_fullscreen_error.connect(_on_adv_show_fullscreen_error)
	YandexSDK.adv.show_fullscreen_offline.connect(_on_adv_show_fullscreen_offline)
	YandexSDK.adv.show_fullscreen_timeout.connect(_on_adv_show_fullscreen_timeout)
	YandexSDK.adv.show_rewarded_video_opened.connect(_on_adv_show_rewarded_video_opened)
	YandexSDK.adv.show_rewarded_video_closed.connect(_on_adv_show_rewarded_video_closed)
	YandexSDK.adv.show_rewarded_video_error.connect(_on_adv_show_rewarded_video_error)
	YandexSDK.adv.show_rewarded_video_rewarded.connect(_on_adv_show_rewarded_video_rewarded)
	YandexSDK.adv.get_banner_status_succeeded.connect(_on_adv_get_banner_status_succeeded)
	YandexSDK.adv.get_banner_status_failed.connect(_on_adv_get_banner_status_failed)
	YandexSDK.adv.show_banner_succeeded.connect(_on_adv_show_banner_succeeded)
	YandexSDK.adv.show_banner_failed.connect(_on_adv_show_banner_failed)
	YandexSDK.adv.hide_banner_succeeded.connect(_on_adv_hide_banner_succeeded)
	YandexSDK.adv.hide_banner_failed.connect(_on_adv_hide_banner_failed)
	#endregion
	
	#region Feedback
	YandexSDK.feedback.can_review_succeeded.connect(_on_feedback_can_review_succeeded)
	YandexSDK.feedback.can_review_failed.connect(_on_feedback_can_review_failed)
	YandexSDK.feedback.request_review_succeeded.connect(_on_feedback_request_review_succeeded)
	YandexSDK.feedback.request_review_failed.connect(_on_feedback_request_review_failed)
	#endregion
	
	#region Fullscreen
	YandexSDK.fullscreen.enter_succeeded.connect(_on_fullscreen_enter_succeeded)
	YandexSDK.fullscreen.enter_failed.connect(_on_fullscreen_enter_failed)
	YandexSDK.fullscreen.exit_succeeded.connect(_on_fullscreen_exit_succeeded)
	YandexSDK.fullscreen.exit_failed.connect(_on_fullscreen_exit_failed)
	#endregion
	
	#region Games
	YandexSDK.games.get_all_succeeded.connect(_on_games_get_all_succeeded)
	YandexSDK.games.get_all_failed.connect(_on_games_get_all_failed)
	YandexSDK.games.get_by_id_succeeded.connect(_on_games_get_by_id_succeeded)
	YandexSDK.games.get_by_id_failed.connect(_on_games_get_by_id_failed)
	#endregion
	
	#region Leaderboard
	YandexSDK.leaderboard.init_succeeded.connect(_on_fullscreen_init_succeeded)
	YandexSDK.leaderboard.init_failed.connect(_on_fullscreen_init_failed)
	YandexSDK.leaderboard.get_description_succeeded.connect(_on_fullscreen_get_description_succeeded)
	YandexSDK.leaderboard.get_description_failed.connect(_on_fullscreen_get_description_failed)
	YandexSDK.leaderboard.get_description_timeout.connect(_on_fullscreen_get_description_timeout)
	YandexSDK.leaderboard.set_score_succeeded.connect(_on_fullscreen_set_score_succeeded)
	YandexSDK.leaderboard.set_score_failed.connect(_on_fullscreen_set_score_failed)
	YandexSDK.leaderboard.set_score_timeout.connect(_on_fullscreen_set_score_timeout)
	YandexSDK.leaderboard.get_player_entry_succeeded.connect(_on_fullscreen_get_player_entry_succeeded)
	YandexSDK.leaderboard.get_player_entry_failed.connect(_on_fullscreen_get_player_entry_failed)
	YandexSDK.leaderboard.get_player_entry_timeout.connect(_on_fullscreen_get_player_entry_timeout)
	YandexSDK.leaderboard.get_entries_succeeded.connect(_on_fullscreen_get_entries_succeeded)
	YandexSDK.leaderboard.get_entries_failed.connect(_on_fullscreen_get_entries_failed)
	YandexSDK.leaderboard.get_entries_timeout.connect(_on_fullscreen_get_entries_timeout)
	#endregion
	
	#region Payments
	YandexSDK.payments.init_succeeded.connect(_on_payments_init_succeeded)
	YandexSDK.payments.init_failed.connect(_on_payments_init_failed)
	YandexSDK.payments.purchase_succeeded.connect(_on_payments_purchase_succeeded)
	YandexSDK.payments.purchase_failed.connect(_on_payments_purchase_failed)
	YandexSDK.payments.get_purchases_succeeded.connect(_on_payments_get_purchases_succeeded)
	YandexSDK.payments.get_purchases_failed.connect(_on_payments_get_purchases_failed)
	YandexSDK.payments.get_catalog_succeeded.connect(_on_payments_get_catalog_succeeded)
	YandexSDK.payments.get_catalog_failed.connect(_on_payments_get_catalog_failed)
	YandexSDK.payments.consume_purchase_succeeded.connect(_on_payments_consume_purchase_succeeded)
	YandexSDK.payments.consume_purchase_failed.connect(_on_payments_consume_purchase_failed)
	#endregion
	
	#region Player
	YandexSDK.player.init_succeeded.connect(_on_player_init_succeeded)
	YandexSDK.player.init_failed.connect(_on_player_init_failed)
	YandexSDK.player.get_ids_per_game_succeeded.connect(_on_player_get_ids_per_game_succeeded)
	YandexSDK.player.get_ids_per_game_failed.connect(_on_player_get_ids_per_game_failed)
	YandexSDK.player.set_data_succeeded.connect(_on_player_set_data_succeeded)
	YandexSDK.player.set_data_failed.connect(_on_player_set_data_failed)
	YandexSDK.player.set_data_timeout.connect(_on_player_set_data_timeout)
	YandexSDK.player.get_data_succeeded.connect(_on_player_get_data_succeeded)
	YandexSDK.player.get_data_failed.connect(_on_player_get_data_failed)
	YandexSDK.player.get_data_timeout.connect(_on_player_get_data_timeout)
	YandexSDK.player.set_stats_succeeded.connect(_on_player_set_stats_succeeded)
	YandexSDK.player.set_stats_failed.connect(_on_player_set_stats_failed)
	YandexSDK.player.set_stats_timeout.connect(_on_player_set_stats_timeout)
	YandexSDK.player.increment_stats_succeeded.connect(_on_player_increment_stats_succeeded)
	YandexSDK.player.increment_stats_failed.connect(_on_player_increment_stats_failed)
	YandexSDK.player.increment_stats_timeout.connect(_on_player_increment_stats_timeout)
	YandexSDK.player.get_stats_succeeded.connect(_on_player_get_stats_succeeded)
	YandexSDK.player.get_stats_failed.connect(_on_player_get_stats_failed)
	YandexSDK.player.get_stats_timeout.connect(_on_player_get_stats_timeout)
	YandexSDK.player.open_auth_dialog_closed.connect(_on_player_open_auth_dialog_closed)
	#endregion
	
	#region Shortcut
	YandexSDK.shortcut.can_show_prompt_succeeded.connect(_on_shortcut_can_show_prompt_succeeded)
	YandexSDK.shortcut.can_show_prompt_failed.connect(_on_shortcut_can_show_prompt_failed)
	YandexSDK.shortcut.show_prompt_succeeded.connect(_on_shortcut_show_prompt_succeeded)
	YandexSDK.shortcut.show_prompt_failed.connect(_on_shortcut_show_prompt_failed)
	#endregion


#region logs
func _prepare_value(value_:Variant) -> Variant:
	if value_ is String:
		return "\"%s\"" % value_
	return  value_


func _logs_signal(text_:String) -> void:
	logs("[color=#A4A]%s[/color]" % text_, 4)


func _logs_signal_param(name_:String,  value_:Variant) -> void:
	logs(["▶ [b]%s[/b]: [code]" % name_, _prepare_value(value_), "[/code]"], 4)


func _logs_method_await(text_:String) -> void:
	logs("[color=#88A][b]await[/b][/color] [color=#44A]%s[/color]" % text_)


func _logs_method(text_:String) -> void:
	logs("[color=#44A]%s[/color]" % text_)


func _logs_return(value_:Variant, status_:Variant = null) -> void:
	var color := "#4A4"
	if null == status_ && !value_ || null != status_ && !status_:
		color = "#A44"
	
	logs(["[color=%s]↪ [code]" % color, _prepare_value(value_), "[/code][/color]"])


func _logs_error(text_:String) -> void:
	logs("[color=tomato][b]Error:[/b] %s[/color]" % text_)


func logs(messages_:Variant, offset_:int = 0) -> void:
	if TYPE_ARRAY != typeof(messages_):
		messages_ = [messages_]
	
	log_output.append_text("[b][color=#444][lb]%s[rb]:[/color][/b] " % Time.get_datetime_string_from_system())
	log_output.append_text(" ".repeat(offset_))
	for m in messages_:
		if m is Dictionary:
			log_output.newline()
			log_output.add_text(JSON.stringify(m, "  ", false, true))
		else:
			log_output.append_text(str(m))
	log_output.newline()
#endregion


#region Sdk
func _on_sdk_error(error_:String) -> void:
	_logs_signal("YandexSDK.sdk_error(error)")
	_logs_signal_param("error", error_)


func _on_init_succeeded() -> void:
	_logs_signal("YandexSDK.init_succeeded()")


func _on_init_failed(error_:String) -> void:
	_logs_signal("YandexSDK.init_failed(error)")
	_logs_signal_param("error", error_)


func _on_get_flags_succeeded(flags_:Dictionary) -> void:
	_logs_signal("YandexSDK.get_flags_succeeded(flags)")
	_logs_signal_param("flags", flags_)


func _on_get_flags_failed(error_:String) -> void:
	_logs_signal("YandexSDK.get_flags_failed(error)")
	_logs_signal_param("error", error_)


func _on_get_flags_timeout() -> void:
	_logs_signal("YandexSDK._on_get_flags_timeout()")


func _on_game_api_paused() -> void:
	_logs_signal("YandexSDK.game_api_paused()")


func _on_game_api_resumed() -> void:
	_logs_signal("YandexSDK.game_api_resumed()")


func _on_history_back_event() -> void:
	_logs_signal("YandexSDK.on_history_back_event()")


func _on_get_last_sdk_error_pressed() -> void:
	_logs_method("YandexSDK.get_last_sdk_error()")
	_logs_return(YandexSDK.get_last_sdk_error())


func _on_init_pressed() -> void:
	_logs_method_await("YandexSDK.init()")
	_logs_return(await YandexSDK.init())


func _on_is_inited_pressed() -> void:
	_logs_method("YandexSDK.is_inited()")
	_logs_return(YandexSDK.is_inited())


func _on_game_ready_pressed() -> void:
	_logs_method("YandexSDK.game_ready()")
	YandexSDK.game_ready()


func _on_is_game_ready_pressed() -> void:
	_logs_method("YandexSDK.is_game_ready()")
	_logs_return(YandexSDK.is_game_ready())


func _on_gameplay_start_pressed() -> void:
	_logs_method("YandexSDK.gameplay_start()")
	YandexSDK.gameplay_start()


func _on_gameplay_stop_pressed() -> void:
	_logs_method("YandexSDK.gameplay_stop()")
	YandexSDK.gameplay_stop()


func _on_is_gameplay_started_pressed() -> void:
	_logs_method("YandexSDK.is_gameplay_started()")
	_logs_return(YandexSDK.is_gameplay_started())


func _on_send_exit_event_pressed() -> void:
	_logs_method("YandexSDK.send_exit_event()")
	YandexSDK.send_exit_event()


@onready var clipboard_text:LineEdit = $VSplitContainer/TabContainer/Sdk/GridContainer/VBoxContainer2/clipboard_text

func _on_clipboard_write_pressed() -> void:
	_logs_method_await("YandexSDK.clipboard_write(\"%s\")" % clipboard_text.text)
	_logs_return(await YandexSDK.clipboard_write(clipboard_text.text))


func _on_get_server_time_pressed() -> void:
	_logs_method("YandexSDK.get_server_time()")
	_logs_return(YandexSDK.get_server_time())


func _on_get_environment_pressed() -> void:
	_logs_method("YandexSDK.get_environment()")
	_logs_return(YandexSDK.get_environment())

@onready var default_flags_edit:CodeEdit = $VSplitContainer/TabContainer/Sdk/GridContainer/VBoxContainer3/default_flags
@onready var client_features_edit:CodeEdit = $VSplitContainer/TabContainer/Sdk/GridContainer/VBoxContainer3/client_features

func _convert_dictionary_array(input_:Array) -> Array[Dictionary]:
	var tmp:Array[Dictionary] = []
	for x in input_:
		tmp.push_back(x)
	return tmp

func _on_get_flags_pressed() -> void:
	var default_flags = JSON.parse_string(default_flags_edit.text)
	var client_features = JSON.parse_string(client_features_edit.text)
	
	var params = null
	var params_string := str(null)
	if TYPE_DICTIONARY != typeof(default_flags):
		_logs_error("Invalid default_flags type")
	elif TYPE_ARRAY != typeof(client_features):
		_logs_error("Invalid client_features type")
	elif !client_features.all(func(e): return TYPE_DICTIONARY == typeof(e)):
		_logs_error("Invalid client_features item type")
	else:
		client_features = _convert_dictionary_array(client_features)
		params = YandexSDK.create_flags_params(default_flags, client_features)
		params_string = "YandexSDK.create_flags_params(%s, %s)" % [default_flags, client_features]
	_logs_method_await("YandexSDK.get_flags(%s)" % params_string)
	_logs_return(await YandexSDK.get_flags(params))


func _on_crl_get_flags_pressed() -> void:
	_logs_method("YandexSDK.crl_get_flags.get_timeout_left_in_sec()")
	logs(YandexSDK.crl_get_flags.get_timeout_left_in_sec())
	_logs_method("YandexSDK.crl_get_flags.get_max_timeout_in_sec()")
	logs(YandexSDK.crl_get_flags.get_max_timeout_in_sec())
	_logs_method("YandexSDK.crl_get_flags.get_requests_count()")
	logs(YandexSDK.crl_get_flags.get_requests_count())
#endregion


#region Adv
func _on_adv_show_fullscreen_opened() -> void:
	_logs_signal("YandexSDK.adv.show_fullscreen_opened()")


func _on_adv_show_fullscreen_closed(was_shown_:bool) -> void:
	_logs_signal("YandexSDK.adv.show_fullscreen_closed(was_shown)")
	_logs_signal_param("was_shown", was_shown_)


func _on_adv_show_fullscreen_error(error_:String) -> void:
	_logs_signal("YandexSDK.adv.show_fullscreen_closed(error)")
	_logs_signal_param("error", error_)


func _on_adv_show_fullscreen_offline() -> void:
	_logs_signal("YandexSDK.adv.show_fullscreen_offline()")


func _on_adv_show_fullscreen_timeout() -> void:
	_logs_signal("YandexSDK.adv.show_fullscreen_timeout()")


func _on_adv_show_rewarded_video_opened() -> void:
	_logs_signal("YandexSDK.adv.show_rewarded_video_opened()")


func _on_adv_show_rewarded_video_closed() -> void:
	_logs_signal("YandexSDK.adv.show_rewarded_video_closed()")


func _on_adv_show_rewarded_video_error(error_:String) -> void:
	_logs_signal("YandexSDK.adv.show_rewarded_video_error(error)")
	_logs_signal_param("error", error_)


func _on_adv_show_rewarded_video_rewarded() -> void:
	_logs_signal("YandexSDK.adv.show_rewarded_video_rewarded()")


func _on_adv_get_banner_status_succeeded(sticky_adv_is_showing_:bool, reason_:Variant) -> void:
	_logs_signal("YandexSDK.adv.get_banner_status_succeeded(sticky_adv_is_showing, reason)")
	_logs_signal_param("sticky_adv_is_showing", sticky_adv_is_showing_)
	_logs_signal_param("reason", reason_)


func _on_adv_get_banner_status_failed(error_:String) -> void:
	_logs_signal("YandexSDK.adv.get_banner_status_failed(error)")
	_logs_signal_param("error", error_)


func _on_adv_show_banner_succeeded(sticky_adv_is_showing_:bool, reason_:Variant) -> void:
	_logs_signal("YandexSDK.adv.show_banner_succeeded(sticky_adv_is_showing, reason)")
	_logs_signal_param("sticky_adv_is_showing", sticky_adv_is_showing_)
	_logs_signal_param("reason", reason_)


func _on_adv_show_banner_failed(error_:String) -> void:
	_logs_signal("YandexSDK.adv.show_banner_failed(error)")
	_logs_signal_param("error", error_)


func _on_adv_hide_banner_succeeded(sticky_adv_is_showing_:bool) -> void:
	_logs_signal("YandexSDK.adv.hide_banner_succeeded(sticky_adv_is_showing)")
	_logs_signal_param("sticky_adv_is_showing", sticky_adv_is_showing_)


func _on_adv_hide_banner_failed(error_:String) -> void:
	_logs_signal("YandexSDK.adv.hide_banner_failed(error)")
	_logs_signal_param("error", error_)


func _on_adv_show_fullscreen_pressed() -> void:
	_logs_method("YandexSDK.adv.show_fullscreen()")
	YandexSDK.adv.show_fullscreen()


func _on_adv_crl_show_fullscreen_pressed() -> void:
	_logs_method("YandexSDK.adv.crl_show_fullscreen.get_timeout_left_in_sec()")
	logs(YandexSDK.adv.crl_show_fullscreen.get_timeout_left_in_sec())
	_logs_method("YandexSDK.adv.crl_show_fullscreen.get_max_timeout_in_sec()")
	logs(YandexSDK.adv.crl_show_fullscreen.get_max_timeout_in_sec())
	_logs_method("YandexSDK.adv.crl_show_fullscreen.get_requests_count()")
	logs(YandexSDK.adv.crl_show_fullscreen.get_requests_count())


func _on_adv_show_rewarded_video_pressed() -> void:
	_logs_method("YandexSDK.adv.show_rewarded_video()")
	YandexSDK.adv.show_rewarded_video()


func _on_adv_get_banner_status_pressed() -> void:
	_logs_method_await("YandexSDK.adv.get_banner_status()")
	_logs_return(await YandexSDK.adv.get_banner_status())


func _on_adv_show_banner_pressed() -> void:
	_logs_method_await("YandexSDK.adv.show_banner()")
	_logs_return(await YandexSDK.adv.show_banner())


func _on_adv_hide_banner_pressed() -> void:
	_logs_method_await("YandexSDK.adv.hide_banner()")
	_logs_return(await YandexSDK.adv.hide_banner())


func _on_adv_get_banner_reason_pressed() -> void:
	_logs_method("YandexSDK.adv.get_banner_reason()")
	_logs_return(YandexSDK.adv.get_banner_reason())
#endregion


#region DeviceInfo
func _on_device_info_is_mobile_pressed() -> void:
	_logs_method("YandexSDK.device_info.is_mobile()")
	_logs_return(YandexSDK.device_info.is_mobile())


func _on_device_info_is_desktop_pressed() -> void:
	_logs_method("YandexSDK.device_info.is_desktop()")
	_logs_return(YandexSDK.device_info.is_desktop())


func _on_device_info_is_tablet_pressed() -> void:
	_logs_method("YandexSDK.device_info.is_tablet()")
	_logs_return(YandexSDK.device_info.is_tablet())


func _on_device_info_is_tv_pressed() -> void:
	_logs_method("YandexSDK.device_info.is_tv()")
	_logs_return(YandexSDK.device_info.is_tv())


func _on_device_info_get_type_pressed() -> void:
	_logs_method("YandexSDK.device_info.get_type()")
	_logs_return(YandexSDK.device_info.get_type())
#endregion


#region Feedback
func _on_feedback_can_review_succeeded(status_:bool, reason_:Variant) -> void:
	_logs_signal("YandexSDK.feedback.can_review_succeeded(status, reason)")
	_logs_signal_param("status", status_)
	_logs_signal_param("reason", reason_)


func _on_feedback_can_review_failed(error_:String) -> void:
	_logs_signal("YandexSDK.feedback.can_review_failed(error)")
	_logs_signal_param("error", error_)


func _on_feedback_request_review_succeeded(feedback_sent_:bool) -> void:
	_logs_signal("YandexSDK.feedback.request_review_succeeded(feedback_sent)")
	_logs_signal_param("feedback_sent", feedback_sent_)


func _on_feedback_request_review_failed(error_:String) -> void:
	_logs_signal("YandexSDK.feedback.request_review_failed(error)")
	_logs_signal_param("error", error_)


func _on_feedback_can_review_pressed() -> void:
	_logs_method_await("YandexSDK.feedback.can_review()")
	_logs_return(await YandexSDK.feedback.can_review())


func _on_feedback_request_review_pressed() -> void:
	_logs_method_await("YandexSDK.feedback.request_review()")
	_logs_return(await YandexSDK.feedback.request_review())


func _on_feedback_get_can_review_reason_pressed() -> void:
	_logs_method("YandexSDK.feedback.get_can_review_reason()")
	_logs_return(YandexSDK.feedback.get_can_review_reason())
#endregion


#region Fullscreen
func _on_fullscreen_enter_succeeded() -> void:
	_logs_signal("YandexSDK.fullscreen.enter_succeeded()")


func _on_fullscreen_enter_failed(error_:String) -> void:
	_logs_signal("YandexSDK.fullscreen.enter_failed(error)")
	_logs_signal_param("error", error_)


func _on_fullscreen_exit_succeeded() -> void:
	_logs_signal("YandexSDK.fullscreen.exit_succeeded()")


func _on_fullscreen_exit_failed(error_:String) -> void:
	_logs_signal("YandexSDK.fullscreen.exit_failed(error)")
	_logs_signal_param("error", error_)


func _on_fullscreen_enter_pressed() -> void:
	_logs_method_await("YandexSDK.fullscreen.enter()")
	_logs_return(await YandexSDK.fullscreen.enter())


func _on_fullscreen_exit_pressed() -> void:
	_logs_method_await("YandexSDK.fullscreen.exit()")
	_logs_return(await YandexSDK.fullscreen.exit())


func _on_fullscreen_is_fullscreen_pressed() -> void:
	_logs_method("YandexSDK.fullscreen.enter()")
	_logs_return(YandexSDK.fullscreen.is_fullscreen())
#endregion


#region Games
func _on_games_get_all_succeeded(games_:Array[Dictionary], developer_url_:String) -> void:
	_logs_signal("YandexSDK.games.get_all_succeeded(games, developer_url)")
	_logs_signal_param("games", games_)
	_logs_signal_param("developer_url", developer_url_)


func _on_games_get_all_failed(error_:String) -> void:
	_logs_signal("YandexSDK.games.get_all_failed(error)")
	_logs_signal_param("error", error_)


func _on_games_get_by_id_succeeded(is_available_:bool, game_:Dictionary) -> void:
	_logs_signal("YandexSDK.games.get_by_id_succeeded(is_available, game)")
	_logs_signal_param("is_available", is_available_)
	_logs_signal_param("game", game_)


func _on_games_get_by_id_failed(error_:String) -> void:
	_logs_signal("YandexSDK.games.get_by_id_failed(error)")
	_logs_signal_param("error", error_)


func _on_games_get_all_pressed() -> void:
	_logs_method_await("YandexSDK.games.get_all()")
	_logs_return(await YandexSDK.games.get_all())


@onready var app_id_text:SpinBox = $VSplitContainer/TabContainer/Games/GridContainer/VBoxContainer/HBoxContainer/app_id_text

func _on_games_get_by_id_pressed() -> void:
	var value:int = app_id_text.value
	_logs_method_await("YandexSDK.games.get_by_id(%d)" % value)
	_logs_return(await YandexSDK.games.get_by_id(value))


func _on_games_get_developer_url_pressed() -> void:
	_logs_method("YandexSDK.games.get_developer_url()")
	_logs_return(YandexSDK.games.get_developer_url())


func _on_games_is_available_game_pressed() -> void:
	_logs_method("YandexSDK.games.is_available_game()")
	_logs_return(YandexSDK.games.is_available_game())
#endregion


#region Leaderboard
func _on_fullscreen_init_succeeded() -> void:
	_logs_signal("YandexSDK.leaderboard.init_succeeded()")


func _on_fullscreen_init_failed(error_:String) -> void:
	_logs_signal("YandexSDK.leaderboard.init_failed(error)")
	_logs_signal_param("error", error_)


func _on_fullscreen_get_description_succeeded(description_:Dictionary) -> void:
	_logs_signal("YandexSDK.leaderboard.get_description_succeeded(description)")
	_logs_signal_param("description", description_)


func _on_fullscreen_get_description_failed(error_:String) -> void:
	_logs_signal("YandexSDK.leaderboard.get_description_failed(error)")
	_logs_signal_param("error", error_)


func _on_fullscreen_get_description_timeout() -> void:
	_logs_signal("YandexSDK.leaderboard.get_description_timeout()")


func _on_fullscreen_set_score_succeeded() -> void:
	_logs_signal("YandexSDK.leaderboard.set_score_succeeded()")


func _on_fullscreen_set_score_failed(error_:String) -> void:
	_logs_signal("YandexSDK.leaderboard.set_score_failed(error)")
	_logs_signal_param("error", error_)


func _on_fullscreen_set_score_timeout() -> void:
	_logs_signal("YandexSDK.leaderboard.set_score_timeout()")


func _on_fullscreen_get_player_entry_succeeded(entry_:Dictionary) -> void:
	_logs_signal("YandexSDK.leaderboard.get_player_entry_succeeded(entry)")
	_logs_signal_param("entry", entry_)


func _on_fullscreen_get_player_entry_failed(error_:String, code_:Variant) -> void:
	_logs_signal("YandexSDK.leaderboard.get_player_entry_failed(error, code)")
	_logs_signal_param("error", error_)
	_logs_signal_param("code", code_)


func _on_fullscreen_get_player_entry_timeout() -> void:
	_logs_signal("YandexSDK.leaderboard.get_player_entry_timeout()")


func _on_fullscreen_get_entries_succeeded(data_:Dictionary) -> void:
	_logs_signal("YandexSDK.leaderboard.get_entries_succeeded(data)")
	_logs_signal_param("data", data_)


func _on_fullscreen_get_entries_failed(error_:String) -> void:
	_logs_signal("YandexSDK.leaderboard.get_entries_failed(error)")
	_logs_signal_param("error", error_)


func _on_fullscreen_get_entries_timeout() -> void:
	_logs_signal("YandexSDK.leaderboard.get_entries_timeout()")


func _on_leaderboard_init_pressed() -> void:
	_logs_method_await("YandexSDK.leaderboard.init()")
	_logs_return(await YandexSDK.leaderboard.init())


func _on_leaderboard_is_inited_pressed() -> void:
	_logs_method("YandexSDK.leaderboard.is_inited()")
	_logs_return(YandexSDK.leaderboard.is_inited())


@onready var get_description_leaderboard_name_text:LineEdit = $VSplitContainer/TabContainer/Leaderboard/GridContainer/VBoxContainer/GridContainer/get_description_leaderboard_name_text

func _on_leaderboard_get_description_pressed() -> void:
	var lb_name:String = get_description_leaderboard_name_text.text
	_logs_method_await("YandexSDK.leaderboard.get_description(\"%s\")" % lb_name)
	_logs_return(await YandexSDK.leaderboard.get_description(lb_name))


func _on_leaderboard_crl_get_description_pressed() -> void:
	_logs_method("YandexSDK.leaderboard.crl_get_description.get_timeout_left_in_sec()")
	logs(YandexSDK.leaderboard.crl_get_description.get_timeout_left_in_sec())
	_logs_method("YandexSDK.leaderboard.crl_get_description.get_max_timeout_in_sec()")
	logs(YandexSDK.leaderboard.crl_get_description.get_max_timeout_in_sec())
	_logs_method("YandexSDK.leaderboard.crl_get_description.get_requests_count()")
	logs(YandexSDK.leaderboard.crl_get_description.get_requests_count())


@onready var set_score_leaderboard_name_text:LineEdit = $VSplitContainer/TabContainer/Leaderboard/GridContainer/VBoxContainer2/GridContainer/set_score_leaderboard_name_text
@onready var set_score_leaderboard_extra_score_text:SpinBox = $VSplitContainer/TabContainer/Leaderboard/GridContainer/VBoxContainer2/GridContainer/set_score_leaderboard_extra_score_text
@onready var set_score_leaderboard_extra_data_text:LineEdit = $VSplitContainer/TabContainer/Leaderboard/GridContainer/VBoxContainer2/GridContainer/set_score_leaderboard_extra_data_text

func _on_leaderboard_set_score_pressed() -> void:
	var lb_name:String = set_score_leaderboard_name_text.text
	var score:int = set_score_leaderboard_extra_score_text.value
	var extra_data:String = set_score_leaderboard_extra_data_text.text
	_logs_method_await("YandexSDK.leaderboard.set_score(\"%s\", %d, \"%s\")" % [lb_name, score, extra_data])
	_logs_return(await YandexSDK.leaderboard.set_score(lb_name, score, extra_data))


func _on_leaderboard_crl_set_score_pressed() -> void:
	_logs_method("YandexSDK.leaderboard.crl_set_score.get_timeout_left_in_sec()")
	logs(YandexSDK.leaderboard.crl_set_score.get_timeout_left_in_sec())
	_logs_method("YandexSDK.leaderboard.crl_set_score.get_max_timeout_in_sec()")
	logs(YandexSDK.leaderboard.crl_set_score.get_max_timeout_in_sec())
	_logs_method("YandexSDK.leaderboard.crl_set_score.get_requests_count()")
	logs(YandexSDK.leaderboard.crl_set_score.get_requests_count())


@onready var get_player_entry_leaderboard_name_text: LineEdit = $VSplitContainer/TabContainer/Leaderboard/GridContainer/VBoxContainer3/GridContainer2/get_player_entry_leaderboard_name_text

func _on_leaderboard_get_player_entry_pressed() -> void:
	var lb_name:String = get_player_entry_leaderboard_name_text.text
	_logs_method_await("YandexSDK.leaderboard.get_player_entry(\"%s\")" % lb_name)
	_logs_return(await YandexSDK.leaderboard.get_player_entry(lb_name))


func _on_leaderboard_crl_get_player_entry_pressed() -> void:
	_logs_method("YandexSDK.leaderboard.crl_get_player_entry.get_timeout_left_in_sec()")
	logs(YandexSDK.leaderboard.crl_get_player_entry.get_timeout_left_in_sec())
	_logs_method("YandexSDK.leaderboard.crl_get_player_entry.get_max_timeout_in_sec()")
	logs(YandexSDK.leaderboard.crl_get_player_entry.get_max_timeout_in_sec())
	_logs_method("YandexSDK.leaderboard.crl_get_player_entry.get_requests_count()")
	logs(YandexSDK.leaderboard.crl_get_player_entry.get_requests_count())


@onready var get_entries_leaderboard_name_text:LineEdit = $VSplitContainer/TabContainer/Leaderboard/GridContainer/VBoxContainer3/GridContainer/get_entries_leaderboard_name_text
@onready var get_entries_quantity_around_text:SpinBox = $VSplitContainer/TabContainer/Leaderboard/GridContainer/VBoxContainer3/GridContainer/get_entries_quantity_around_text
@onready var get_entries_quantity_top_text:SpinBox = $VSplitContainer/TabContainer/Leaderboard/GridContainer/VBoxContainer3/GridContainer/get_entries_quantity_top_text
@onready var get_entries_include_user:CheckBox = $VSplitContainer/TabContainer/Leaderboard/GridContainer/VBoxContainer3/GridContainer/get_entries_include_user

func _on_leaderboard_get_entries_pressed() -> void:
	var lb_name:String = get_entries_leaderboard_name_text.text
	var include_user:bool = get_entries_include_user.button_pressed
	var quantity_around:int = get_entries_quantity_around_text.value
	var quantity_top:int = get_entries_quantity_top_text.value
	_logs_method_await("YandexSDK.leaderboard.get_entries(\"%s\", %s, %d, %d)" % [lb_name, include_user, quantity_around, quantity_top])
	_logs_return(await YandexSDK.leaderboard.get_entries(lb_name, include_user, quantity_around, quantity_top))


func _on_leaderboard_crl_get_entries_pressed() -> void:
	_logs_method("YandexSDK.leaderboard.crl_get_entries.get_timeout_left_in_sec()")
	logs(YandexSDK.leaderboard.crl_get_entries.get_timeout_left_in_sec())
	_logs_method("YandexSDK.leaderboard.crl_get_entries.get_max_timeout_in_sec()")
	logs(YandexSDK.leaderboard.crl_get_entries.get_max_timeout_in_sec())
	_logs_method("YandexSDK.leaderboard.crl_get_entries.get_requests_count()")
	logs(YandexSDK.leaderboard.crl_get_entries.get_requests_count())


func _on_leaderboard_get_player_entry_code_pressed() -> void:
	_logs_method("YandexSDK.leaderboard.get_player_entry_code()")
	_logs_return(YandexSDK.leaderboard.get_player_entry_code())
#endregion


#region Payments
func _on_payments_init_succeeded() -> void:
	_logs_signal("YandexSDK.payments.init_succeeded()")


func _on_payments_init_failed(error_:String) -> void:
	_logs_signal("YandexSDK.payments.init_failed(error)")
	_logs_signal_param("error", error_)


func _on_payments_purchase_succeeded(purchase_:Dictionary) -> void:
	_logs_signal("YandexSDK.payments.purchase_succeeded(purchase)")
	_logs_signal_param("purchase", purchase_)


func _on_payments_purchase_failed(error_:String) -> void:
	_logs_signal("YandexSDK.payments.purchase_failed(error)")
	_logs_signal_param("error", error_)


func _on_payments_get_purchases_succeeded(purchases_:Array[Dictionary]) -> void:
	_logs_signal("YandexSDK.payments.get_purchases_succeeded(purchases)")
	_logs_signal_param("purchases", purchases_)


func _on_payments_get_purchases_failed(error_:String) -> void:
	_logs_signal("YandexSDK.payments.get_purchases_failed(error)")
	_logs_signal_param("error", error_)


func _on_payments_get_catalog_succeeded(products_:Array[Dictionary]) -> void:
	_logs_signal("YandexSDK.payments.get_catalog_succeeded(products)")
	_logs_signal_param("products", products_)


func _on_payments_get_catalog_failed(error_:String) -> void:
	_logs_signal("YandexSDK.payments.get_catalog_failed(error)")
	_logs_signal_param("error", error_)


func _on_payments_consume_purchase_succeeded() -> void:
	_logs_signal("YandexSDK.payments.consume_purchase_succeeded()")


func _on_payments_consume_purchase_failed(error_:String) -> void:
	_logs_signal("YandexSDK.payments.consume_purchase_failed(error)")
	_logs_signal_param("error", error_)


func _on_payments_init_pressed() -> void:
	_logs_method_await("YandexSDK.payments.init()")
	_logs_return(await YandexSDK.payments.init())


func _on_payments_is_inited_pressed() -> void:
	_logs_method("YandexSDK.payments.is_inited()")
	_logs_return(YandexSDK.payments.is_inited())


@onready var purchase_id_text:LineEdit = $VSplitContainer/TabContainer/Payments/GridContainer/VBoxContainer3/GridContainer/purchase_id_text
@onready var purchase_developer_payload_text:LineEdit = $VSplitContainer/TabContainer/Payments/GridContainer/VBoxContainer3/GridContainer/purchase_developer_payload_text

func _on_payments_purchase_pressed() -> void:
	var id:String = purchase_id_text.text
	var developer_payload:String = purchase_developer_payload_text.text
	_logs_method_await("YandexSDK.payments.purchase(\"%s\", \"%s\")" % [id, developer_payload])
	_logs_return(await YandexSDK.payments.purchase(id, developer_payload))


@onready var purchases_container:ItemList = $VSplitContainer/TabContainer/Payments/GridContainer/VBoxContainer2/purchases

func _on_payments_get_purchases_pressed() -> void:
	_logs_method_await("YandexSDK.payments.get_purchases()")
	var purchases = await YandexSDK.payments.get_purchases()
	_logs_return(purchases)
	
	purchases_container.clear()
	if null != purchases:
		for purchase in purchases:
			purchases_container.add_item(purchase.product_id)
			purchases_container.set_item_metadata(purchases_container.item_count - 1, purchase)


func _on_purchases_item_clicked(index_:int, at_position_:Vector2, mouse_button_index_:int) -> void:
	var purchase = purchases_container.get_item_metadata(index_)
	purchase_token_text.text = purchase.purchase_token


@onready var catalog:ItemList = $VSplitContainer/TabContainer/Payments/GridContainer/VBoxContainer2/catalog

func _on_payments_get_catalog_pressed() -> void:
	_logs_method_await("YandexSDK.payments.get_catalog()")
	var products = await YandexSDK.payments.get_catalog()
	_logs_return(products)
	
	catalog.clear()
	if null != products:
		for product in products:
			var texture := await YandexSDK.request_image_by_url(product.image_uri)
			texture.set_size_override(Vector2(32, 32))
			catalog.add_item(product.title, texture, false)
			catalog.set_item_metadata(catalog.item_count - 1, product)


func _on_catalog_item_clicked(index_:int, at_position_:Vector2, mouse_button_index_:int) -> void:
	var product = catalog.get_item_metadata(index_)
	purchase_id_text.text = product.id


@onready var purchase_token_text:LineEdit = $VSplitContainer/TabContainer/Payments/GridContainer/VBoxContainer3/GridContainer2/purchase_token_text

func _on_payments_consume_purchase_pressed() -> void:
	var purchase_token:String = purchase_token_text.text
	_logs_method_await("YandexSDK.payments.consume_purchase()")
	_logs_return(await YandexSDK.payments.consume_purchase(purchase_token))
#endregion


#region Player
func _on_player_init_succeeded() -> void:
	_logs_signal("YandexSDK.player.init_succeeded()")


func _on_player_init_failed(error_:String) -> void:
	_logs_signal("YandexSDK.player.init_failed(error)")
	_logs_signal_param("error", error_)


func _on_player_get_ids_per_game_succeeded(ids_per_game_:Array[Dictionary]) -> void:
	_logs_signal("YandexSDK.player.get_ids_per_game_succeeded(ids_per_game)")
	_logs_signal_param("ids_per_game", ids_per_game_)


func _on_player_get_ids_per_game_failed(error_:String) -> void:
	_logs_signal("YandexSDK.player.get_ids_per_game_failed(error)")
	_logs_signal_param("error", error_)


func _on_player_set_data_succeeded(was_saved_:bool) -> void:
	_logs_signal("YandexSDK.player.set_data_succeeded(was_saved)")
	_logs_signal_param("was_saved", was_saved_)


func _on_player_set_data_failed(error_:String) -> void:
	_logs_signal("YandexSDK.player.set_data_failed(error)")
	_logs_signal_param("error", error_)


func _on_player_set_data_timeout() -> void:
	_logs_signal("YandexSDK.player.set_data_timeout()")


func _on_player_get_data_succeeded(data_:Dictionary) -> void:
	_logs_signal("YandexSDK.player.get_data_succeeded(data)")
	_logs_signal_param("data", data_)


func _on_player_get_data_failed(error_:String) -> void:
	_logs_signal("YandexSDK.player.get_data_failed(error)")
	_logs_signal_param("error", error_)


func _on_player_get_data_timeout() -> void:
	_logs_signal("YandexSDK.player.get_data_timeout()")


func _on_player_set_stats_succeeded() -> void:
	_logs_signal("YandexSDK.player.set_stats_succeeded()")


func _on_player_set_stats_failed(error_:String) -> void:
	_logs_signal("YandexSDK.player.set_stats_failed(error)")
	_logs_signal_param("error", error_)


func _on_player_set_stats_timeout() -> void:
	_logs_signal("YandexSDK.player.set_stats_timeout()")


func _on_player_increment_stats_succeeded(data_:Dictionary) -> void:
	_logs_signal("YandexSDK.player.increment_stats_succeeded(data)")
	_logs_signal_param("data", data_)


func _on_player_increment_stats_failed(error_:String) -> void:
	_logs_signal("YandexSDK.player.increment_stats_failed(error)")
	_logs_signal_param("error", error_)


func _on_player_increment_stats_timeout() -> void:
	_logs_signal("YandexSDK.player.increment_stats_timeout()")


func _on_player_get_stats_succeeded(data_:Dictionary) -> void:
	_logs_signal("YandexSDK.player.get_stats_succeeded(data)")
	_logs_signal_param("data", data_)


func _on_player_get_stats_failed(error_:String) -> void:
	_logs_signal("YandexSDK.player.get_stats_failed(error)")
	_logs_signal_param("error", error_)


func _on_player_get_stats_timeout() -> void:
	_logs_signal("YandexSDK.player.get_stats_timeout()")


func _on_player_open_auth_dialog_closed(is_authenticated_:bool) -> void:
	_logs_signal("YandexSDK.player.open_auth_dialog_closed(is_authenticated)")
	_logs_signal_param("is_authenticated", is_authenticated_)


func _on_player_init_pressed() -> void:
	_logs_method_await("YandexSDK.player.init()")
	_logs_return(await YandexSDK.player.init())


func _on_player_is_inited_pressed() -> void:
	_logs_method("YandexSDK.player.is_inited()")
	_logs_return(YandexSDK.player.is_inited())


func _on_player_open_auth_dialog_pressed() -> void:
	_logs_method_await("YandexSDK.player.open_auth_dialog()")
	_logs_return(await YandexSDK.player.open_auth_dialog())


func _on_player_is_authorized_pressed() -> void:
	_logs_method("YandexSDK.player.is_authorized()")
	_logs_return(YandexSDK.player.is_authorized())


func _on_player_get_mode_pressed() -> void:
	_logs_method("YandexSDK.player.get_mode()")
	_logs_return(YandexSDK.player.get_mode())


func _on_player_get_ids_per_game_pressed() -> void:
	_logs_method_await("YandexSDK.player.get_ids_per_game()")
	_logs_return(await YandexSDK.player.get_ids_per_game())


func _on_player_get_name_pressed() -> void:
	_logs_method("YandexSDK.player.get_name()")
	_logs_return(YandexSDK.player.get_name())


func _on_player_get_photo_pressed() -> void:
	_logs_method("YandexSDK.player.get_photo(YandexPlayer.PHOTO_SIZE_SMALL)")
	_logs_return(YandexSDK.player.get_photo(YandexPlayer.PHOTO_SIZE_SMALL))
	_logs_method("YandexSDK.player.get_photo(YandexPlayer.PHOTO_SIZE_MEDIUM)")
	_logs_return(YandexSDK.player.get_photo(YandexPlayer.PHOTO_SIZE_MEDIUM))
	_logs_method("YandexSDK.player.get_photo(YandexPlayer.PHOTO_SIZE_LARGE)")
	_logs_return(YandexSDK.player.get_photo(YandexPlayer.PHOTO_SIZE_LARGE))


func _on_player_get_paying_status_pressed() -> void:
	_logs_method("YandexSDK.player.get_paying_status()")
	_logs_return(YandexSDK.player.get_paying_status())


func _on_player_get_id_pressed() -> void:
	_logs_method("YandexSDK.player.get_id()")
	_logs_return(YandexSDK.player.get_id())


func _on_player_get_unique_id_pressed() -> void:
	_logs_method("YandexSDK.player.get_unique_id()")
	_logs_return(YandexSDK.player.get_unique_id())


func _on_player_get_signature_pressed() -> void:
	_logs_method("YandexSDK.player.get_signature()")
	_logs_return(YandexSDK.player.get_signature())

@onready var player_data:CodeEdit = $VSplitContainer/TabContainer/Player/GridContainer/VBoxContainer3/data

func _on_player_set_data_pressed() -> void:
	var flush = false
	var data = JSON.parse_string(player_data.text)
	if TYPE_DICTIONARY != typeof(data):
		_logs_error("Invalid data type")
	else:
		_logs_method_await("YandexSDK.player.set_data(%s, %s)" % [data, flush])
		_logs_return(await YandexSDK.player.set_data(data, flush))


func _on_player_crl_set_data_pressed() -> void:
	_logs_method("YandexSDK.player.crl_set_data.get_timeout_left_in_sec()")
	logs(YandexSDK.player.crl_set_data.get_timeout_left_in_sec())
	_logs_method("YandexSDK.player.crl_set_data.get_max_timeout_in_sec()")
	logs(YandexSDK.player.crl_set_data.get_max_timeout_in_sec())
	_logs_method("YandexSDK.player.crl_set_data.get_requests_count()")
	logs(YandexSDK.player.crl_set_data.get_requests_count())


@onready var player_data_keys:CodeEdit = $VSplitContainer/TabContainer/Player/GridContainer/VBoxContainer3/data_keys

func _on_player_get_data_pressed() -> void:
	var keys = JSON.parse_string(player_data_keys.text)
	if null == keys:
		_logs_error("Failed to parse keys")
	elif TYPE_ARRAY != typeof(keys):
		_logs_error("Invalid keys type")
	elif !keys.all(func(e): return TYPE_STRING == typeof(e)):
		_logs_error("Invalid keys item type")
	else:
		var string_keys:Array[String]
		string_keys.append_array(keys)
		_logs_method_await("YandexSDK.player.get_data(%s)" % string_keys)
		var data = await YandexSDK.player.get_data(string_keys)
		_logs_return(data)
		if null != data:
			player_data.text = JSON.stringify(data, "    ")


func _on_player_crl_get_data_pressed() -> void:
	_logs_method("YandexSDK.player.crl_get_data.get_timeout_left_in_sec()")
	logs(YandexSDK.player.crl_get_data.get_timeout_left_in_sec())
	_logs_method("YandexSDK.player.crl_get_data.get_max_timeout_in_sec()")
	logs(YandexSDK.player.crl_get_data.get_max_timeout_in_sec())
	_logs_method("YandexSDK.player.crl_get_data.get_requests_count()")
	logs(YandexSDK.player.crl_get_data.get_requests_count())


@onready var player_stats:CodeEdit = $VSplitContainer/TabContainer/Player/GridContainer/VBoxContainer4/stats

func _on_player_set_stats_pressed() -> void:
	var stats = JSON.parse_string(player_stats.text)
	if null == stats:
		_logs_error("Failed to parse stats")
	elif TYPE_DICTIONARY != typeof(stats):
		_logs_error("Invalid stats type")
	else:
		_logs_method_await("YandexSDK.player.set_stats(%s)" % [stats])
		_logs_return(await YandexSDK.player.set_stats(stats))


func _on_player_crl_set_stats_pressed() -> void:
	_logs_method("YandexSDK.player.crl_set_stats.get_timeout_left_in_sec()")
	logs(YandexSDK.player.crl_set_stats.get_timeout_left_in_sec())
	_logs_method("YandexSDK.player.crl_set_stats.get_max_timeout_in_sec()")
	logs(YandexSDK.player.crl_set_stats.get_max_timeout_in_sec())
	_logs_method("YandexSDK.player.crl_set_stats.get_requests_count()")
	logs(YandexSDK.player.crl_set_stats.get_requests_count())


@onready var player_stats_keys:CodeEdit = $VSplitContainer/TabContainer/Player/GridContainer/VBoxContainer4/stats_keys

func _on_player_get_stats_pressed() -> void:
	var keys = JSON.parse_string(player_stats_keys.text)
	if null == keys:
		_logs_error("Failed to parse keys")
	elif TYPE_ARRAY != typeof(keys):
		_logs_error("Invalid keys type")
	elif !keys.all(func(e): return TYPE_STRING == typeof(e)):
		_logs_error("Invalid keys item type")
	else:
		var string_keys:Array[String]
		string_keys.append_array(keys)
		_logs_method_await("YandexSDK.player.get_stats(%s)" % [string_keys])
		var data = await YandexSDK.player.get_stats(string_keys)
		_logs_return(data)
		if null != data:
			player_stats.text = JSON.stringify(data, "    ")


func _on_player_crl_get_stats_pressed() -> void:
	_logs_method("YandexSDK.player.crl_get_stats.get_timeout_left_in_sec()")
	logs(YandexSDK.player.crl_get_stats.get_timeout_left_in_sec())
	_logs_method("YandexSDK.player.crl_get_stats.get_max_timeout_in_sec()")
	logs(YandexSDK.player.crl_get_stats.get_max_timeout_in_sec())
	_logs_method("YandexSDK.player.crl_get_stats.get_requests_count()")
	logs(YandexSDK.player.crl_get_stats.get_requests_count())


@onready var stats_stats_increment:CodeEdit = $VSplitContainer/TabContainer/Player/GridContainer/VBoxContainer4/stats_stats_increment

func _on_player_increment_stats_pressed() -> void:
	var increments = JSON.parse_string(stats_stats_increment.text)
	if null == increments:
		_logs_error("Failed to parse increments")
	elif TYPE_DICTIONARY != typeof(increments):
		_logs_error("Invalid increments type")
	else:
		_logs_method_await("YandexSDK.player.increment_stats(%s)" % [increments])
		var data = await YandexSDK.player.increment_stats(increments)
		_logs_return(data)
		if null != data:
			player_stats.text = JSON.stringify(data["stats"], "    ")


func _on_player_crl_increment_stats_pressed() -> void:
	_logs_method("YandexSDK.player.crl_increment_stats.get_timeout_left_in_sec()")
	logs(YandexSDK.player.crl_increment_stats.get_timeout_left_in_sec())
	_logs_method("YandexSDK.player.crl_increment_stats.get_max_timeout_in_sec()")
	logs(YandexSDK.player.crl_increment_stats.get_max_timeout_in_sec())
	_logs_method("YandexSDK.player.crl_increment_stats.get_requests_count()")
	logs(YandexSDK.player.crl_increment_stats.get_requests_count())
#endregion


#region Shortcut
func _on_shortcut_can_show_prompt_succeeded(can_show_:bool, reason_:Variant) -> void:
	_logs_signal("YandexSDK.shortcut.can_show_prompt_succeeded(can_show, reason)")
	_logs_signal_param("can_show", can_show_)
	_logs_signal_param("reason", reason_)


func _on_shortcut_can_show_prompt_failed(error_:String) -> void:
	_logs_signal("YandexSDK.shortcut.can_show_prompt(error)")
	_logs_signal_param("error", error_)


func _on_shortcut_show_prompt_succeeded(accepted_:bool) -> void:
	_logs_signal("YandexSDK.shortcut.show_prompt_succeeded(accepted)")
	_logs_signal_param("accepted", accepted_)


func _on_shortcut_show_prompt_failed(error_:String) -> void:
	_logs_signal("YandexSDK.shortcut.show_prompt_failed(error)")
	_logs_signal_param("error", error_)


func _on_shortcut_can_show_prompt_pressed() -> void:
	_logs_method_await("YandexSDK.shortcut.can_show_prompt()")
	_logs_return(await YandexSDK.shortcut.can_show_prompt())


func _on_shortcut_show_prompt_pressed() -> void:
	_logs_method_await("YandexSDK.shortcut.show_prompt()")
	_logs_return(await YandexSDK.shortcut.show_prompt())


func _on_shortcut_get_show_prompt_reason_pressed() -> void:
	_logs_method("YandexSDK.shortcut.get_show_prompt_reason()")
	_logs_return(YandexSDK.shortcut.get_show_prompt_reason())
#endregion


#region Tests
@onready var tests:TestNode = $VSplitContainer/TabContainer/Tests/GridContainer/VBoxContainer/tests
@onready var run_tests_button:Button = $VSplitContainer/TabContainer/Tests/GridContainer/VBoxContainer/run_tests
var _done_tests:Array

func _on_run_tests_pressed() -> void:
	run_tests_button.disabled = true
	_done_tests = []
	await tests.execute_all_tests()
	run_tests_button.disabled = false


func _on_tests_all_tests_done() -> void:
	for test in _done_tests:
		if test["result"]:
			logs("[color=#4A4][PASSED] %s[/color]" % test["name"])
		else:
			logs("[color=#A44][FAILED] %s[/color]" % test["name"])
	logs("Tests done")


func _on_tests_test_done(test_name_:String, is_ok_:bool) -> void:
	_done_tests.push_back({"name": test_name_, "result": is_ok_})


func _on_tests_test_error(message_:String) -> void:
	logs(["[color=#A44]", message_, "[/color]"])


func _on_tests_test_print(message_:String) -> void:
	logs(message_)
#endregion
