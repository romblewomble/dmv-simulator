extends Node

const MAIN_SCENE := preload("res://scenes/main.tscn")
const MINIGAME_SCENE := preload("res://scenes/hemorrhoid_minigame.tscn")
const TEST_SAVE_PATH := "/tmp/dmv_insurance_guy_test_save.json"

var _failures: Array[String] = []
var _consequence_messages := 0

func _ready():
	_run.call_deferred()

func _run():
	GameState.reset_new_game()
	var main = MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var insurance = main.get_node("World/InsuranceGuy")
	insurance.set_process(false)
	insurance.authored_message.connect(_on_insurance_message)

	var baseline: Dictionary = insurance.get_debug_state()
	_check(baseline.routine_state == "PACE_A", "baseline routine is PACE_A")
	_check(not baseline.interruption_active, "baseline has no active interruption")
	_check(not baseline.consequence_pending, "baseline has no pending consequence")
	_check(not baseline.consequence_completed, "baseline has no completed consequence")

	_advance(insurance, 1.0)
	var first_run: Dictionary = insurance.get_debug_state()
	GameState.reset_loop()
	_advance(insurance, 1.0)
	var second_run: Dictionary = insurance.get_debug_state()
	_check(_positions_match(first_run.position, second_run.position), "fresh loops reproduce position")
	_check(first_run.routine_state == second_run.routine_state, "fresh loops reproduce routine stage")
	GameState.reset_loop()
	var first_trace := _routine_trace(insurance, 8.0)
	GameState.reset_loop()
	var second_trace := _routine_trace(insurance, 8.0)
	_check(first_trace == second_trace, "deterministic routine transition order reproduces")

	GameState.reset_loop()
	_check(insurance.begin_player_interruption(), "ordinary interruption starts")
	_check(not insurance.begin_player_interruption(), "re-entrant interruption is rejected")
	_check(insurance.get_debug_state().interruption_active, "interruption state is explicit")
	_advance(insurance, 2.6)
	var post_interruption: Dictionary = insurance.get_debug_state()
	_check(post_interruption.interrupted_this_loop, "interruption result is loop-local")
	_check(post_interruption.consequence_pending, "authored consequence becomes pending")

	_advance(insurance, 1.1)
	GameState.advance_waiting_minutes(7.0)
	var saved_state: Dictionary = insurance.get_debug_state()
	var saved_time := GameState.get_waiting_minutes()
	_check(GameState.save_game(TEST_SAVE_PATH), "test save writes")

	_advance(insurance, 8.0)
	_check(insurance.get_debug_state().consequence_completed, "pending consequence completes")
	var emissions_before_load := _consequence_messages
	_check(GameState.load_game(TEST_SAVE_PATH), "test save loads")
	var loaded_state: Dictionary = insurance.get_debug_state()
	_check(_positions_match(saved_state.position, loaded_state.position), "load restores exact-enough position")
	_check(saved_state.routine_state == loaded_state.routine_state, "load restores routine stage")
	_check(is_equal_approx(saved_state.consequence_delay_remaining, loaded_state.consequence_delay_remaining), "load restores consequence progress")
	_check(is_equal_approx(saved_time, GameState.get_waiting_minutes()), "load restores loop time")
	_check(loaded_state.consequence_pending and not loaded_state.consequence_completed, "load restores pending consequence")

	_advance(insurance, 8.0)
	_check(insurance.get_debug_state().consequence_completed, "loaded consequence completes")
	_check(_consequence_messages == emissions_before_load + 1, "loaded consequence fires exactly once")
	_advance(insurance, 10.0)
	_check(_consequence_messages == emissions_before_load + 1, "completed consequence does not duplicate")

	GameState.add_certification("test_persistent_certification")
	GameState.reset_loop()
	var reset_state: Dictionary = insurance.get_debug_state()
	_check(reset_state.routine_state == "PACE_A", "loop reset restores baseline routine")
	_check(not reset_state.interrupted_this_loop, "loop reset clears interruption result")
	_check(not reset_state.consequence_pending and not reset_state.consequence_completed, "loop reset clears consequence state")
	_check(GameState.has_certification("test_persistent_certification"), "loop reset preserves persistent certification")

	var ticket_system = main.get_node("TicketSystem")
	var ticket: int = ticket_system.take_ticket()
	_check(GameState.has_ticket() and ticket >= ticket_system.ticket_min and ticket <= ticket_system.ticket_max, "ticket behavior remains functional")

	var player = main.get_node("Player")
	var player_start: Vector2 = player.position
	Input.action_press("ui_right")
	for frame in range(4):
		await get_tree().physics_frame
	Input.action_release("ui_right")
	_check(player.position.x > player_start.x, "player movement remains functional")

	var existing_npc = main.get_node("World/NPC2")
	existing_npc.set_process(false)
	var npc_start_y: float = existing_npc.position.y
	existing_npc._process(0.5)
	_check(not is_equal_approx(existing_npc.position.y, npc_start_y), "existing NPC idle behavior remains functional")

	var minigame = MINIGAME_SCENE.instantiate()
	get_tree().root.add_child(minigame)
	await get_tree().process_frame
	_check(minigame.get("risk") != null and minigame.get("elapsed") != null, "Hemorrhoid Prevention still instantiates")
	minigame.set_process(false)
	var risk_before: float = minigame.risk
	minigame._process(0.5)
	_check(minigame.risk > risk_before, "Hemorrhoid Prevention simulation still advances")
	minigame.queue_free()

	if _failures.is_empty():
		print("INSURANCE_GUY_TEST: PASS")
		get_tree().quit(0)
	else:
		for failure in _failures:
			push_error("INSURANCE_GUY_TEST: %s" % failure)
		get_tree().quit(1)

func _advance(insurance, seconds: float):
	var remaining := seconds
	while remaining > 0.0:
		var step := minf(0.1, remaining)
		insurance._process(step)
		remaining -= step

func _positions_match(a: Array, b: Array) -> bool:
	return Vector2(float(a[0]), float(a[1])).distance_to(Vector2(float(b[0]), float(b[1]))) < 0.01

func _routine_trace(insurance, seconds: float) -> Array[String]:
	var trace: Array[String] = []
	var elapsed := 0.0
	while elapsed < seconds:
		_advance(insurance, 0.5)
		elapsed += 0.5
		trace.append(str(insurance.get_debug_state().routine_state))
	return trace

func _on_insurance_message(text: String):
	if "disconnected" in text:
		_consequence_messages += 1

func _check(condition: bool, description: String):
	if not condition:
		_failures.append(description)
