extends CharacterBody2D

@export var speed: float = 80.0  # Movement speed
@onready var extinguish_timer: Timer = $Timer  # Timer for extinguishing torches

var target_torch: Node2D = null
var near_torch = false  # Track if the hooded guy is near a torch

func _ready():
	find_target_torch()
	extinguish_timer.wait_time = 1.0  # Time to reduce health
	extinguish_timer.one_shot = true  # Only triggers once per torch
	add_to_group("HoodedGuys")

func _process(delta):
	if get_parent().creating_fire_string:
		die()
	if target_torch and target_torch.is_burning:
		move_toward_torch(delta)
	else:
		find_target_torch()

func move_toward_torch(delta):
	var direction = (target_torch.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func find_target_torch():
	extinguish_timer.stop()  # Stop timer when switching torches
	near_torch = false  # Reset status
	var torches = get_tree().get_nodes_in_group("LitTorches")
	if torches.size() > 0:
		torches.sort_custom(func(a, b): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
		target_torch = torches.front()
	else:
		die()

func die() -> void:
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func _on_timer_timeout() -> void:
	if near_torch and target_torch and is_instance_valid(target_torch):
		target_torch.reduce_health()
		if target_torch.health > 0:
			extinguish_timer.start()  # Restart only if still near
		else:
			find_target_torch()  # Look for a new torch

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		die()
	elif body.is_in_group("LitTorches"):
		if target_torch != body:  # Prevent duplicate triggers
			target_torch = body
		near_torch = true
		extinguish_timer.start()  # Start the timer only when entering

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == target_torch:
		extinguish_timer.stop()
		near_torch = false
