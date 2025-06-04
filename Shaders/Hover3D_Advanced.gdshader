//3D hover - pro
//Attach the "Hover3D_pro.gd" script to your canvas item

shader_type canvas_item;

group_uniforms hover;
uniform float _tilt_Scale = 0.25;
uniform vec4 _mainTint : source_color = vec4(1, 1, 1, 1);
/**
* secondary texture position, width and height
* X, Y = postion ((0, 0)start pos at top left) // z, w = width and height
*/
uniform vec4 _texPos = vec4(0, 0, 1, 1);
uniform float _zDist : hint_range(0., 0.1) = 0;
group_uniforms;

group_uniforms secondary_ui;
uniform bool _isSecondTex;
uniform sampler2D _secondTex : source_color, repeat_disable;
uniform vec4 _secondTint : source_color = vec4(1, 1, 1, 1);
/**
* secondary texture position, width and height
* X, Y = postion ((0, 0)start pos at top left) // z, w = width and height
*/
uniform vec4 _texPos2 = vec4(0, 0, 1, 1);
/**
* depth
*/
uniform float _zDist2 : hint_range(0., 0.1) = 0;
group_uniforms;

group_uniforms shadows;
uniform bool _isShadows = true;
/**
* shadow offset for main tex
*/
uniform vec2 _shadowOffset;
/**
* shadow offset for second tex
*/
uniform vec2 _shadowOffset2;
uniform vec4 _shadowCol : source_color = vec4(0, 0, 0, 0.5);
group_uniforms;

group_uniforms specular_highlight;
uniform bool _isSpecularLight = false;
uniform float _speularLightIntensity = 0.3;
uniform float _speularLightPower = 3.0;
group_uniforms;

group_uniforms others;
/**
* this value set by the gdscript attached to this canvasitem
*/
uniform vec2 _mousePos;
group_uniforms;

bool IsOutofBounds(vec2 uv){
	return uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0;
}

mat3 rotateMatrix(float xAngle, float yAngle, float zAngle){
	// Rotation matrices around the X, Y, and Z axes

	//Rotation along X-axis
    float cosX = cos(xAngle);
    float sinX = sin(xAngle);
    mat3 rotationX;
    rotationX[0] = vec3(1.0, 0.0, 0.0);
    rotationX[1] = vec3(0.0, cosX, -sinX);
    rotationX[2] = vec3(0.0, sinX, cosX);

	//Rotation along Y-axis
    float cosY = cos(yAngle);
    float sinY = sin(yAngle);
    mat3 rotationY;
    rotationY[0] = vec3(cosY, 0.0, sinY);
    rotationY[1] = vec3(0.0, 1.0, 0.0);
    rotationY[2] = vec3(-sinY, 0.0, cosY);

	//Rotation along Z-axis
    float cosZ = cos(zAngle);
    float sinZ = sin(zAngle);
    mat3 rotationZ;
    rotationZ[0] = vec3(cosZ, -sinZ, 0.0);
    rotationZ[1] = vec3(sinZ, cosZ, 0.0);
    rotationZ[2] = vec3(0.0, 0.0, 1.0);

    // Combine rotations
    return rotationZ * rotationY * rotationX;
}

vec2 transformUV(vec3 centeredCoord, mat3 rotation, vec2 uvcoord){
	//Apply the rotation to the uv coord
    vec3 transformedUV = rotation * centeredCoord;
    //Apply perspective projection
    float perspective = 1.0 / (1.0 - transformedUV.z * 0.5);
    transformedUV.xy *= perspective;
	//back to screen coord
	vec2 uv = transformedUV.xy + vec2(0.5);
	//perspective inversion for texture sampling
	uv = uvcoord * (2. - uv/uvcoord);
	return uv;
}

void vertex() {

}

void fragment() {
	// Center the coordinates around the origin
	vec2 centeredCoord = UV - vec2(0.5);
	vec2 mouse_centered = ((_mousePos + 0.5/TEXTURE_PIXEL_SIZE) * TEXTURE_PIXEL_SIZE) * 2.0 - 1.0;
	vec2 mouseoffset = mouse_centered / 2.0;

	//rotation matrix
	float tiltAngleX = mouse_centered.y * _tilt_Scale;
	float tiltAngleY = -mouse_centered.x * _tilt_Scale;
	float tiltAngleZ = 0.; //no rotation along Z-axis, so the angle is zero
	mat3 rotation = rotateMatrix(tiltAngleX, tiltAngleY, tiltAngleZ);

	vec2 uv = transformUV(vec3(centeredCoord, _zDist), rotation, UV);
	uv = (uv - _texPos.xy) / _texPos.zw;
	vec4 texCol = texture(TEXTURE, uv) * _mainTint;
	texCol.a = IsOutofBounds(uv) ? 0. : texCol.a;

	vec4 secondTexCol = vec4(0.0);
	if(_isSecondTex){
		vec2 uv2 = transformUV(vec3(centeredCoord, _zDist + _zDist2), rotation, UV);
		uv2 = (uv2 - _texPos2.xy) / _texPos2.zw;
		secondTexCol = texture(_secondTex, uv2) * _secondTint;
		secondTexCol.a = IsOutofBounds(uv2) ? 0. : secondTexCol.a;
	}

	vec4 shadowCol1 = vec4(0.0);
	vec4 shadowCol2 = vec4(0.0);
	if(_isShadows){
		vec2 shadowUv1 = transformUV(vec3(centeredCoord - _shadowOffset.xy, _zDist), rotation, UV);
		vec2 shadowUv2 = transformUV(vec3(centeredCoord - _shadowOffset2.xy, _zDist + _zDist2), rotation, UV);

		shadowUv1 = (shadowUv1 - _texPos.xy) / _texPos.zw;
		shadowUv1 -= vec2(tiltAngleY, -tiltAngleX) * 0.1;
		shadowCol1 = texture(TEXTURE, shadowUv1) * _shadowCol;
		shadowCol1.a = IsOutofBounds(shadowUv1) ? 0. : shadowCol1.a;

		if(_isSecondTex){
			vec2 shadowUv2 = (shadowUv2 - _texPos2.xy) / _texPos2.zw;
			shadowUv2 -= vec2(tiltAngleY, -tiltAngleX) * 0.1;
			shadowCol2 = texture(_secondTex, shadowUv2) * _shadowCol;
			shadowCol2.a = IsOutofBounds(shadowUv2) ? 0. : shadowCol2.a;
		}
	}

	//main color with shadow
	vec4 mainCol = mix(shadowCol1, texCol, texCol.a);

	//second color with shadow
	vec4 secondCol = mix(shadowCol2, secondTexCol, secondTexCol.a);

	vec4 finalCol = mix(mainCol, secondCol, secondCol.a);

	//specular light
	float specularvalue = pow(clamp(1.0 - length(uv - 0.5 + mouseoffset), 0.0, 1.0), _speularLightPower) * _speularLightIntensity;
	vec3 specularCol = vec3(specularvalue);

	COLOR = _isSpecularLight ? finalCol + vec4(specularCol, 0.0) : finalCol;

}