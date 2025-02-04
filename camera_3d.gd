extends Camera3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var grab_target: Node3D = $RayCast3D/GrabTarget

@export var charactor : CharacterBody3D

var mouse_position : Vector2

var grab_distance = 10
var grabbed_object = null

#Camera FOV / Zoom Level
var desiredFov = 70
var fovStep = 3
var maxFov = 75
var minFov = 25

var piece_slot_found = false
var piece_slot_position : Vector3
var previous_slot_position : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.set_piece_slot.connect(set_piece_slot_new_position)
	GlobalSignals.piece_previous_slot.connect(set_piece_slot_previous_position)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		mouse_position = get_viewport().get_mouse_position()
		ray_cast_3d.target_position = project_local_ray_normal(mouse_position) * 100
		ray_cast_3d.collision_mask = 1
		ray_cast_3d.force_raycast_update()
		
		if ray_cast_3d.is_colliding() and "floor" in ray_cast_3d.get_collider().get_groups():
			charactor.move_character_on_click(ray_cast_3d.get_collision_point())

	if Input.is_action_pressed("click"):
		mouse_position = get_viewport().get_mouse_position()
		ray_cast_3d.target_position = project_local_ray_normal(mouse_position) * 100
		ray_cast_3d.collision_mask = 2
		ray_cast_3d.force_raycast_update()
		if ray_cast_3d.is_colliding() and "item" in ray_cast_3d.get_collider().get_groups():
			grabbed_object = ray_cast_3d.get_collider()

	if Input.is_action_just_released("click"):
		if piece_slot_found and piece_slot_position:
			grabbed_object.position = piece_slot_position
			grabbed_object.linear_velocity = Vector3.ZERO
		grabbed_object = null
		piece_slot_found = false
		piece_slot_position = Vector3.ZERO
			
	if Input.is_action_just_released("mouse_scroll_up") and self.fov > minFov:
		desiredFov = desiredFov - fovStep
	elif Input.is_action_just_released("mouse_scroll_down") and self.fov < maxFov:
		desiredFov = desiredFov + fovStep
	clamp(desiredFov, minFov, maxFov)
	self.set_fov(desiredFov)
	
	#Move obj if grabbed
	if grabbed_object:
		if grabbed_object is RigidBody3D:
			lift_item(grabbed_object,get_grab_position(),delta)
		else:
			grabbed_object.position = get_grab_position()

func get_grab_position():
	return self.project_position(mouse_position,grab_distance)

func lift_item(item:RigidBody3D,target_position:Vector3,delta):
		#attach to objects to move
		var I = 300.0 #influence #export to make adjustable
		var S = 50.0 #stiffness #export to make adjustable
		var P = target_position - item.global_position
		var M = item.mass
		var V = item.linear_velocity
		var impulse = (I*P) - (S*M*V)
		item.apply_central_impulse(impulse * delta)

func _on_piece_slot_area_area_exited(area: Area3D) -> void:
	piece_slot_found = false
	piece_slot_position = Vector3.ZERO

func _on_piece_area_area_entered(area: Area3D) -> void:
	if grabbed_object:
			piece_slot_found = true
			piece_slot_position = area.get_parent().global_transform.origin

func set_piece_slot_new_position(parent_position: Vector3):
	print("previous position: ", previous_slot_position)
	if grabbed_object:
			piece_slot_found = true
			piece_slot_position = parent_position

func set_piece_slot_previous_position(previous_position: Vector3):
	previous_slot_position = previous_position
