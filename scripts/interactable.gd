class_name DMVInteractable
extends Area2D

## Reusable world object that Main can discover, prompt for, and activate.
signal interaction_requested(interactable)

@export var interaction_id := ""
@export var display_name := ""
@export_multiline var response_text := ""

func _ready():
	add_to_group("dmv_interactables")

func interact():
	interaction_requested.emit(self)
