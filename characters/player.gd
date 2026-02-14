extends CharacterBody2D

const SPEED := 180.0
const ACCEL := 1200.0
const JOYSTICK_RADIUS := 70.0
const DEADZONE := 10.0

var touch_direction := Vector2.ZERO
var touch_id := -1
var joystick_origin := Vector2.ZERO
var current_touch_pos := Vector2.ZERO

@onready var sprite := $AnimatedSprite2D


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1:
			touch_id = event.index
			joystick_origin = event.position
			current_touch_pos = event.position
			queue_redraw()
		elif not event.pressed and event.index == touch_id:
			touch_id = -1
			touch_direction = Vector2.ZERO
			queue_redraw()

	elif event is InputEventScreenDrag and event.index == touch_id:
		current_touch_pos = event.position
		var drag := current_touch_pos - joystick_origin
		var distance := drag.length()
		if distance < DEADZONE:
			touch_direction = Vector2.ZERO
		else:
			touch_direction = drag.limit_length(JOYSTICK_RADIUS) / JOYSTICK_RADIUS
		queue_redraw()


func _physics_process(delta: float) -> void:
	var kb_direction := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

	var input_direction := touch_direction if touch_id != -1 else kb_direction

	var target_velocity := input_direction * SPEED
	velocity = velocity.move_toward(target_velocity, ACCEL * delta)

	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

	move_and_slide()
	check_screen_wrap()


func check_screen_wrap():
	var screen_size = get_viewport_rect().size

	if position.x < 0:
		position.x = screen_size.x
	elif position.x > screen_size.x:
		position.x = 0

	if position.y < 0:
		position.y = screen_size.y
	elif position.y > screen_size.y:
		position.y = 0
