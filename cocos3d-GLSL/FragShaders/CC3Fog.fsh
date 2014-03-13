/*
 * CC3Fog.fsh
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * http://en.wikipedia.org/wiki/MIT_License
 */

/**
 * This fragment shader is used in a post-processing surface to add a fog effect.
 *
 * This fragment shader can be paired with the following vertex shaders:
 *   - CC3ClipSpaceTexturable.vsh
 *
 * The semantics of the variables in this shader can be mapped using a
 * CC3ShaderSemanticsByVarName instance.
 */

#import "CC3LibDefaultPrecision.fsh"

//-------------- UNIFORMS ----------------------
uniform bool		u_cc3FogIsEnabled;			/**< Whether scene fogging is enabled. */
uniform lowp vec4	u_cc3FogColor;				/**< Fog color. */
uniform int			u_cc3FogAttenuationMode;	/**< Fog attenuation mode (one of GL_LINEAR, GL_EXP or GL_EXP2). */
uniform float		u_cc3FogDensity;			/**< Fog density. */
uniform float		u_cc3FogStartDistance;		/**< Distance from camera at which fogging effect starts. */
uniform float		u_cc3FogEndDistance;		/**< Distance from camera at which fogging effect ends. */

uniform vec4		u_cc3CameraFrustumDepth;	/**< The depth of the camera frustum (far clip, near clip, -(f+n)/(f-n), -2nf/(f-n)). */

// Textures
uniform sampler2D	s_cc3Textures[2];			/**< Texture samplers. Color in first, depth in second. */

//-------------- VARYING VARIABLE INPUTS ----------------------
varying vec2		v_texCoord0;					/**< Fragment texture coordinates. */


//-------------- FUNCTIONS ----------------------

/** 
 * Applies fog to the specified color, the intensity of which is based on the specified 
 * distance to the fragment, in eye-space coordinates, and returns the adjusted color.
 */
lowp vec4 fogify(lowp vec4 aColor, float eyeDist) {
	
#	define k_GL_LINEAR                 0x2601
#	define k_GL_EXP                    0x0800
#	define k_GL_EXP2                   0x0801
	
	if ( !u_cc3FogIsEnabled ) return aColor;
	
	// Determine visibility based on fog attentuation characteristics and distance through fog
	float visibility = 1.0;
	if (u_cc3FogAttenuationMode == k_GL_LINEAR) {
		visibility = (u_cc3FogEndDistance - eyeDist) / (u_cc3FogEndDistance - u_cc3FogStartDistance);
	} else if (u_cc3FogAttenuationMode == k_GL_EXP) {
		float d = u_cc3FogDensity * eyeDist;
		visibility = exp(-d);
	} else if (u_cc3FogAttenuationMode == k_GL_EXP2) {
		float d = u_cc3FogDensity * eyeDist;
		visibility = exp(-(d * d));
	}
	visibility = clamp(visibility, 0.0, 1.0);

	// Mix alpha-adjusted fog color into fragment color based on visibility.
	aColor.rgb = mix(u_cc3FogColor.rgb * aColor.a, aColor.rgb, visibility);
	return aColor;
}

/**
 * Linearizes the specified depth value retrieved from the depth buffer, by converting the 
 * buffer value to normalized device coordinates, and then inverting the camera projection.
 *
 * The returned value is a distance in eye-space coordinates.
 *
 * Given the following values from the camera projection matrix:
 *   - b = -(f+n)/(f-n)		[c3r3 of the projection matrix]
 *   - a = -2nf/(f-n)		[c4r3 of the projection matrix]
 *
 * the z value of a location in eye-space is projected to normalized device coords by the
 * camera projection matrix as follows:
 *   zn = (b*ze + a) / -ze
 *
 * And therefore, the inverse of this, taking the normalized device coordinate to eye-space is:
 *   ze = a / (zn + b)
 */
float linearizeDepth(float zb){
	float zn = 2.0 * zb - 1.0;								// Normalized device coordinates
	return u_cc3CameraFrustumDepth.a / (zn + u_cc3CameraFrustumDepth.b);
}


//-------------- ENTRY POINT ----------------------
void main (void) {
	lowp vec4 fragColor = texture2D(s_cc3Textures[0], v_texCoord0);
	vec4 buffDepth = texture2D(s_cc3Textures[1], v_texCoord0);
	float eyeDepth = linearizeDepth(buffDepth.r);
	gl_FragColor = fogify(fragColor, eyeDepth);
}
