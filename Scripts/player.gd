extends CharacterBody3D
class_name Player

@export_group("Node Requirements")
@export var animator : AnimatedSprite3D
@export var shadow_animator : AnimatedSprite3D
@export var shadow_ray : RayCast3D

@export_group("Stats Config")
@export var top_speed : float = 3.5
@export var jump_force : float = 3.5
@export var air_acceleration : float = 4.0
@export var top_speed_acceleration : float = 25.0
@export var normal_acceleration : float = 12.0
@export var decceleration : float = 18.0

var anim_controller : AnimationController
var input_master : InputMaster

var gravity : float = 9.8
var input_dir : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2.ZERO
var previous_dir : Vector2 = Vector2.ZERO

const FAST_TURN_SPEED : float = 2.25
var facing_dir    : int = 1
var desired_dir   : int = 1
var turn_speed    : float = 3.0
var turn_progress : float = 0.0
var is_turning    : bool = false
var override_anim : bool = false

func _ready() -> void:
	anim_controller = AnimationController.new(animator)
	input_master = InputMaster.new()

func _process(_delta: float) -> void:
	anim_controller.update()
	input_master._update(_delta)
	handle_input()
	handle_shadow()
	
#func _physics_process(delta: float) -> void:
	#print("Speed : %s" % velocity.length())

func handle_input() -> void:
	input_dir.x = Input.get_axis("move_left","move_right")
	input_dir.y = Input.get_axis("move_forward","move_backward")
	
	# storing the last direction without it being zero.
	if not input_dir.is_equal_approx(Vector2.ZERO):
		direction = input_dir
	
	if not is_equal_approx(input_dir.x,0.0):
		desired_dir = sign(input_dir.x)
	

func handle_movement(delta : float) -> void:
	if input_dir.is_equal_approx(Vector2.ZERO):
		apply_decceleration(delta)
	
	apply_acceleration(delta)
	
	
	#if is_turning and not is_at_speed():
		#velocity *= 0.8
	
	move_and_slide()

func apply_acceleration(delta : float) -> void:
	# we use this for air movement, if we just use input dir directly we get no air movement.
	if not input_dir.is_equal_approx(Vector2.ZERO) or is_on_floor():
		previous_dir = input_dir
		
	var target_speed : Vector2 = previous_dir * top_speed
	
	var accel : float = 0.0
	
	if is_on_floor():
		#if is_at_speed():
			#accel = top_speed_acceleration
		#else:
		accel = normal_acceleration
	else:
		accel = air_acceleration
		
	#var accel : float = acceleration if is_on_floor() else air_acceleration
	
	velocity.x = move_toward(velocity.x,target_speed.x,accel * delta)
	velocity.z = move_toward(velocity.z,target_speed.y,accel * delta)

func apply_decceleration(delta : float) -> void:
	velocity.x = move_toward(velocity.x,0.0,decceleration * delta)
	velocity.z = move_toward(velocity.z,0.0,decceleration * delta)

func apply_gravity(delta : float) -> void:
	velocity.y -= gravity * delta

func is_at_speed() -> bool:
	var movement_dir : Vector3 = Vector3(input_dir.x,0.0,input_dir.y)
	var ground_speed : float = abs(velocity.dot(movement_dir))
	var is_fast : bool = (is_on_floor() and abs(input_dir.x) > 0 and ground_speed > FAST_TURN_SPEED)
	
	return is_fast

func handle_slow_turning(delta : float) -> void:
	
	if override_anim:
		return
	
	if not is_equal_approx(input_dir.x,0.0):
		desired_dir = sign(input_dir.x)
	
	var turn_state : bool = is_at_speed()
	
	match turn_state:
		true:
			if desired_dir != facing_dir:
				animator.flip_h = false
				facing_dir = desired_dir
				if facing_dir == -1:
					animator.play("turning_around_fast")
				else:
					animator.play_backwards("turning_around_fast")
				await animator.animation_finished
				animator.flip_h = facing_dir == -1
				if not input_dir.is_equal_approx(Vector2.ZERO):
					animator.play("running")
				else:
					animator.play("idle")
		false:
			if desired_dir != facing_dir:
				is_turning = true
				turn_progress += turn_speed * delta
			else:
				turn_progress -= turn_speed * delta
				if turn_progress <= 0:
					is_turning = false
			
			turn_progress = clamp(turn_progress, 0, 1.1) # add some buffer
			
			if turn_progress >= 1:
				facing_dir = desired_dir
				turn_progress = 0
				animator.flip_h = facing_dir == -1
				if not input_dir.is_equal_approx(Vector2.ZERO):
					animator.play("running")
				else:
					animator.play("idle")
	
	if desired_dir != facing_dir:
		#print("Progress %s" % ceili(turn_progress * 3))
		animator.play("turning_around")
		var frame_index : int = ceili(turn_progress * 3)
		animator.frame = frame_index - 1
	

func handle_shadow() -> void:
	var max_height : float = 1.0
	if not shadow_animator.top_level:
		shadow_animator.top_level = true
		
	shadow_ray.force_raycast_update()
	
	if shadow_ray.is_colliding():
		var point : Vector3 = shadow_ray.get_collision_point()
		var offset : float = 0.045
		shadow_animator.global_position = point + Vector3(0.0,offset,-0.01)
		var dist : float = point.distance_to(global_position)
		var ratio : float = dist / max_height
		
		var convert_to_frames : int = int(ratio * 4.0)
		shadow_animator.frame = clampi(convert_to_frames,0,3)
