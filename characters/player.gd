extends CharacterBody2D

const SPEED := 180.0

@onready var sprite := $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	
	velocity = direction * SPEED if direction != Vector2.ZERO else velocity.move_toward(Vector2.ZERO, SPEED)
	
	if direction.x != 0:
		sprite.flip_h = direction.x > 0
	
	move_and_slide()
	check_screen_wrap()

func check_screen_wrap():
	var screen_size = get_viewport_rect().size

	# Wrap horizontally
	if position.x < 0:
		position.x = screen_size.x
	elif position.x > screen_size.x:
		position.x = 0

	# Wrap vertically
	if position.y < 0:
		position.y = screen_size.y
	elif position.y > screen_size.y:
		position.y = 0
