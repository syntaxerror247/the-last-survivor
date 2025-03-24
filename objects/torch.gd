extends StaticBody2D

@onready var blast_animation: AnimatedSprite2D = $blast
@onready var burn_sound: AudioStreamPlayer2D = $burn
@onready var fire_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light: PointLight2D = $PointLight2D
@onready var detection_area: Area2D = $Area2D
@onready var extinguish_sound: AudioStreamPlayer2D = $extinguish

var is_burning = false

var health = 4

func _on_area_2d_body_entered(body: Node2D) -> void:
	if get_parent().creating_fire_string:
		return
	if body.name == "Player":
		blast_animation.play("default")
		burn_sound.play()

func _on_blast_frame_changed() -> void:
	if blast_animation.frame == 3:
		fire_sprite.play("burning")
		point_light.enabled = true
		detection_area.monitoring = false
		add_to_group("LitTorches")
		is_burning = true
		health = 6
		get_parent().update_torch_status(true, global_position)
		get_parent().spawn_hooded_guy()

func unlit_flame() -> void:
	fire_sprite.play("empty")
	point_light.enabled = false
	detection_area.monitoring = true
	extinguish_sound.play()
	remove_from_group("LitTorches")
	is_burning = false
	get_parent().update_torch_status(false, global_position)

func reduce_health() -> void:
	if health > 0:
		health -= 1
		if health == 0:
			unlit_flame()
