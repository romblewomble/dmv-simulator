class_name WaitingNPC
extends Node2D

signal interaction_requested(npc)

@export var display_name := "WAITING"
@export var shirt_color := Color("758b78")
@export var idle_style := 0
@export_multiline var dialogue_text := "The line has been here longer than I have."

var interaction_id := "npc"
var response_text := ""
var _time := 0.0
var _base_position := Vector2.ZERO
var _impatient := false
var _phone_active := false
var _phone_timer := 0.0
var _ambient_action := ""
var _ambient_action_time := 0.0
var _engagement_active := false
var _engagement_timer := 0.0

func _ready():
	_base_position = position
	add_to_group("dmv_interactables")
	queue_redraw()

func interact():
	interaction_requested.emit(self)

func become_impatient():
	_impatient = true
	idle_style = 3
	queue_redraw()

func raise_phone(duration := 8.0):
	_phone_active = true
	_phone_timer = duration
	queue_redraw()

func perform_ambient_action(action := "look_at_phone"):
	_ambient_action = action
	_ambient_action_time = 1.5

	if action == "look_at_phone":
		raise_phone(1.5)

	queue_redraw()

func start_engagement(duration := 4.0):
	_engagement_active = true
	_engagement_timer = duration
	queue_redraw()

func _process(delta):
	_time += delta

	if _phone_active:
		_phone_timer -= delta
		if _phone_timer <= 0.0:
			_phone_active = false
			queue_redraw()

	if _engagement_active:
		_engagement_timer -= delta
		if _engagement_timer <= 0.0:
			_engagement_active = false
			queue_redraw()

	if idle_style == 1:
		position.y = _base_position.y + sin(_time * 1.8) * 3.0
	elif idle_style == 2:
		rotation = sin(_time * 0.8) * 0.035
	elif idle_style == 3:
		position.x = _base_position.x + sin(_time * (2.6 if _impatient else 0.55)) * (9.0 if _impatient else 5.0)

	queue_redraw()

func _draw():
	draw_circle(Vector2(0, -13), 7.0, Color("e1b28c"))
	draw_rect(Rect2(-9, -5, 18, 18), Color("a34338") if _impatient else shirt_color, true)
	draw_rect(Rect2(-8, 13, 6, 7), Color("3c4652"), true)
	draw_rect(Rect2(2, 13, 6, 7), Color("3c4652"), true)

	if _impatient:
		draw_string(ThemeDB.fallback_font, Vector2(-18, -29), "...", HORIZONTAL_ALIGNMENT_CENTER, 36, 15, Color("ffdc6b"))

	if _phone_active:
		draw_rect(Rect2(5, -10, 16, 24), Color.WHITE, true)
		draw_rect(Rect2(7, -8, 12, 18), Color.BLACK, true)

	if _engagement_active:
		draw_circle(Vector2(15, -18), 3.0, Color("ffdc6b"))

	draw_string(ThemeDB.fallback_font, Vector2(-50, 34), display_name, HORIZONTAL_ALIGNMENT_CENTER, 100, 10, Color("d9d6c9"))
