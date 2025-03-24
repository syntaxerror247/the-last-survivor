extends Node2D

@onready var dialog_box: Label = $CanvasLayer/DialogBox
@onready var player: CharacterBody2D = $Player

var background: TextureRect

var fire_wizard_nodes: Array[Node] = []  # Stores randomized FireWizard nodes
var fire_wizard_positions: Array[Vector2] = []  # Stores positions of chosen wizards


const CONVERSATION: Array[Dictionary] = [
	{"name": "Agni", "text": "The hooded ones grow stronger..."},
	{"name": "Tejas", "text": "They have already captured almost all of us..."},
	{"name": "Vahni", "text": "You are the last one left, little flame..."},
	{"name": "Jwala", "text": "You must find a way to rekindle our spirits..."},
	{"name": "Pralay", "text": "Time is running out! Save the fire, or we will fade forever!"}
]

var current_speaker: int = 0
var tween: Tween

func _ready() -> void:
	_randomize_wizards()
	await get_tree().create_timer(1.0).timeout
	_start_intro()

func _randomize_wizards():
	fire_wizard_nodes = get_children().filter(func(node): return node.name.begins_with("FireWizard"))
	fire_wizard_nodes.shuffle()  # Shuffle wizards before selecting
	
	for wizard in fire_wizard_nodes:
		fire_wizard_positions.append(wizard.global_position)

func _start_intro() -> void:
	if current_speaker < CONVERSATION.size():
		_switch_wizard()
		var dialogue = CONVERSATION[current_speaker]
		_animate_text(dialogue["name"], dialogue["text"], 0.09)
	else:
		_end_intro()

func _switch_wizard() -> void:
	if current_speaker > 0:
		tween = get_tree().create_tween()
		tween.tween_property(fire_wizard_nodes[current_speaker - 1], "scale", Vector2.ZERO, 0.5)
	
	if current_speaker < fire_wizard_nodes.size():
		fire_wizard_nodes[current_speaker].scale = Vector2(0.4, 0.4)
		$Player/AnimatedSprite2D.flip_h = fire_wizard_nodes[current_speaker].global_position.x > $Player.global_position.x

func _animate_text(speaker_name: String, full_text: String, speed: float) -> void:
	tween = get_tree().create_tween()
	dialog_box.text = ""
	
	for i in range(full_text.length()):
		tween.tween_callback(_set_text.bind(full_text.substr(0, i + 1), speaker_name))
		tween.tween_interval(speed)
	
	tween.tween_callback(_advance_dialogue)

func _set_text(new_text: String, speaker_name: String) -> void:
	dialog_box.text = "%s :-  %s" % [speaker_name, new_text]

func _advance_dialogue() -> void:
	current_speaker += 1
	_start_intro()

func _end_intro() -> void:
	tween = get_tree().create_tween()
	tween.tween_property(fire_wizard_nodes[current_speaker - 1], "scale", Vector2.ZERO, 0.5)
	dialog_box.hide()
	tween.tween_property(background, "modulate", Color.BLACK, 0.5)
	get_parent().intro_over()
