extends CharacterBody2D

@export var movement_data: PlayerMovementData

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $AnimatedSprite2D
@onready var coyote_timer = $CoytoteJumpTimer
@onready var starting_position = global_position

var can_air_jump = false
var just_wall_jumped = false


func _physics_process(delta: float):
	var input_axis = Input.get_axis("move_left", "move_right")

	apply_gravity(delta)

	handle_wall_jump()
	handle_jump()

	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)

	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)

	update_animation(input_axis)

	var was_on_floor = is_on_floor()
	move_and_slide()
	handle_coyote_jump_timer(was_on_floor)

	just_wall_jumped = false


func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta


func handle_coyote_jump_timer(was_on_floor: bool):
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_timer.start()


func handle_wall_jump():
	if not is_on_wall_only():
		return
	var wall_normal = get_wall_normal()

	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true


func handle_jump():
	if is_on_floor():
		can_air_jump = true

	if is_on_floor() or coyote_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
		if Input.is_action_just_pressed("jump") and can_air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * movement_data.air_jump_factor
			can_air_jump = false


func handle_acceleration(input_axis: float, delta: float):
	if not is_on_floor():
		return
	if input_axis:
		velocity.x = move_toward(
			velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta
		)


func handle_air_acceleration(input_axis: float, delta: float):
	if is_on_floor():
		return
	if input_axis:
		velocity.x = move_toward(
			velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta
		)


func apply_friction(input_axis: float, delta: float):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)


func apply_air_resistance(input_axis: float, delta: float):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)


func update_animation(input_axis: float):
	if input_axis != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false

	if not is_on_floor():
		sprite.play("jump")


func _on_hazard_detector_area_entered(_area):
	global_position = starting_position
