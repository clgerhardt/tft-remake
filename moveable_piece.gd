extends RigidBody3D

func _on_moveable_piece_area_entered(area: Area3D) -> void:
	GlobalSignals.set_piece_slot.emit(area.get_parent().global_transform.origin)

func _on_moveable_piece_area_exited(area: Area3D) -> void:
	GlobalSignals.set_piece_slot.emit(area.get_parent().global_transform.origin)
	GlobalSignals.piece_previous_slot.emit(area.get_parent().global_transform.origin)
