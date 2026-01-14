extends Node3D
class_name CameraGimble

@export var rot_speed : float = 10.0

func _physics_process(delta: float) -> void:
	rotate_y(deg_to_rad(rot_speed) * delta)
