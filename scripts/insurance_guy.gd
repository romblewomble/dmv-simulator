class_name InsuranceGuy
extends WaitingNPC

## A deliberately small authored routine proof. This node owns choreography;
## GameState owns its serialized loop snapshot.
signal authored_message(text: String)

const NPC_ID := "insurance_guy"
const PACE_A := "PACE_A"
const WAIT_A := "WAIT_A"
const PACE_B := "PACE_B"
const WAIT_B := "WAIT_B"
const INTERRUPTED := "INTERRUPTED"
const CONSEQUENCE := "CONSEQUENCE"

@export var pace_point_a := Vector2(-325.0, 40.0)
@export var pace_point_b := Vector2(-470.0, 40.0)
@export var pace_speed := 72.0
@export var stop_seconds := 1.5
@export var interruption_seconds := 2.5
@export var consequence_delay_seconds := 4.0
@export var consequence_pause_seconds := 2.5

var routine_state := PACE_A
var wait_remaining := 0.0
var interruption_active := false
var interruption_remaining := 0.0
var interrupted_this_loop := false
var consequence_pending := false
var consequence_completed := false
var consequence_delay_remaining := 0.0
var consequence_pause_remaining := 0.0
var _suspended_routine := {}
var _consequence_resume := {}

func _ready():
	display_name = "INSURANCE GUY"
	shirt_color = Color("9aa9bd")
	dialogue_text = "He is attempting to remain polite to an insurance company."
	interaction_id = "insurance_guy"
	super._ready()
	GameState.game_loaded.connect(_restore_from_game_state)
	GameState.loop_reset.connect(_reset_to_baseline)
	_phone_active = true
	_phone_timer = 360000.0
	var saved := GameState.get_loop_npc_state(NPC_ID)
	if saved.is_empty():
		_reset_to_baseline()
	else:
		_apply_state(saved)

func _process(delta):
	super._process(delta)
	# Main pauses the tree for minigames. This guard also makes direct calls in
	# focused tests obey the same rule.
	if bool(GameState.session.get("is_in_minigame", false)):
		return
	_advance_authored_state(delta)
	_store_state()

func interact():
	interaction_requested.emit(self)

func begin_player_interruption() -> bool:
	if interruption_active or routine_state == CONSEQUENCE:
		return false
	_suspended_routine = _capture_routine_progress()
	interruption_active = true
	interruption_remaining = interruption_seconds
	routine_state = INTERRUPTED
	authored_message.emit("INSURANCE GUY: \"Sorry—one second. They may finally be transferring me.\"")
	_store_state()
	return true

func get_debug_state() -> Dictionary:
	return _capture_state()

func _advance_authored_state(delta: float):
	if interruption_active:
		interruption_remaining = maxf(0.0, interruption_remaining - delta)
		if interruption_remaining <= 0.0:
			_finish_interruption()
		return

	if routine_state == CONSEQUENCE:
		consequence_pause_remaining = maxf(0.0, consequence_pause_remaining - delta)
		if consequence_pause_remaining <= 0.0:
			_restore_routine_progress(_consequence_resume)
		return

	_advance_routine(delta)

	if consequence_pending:
		consequence_delay_remaining = maxf(0.0, consequence_delay_remaining - delta)
		if consequence_delay_remaining <= 0.0:
			_begin_consequence()

func _advance_routine(delta: float):
	match routine_state:
		PACE_A:
			_move_toward(pace_point_a, delta, WAIT_A)
		PACE_B:
			_move_toward(pace_point_b, delta, WAIT_B)
		WAIT_A:
			wait_remaining = maxf(0.0, wait_remaining - delta)
			if wait_remaining <= 0.0:
				routine_state = PACE_B
		WAIT_B:
			wait_remaining = maxf(0.0, wait_remaining - delta)
			if wait_remaining <= 0.0:
				routine_state = PACE_A
		_:
			routine_state = PACE_A

func _move_toward(destination: Vector2, delta: float, arrival_state: String):
	position = position.move_toward(destination, pace_speed * delta)
	if position.is_equal_approx(destination):
		position = destination
		routine_state = arrival_state
		wait_remaining = stop_seconds

func _finish_interruption():
	interruption_active = false
	interruption_remaining = 0.0
	interrupted_this_loop = true
	consequence_pending = true
	consequence_delay_remaining = consequence_delay_seconds
	_restore_routine_progress(_suspended_routine)
	authored_message.emit("INSURANCE GUY: \"Thank you. I have resumed being on hold.\"")

func _begin_consequence():
	_consequence_resume = _capture_routine_progress()
	consequence_pending = false
	consequence_completed = true
	consequence_pause_remaining = consequence_pause_seconds
	routine_state = CONSEQUENCE
	authored_message.emit("INSURANCE GUY: \"Wait—it disconnected. Right. So I just start over?\"")

func _capture_routine_progress() -> Dictionary:
	return {
		"routine_state": routine_state,
		"wait_remaining": wait_remaining,
	}

func _restore_routine_progress(progress: Dictionary):
	routine_state = str(progress.get("routine_state", PACE_A))
	wait_remaining = float(progress.get("wait_remaining", 0.0))

func _capture_state() -> Dictionary:
	return {
		"position": [position.x, position.y],
		"routine_state": routine_state,
		"wait_remaining": wait_remaining,
		"interruption_active": interruption_active,
		"interruption_remaining": interruption_remaining,
		"interrupted_this_loop": interrupted_this_loop,
		"consequence_pending": consequence_pending,
		"consequence_completed": consequence_completed,
		"consequence_delay_remaining": consequence_delay_remaining,
		"consequence_pause_remaining": consequence_pause_remaining,
		"suspended_routine": _suspended_routine.duplicate(true),
		"consequence_resume": _consequence_resume.duplicate(true),
		"phone_active": true,
	}

func _store_state():
	GameState.set_loop_npc_state(NPC_ID, _capture_state())

func _restore_from_game_state():
	var saved := GameState.get_loop_npc_state(NPC_ID)
	if saved.is_empty():
		_reset_to_baseline()
	else:
		_apply_state(saved)

func _apply_state(state: Dictionary):
	var saved_position: Array = state.get("position", [pace_point_b.x, pace_point_b.y])
	position = Vector2(float(saved_position[0]), float(saved_position[1]))
	routine_state = str(state.get("routine_state", PACE_A))
	wait_remaining = float(state.get("wait_remaining", 0.0))
	interruption_active = bool(state.get("interruption_active", false))
	interruption_remaining = float(state.get("interruption_remaining", 0.0))
	interrupted_this_loop = bool(state.get("interrupted_this_loop", false))
	consequence_pending = bool(state.get("consequence_pending", false))
	consequence_completed = bool(state.get("consequence_completed", false))
	consequence_delay_remaining = float(state.get("consequence_delay_remaining", 0.0))
	consequence_pause_remaining = float(state.get("consequence_pause_remaining", 0.0))
	_suspended_routine = state.get("suspended_routine", {}).duplicate(true)
	_consequence_resume = state.get("consequence_resume", {}).duplicate(true)
	_phone_active = true
	_phone_timer = 360000.0
	queue_redraw()

func _reset_to_baseline():
	position = pace_point_b
	routine_state = PACE_A
	wait_remaining = 0.0
	interruption_active = false
	interruption_remaining = 0.0
	interrupted_this_loop = false
	consequence_pending = false
	consequence_completed = false
	consequence_delay_remaining = 0.0
	consequence_pause_remaining = 0.0
	_suspended_routine = {}
	_consequence_resume = {}
	_phone_active = true
	_phone_timer = 360000.0
	_store_state()
	queue_redraw()
