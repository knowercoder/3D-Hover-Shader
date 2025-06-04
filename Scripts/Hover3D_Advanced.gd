extends TextureRect

@export var exit_tween_duration: float = 0.3

var is_mouse_inside : bool
var exit_tween : Tween

var relative_mouse_position = Vector2(0, 0)

# shader parameters
var tex_pos = Vector2(0, 0)
var tex_size = Vector2(1, 1)
var zdist = 0.0
var shadow_pos = Vector2(0, 0)

var tex_pos2 = Vector2(0, 0)
var tex_size2 = Vector2(1, 1)
var zdist2 = 0.0
var shadow_pos2 = Vector2(0, 0)

func _ready() -> void:
	set_process_input(true)
	zdist = material.get_shader_parameter("_zDist")
	zdist2 = material.get_shader_parameter("_zDist")
	shadow_pos = material.get_shader_parameter("_shadowOffset")
	shadow_pos2 = material.get_shader_parameter("_shadowOffset2")
	
	var tex_pos_size = material.get_shader_parameter("_texPos")
	tex_pos = Vector2(tex_pos_size.x, tex_pos_size.y) * size * scale
	tex_size = tex_pos + Vector2(tex_pos_size.z, tex_pos_size.w) * size * scale
	
	var tex_pos_size2 = material.get_shader_parameter("_texPos2")
	tex_pos2 = Vector2(tex_pos_size2.x, tex_pos_size2.y) * size * scale
	tex_size2 = tex_pos2 + Vector2(tex_pos_size2.z, tex_pos_size2.w) * size * scale

func _input(event):
	var mouse_position = event.position
	if event is InputEventMouseMotion and is_mouse_inside:		
		relative_mouse_position = mouse_position - global_position
		
		#divide by scale to make independant of scale
		#subtract by size/2.0 to center the mouse pos
		var centred_mouse_postion = relative_mouse_position/scale - size/2.0		
		material.set_shader_parameter("_mousePos", centred_mouse_postion)
		
	# mouse click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed: # click down
			relative_mouse_position = mouse_position - global_position
			# if mouse inside the second tex
			if relative_mouse_position.x > tex_pos2.x and relative_mouse_position.y > tex_pos2.y and \
			relative_mouse_position.x < tex_size2.x and relative_mouse_position.y < tex_size2.y:
				material.set_shader_parameter("_zDist2", zdist - 0.05)
				material.set_shader_parameter("_shadowOffset2", Vector2(0, 0))
			# else if mouse inside the main tex
			elif relative_mouse_position.x > tex_pos.x and relative_mouse_position.y > tex_pos.y and \
			relative_mouse_position.x < tex_size.x and relative_mouse_position.y < tex_size.y:
				material.set_shader_parameter("_zDist", zdist - 0.05)
				material.set_shader_parameter("_shadowOffset", Vector2(0, 0))		
		
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed: # click up
			material.set_shader_parameter("_zDist", zdist)
			material.set_shader_parameter("_zDist2", zdist2)
			material.set_shader_parameter("_shadowOffset", shadow_pos)
			material.set_shader_parameter("_shadowOffset2", shadow_pos2)

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
