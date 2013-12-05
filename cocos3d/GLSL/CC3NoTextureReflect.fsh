/*
 * CC3NoTextureReflect.fsh
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
 * This fragment shader creates an environmental reflection on a model that has no visible texture.
 *
 * Even though there is no visible texture, the shader expects one cube-map texture used to
 * provide the environmental reflection.
 *
 * CC3Texturable.vsh is the vertex shader paired with this fragment shader.
 *
 * The semantics of the variables in this shader can be mapped using a
 * CC3ShaderProgramSemanticsByVarName instance.
 */

precision mediump float;

//-------------- UNIFORMS ----------------------
uniform float		u_cc3MaterialReflectivity;	/**< Reflectivity of the material (0 <> 1). */

// Textures
uniform samplerCube	s_cc3TextureCube;			/**< Reflection cube-map texture sampler. */

//-------------- VARYING VARIABLE INPUTS ----------------------
varying vec2		v_texCoord;					/**< Fragment texture coordinates. */
varying lowp vec4	v_color;					/**< Fragment front-face color. */
varying lowp vec4	v_colorBack;				/**< Fragment back-face color. */
varying vec3		v_reflectDirGlobal;			/**< Fragment reflection vector direction in global coordinates. */

//-------------- ENTRY POINT ----------------------
void main() {
	lowp vec4 fragColor = gl_FrontFacing ? v_color : v_colorBack;
	
	// Mix the fragment color with the reflection color in proportion to the material reflectivity
	lowp vec4 reflectColor = textureCube(s_cc3TextureCube, v_reflectDirGlobal);
	fragColor = mix(fragColor, reflectColor, u_cc3MaterialReflectivity);
	
	gl_FragColor = fragColor;
}
