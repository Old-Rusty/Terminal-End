extends RefCounted
class_name Pid2D

var _p: float
var _i: float
var _d: float

var _error_integral: Vector2
var _prev_error: Vector2

func _init(p: float, i: float, d:float) -> void:
	_p = p
	_d = d
	_i = i

func update(error:Vector2, delta:float) -> Vector2:
	_error_integral += error * delta
	var error_derivative = (error - _prev_error)/delta
	_prev_error = error
	return _p * error + _i * _error_integral + _d * error_derivative
