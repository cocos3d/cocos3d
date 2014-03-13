/*
 * CC3ClipSpaceTexturable.vsh
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
 * This vertex shader provides a very simple shader for rendering in clip-space,
 * with or without a texture. No transform matrices are applied in this shader.
 *
 * This vertex shader can be paired with the following fragment shaders:
 *   - CC3ClipSpaceSingleTexture.fsh
 *   - CC3ClipSpaceNoTexture.fsh
 *   - CC3PureColor.fsh (for node picking from touches)
 *
 * The semantics of the variables in this shader can be mapped using a
 * CC3ShaderSemanticsByVarName instance.
 */

#import "CC3LibDefaultPrecision.vsh"

//-------------- UNIFORMS ----------------------

uniform lowp vec4		u_cc3Color;				/**< Color when lighting & materials are not in use. */
uniform bool			u_cc3VertexHasColor;	/**< Whether the vertex color is available. */

//-------------- VERTEX ATTRIBUTES ----------------------
attribute highp vec4	a_cc3Position;			/**< Vertex position. */
attribute lowp vec4		a_cc3Color;				/**< Vertex color. */
attribute vec2			a_cc3TexCoord;			/**< Vertex texture coordinate. */

//-------------- VARYING VARIABLE OUTPUTS ----------------------
varying lowp vec4		v_color;				/**< Fragment base color. */
varying vec2			v_texCoord0;			/**< Fragment texture coordinates. */


//-------------- ENTRY POINT ----------------------
void main() {
	
	// If vertices have individual colors, use them, otherwise use pure color.
	v_color = u_cc3VertexHasColor ? a_cc3Color : u_cc3Color;
	v_texCoord0	= a_cc3TexCoord;
	gl_Position = a_cc3Position;
}

