class_name WaitingEventManager
extends Node

## Event definitions live here so future narrative beats can be added as data
## instead of becoming another timer in a room or minigame script.
signal announcement_requested(text: String)
signal npc_impatience_requested(npc_path: NodePath)
signal minigame_requested(minigame_id: String)
signal ambient_action_requested(npc_path: NodePath, action: String)
signal engagement_requested(npc_path: NodePath, engagement_id: String)

const EVENTS = [
	{
		"id": "golden_01_phone_check",
		"minutes": 1.0,
		"kind": "ambient",
		"npc": NodePath("World/NPC2"),
		"action": "look_at_phone"
	},
	{
		"id": "golden_02_insurance_story",
		"minutes": 3.0,
		"kind": "engagement",
		"npc": NodePath("World/NPC3"),
		"engagement": "insurance_story"
	},
	{
		"id": "golden_03_downtime",
		"minutes": 5.0,
		"kind": "announcement",
		"text": "YOU HAVE NOTHING URGENT TO DO."
	},
	{
		"id": "golden_04_mid_slice",
		"minutes": 7.0,
		"kind": "announcement",
		"text": "ATTENTION: PLEASE CONTINUE WAITING."
	},
	{
		"id": "golden_05_slice_end",
		"minutes": 10.0,
		"kind": "announcement",
		"text": "THE DMV THANKS YOU FOR YOUR PATIENCE."
	},
]

func _ready():
	GameState.wait_time_changed.connect(_on_wait_time_changed)

func _on_wait_time_changed(waiting_minutes: float):
	for event in EVENTS:
		if GameState.has_triggered(event.id):
			continue
		if waiting_minutes < event.minutes:
			continue
		GameState.mark_event_triggered(event.id)
		match event.kind:
			"announcement":
				announcement_requested.emit(event.text)
			"impatient_npc":
				npc_impatience_requested.emit(event.npc)
			"minigame":
				minigame_requested.emit(event.minigame)
			"ambient":
				ambient_action_requested.emit(event.npc, event.action)
			"engagement":
				engagement_requested.emit(event.npc, event.engagement)
