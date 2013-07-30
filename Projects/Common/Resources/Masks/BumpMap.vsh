attribute highp vec4  inVertex;
attribute highp vec3  inNormal;
attribute highp vec2  inTexCoord;
attribute highp vec3  inTangent;

uniform highp mat4  MVPMatrix;		// model view projection transformation
uniform highp vec3  LightDirModel;	// Light direction in model space

varying lowp vec3  LightVec;
varying mediump vec2  TexCoord;

void main() {
	
	// PVR semantic for light direction is from light to model.
	// We need the vector from model to light, so flip light direction.
	highp vec3 lightDir = -LightDirModel;

	// Transform light direction from model space to tangent space.
	highp vec3 bitangent = cross(inNormal, inTangent);
	highp mat3 tangentSpaceXform = mat3(inTangent, bitangent, inNormal);
	LightVec = lightDir * tangentSpaceXform;

	gl_Position = MVPMatrix * inVertex;
	TexCoord = inTexCoord;
}
