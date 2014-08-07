/*
 * CC3LibDualSidedFragmentColor.fsh
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
 * This fragment shader library initializes the fragment color from either the front or back color
 * set by the vertex shader, depending on whether the fragment is front-facing or back-facing.
 *
 * This library requires the following varying variables be declared and populated in the vertex shader:
 *   - varying lowp vec4	v_color;				// Fragment front-face color.
 *   - varying lowp vec4	v_colorBack;			// Fragment back-face color.
 *   - varying vec3			v_vtxNormalGlobal;		// Vertex normal in global coordinates.
 *
 * This library declares and sets the intial values of the following local variables:
 *   - lowp vec4			fragColor;				// The fragment color
 *   - vec3					fragNormalGlobal;		// Local normal in global coordinates.
 */

varying lowp vec4	v_color;			/**< Fragment front-face color. */
varying lowp vec4	v_colorBack;		/**< Fragment back-face color. */
varying vec3		v_vtxNormalGlobal;	/**< Vertex normal in global coordinates. */

lowp vec4			fragColor;			/**< Local fragment color variable. */
vec3				fragNormalGlobal;	/**< Local normal in global coordinates. */

/** 
 * Sets the initial value of the fragment color from either the front 
 * or back varying color established by the vertex shader.
 */
void initFragmentColor() {
	if (gl_FrontFacing) {
		fragColor = v_color;
		fragNormalGlobal = v_vtxNormalGlobal;
	} else {
		fragColor = v_colorBack;
		fragNormalGlobal = -v_vtxNormalGlobal;
	}
}
