extends Node

## GameState is an autoload: one persistent node that exists across scene
## changes. It stores data and exposes safe APIs; room, ticket, event, and
## minigame scripts remain responsible for gameplay behavior.
##
## Beginner quick reference:
## - New item: GameState.add_item("pencil")
## - New certification: GameState.add_certification("shark_survivor")
## - New flag: GameState.set_flag("shark_defeated", true)
## - New stat: GameState.modify_stat("courage", 10)
## - Minigame result: GameState.record_minigame_result("id", score, "RESULT")
## - Persistence: GameState.save_game() / GameState.load_game()

signal phase_changed(new_phase: String)
signal wait_time_changed(waiting_minutes: float)
signal serving_number_changed(number: int)
signal dmv_announcement(text: String)

const SAVE_PATH := "user://dmv_simulator_save.json"
const GAME_VERSION := "0.2.1-architecture-1"

const PHASES := {
	"ARRIVAL": "ARRIVAL",
	"NORMAL_WAITING": "NORMAL_WAITING",
	"ABSURDITY": "ABSURDITY",
	"HALLUCINATION": "HALLUCINATION",
	"UNDER_DMV": "UNDER_DMV",
	"ESPIONAGE": "ESPIONAGE",
	"FINAL_LOOP": "FINAL_LOOP",
}

const LOCATIONS := {
	"DMV": "DMV",
	"MINIGAME": "MINIGAME",
	"UNDER_DMV": "UNDER_DMV",
	"ESPIONAGE": "ESPIONAGE",
}

# Six real seconds per simulated hour = ten simulated minutes per real second.
@export var simulated_minutes_per_real_second := 1.0
@export var service_number_interval_minutes := 60.0
@export var starting_hour := 9
@export var starting_minute := 0

# Logical state sections. Keep future state in the appropriate section instead
# of adding unrelated top-level variables to this singleton.
var session := {}
var dmv := {}
var player_stats := {}
var inventory := {}
var certifications := {}
var flags := {}
var minigame_records := {}
var npc_relationships := {}
var narrative := {}
var world := {}

var item_catalog := {}
var certification_catalog := {}
var _service_progress_minutes := 0.0

func _ready():
	reset_new_game()

func reset_new_game():
	session = {
		"game_version": GAME_VERSION,
		"new_game": true,
		"current_phase": PHASES.ARRIVAL,
		"current_location": LOCATIONS.DMV,
		"is_in_minigame": false,
		"game_over": false,
	}
	dmv = {
		"ticket_number": 0,
		"now_serving": 118,
		"has_ticket": false,
		"waiting_minutes": 0.0,
		"waiting_time_multiplier": 1.0,
		"service_completed": false,
		"triggered_events": {},
		"completed_minigames": {},
	}
	player_stats = _default_stats()
	item_catalog = _default_item_catalog()
	inventory = {}
	certification_catalog = _default_certification_catalog()
	certifications = {}
	flags = _default_flags()
	minigame_records = {"hemorrhoid_prevention": _new_minigame_record()}
	npc_relationships = {}
	narrative = {"chapter": "CHAPTER_1_DMV_WAITING", "major_flags": {}, "completed_events": {}}
	world = {
		"dmv_power_outage": false,
		"vending_machine_status": "working",
		"bathroom_status": "out_of_order",
		"under_dmv_access": false,
		"shark_status": "not_encountered",
	}
	_service_progress_minutes = 0.0
	serving_number_changed.emit(get_now_serving())
	wait_time_changed.emit(get_waiting_minutes())

func _process(delta):
	if get_current_phase() != PHASES.NORMAL_WAITING:
		return

	var speed_multiplier := 1.0

	if Input.is_action_pressed("stretch"):
		speed_multiplier = 10.0

	var minutes = (
		delta
		* simulated_minutes_per_real_second
		* float(dmv.waiting_time_multiplier)
		* speed_multiplier
	)

	advance_waiting_minutes(minutes)

func begin_waiting():
	set_phase(PHASES.NORMAL_WAITING)

func begin_minigame():
	session.is_in_minigame = true
	session.current_location = LOCATIONS.MINIGAME
	set_phase(PHASES.ABSURDITY)

func finish_minigame(minigame_id: String):
	dmv.completed_minigames[minigame_id] = true
	session.is_in_minigame = false
	session.current_location = LOCATIONS.DMV
	set_phase(PHASES.NORMAL_WAITING)

func mark_called():
	dmv.service_completed = true

func set_phase(new_phase: String):
	if session.current_phase == new_phase:
		return
	session.current_phase = new_phase
	phase_changed.emit(new_phase)

func get_current_phase() -> String:
	return str(session.current_phase)

func advance_waiting_minutes(minutes: float):
	if minutes <= 0.0:
		return
	dmv.waiting_minutes += minutes
	_service_progress_minutes += minutes
	wait_time_changed.emit(dmv.waiting_minutes)
	while _service_progress_minutes >= service_number_interval_minutes:
		_service_progress_minutes -= service_number_interval_minutes
		dmv.now_serving += 1
		serving_number_changed.emit(dmv.now_serving)
		dmv_announcement.emit("ATTENTION: NOW SERVING %03d. THANK YOU FOR YOUR PATIENCE." % dmv.now_serving)

func get_waiting_minutes() -> float:
	return float(dmv.waiting_minutes)

func get_wait_time_text() -> String:
	var total_minutes = starting_hour * 60 + starting_minute + int(get_waiting_minutes())
	var hour_24 = (total_minutes / 60) % 24
	var minute = total_minutes % 60
	var suffix = "AM" if hour_24 < 12 else "PM"
	var hour_12 = hour_24 % 12
	if hour_12 == 0:
		hour_12 = 12
	return "%d:%02d %s" % [hour_12, minute, suffix]

func get_now_serving() -> int:
	return int(dmv.now_serving)

func get_ticket_number() -> int:
	return int(dmv.ticket_number)

func assign_ticket(number: int):
	if not bool(dmv.has_ticket):
		dmv.ticket_number = number
		dmv.has_ticket = true
		begin_waiting()

func has_ticket() -> bool:
	return bool(dmv.has_ticket)

func mark_event_triggered(event_id: String):
	dmv.triggered_events[event_id] = true
	narrative.completed_events[event_id] = true

func has_triggered(event_id: String) -> bool:
	return dmv.triggered_events.has(event_id)

# Stats are numeric 0-100. Higher is generally better for skills/health and
# patience; higher is generally worse for hunger, fatigue, pressure, weirdness,
# hallucination, and sleep deprivation. Callers use these accessors only.
func get_stat(stat_id: String) -> float:
	return float(player_stats.get(stat_id, 0.0))

func set_stat(stat_id: String, value: float):
	player_stats[stat_id] = clampf(value, 0.0, 100.0)

func modify_stat(stat_id: String, amount: float):
	set_stat(stat_id, get_stat(stat_id) + amount)

# Items are stored by ID. New IDs receive a safe generic definition, so future
# content can add an item without changing this singleton's structure.
func add_item(item_id: String, quantity := 1, definition := {}):
	if quantity <= 0:
		return
	if not item_catalog.has(item_id):
		item_catalog[item_id] = _item_definition(item_id, definition)
	var item = inventory.get(item_id, _item_definition(item_id, item_catalog[item_id]))
	if bool(item.is_unique):
		item.quantity = 1
	else:
		item.quantity = int(item.quantity) + quantity
	inventory[item_id] = item

func remove_item(item_id: String, quantity := 1) -> bool:
	if not inventory.has(item_id) or quantity <= 0:
		return false
	var item = inventory[item_id]
	if int(item.quantity) < quantity:
		return false
	item.quantity = int(item.quantity) - quantity
	if int(item.quantity) <= 0:
		inventory.erase(item_id)
	else:
		inventory[item_id] = item
	return true

func has_item(item_id: String) -> bool:
	return get_item_quantity(item_id) > 0

func get_item_quantity(item_id: String) -> int:
	return int(inventory.get(item_id, {}).get("quantity", 0))

func add_certification(certification_id: String):
	certifications[certification_id] = true

func remove_certification(certification_id: String):
	certifications.erase(certification_id)

func has_certification(certification_id: String) -> bool:
	return bool(certifications.get(certification_id, false))

func get_flag(flag_id: String) -> bool:
	return bool(flags.get(flag_id, false))

func set_flag(flag_id: String, value := true):
	flags[flag_id] = value

func has_flag(flag_id: String) -> bool:
	return get_flag(flag_id)

func record_minigame_result(minigame_id: String, score: float, result: String):
	var record = minigame_records.get(minigame_id, _new_minigame_record())
	record.completed = true
	record.attempts = int(record.attempts) + 1
	record.last_score = score
	record.best_score = maxf(float(record.best_score), score)
	record.result = result
	minigame_records[minigame_id] = record

func get_minigame_record(minigame_id: String) -> Dictionary:
	return minigame_records.get(minigame_id, _new_minigame_record()).duplicate(true)

func get_relationship(npc_id: String) -> Dictionary:
	if not npc_relationships.has(npc_id):
		npc_relationships[npc_id] = {"affinity": 0, "flags": {}}
	return npc_relationships[npc_id]

func set_relationship_affinity(npc_id: String, affinity: int):
	var relationship = get_relationship(npc_id)
	relationship.affinity = clampi(affinity, -100, 100)
	npc_relationships[npc_id] = relationship

func save_game() -> bool:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open GameState save file.")
		return false
	file.store_string(JSON.stringify(_to_save_data(), "\t"))
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("GameState save file is invalid JSON.")
		return false
	_apply_save_data(parsed)
	serving_number_changed.emit(get_now_serving())
	wait_time_changed.emit(get_waiting_minutes())
	return true

func _to_save_data() -> Dictionary:
	return {
		"session": session, "dmv": dmv, "player_stats": player_stats,
		"inventory": inventory, "certifications": certifications, "flags": flags,
		"minigame_records": minigame_records, "npc_relationships": npc_relationships,
		"narrative": narrative, "world": world,
		"item_catalog": item_catalog, "certification_catalog": certification_catalog,
		"service_progress_minutes": _service_progress_minutes,
	}

func _apply_save_data(data: Dictionary):
	session = data.get("session", session)
	dmv = data.get("dmv", dmv)
	player_stats = data.get("player_stats", player_stats)
	inventory = data.get("inventory", inventory)
	certifications = data.get("certifications", certifications)
	flags = data.get("flags", flags)
	minigame_records = data.get("minigame_records", minigame_records)
	npc_relationships = data.get("npc_relationships", npc_relationships)
	narrative = data.get("narrative", narrative)
	world = data.get("world", world)
	item_catalog = data.get("item_catalog", item_catalog)
	certification_catalog = data.get("certification_catalog", certification_catalog)
	_service_progress_minutes = float(data.get("service_progress_minutes", 0.0))

func _new_minigame_record() -> Dictionary:
	return {"completed": false, "attempts": 0, "best_score": 0.0, "last_score": 0.0, "result": ""}

func _item_definition(item_id: String, override := {}) -> Dictionary:
	return {
		"id": item_id,
		"display_name": override.get("display_name", item_id.capitalize()),
		"description": override.get("description", "A bureaucratically significant item."),
		"quantity": 0,
		"is_unique": override.get("is_unique", false),
	}

func _default_item_catalog() -> Dictionary:
	return {
		"pencil": _item_definition("pencil", {"display_name": "Pencil", "description": "Barely sharpened."}),
		"stapler": _item_definition("stapler", {"display_name": "Stapler", "description": "Office-grade mechanical authority.", "is_unique": true}),
		"shark_repellent_bat_spray": _item_definition("shark_repellent_bat_spray", {"display_name": "Shark Repellent Bat Spray", "description": "For remarkably specific emergencies."}),
		"dmv_seat_cushion_coupon": _item_definition("dmv_seat_cushion_coupon", {"display_name": "DMV Seat Cushion Coupon", "description": "Redeemable in a better world."}),
		"couples_therapy_worksheet": _item_definition("couples_therapy_worksheet", {"display_name": "Couples Therapy Worksheet", "description": "Please use indoor voices."}),
		"preparation_h": _item_definition("preparation_h", {"display_name": "Preparation H", "description": "A very practical prize."}),
	}

func _default_certification_catalog() -> Dictionary:
	return {"low_hemorrhoid_risk": true, "amateur_couples_mediator": true, "shark_survivor": true, "bureaucratic_competence": true, "office_equipment_technician": true, "underdmv_initiate": true}

func _default_flags() -> Dictionary:
	return {"hemorrhoid_game_completed": false, "hemorrhoids_active": false, "couple_reconciled": false, "couple_escalated": false, "shark_encountered": false, "vending_machine_shaken": false, "vending_machine_knowledge": false, "shark_defeated": false, "stapler_repaired": false, "under_dmv_discovered": false}

func _default_stats() -> Dictionary:
	return {"emotional_health": 100.0, "posterior_health": 100.0, "hunger": 0.0, "sleep_deprivation": 0.0, "combat_confidence": 0.0, "rhythm_score": 0.0, "diplomacy": 0.0, "bureaucratic_competence": 0.0, "perception": 0.0, "driving_skill": 0.0, "pattern_recognition": 0.0, "bladder_pressure": 0.0, "attention_span": 100.0, "digital_literacy": 0.0, "patience": 100.0, "comfort": 0.0, "observation": 0.0, "auditory_attention": 0.0, "bureaucracy_alignment": 0.0, "physical_fatigue": 0.0, "mechanical_skill": 0.0, "emotional_regulation": 0.0, "weirdness": 0.0, "courage": 0.0, "hallucination": 0.0}
