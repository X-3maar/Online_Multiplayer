extends CharacterBody3D

@onready var camera: Camera3D = $Camera
@onready var animation: AnimationPlayer = $Camera/Hand/AnimationPlayer
@onready var gpu_particles_3d: GPUParticles3D = $Camera/Hand/Pistol/GPUParticles3D
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

const SPEED = 10
const JUMP_VELOCITY = 5
var lock = false
var pause = false
func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
func _ready() -> void:
	if !is_multiplayer_authority():
		return 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	lock = true
func _unhandled_input(event: InputEvent) -> void:
	
	if !is_multiplayer_authority():
		return 
	if event is InputEventMouseMotion:
		if lock:
			rotate_y(-event.relative.x * 0.005)
			camera.rotation.x = clamp(camera.rotation.x - event.relative.y * 0.01,deg_to_rad(-60),deg_to_rad(60))
		
	if Input.is_action_just_pressed("shoot") and animation.current_animation != "shoot":
		animation.stop()
		animation.play("shoot")
		gpu_particles_3d.restart()
		gpu_particles_3d.emitting = true
func _physics_process(delta: float) -> void:
	
	if !is_multiplayer_authority():
		camera.current = false
		return 
	camera.current = true
	if Input.is_action_just_pressed("ctrl") and lock:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		lock = false
	elif Input.is_action_just_pressed("ctrl") and !lock:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		lock = true
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta 

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
	if animation.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		animation.play("move")
	else:
		animation.play("idle")
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
