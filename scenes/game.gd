extends Node2D

@onready var fire_line: Line2D = $FireLine
@onready var player: CharacterBody2D = $Player
@onready var dialog_box: Control = $CanvasLayer/DialogBox
@onready var restart_button: Button = $CanvasLayer/RestartButton

var background: TextureRect

var hooded_guy_node = preload("res://characters/hooded_guy.tscn")

var torches: Array[Vector2] = []
var required_positions: Array[Vector2] = []

var tween: Tween
const POINTS_PER_SEGMENT: int = 10
const DRAW_SPEED: float = 0.05
var attempt_count: int = 0

var creating_fire_string: bool = false

const DIALOGUE_ATTEMPTS: Array = [
	[
		{"name": "Player", "text": "No... No, no, no! This can't be happening!"},
		{"name": "Player", "text": "There has to be a way... A pattern... Something I’m missing!"},
	],
	[
		{"name": "Player", "text": "Not again... Why does this keep happening?!"},
		{"name": "Player", "text": "It’s like I’m trapped in an endless loop..."},
	],
	[
		{"name": "Player", "text": "Every time, the same result..."},
		{"name": "Player", "text": "What am I overlooking? There must be a way out..."},
	]
]

var current_dialog_index: int = 0

func _ready() -> void:
	dialog_box.hide()
	restart_button.hide()

func start(position: Vector2, fire_wizard_positions: Array[Vector2]) -> void:
	player.position = position
	required_positions = fire_wizard_positions
	dialog_box.hide()
	restart_button.hide()
	tween = get_tree().create_tween()
	tween.tween_property(background, "modulate", Color8(25,25,25,255), 1).from(Color.BLACK)

func create_fire_string() -> void:
	creating_fire_string = true
	tween = get_tree().create_tween()
	tween.set_parallel(false)
	
	for i in range(torches.size()):
		animate_segment(torches[i], torches[(i + 1) % torches.size()])
	
	await tween.finished
	await get_tree().create_timer(1).timeout
	
	if torches == required_positions:
		$CanvasLayer/DialogBox.show()
		animate_text("Player", "I finally did it!", 0.05 ,player_won)
	else:
		handle_loss()

func animate_segment(start_pos: Vector2, end_pos: Vector2) -> void:
	for j in range(POINTS_PER_SEGMENT + 1):
		var t: float = float(j) / POINTS_PER_SEGMENT
		var interpolated_pos: Vector2 = start_pos.lerp(end_pos, t)
		tween.tween_callback(add_fire_point.bind(interpolated_pos))
		tween.tween_interval(DRAW_SPEED)

func add_fire_point(pos: Vector2) -> void:
	fire_line.add_point(pos)

func update_torch_status(is_burning: bool, position: Vector2) -> void:
	if is_burning:
		torches.append(position)
	else:
		torches.erase(position)
	
	if torches.size() == 5:
		fire_line.clear_points()
		create_fire_string()

func player_won() -> void:
	$CanvasLayer/Label.show()
	$CanvasLayer/RestartButton.text = "MainMenu"
	$CanvasLayer/RestartButton.show()

func handle_loss() -> void:
	dialog_box.hide()
	
	for torch in get_children():
		if not torch:
			continue
		if torch.name.begins_with("Torch"):
			torch.unlit_flame()
			await get_tree().create_timer(0.3).timeout
	torches.clear()
	fire_line.clear_points()
	creating_fire_string = false
	
	await get_tree().create_timer(1).timeout
	
	if attempt_count >= 2:
		restart_button.show()
	
	dialog_box.show()
	current_dialog_index = 0
	display_loss_dialogue()
	$Timer.stop()

func display_loss_dialogue() -> void:
	var dialogues = DIALOGUE_ATTEMPTS[min(attempt_count, DIALOGUE_ATTEMPTS.size() - 1)]
	
	if current_dialog_index < dialogues.size():
		var data = dialogues[current_dialog_index]
		animate_text(data["name"], data["text"], 0.05, display_loss_dialogue)
		current_dialog_index += 1
	else:
		await get_tree().create_timer(2).timeout
		dialog_box.hide()
		$Timer.start()
		attempt_count += 1

func animate_text(name: String, text: String, speed: float, callback: Callable = Callable()) -> void:
	tween = get_tree().create_tween()
	dialog_box.text = ""
	
	for i in range(text.length()):
		tween.tween_callback(_set_dialog_text.bind(text.substr(0, i + 1), name))
		tween.tween_interval(speed)
	
	if callback.is_valid():
		tween.tween_callback(callback)

func _set_dialog_text(new_text: String, name: String) -> void:
	dialog_box.text = "%s :-  %s" % [name, new_text]


func spawn_hooded_guy() -> void:
	var node: CharacterBody2D = hooded_guy_node.instantiate()
	node.global_position = get_random_position()
	add_child(node)

func get_random_position() -> Vector2:
	var screen_size = get_viewport_rect().size  # Get screen dimensions
	var random_x = randf_range(0, screen_size.x)
	var random_y = randf_range(0, screen_size.y)
	return Vector2(random_x, random_y)

func _on_timer_timeout() -> void:
	if not get_tree().get_nodes_in_group("LitTorches").is_empty() and not creating_fire_string:
		spawn_hooded_guy()


func _on_restart_button_pressed() -> void:
	print("Restarting game...")
	attempt_count = 0
	get_tree().reload_current_scene()
