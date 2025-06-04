extends TextureRect

@export var exit_tween_duration: float = 0.3

var is_mouse_inside : bool
var exit_tween : Tween

func _ready() -> void:
	set_process_input(true)

func _input(event):
	if event is InputEventMouseMotion and is_mouse_inside:
		var mouse_position = event.position
		var relative_mouse_position = mouse_position - global_position
		
		#divide by scale to make independant of scale
		#subtract by size/2.0 to center the mouse pos
		var centred_mouse_postion = relative_mouse_position/scale - size/2.0
		
		material.set_shader_parameter("_mousePos", centred_mouse_postion)

func _on_mouse_entered():
	is_mouse_inside = true

func _on_mouse_exited():
	is_mouse_inside = false
	setNormalState()
	
#go back to original state with ease out
func setNormalState():
	if exit_tween and exit_tween.is_valid():
		exit_tween.kill()
	exit_tween = get_tree().create_tween()
	exit_tween.tween_property(material, "shader_parameter/_mousePos", Vector2.ZERO, exit_tween_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
