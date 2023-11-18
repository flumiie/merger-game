extends RigidBody2D

var obj_scene = preload("res://ui/object.tscn")
@onready var collision = $Collision
var max_size = 10
var size = 1

func _ready() -> void:
	collision.shape.radius = size * 10
	mass = (size^2) * PI
	body_entered.connect(handle_merge_on_contact)

func _draw() -> void:
	var color = Color.from_hsv(float(size) / max_size, 1, 1)
	draw_circle(Vector2.ZERO, collision.shape.radius, color)

func handle_merge_on_contact(body):
	if is_queued_for_deletion() or not body.is_in_group("objects"):
		return
	
	var new_obj_position = (global_position + body.global_position) / 2
	SignalBus.container_full.emit(new_obj_position.y)
	
	if body.size != size:
		return

	body.queue_free()
	queue_free()

	if size < max_size:
		var obj = obj_scene.instantiate()
		obj.enable_physics()
		obj.global_position = new_obj_position
		obj.size = size + 1
		get_parent().add_child.call_deferred(obj)

	SignalBus.object_removed.emit(size)

func enable_physics():
	gravity_scale = 1
	collision_layer = 1
	collision_mask = 1

func disable_physics():
	gravity_scale = 0
	collision_layer = 0
	collision_mask = 0
