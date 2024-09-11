extends TextureRect

var is_mouse_inside = false

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventMouseMotion and is_mouse_inside:
		var mouse_position = event.position
		var relaytive_mouse_position = mouse_position - position
		material.set_shader_parameter("_mousePos", relaytive_mouse_position)				



func _on_mouse_entered():
	is_mouse_inside = true

func _on_mouse_exited():
	is_mouse_inside = false
	material.set_shader_parameter("_mousePos", size/2.0)
