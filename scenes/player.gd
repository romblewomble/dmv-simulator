extends CharacterBody2D

@export var speed := 250.0

# This temporary drawing keeps the player visible without requiring art assets.
func _draw():
	# Head, shirt, and little badge: intentionally simple for the prototype.
	draw_circle(Vector2(0, -12), 7.0, Color("f0c6a0"))
	draw_rect(Rect2(-9, -4, 18, 18), Color("385a79"), true)
	draw_rect(Rect2(-5, 1, 10, 4), Color("dbe7ea"), true)
	draw_circle(Vector2(-4, 16), 3.0, Color("293b4a"))
	draw_circle(Vector2(4, 16), 3.0, Color("293b4a"))

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
