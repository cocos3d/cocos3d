/*
 * CC3DefaultByVarNames.fsh
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * When running under OpenGL ES 2, this fragment shader is used as a default when a
 * CC3Material has not been assigned a specific GL shader program.
 *
 * CC3DefaultByVarNames.vsh is the vertex shader associated with this fragment shader.
 *
 * The semantics of the variables in this shader can be mapped using the
 * CC3GLProgramSemanticsDelegateByVarNames sharedDefaultDelegate instance.
 */

#define MAX_TEXTURES				4

precision mediump float;

//-------------- UNIFORMS ----------------------

uniform lowp int u_cc3TexCoordCount;			/**< Number of texture coordinate attributes. */

//-------------- TEXTURE SAMPLERS ----------------------
uniform sampler2D s_cc3Texture[MAX_TEXTURES];

//-------------- VARYING VARIABLES INPUTS ----------------------
varying vec2 v_texCoord[MAX_TEXTURES];
varying lowp vec4 v_color;

void main() {
	if (u_cc3TexCoordCount > 0)
		gl_FragColor = texture2D(s_cc3Texture[0], v_texCoord[0]) * v_color;
	else
		gl_FragColor = v_color;
}

