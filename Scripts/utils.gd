extends Node

func get_target_ray_cast(camera: Camera3D, ray_cast_3d: RayCast3D, mask_layer: int):
	var mouse_position = get_viewport().get_mouse_position()
	ray_cast_3d.target_position = camera.project_local_ray_normal(mouse_position) * 100
	ray_cast_3d.collision_mask = mask_layer
	ray_cast_3d.force_raycast_update()
	return mouse_position
