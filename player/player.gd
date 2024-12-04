extends CharacterBody2D
@onready var gun: Node2D = $Gun
@onready var camera: Camera2D = $Camera2D
@onready var hurtbox: CollisionShape2D = $playerHurtbox/CollisionShape2D
@onready var invincibleTimer = $InvincibleTimer

var momentum: float
var angularMomentum: float

enum States {NORMAL, HURT, INVINCIBLE}
var state: States  = States.NORMAL

func _ready():
	momentum = 0
	angularMomentum = 0


func _physics_process(delta):
	move(delta)
	aim()
	check_states()
	
	#print("Velocity: ", velocity.length(), " Target Speed: ", pv.top_speed, " Momentum: ",momentum)

func move(delta):
	#TURNING
	if Input.is_action_pressed("move_left"):
		angularMomentum = max(angularMomentum - pv.turn_accel, -pv.max_angular_speed)
	elif Input.is_action_pressed("move_right"):
		angularMomentum = min(angularMomentum + pv.turn_accel, pv.max_angular_speed)
	else:
		angularMomentum = lerpf(angularMomentum, 0, 0.05)
	rotation += angularMomentum * delta
	
	#THRUST
	if Input.is_action_pressed("move_up"):
		momentum = min(momentum + pv.accel, pv.top_speed)
	elif Input.is_action_pressed("move_down"):
		momentum = max(momentum - pv.decel, -0.5 * pv.top_speed)
	else:
		momentum = max(momentum - envp.background_decel, 0)
	
	velocity = Vector2.UP.rotated(rotation) * momentum
	move_and_slide()

func aim():
	
	if Input.is_action_pressed("l_click"):
		gun.shoot()
	else:
		return

func check_states():
	if state == States.NORMAL:
		pass

	elif state == States.HURT:
		#-hp
		momentum -= momentum/4
		print("hurt")
		invincibleTimer.start()
		state = States.INVINCIBLE

	elif state == States.INVINCIBLE:
		hurtbox.disabled = true


func _on_invincible_timer_timeout():
	hurtbox.disabled = false
	state = States.NORMAL


func _on_player_hurtbox_area_entered(area):
	state = States.HURT
