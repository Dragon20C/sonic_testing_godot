extends CharacterBody3D
class_name DebugPlayer

@export var root_body : Node3D

var top_speed : float = 14.0
var accel : float = 36.0
var deccel : float = 80.0
var friction : float = 24.0
var jump_force : float = 6.0
var gravity : float = 9.8
var fall_gravity : float = 18.0
var visual_rot_smoothing : float = 8.0

var input : Vector2 = Vector2.ZERO
var ground_speed : float = 0.0
var velocity_angle : float = 0.0

func _physics_process(delta: float) -> void:
	handle_input()
	
	handle_gravity(delta)
	
	handle_jump()
	
	handle_accelerations(delta)
	
	move_and_slide()
	
	velocity_angle = atan2(velocity.x,velocity.z)
	if not velocity.is_equal_approx(Vector3.ZERO):
		root_body.rotation.y = lerp_angle(root_body.rotation.y,velocity_angle - PI,visual_rot_smoothing * delta)

func handle_input() -> void:
	input = Input.get_vector("move_left","move_right","move_forward","move_backward")

func handle_gravity(delta : float) -> void:
	if velocity.y < 0.0:
		velocity.y -= fall_gravity * delta
	elif not is_on_floor():
		velocity.y -= gravity * delta
	

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	if Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y *= 0.5
		#velocity.y -= jump_force / 2.0

func handle_accelerations(delta : float) -> void:
	
	var current_accel : float = accel
	
	var desired_dir : float = velocity.normalized().dot(Vector3(input.x,0.0,input.y))
	
	if desired_dir < 0.0:
		print("Oh, wait a minute!")
		current_accel = deccel
	
	var up_velocity : Vector3 = Vector3.UP.normalized() * velocity.dot(Vector3.UP)
	
	var target_velocity : Vector3 = Vector3(input.x,0.0,input.y) * top_speed
	
	if input.is_equal_approx(Vector2.ZERO) and is_on_floor():
		current_accel = friction
		
	if is_on_floor() or not input.is_equal_approx(Vector2.ZERO):
		velocity = (velocity - up_velocity).move_toward(target_velocity,current_accel * delta) + up_velocity
