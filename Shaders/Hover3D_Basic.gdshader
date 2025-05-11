shader_type canvas_item;

uniform float _tilt_Scale = 0.5;
uniform bool _isSpecularLight = false;
uniform float _speularLightIntensity = 0.5;
uniform float _speularLightPower = 3.0;
uniform vec2 _mousePos;

varying vec2 vTexCoord;
varying float vFragPerspective;
varying vec2 vMouseoffset;

void vertex() {
    // Normalize texture coordinates
    vTexCoord = VERTEX.xy * TEXTURE_PIXEL_SIZE;

    // Center the coordinates around the origin
    vec2 centeredCoord = vTexCoord - vec2(0.5, 0.5);
	vec2 mouse_centered = ((_mousePos + 0.5/TEXTURE_PIXEL_SIZE) * TEXTURE_PIXEL_SIZE) * 2.0 - 1.0;

	vMouseoffset = mouse_centered / 2.0; // varying to be passed to fragment

    // Rotation matrices around the X, Y, and Z axes

	//Rotation along X-axis
    float cosX = cos(mouse_centered.y * _tilt_Scale);
    float sinX = sin(mouse_centered.y * _tilt_Scale);
    mat3 rotationX;
    rotationX[0] = vec3(1.0, 0.0, 0.0);
    rotationX[1] = vec3(0.0, cosX, -sinX);
    rotationX[2] = vec3(0.0, sinX, cosX);

	//Rotation along Y-axis
    float cosY = cos(-mouse_centered.x * _tilt_Scale);
    float sinY = sin(-mouse_centered.x * _tilt_Scale);
    mat3 rotationY;
    rotationY[0] = vec3(cosY, 0.0, sinY);
    rotationY[1] = vec3(0.0, 1.0, 0.0);
    rotationY[2] = vec3(-sinY, 0.0, cosY);

	//Rotation along Z-axis
	//no rotation along Z-axis, so the angle is zero
    float cosZ = cos(0.);
    float sinZ = sin(0.);
    mat3 rotationZ;
    rotationZ[0] = vec3(cosZ, -sinZ, 0.0);
    rotationZ[1] = vec3(sinZ, cosZ, 0.0);
    rotationZ[2] = vec3(0.0, 0.0, 1.0);

    // Combine rotations
    mat3 rotation = rotationZ * rotationY * rotationX;

    // Apply the rotation to the vertex position
    vec3 transformedCoord = rotation * vec3(centeredCoord, 0.0);

    // Apply perspective projection
    float perspective = 1.0 / (1.0 - transformedCoord.z * 0.5);
    transformedCoord.xy *= perspective;
	vTexCoord *= perspective;
	vFragPerspective = perspective;

    // Transform back to screen coordinates
    vec2 screenPosition = (transformedCoord.xy + vec2(0.5)) / TEXTURE_PIXEL_SIZE;
    VERTEX = screenPosition;
}

void fragment() {
	//perspective correction of UV
    vec2 finalTexCoord = vTexCoord / vFragPerspective;
    vec4 texColor = texture(TEXTURE, finalTexCoord);

	//specular light
	float specularvalue = pow(clamp(1.0 - length(finalTexCoord - 0.5 + vMouseoffset), 0.0, 1.0), _speularLightPower) * _speularLightIntensity;
	vec3 specularCol = vec3(specularvalue);

	if(_isSpecularLight)
    	COLOR = texColor + vec4(specularCol, 0.0);
	else
		COLOR = texColor;
}