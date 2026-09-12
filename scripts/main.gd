extends Node2D

const HEMORRHOID_MINIGAME = preload("res://scenes/hemorrhoid_minigame.tscn")

@onready var player = $Player
@onready var ticket_system = $TicketSystem
@onready var event_manager = $WaitingEventManager
@onready var prompt_label: Label = $HUD/PromptPanel/Prompt
@onready var message_label: Label = $HUD/Message
@onready var serving_label: Label = $HUD/ServingPanel/Serving
@onready var ticket_label: Label = $HUD/TicketPanel/Ticket
@onready var wait_time_label: Label = $HUD/WaitPanel/WaitTime
@onready var room_serving_label: Label = $World/NumberDisplay/Number

var _nearby
var _message_time := 0.0
var _active_minigame
var _engagement_active := false
var _engagement_npc = null
var _engagement_id := ""

func _ready():
	GameState.serving_number_changed.connect(_on_serving_changed)
	GameState.wait_time_changed.connect(_on_wait_time_changed)
	GameState.dmv_announcement.connect(_show_message)
	ticket_system.ticket_issued.connect(_on_ticket_issued)
	event_manager.announcement_requested.connect(_show_message)
	event_manager.npc_impatience_requested.connect(_make_npc_impatient)
	event_manager.minigame_requested.connect(_launch_minigame)
	event_manager.ambient_action_requested.connect(_perform_ambient_action)
	event_manager.engagement_requested.connect(_start_engagement)
	for object in get_tree().get_nodes_in_group("dmv_interactables"):
		object.interaction_requested.connect(_on_interaction_requested)
	_on_serving_changed(GameState.get_now_serving())
	_on_wait_time_changed(GameState.get_waiting_minutes())
	_update_ticket_label()

func _process(delta):
	_find_nearest_interactable()

	if _engagement_active:
		if Input.is_key_pressed(KEY_1):
			_resolve_engagement(true)
		elif Input.is_key_pressed(KEY_2):
			_resolve_engagement(false)
		return

	if Input.is_action_just_pressed("interact") and _nearby:
		_nearby.interact()
	if _message_time > 0.0:
		_message_time -= delta
		if _message_time <= 0.0:
			message_label.text = ""

func _find_nearest_interactable():
	_nearby = null
	var best_distance := 72.0
	for object in get_tree().get_nodes_in_group("dmv_interactables"):
		var distance = player.global_position.distance_to(object.global_position)
		if distance < best_distance:
			best_distance = distance
			_nearby = object

	if _engagement_active:
		prompt_label.text = "[1] LISTEN     [2] POLITELY DISENGAGE"
	else:
		prompt_label.text = "Press E to interact — %s" % _nearby.display_name if _nearby else ""

func _on_interaction_requested(object):
	match object.interaction_id:
		"ticket_dispenser":
			if not GameState.has_ticket():
				var number = ticket_system.take_ticket()
				_show_message("YOUR NUMBER IS %03d. PLEASE WAIT." % number)
			else:
				_show_message("ONE TICKET PER PERSON. YOU HAVE %03d." % GameState.get_ticket_number())
		"number_display": _show_message("NOW SERVING %03d. PLEASE DO NOT ASK THE CLERK." % GameState.get_now_serving())
		"bathroom": _show_message("RESTROOM: OUT OF ORDER. OF COURSE.")
		"service_counter":
			if not GameState.has_ticket():
				_show_message("PLEASE TAKE A NUMBER BEFORE APPROACHING THE COUNTER.")
			elif GameState.get_now_serving() < GameState.get_ticket_number():
				_show_message("PLEASE WAIT. NOW SERVING %03d." % GameState.get_now_serving())
			else:
				GameState.mark_called()
				_show_message("YOU MAY APPROACH. PLEASE HAVE EVERY DOCUMENT EVER ISSUED.")
		"npc": _show_message(object.dialogue_text)
		_: _show_message(object.response_text)

func _on_serving_changed(number: int):
	serving_label.text = "NOW SERVING\n%03d" % number
	room_serving_label.text = "%03d" % number
	# Brief visual feedback is provided by the announcement/message channel.

func _on_wait_time_changed(_minutes: float):
	wait_time_label.text = "TIME\n%s" % GameState.get_wait_time_text()

func _on_ticket_issued(_number: int):
	_update_ticket_label()

func _update_ticket_label():
	var ticket_text = "---" if not GameState.has_ticket() else "%03d" % GameState.get_ticket_number()
	ticket_label.text = "TICKET\n%s" % ticket_text

func _make_npc_impatient(npc_path: NodePath):
	var npc = get_node_or_null(npc_path)
	if npc:
		npc.become_impatient()
	_show_message("SOMEONE IN THE WAITING ROOM AUDIBLY SIGHS.")

func _launch_minigame(minigame_id: String):
	if minigame_id != "hemorrhoid_prevention" or _active_minigame:
		return
	GameState.begin_minigame()
	_active_minigame = HEMORRHOID_MINIGAME.instantiate()
	add_child(_active_minigame)
	_active_minigame.minigame_finished.connect(_finish_minigame)
	get_tree().paused = true

func _finish_minigame(minigame_id: String, risk: float, result: String):
	get_tree().paused = false
	_active_minigame.queue_free()
	_active_minigame = null
	var score = clampf(100.0 - risk, 0.0, 100.0)
	GameState.record_minigame_result(minigame_id, score, result)
	GameState.set_flag("hemorrhoid_game_completed", true)
	if result == "LOW RISK":
		GameState.add_certification("low_hemorrhoid_risk")
		GameState.add_item("dmv_seat_cushion_coupon")
		GameState.modify_stat("posterior_health", 10.0)
	else:
		if result == "HIGH RISK":
			GameState.set_flag("hemorrhoids_active", true)
			GameState.modify_stat("posterior_health", -25.0)
		else:
			GameState.modify_stat("posterior_health", -8.0)
	GameState.finish_minigame(minigame_id)
	_show_message("MINIGAME COMPLETE: %s. THE DMV CONTINUES." % result)

func _show_message(text: String):
	message_label.text = text
	_message_time = 5.0

func _perform_ambient_action(npc_path: NodePath, action: String):
	var npc = get_node_or_null(npc_path)
	if npc and npc.has_method("perform_ambient_action"):
		npc.perform_ambient_action(action)

func _start_engagement(npc_path: NodePath, engagement_id: String):
	var npc = get_node_or_null(npc_path)
	if npc == null:
		return

	if engagement_id == "insurance_story":
		_engagement_active = true
		_engagement_npc = npc
		_engagement_id = engagement_id

		if npc.has_method("start_engagement"):
			npc.start_engagement()

		message_label.text = "DAVE: \"You ever have an insurance deductible that's technically your deductible, but then there's a separate deductible for the windshield?\""
		_message_time = 0.0
		prompt_label.text = "[1] LISTEN     [2] POLITELY DISENGAGE"

func _resolve_engagement(listened: bool):
	if not _engagement_active:
		return

	_engagement_active = false

	if listened:
		GameState.set_flag("insurance_story_heard", true)
		_show_message("DAVE EXPLAINS THE ENTIRE INSURANCE DEDUCTIBLE SITUATION.")
		prompt_label.text = ""
	else:
		_show_message("DAVE: \"Yeah. No, I get it.\"")
		prompt_label.text = ""

	_engagement_npc = null
	_engagement_id = ""

# Lightweight development shortcuts. They are intentionally not part of the
# player-facing HUD: F5 saves the singleton state and F9 reloads it.
func _unhandled_key_input(event):
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F5:
		_show_message("SAVE %s." % ("COMPLETE" if GameState.save_game() else "FAILED"))
	elif event.keycode == KEY_F9:
		_show_message("LOAD %s." % ("COMPLETE" if GameState.load_game() else "FAILED"))
