extends RigidBody2D

@onready var stunTimer: Timer = $stunTimer
@onready var stunArea: CollisionShape2D = $StunRange/CollisionShape2D
@onready var ramArea: CollisionShape2D = $RamRange/CollisionShape2D

var _pid = Pid2D.new(2.0, 0.1, 4.0)
var target: Node2D  # Reference to the player node

var target_dir: Vector2
var prediction_element: Vector2
var target_velocity: Vector2
var error: Vector2
var correction: Vector2
var thrust: Vector2
var impulse: Vector2

var thrustF: float = enep.thrust1
var ramF: float = enep.ram1

enum States {NORMAL, STUNNED, RAMMING}
var state: States

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	stunArea.disabled = false
	state = States.NORMAL

func _physics_process(delta: float) -> void:
	if not target:
		return
	target_dir = target.global_position - self.global_position
	prediction_element = (target.linear_velocity - self.linear_velocity) * delta
	target_velocity = (target_dir + prediction_element) * thrustF
	error =  target_velocity - self.linear_velocity
	correction = _pid.update(error, delta) * delta
	
	if state == States.NORMAL:
		thrust = correction
		rotation = lerp_angle(rotation, correction.angle(), 0.05)
		apply_central_force(thrust)
		print("normal")
		

	elif state == States.STUNNED:
		thrust = Vector2.ZERO
		print("stun")

	if state == States.RAMMING:
		rotation = lerp_angle(rotation, impulse.angle(), 0.05)
		apply_central_impulse(impulse * delta)
		print("ram")


func _on_hurt_box_area_entered(area: Area2D) -> void:
	call_deferred("free")


func _on_stun_timer_timeout() -> void:
	state = States.NORMAL
	ramArea.disabled = false
	stunArea.disabled = false


func _on_ram_range_area_entered(area: Area2D) -> void:
	state = States.RAMMING
	impulse = (target_dir + prediction_element) * thrustF



func _on_ram_range_area_exited(area: Area2D) -> void:
	if ramArea.disabled == false:
		state = States.NORMAL


func _on_stun_range_body_entered(body: RigidBody2D) -> void:
	ramArea.disabled = true
	stunArea.disabled = true
	stunTimer.start()
	state = States.STUNNED
