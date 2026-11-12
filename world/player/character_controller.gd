extends CharacterBody3D
## Based on the ProtoController

@export var can_move    : bool = true
@export var has_gravity : bool = true
@export var can_jump    : bool = true
@export var can_sprint  : bool = false
@export var can_freefly : bool = false

@export_group("Speeds")
@export var look_speed    : float = 0.002
@export var base_speed    : float = 7.0
@export var jump_velocity : float = 4.5
@export var sprint_speed  : float = 10.0
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
@export var input_left    : String = "input_left"
@export var input_right   : String = "input_right"
@export var input_forward : String = "input_forward"
@export var input_back    : String = "input_back"
@export var input_jump    : String = "input_jump"
@export var input_sprint  : String = "input_sprint"
@export var input_freefly : String = "input_freefly"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

@onready var _head           : Node3D    = %CharacterHead
@onready var _player_camera  : Camera3D  = %PlayerCamera
@onready var _raycast        : RayCast3D = %InteractRay
@onready var _snowball_pos   : Marker3D  = %SnowballPos
@onready var _item_use_timer : Timer     = %ItemUseTimer
@onready var _collider   : CollisionShape3D       = %CharacterCollider
@onready var _replicator : FusionSharedReplicator = %CharacterReplicator

var current_interactable = null
var held_fish = null
var can_throw : bool = true
var slapping  : bool = false

#region Node Overrides

func _ready() -> void:
	if Fusion.is_connected_to_photon() and not _replicator.has_authority():
		_player_camera.current = false
		return
	
	_item_use_timer.timeout.connect(_on_item_use_timer_timeout)
	
	_check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = _head.rotation.x
	
	GlobalEvents.request_show_hud(UIDs.HUDs[UIDs.HUD.PLAYER])

func _physics_process(delta: float) -> void:
	# Prevent other players from controlling this character
	if Fusion.is_connected_to_photon() and not _replicator.has_authority():
		return
	
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		_handle_freeflight(delta)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		_handle_gravity(delta)

	# Apply jumping
	if can_jump:
		_handle_jump()

	# Modify speed based on sprinting
	_set_movement_speed()

	# Apply desired movement to velocity
	_handle_movement()
	
	# Use velocity to actually move
	move_and_slide()
	
	_check_hover_collision()
	
	if Input.is_action_just_pressed("input_throw"):
		_use_held_item()

func _unhandled_input(event: InputEvent) -> void:
	# Prevent other players from controlling this character
	if Fusion.is_connected_to_photon() and not _replicator.has_authority():
		return
	
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		_release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		_rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			_enable_freefly()
		else:
			_disable_freefly()
	
	# Interact
	if event.is_action_pressed("interact"):
		activate()

#endregion

#region Movement

## Handles freeflight movement over a time delta
func _handle_freeflight(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector(input_left, input_right, input_forward, input_back)
	var motion: Vector3 = (_head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	motion *= freefly_speed * delta
	move_and_collide(motion)

## Handles gravity by modifying y velocity
## while the character is in the air
func _handle_gravity(delta: float) -> void:
	if is_on_floor():
		return
	
	velocity += get_gravity() * delta

## Handles jumping by setting y velocity
## when receiving jump input while on the floor
func _handle_jump() -> void:
	if not Input.is_action_just_pressed(input_jump) or not is_on_floor():
		return
	
	velocity.y = jump_velocity

## Sets movement speed based on sprint input
func _set_movement_speed() -> void:
	if can_sprint and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed
	else:
		move_speed = base_speed

## Handles movement by modifying x and z velocities
func _handle_movement() -> void:
	if not can_move:
		velocity.x = 0
		velocity.z = 0
		return
	
	var input_dir: Vector2 = Input.get_vector(input_left, input_right, input_forward, input_back)
	var move_dir: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_dir:
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func _rotate_look(rot_input: Vector2) -> void:
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	_head.transform.basis = Basis()
	_head.rotate_x(look_rotation.x)

## Enables the ability to fly around freely
## No gravity or collisions
func _enable_freefly() -> void:
	_collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

## Disables the ability to fly around freely
## Re-enables collisions and possible gravity
func _disable_freefly() -> void:
	_collider.disabled = false
	freeflying = false

#endregion Movement

#region Input

## Sets the mouse to be hidden and locked at the center of the window
func _capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

## Sets the mouse to be shown and able to move around
func _release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func _check_input_mappings() -> void:
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false

#endregion

#region Items / Interactions

func _check_hover_collision() -> void:
	if not _raycast.is_colliding():
		return
	
	var collider: Object = _raycast.get_collider()
	if not collider:
		return
	
	# TODO: Check if collider parent is an Interactable instead of checking if
	# 		it has an "interact" method 
	var item = collider.get_parent()
	if not item.has_method("interact"):
		item = null

	if item == current_interactable:
		return
	
	# TODO: Move prompt to player HUD
	_hide_current_prompt()

	if item:
		current_interactable = item
		current_interactable.show_prompt()

func _hide_current_prompt() -> void:
	if not current_interactable:
		return
		
	current_interactable.hide_prompt()
	current_interactable = null

func _use_held_item() -> void:
	# TODO: Refactor item use logic to individual item scripts and just call
	# held_item.use() or equivalent
	if held_fish:
		slap()
		return

	if can_throw:
		can_throw = false
		_item_use_timer.start()
		
		GlobalEvents.request_snowball_throw(_snowball_pos)

#endregion

func _on_item_use_timer_timeout() -> void:
	can_throw = true

func activate() -> void:
	if held_fish:
		held_fish.drop()
		held_fish = null
		return

	if not _raycast.is_colliding():
		return

	var hit = _raycast.get_collider()
	if hit == null:
		return

	var item = hit.get_parent()
	if item and item.has_method("pick_up"):
		_hide_current_prompt()
		held_fish = item
		item.pick_up(_player_camera)

func slap() -> void:
	if slapping:
		return

	slapping = true
	var swing = create_tween()
	swing.tween_property(held_fish, "rotation_degrees:y", 180.0 + 65.0, 0.10)
	swing.tween_property(held_fish, "rotation_degrees:y", 180.0, 0.18)

	_raycast.force_raycast_update()
	var target = _raycast.get_collider()

	if target is RigidBody3D and _raycast.global_position.distance_to(_raycast.get_collision_point()) < 2.5:
		target.apply_central_impulse(-_raycast.global_basis.z * 8.0)

	await swing.finished
	slapping = false
