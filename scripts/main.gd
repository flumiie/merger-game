extends Node2D

@onready var marker_left = $"Marker Left"
@onready var marker_right = $"Marker Right"
@onready var marker_next_object = $"Marker Next Object"
@onready var marker_full = $"Marker Full"
@onready var game_over_grid_container = $Canvas/GridContainer

var obj_scene := preload("res://ui/object.tscn")
var current_object
var next_object
var is_game_over = false

func _ready() -> void:
	current_object = create_object((marker_left.global_position + marker_right.global_position) / 2)
	next_object = create_object(marker_next_object.global_position)
	SignalBus.container_full.connect(on_game_over)

func _physics_process(delta: float) -> void:
	if is_game_over:
		return

	if current_object != null:
		# Object to unfollow the cursor on drop
		if current_object.gravity_scale == 0:
			var object_pos_x = get_object_x_position()
			current_object.global_position.x = object_pos_x
			current_object.global_position.y = marker_left.global_position.y
		if Input.is_action_just_pressed("drop"):
			drop_object()

func create_object(position):
	var new_obj = obj_scene.instantiate()
	new_obj.disable_physics()
	new_obj.global_position = position
	new_obj.size = randi_range(1, 5)
	add_child(new_obj)
	return new_obj

func get_object_x_position():
	return clamp(
		get_global_mouse_position().x,
		marker_left.global_position.x,
		marker_right.global_position.x
	)

func drop_object():
	current_object.enable_physics()
	# To prevent spawning spam, set it to null,
	# then check it on _physics_process
	current_object = null
	await get_tree().create_timer(0.5).timeout
	current_object = next_object
	next_object = create_object(marker_next_object.global_position)

func on_game_over(height: float):
	if height <= marker_full.global_position.y:
		is_game_over = true
		game_over_grid_container.visible = true

func _on_button_pressed():
	get_tree().reload_current_scene()

