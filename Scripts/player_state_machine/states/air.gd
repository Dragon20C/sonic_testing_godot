extends PuppetS


enum modifiers {Air,AirDash}
var current_modifier : modifiers = modifiers.Air
var delay_duration : float = 0.0
var has_air_dashed : bool = false
@export var combos : Array[Combo]

func _on_enter(_context : Dictionary = {}) -> void:
	#print("Entered %s state" % name)
	current_modifier = modifiers.Air
	puppet.anim_controller.set_base("falling")
	
	if _context.has("delay"):
		delay_duration = 0.25
		
	has_air_dashed = false

func _on_exit() -> void:
	#print("Exited %s state" % name)
	pass

func _on_update(_delta : float) -> void:
	pass

func _on_physics_update(_delta : float) -> void:
	delay_duration -= _delta
	
	handle_modifiers(_delta)
	handle_transitions()

func handle_transitions() -> void:
	
	if Input.is_action_just_pressed("attack") and delay_duration < 0.0:
		transition("attack",{"AttackType" : "Air"})
		return
	
	match puppet.is_on_floor():
		true:
			if not puppet.input_dir.is_equal_approx(Vector2.ZERO):
				puppet.anim_controller.play("landing",true)
				puppet.velocity = Vector3.ZERO
				await puppet.animator.animation_finished
				transition("Move")
			else:
				puppet.anim_controller.play("landing",true)
				puppet.velocity = Vector3.ZERO
				await puppet.animator.animation_finished
				transition("Idle")

func handle_modifiers(delta : float) -> void:
	
	match current_modifier:
		modifiers.Air:
			puppet.velocity.y -= puppet.gravity * delta
			puppet.handle_movement(delta)
			
			for combo in combos:
				if puppet.input_master.match_combo(combo):
					match combo.combo_type:
						"dash":
							current_modifier = modifiers.AirDash
							return
			
		modifiers.AirDash:
			if not has_air_dashed:
				puppet.anim_controller.play("air_dash")
				var dash_height : float = 2.5
				var direction_force : float = 3.8
				var dir : Vector2 = puppet.direction
				#puppet.facing_dir = 1 if dir.x > 0 else -1
				puppet.animator.flip_h = puppet.facing_dir == -1
				var force_vec : Vector3 = Vector3(dir.x,0.0,dir.y)  * direction_force
				force_vec.y = dash_height
				puppet.velocity += force_vec
				has_air_dashed = true
			
			puppet.apply_gravity(delta)
			puppet.move_and_slide()
			
			await puppet.animator.animation_finished
			current_modifier = modifiers.Air
			
