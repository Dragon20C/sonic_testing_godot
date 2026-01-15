extends PuppetS



var is_stopping : bool = false
var has_dashed : bool = false
var is_slow_turning : bool = false
enum modifiers {Running, Dashing}
var current_modifier : modifiers = modifiers.Running
@export var combos : Array[Combo]

func _on_enter(_context : Dictionary = {}) -> void:
	#print("Entered %s state" % name)
	puppet.anim_controller.set_base("running")
	current_modifier = modifiers.Running
	#puppet.animator.play("running")

func _on_exit() -> void:
	#print("Exited %s state" % name)
	pass

func _on_update(_delta : float) -> void:
	pass
		
func _on_physics_update(_delta : float) -> void:
	
	_update_modifiers(_delta)
	
	if puppet.is_at_speed():
		is_stopping = true
	else :
		is_stopping = false
	
	handle_transitions()

func handle_transitions() -> void:
	match puppet.is_on_floor():
		true:
			
			if current_modifier == modifiers.Dashing:
				return
			
			if puppet.velocity.is_equal_approx(Vector3.ZERO) and puppet.input_dir.is_equal_approx(Vector2.ZERO):
				transition("Idle",{"stopping" : is_stopping})
			
			if Input.is_action_just_pressed("jump"):
				transition("Jump")
		false:
			if current_modifier == modifiers.Dashing:
				return
			transition("Air")

func _update_modifiers(delta : float) -> void:
	
	match current_modifier:
		modifiers.Running:
			
			for combo in combos:
				if puppet.input_master.match_combo(combo):
					match combo.combo_type:
						"dash":
							puppet.anim_controller.play("dashing",true)
							has_dashed = false
							current_modifier = modifiers.Dashing
							return
						_:
							print("Unknown combo : %s" % combo.combo_type)
			
			# slow down the turning
			if is_slow_turning:
				puppet.velocity *= 0.9
			
			puppet.handle_movement(delta)
			
			if puppet.facing_dir != puppet.desired_dir:
				puppet.facing_dir = puppet.desired_dir
				# Fast turning
				if puppet.is_at_speed():
					puppet.anim_controller.play("fast_turn",true)
					await puppet.animator.animation_finished
					puppet.animator.flip_h = puppet.facing_dir == -1
				else:
					# Slow turning
					is_slow_turning = true
					puppet.anim_controller.play("slow_turn",true)
					await puppet.animator.animation_finished
					puppet.animator.flip_h = puppet.facing_dir == -1
					is_slow_turning = false
			
		modifiers.Dashing:
			if not has_dashed:
				var dash_height : float = 2.0
				var direction_force : float = 3.5
				var dir : Vector2 = puppet.direction
				#puppet.facing_dir = 1 if dir.x > 0 else -1
				puppet.animator.flip_h = puppet.facing_dir == -1
				var force_vec : Vector3 = Vector3(dir.x,0.0,dir.y)  * direction_force
				force_vec.y = dash_height
				puppet.velocity += force_vec
				has_dashed = true
				
			puppet.apply_gravity(delta)
			puppet.move_and_slide()
			
			if puppet.is_on_floor():
				puppet.velocity = Vector3.ZERO
				puppet.anim_controller.play("landing",true)
				await puppet.animator.animation_finished
				current_modifier = modifiers.Running
		
		
