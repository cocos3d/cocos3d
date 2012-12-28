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

#define MAX_TEXTURES			4

precision mediump float;

//-------------- STRUCTURES ----------------------

/**
 * The parameters to use when displaying vertices as points.
 *
 * When using this structure as the basis of a simpler implementation, remove any elements
 * that your shader does not use, to reduce the number of uniforms that need to be retrieved
 * and pased to your shader (uniform structure elements are passed individually in GLSL).
 */
struct Point {
	float	size;							/**< Default size of points, if not specified per-vertex. */
	float	minimumSize;					/**< Minimum size to which points will be allowed to shrink. */
	float	maximumSize;					/**< Maximum size to which points will be allowed to grow. */
	vec3	sizeAttenuation;				/**< Coefficients of the size attenuation equation. */
	float	sizeFadeThreshold;				/**< Alpha fade threshold for smaller points. */
	bool	isDrawingPoints;				/**< Whether the vertices are being drawn as points. */
	bool	hasVertexPointSize;				/**< Whether vertex point size attribute is available. */
	bool	shouldDisplayAsSprites;			/**< Whether points should be interpeted as textured sprites. */
};


//-------------- UNIFORMS ----------------------

uniform bool u_cc3HasVertexTexCoord;			/**< Whether vertex texture coordinate attribute is available. */
uniform lowp int u_cc3TextureCount;				/**< Number of textures. */
uniform sampler2D s_cc3Texture[MAX_TEXTURES];	/**< Texture samplers. */
uniform Point u_cc3Points;						/**< Point parameters. */


//-------------- VARYING VARIABLES INPUTS ----------------------
varying vec2 v_texCoord[MAX_TEXTURES];
varying lowp vec4 v_color;

void main() {
	if (u_cc3HasVertexTexCoord) {
		gl_FragColor = texture2D(s_cc3Texture[0], v_texCoord[0]) * v_color;
	} else if (u_cc3Points.isDrawingPoints && u_cc3Points.shouldDisplayAsSprites) {
		gl_FragColor = texture2D(s_cc3Texture[0], gl_PointCoord) * v_color;
	} else {
		gl_FragColor = v_color;
	}
}

