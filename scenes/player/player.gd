extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const ACCELERATION = 600
const FRICTION = 1000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $AnimatedSprite2D


func _physics_process(delta: float):
	apply_gravity(delta)

	handle_jump()

	var input_axis = Input.get_axis("move_left", "move_right")
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)

	update_animation(input_axis)

	move_and_slide()


func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta


func handle_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	else:
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2


func handle_acceleration(input_axis: float, delta: float):
	if input_axis:
		velocity.x = move_toward(velocity.x, SPEED * input_axis, ACCELERATION * delta)


func apply_friction(input_axis: float, delta: float):
	if input_axis == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


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
