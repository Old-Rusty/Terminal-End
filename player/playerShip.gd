extends RigidBody2D
var _pid = Pid2D.new(2.0, 0.1, 2.0)
var correction: Vector2
var current_thrust: float = 0
var target_rotation: float
var angularMomentum: float = 0

@onready var hull_test: AnimatedSprite2D = $NaDefaultHull/hull
@onready var hurt_box: CollisionPolygon2D = $NaDefaultHull/HurtBox/CollisionPolygon2D
@onready var i_timer: Timer = $InvincibleTimer
@onready var stun_timer: Timer = $StunTimer
@onready var weapon1: Node2D = $Gun

enum States {NORMAL, STUNNED}
var state: States  = States.NORMAL
var invincible: bool = false

func _ready():
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("l_click"):
		weapon1.shoot(delta)
	_ichecker()
	_state_check(delta)
	apply_central_force(correction)

func _state_check(delta) -> void:
	if state == States.NORMAL:
		#TORQUE
		if Input.is_action_pressed("move_left"):
			angularMomentum = max(angularMomentum - pv.turn_accel, -pv.max_angular_speed)
		elif Input.is_action_pressed("move_right"):
			angularMomentum = min(angularMomentum + pv.turn_accel, pv.max_angular_speed)
		else:
			angularMomentum = lerpf(angularMomentum, 0, 0.05)
		rotation += angularMomentum * delta
		#THRUST
		if Input.is_action_pressed("move_up"):
			current_thrust = min(current_thrust + pv.TARGET_THRUST_ACCEL, pv.MAX_THRUST)
		elif Input.is_action_pressed("move_down"):
			current_thrust = max(current_thrust - pv.TARGET_THRUST_ACCEL, pv.MIN_THRUST)
		else:
			pass
		
		var target_velocity = current_thrust * Vector2.UP.rotated(rotation) * mass
		var error = target_velocity - linear_velocity
		correction = _pid.update(error, delta)
		#thrust = current_thrust * Vector2.UP.rotated(rotation) * mass
	
	elif state == States.STUNNED:
		angularMomentum = 0
		current_thrust = 0
		correction = _pid.update(Vector2.ZERO, delta)

func _ichecker() -> void:
	if invincible == true:
		hurt_box.disabled = true
		hull_test.play("inv")

	else:
		hurt_box.disabled = false
		hull_test.play("default")

func _hurt(area) -> void:
	invincible = true
	i_timer.start()
	if area.is_in_group("charge_enemy") and area.get_parent().ramming == true:
		state = States.STUNNED
		stun_timer.start()


func _on_hurt_box_area_entered(area):
	_hurt(area)


func _on_stun_timer_timeout():
	state = States.NORMAL


func _on_invincible_timer_timeout():
	invincible = false
