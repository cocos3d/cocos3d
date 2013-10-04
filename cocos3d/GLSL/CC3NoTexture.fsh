/*
 * CC3NoTexture.fsh
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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
 * This fragment shader handles a material that does not have a texture.
 *
 * CC3Texturable.vsh is the vertex shader paired with this fragment shader.
 *
 * The semantics of the variables in this shader can be mapped using a
 * CC3ShaderProgramSemanticsByVarName instance.
 */

precision mediump float;

//-------------- UNIFORMS ----------------------
uniform bool		u_cc3FogIsEnabled;			/**< Whether scene fogging is enabled. */
uniform lowp vec4	u_cc3FogColor;				/**< Fog color. */
uniform int			u_cc3FogAttenuationMode;	/**< Fog attenuation mode (one of GL_LINEAR, GL_EXP or GL_EXP2). */
uniform highp float	u_cc3FogDensity;			/**< Fog density. */
uniform highp float	u_cc3FogStartDistance;		/**< Distance from camera at which fogging effect starts. */
uniform highp float	u_cc3FogEndDistance;		/**< Distance from camera at which fogging effect ends. */

//-------------- VARYING VARIABLE INPUTS ----------------------
varying lowp vec4	v_color;					/**< Fragment front-face color. */
varying lowp vec4	v_colorBack;				/**< Fragment back-face color. */
varying highp float v_distEye;					/**< Fragment distance in eye coordinates. */


//-------------- FUNCTIONS ----------------------

/** Applies fog to the specified color and returns the adjusted color. */
lowp vec4 fogify(lowp vec4 aColor) {
	
#	define GL_LINEAR                 0x2601
#	define GL_EXP                    0x0800
#	define GL_EXP2                   0x0801
	
	if ( !u_cc3FogIsEnabled ) return aColor;
	
	// Determine visibility based on fog attentuation characteristics and distance through fog
	float visibility = 1.0;
	if (u_cc3FogAttenuationMode == GL_LINEAR) {
		visibility = (u_cc3FogEndDistance - v_distEye) / (u_cc3FogEndDistance - u_cc3FogStartDistance);
	} else if (u_cc3FogAttenuationMode == GL_EXP) {
		float d = u_cc3FogDensity * v_distEye;
		visibility = exp(-d);
	} else if (u_cc3FogAttenuationMode == GL_EXP2) {
		float d = u_cc3FogDensity * v_distEye;
		visibility = exp(-(d * d));
	}
	visibility = clamp(visibility, 0.0, 1.0);
	
	// Mix alpha-adjusted fog color into fragment color based on visibility.
	aColor.rgb = mix(u_cc3FogColor.rgb * aColor.a, aColor.rgb, visibility);
	return aColor;
}

//-------------- ENTRY POINT ----------------------
void main() {
	lowp vec4 fragColor = gl_FrontFacing ? v_color : v_colorBack;
	
	gl_FragColor = fogify(fragColor);
}
