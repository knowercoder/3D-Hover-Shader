# 3D-Hover-Shader
This shader creates a 3D hovering effect with mouse interaction on a canvasitem like TextureRect, in Godot game engine.

https://github.com/user-attachments/assets/a2198237-b35d-46a7-807d-c169611b9887


## Features:

- 3D tilting on mouse hover
- Specular highlight that changes with hover.
- A second texture, laid on top, with adjustable depth
- Customizable drop shadow for depth
- Click animation that mimics button press

## Note:

You should assign the Hover3D gdScript to your canvasitem node. This script will set the “Mouse Pos” parameter in the shader.  
This script also modifies the TexPos and zDist parameters for the click animation.


## Tutorial
Learn here [how the basic shader code works](https://knowercoder.itch.io/3d-hover-shader-godot/devlog/913870/3d-hover-shader-for-godot-make-your-ui-elements-pop)

