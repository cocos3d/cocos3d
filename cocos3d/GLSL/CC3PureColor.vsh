/*
 * CC3PureColor.vsh
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
 * When running under OpenGL ES 2, this vertex shader is used to paint a node with a pure color.
 *
 * This shader is used during node picking and when a node does not have a material.
 *
 * The semantics of the variables in this shader can be mapped using the
 * CC3GLProgramSemanticsByVarName sharedDefaultDelegate instance.
 */

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


//-------------- UNIFORMS & VERTEX ATTRIBUTES ----------------------

uniform mat4 u_cc3MtxModelView;						/**< Current modelview matrix. */
uniform highp mat4 u_cc3MtxModelViewProj;					/**< Current modelview-projection matrix. */
uniform Point u_cc3Points;						/**< Point parameters. */

//-------------- VERTEX ATTRIBUTES ----------------------
attribute highp vec4 a_cc3Position;				/**< Vertex position. */
attribute float a_cc3PointSize;					/**< Vertex point size. */

//-------------- CONSTANTS ----------------------
const vec3 kVec3Zero = vec3(0.0, 0.0, 0.0);
const vec3 kAttenuationNone = vec3(1.0, 0.0, 0.0);

//-------------- LOCAL VARIABLES ----------------------
highp vec3 vtxPosEye;		/**< The position of the vertex, in eye coordinates. High prec required for point sizing calcs. */


//-------------- FUNCTIONS ----------------------

/** Returns the vertex position in eye space, if it is needed. Otherwise, returns the zero vector. */
highp vec3 vertexPositionInEyeSpace() {
	if(u_cc3Points.isDrawingPoints && u_cc3Points.sizeAttenuation != kAttenuationNone)
		return (u_cc3MtxModelView * a_cc3Position).xyz;
	else
		return vec3(0.0, 0.0, 0.0);
}

/**
 * If this vertices are being drawn as points, returns the size of the point for the current vertex.
 * If the size is not needed, or if the size cannot be determined, returns the value one.
 */
float pointSize() {
	float size = 1.0;
	if (u_cc3Points.isDrawingPoints) {
		size = u_cc3Points.hasVertexPointSize ? a_cc3PointSize : u_cc3Points.size;
		if (u_cc3Points.sizeAttenuation != kAttenuationNone && u_cc3Points.sizeAttenuation != kVec3Zero) {
			vec3 attenuationEquation;
			attenuationEquation.x = 1.0;
			attenuationEquation.z = dot(vtxPosEye, vtxPosEye);
			attenuationEquation.y = sqrt(attenuationEquation.z);
			size /= dot(attenuationEquation, u_cc3Points.sizeAttenuation);
		}
		size = clamp(size, u_cc3Points.minimumSize, u_cc3Points.maximumSize);
	}
	return size;
}

//-------------- ENTRY POINT ----------------------
void main() {

	// The vertex position in eye space. If not needed, it is simply set to the zero vector.
	vtxPosEye = vertexPositionInEyeSpace();

	gl_Position = u_cc3MtxModelViewProj * a_cc3Position;
	
	gl_PointSize = pointSize();
}

