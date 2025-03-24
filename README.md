# 3D-Hover-Shader
This shader will create a 3D hovering effect with mouse interaction on a canvas item like TextureRect. Also, it renders a specular highlight that changes with hover.

![Hover3D](https://github.com/user-attachments/assets/8e22a6b9-e204-44ce-97ba-66f7e352bc80)


Shader Properties:
- Tilt Scale - Amount of tilt on mouse hover
- Is Specular Light - Enable/disable specular highlight
- Specular Light Intensity - specular highlight strength
- Specular Light Power - controls the spread of specular highlight
- Mouse Pos - This is the mouse position that will be set via GDScript attached to the canvas item.

It is recommended to use a texture with some transparent space at the borders so that the image is not clipped when tilted.
