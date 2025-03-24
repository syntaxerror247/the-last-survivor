extends Node

const GAME_SCENE: PackedScene = preload("res://scenes/game.tscn")
const INTRO_SCENE: PackedScene = preload("res://scenes/intro.tscn")

@onready var rain_effect: CPUParticles2D = $CanvasLayer/rain
@onready var rain_sound: AudioStreamPlayer = $RainSound
@onready var objective_label: Label = $CanvasLayer/objective_label
@onready var game_menu: Control = $CanvasLayer/GameMenu
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()

func intro_over() -> void:
	rain_effect.emitting = true
	rain_sound.play()
	await get_tree().create_timer(2.0).timeout

	var game_instance: Node = GAME_SCENE.instantiate()
	game_instance.background = $Background
	add_child(game_instance)

	var intro_scene_ref: Node = $Intro
	game_instance.player.global_position = intro_scene_ref.player.global_position
	game_instance.start(intro_scene_ref.player.global_position, intro_scene_ref.fire_wizard_positions)
	intro_scene_ref.queue_free()

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(objective_label, "modulate", Color8(255, 255, 255, 255), 1.0)
	tween.tween_callback(objective_label.queue_free.bind()).set_delay(1.0)

func _on_play_pressed() -> void:
	game_menu.queue_free()
	var intro = INTRO_SCENE.instantiate()
	intro.background = $Background
	add_child(intro)
	audio_player.play()

func _on_credits_pressed() -> void:
	$CanvasLayer/GameMenu/RichTextLabel.show()
	$CanvasLayer/GameMenu/close_credits.show()

func _on_close_credits_pressed() -> void:
	$CanvasLayer/GameMenu/RichTextLabel.hide()
	$CanvasLayer/GameMenu/close_credits.hide()


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
