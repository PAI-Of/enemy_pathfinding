extends CharacterBody3D

@onready var Head = $Head
@onready var standing_collider: CollisionShape3D = $standing_collider
@onready var crouching_collider: CollisionShape3D = $crouching_collider
@onready var clearance_cast: RayCast3D = $ClearanceCast

# Constants
var speed = 5.0
var direction = Vector3.ZERO
const sprint_velocity = 8.0
const normal_velocity = 5.0
const crouch_velocity = 3.0
const jump_velocity = 4.5
const crouch_depth = -0.5

# Preferences (Later: Customizable) via Settings
const lerp_speed = 10.0
const sensivitity = 0.4

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensivitity))
		Head.rotate_x(deg_to_rad(-event.relative.y * sensivitity))
		Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("crouch"):
		speed = crouch_velocity
		Head.position.y = lerp(Head.position.y, 0.8 + crouch_depth, delta * lerp_speed)
		standing_collider.disabled = true
		crouching_collider.disabled = false
	elif !clearance_cast.is_colliding():
		crouching_collider.disabled = true
		standing_collider.disabled = false
		Head.position.y = lerp(Head.position.y, 0.8, delta*lerp_speed)
		if Input.is_action_pressed("sprint"):
			speed = sprint_velocity
		else: 
			speed = normal_velocity

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
