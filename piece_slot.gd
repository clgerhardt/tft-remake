extends Node3D

var occupied = false
var current_piece : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.piece_slot_occupied.connect(set_peice_slot_occupied)

func set_peice_slot_occupied(val: bool, cp: Node3D):
	if !occupied:
		current_piece = cp

	occupied = val
