/*
 * CC3LibSetGLFragColorAlphaTest.fsh
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
 * This fragment shader library contains a setGLFragColor() function that tests the alpha of
 * the fragment against a threshold and discards the fragment if it is below that threshold.
 *
 * This library includes two algorithms. In the first, the fragments with low alpha are discarded.
 * This has several benefits, including that the fragment is not rendered to the depth buffer,
 * which can help with fog and other post-processing effects.
 *
 * However, fragment discarding can result in significant performance costs. An alternate algorithm
 * that zeros the alpha, is provided. You can use this by commenting out one algo or the other below.
 *
 * This library requires the following local variables be declared and populated outside this library:
 *   - lowp vec4		fragColor;							// The fragment color
 *
 * This library declares and uses the following attribute and uniform variables:
 *   - uniform float	u_cc3MaterialMinimumDrawnAlpha;		// Minimum alpha value to be drawn, otherwise fragment will be rendered fully transparent.
 */

uniform float	u_cc3MaterialMinimumDrawnAlpha;	/**< Minimum alpha value to be drawn, otherwise fragment will be rendered fully transparent. */

/**
 * Algorithm 1. Discard the fragment if it's alpha is under the minimum threshold.
 *
 * This algorithm incurs a performance penalty relative to zeroing the alpha, but can be useful
 * in some circumstances, including fog effects and other effects that depend on the depth buffer,
 * depending on the required blending.
 */
void setGLFragColor() {
	if (fragColor.a >= u_cc3MaterialMinimumDrawnAlpha)
		gl_FragColor = fragColor;
	else
		discard;
}

/** 
 * Algorithm 2. If the fragment is lower than the minimum threshold, force the alpha to zero.
 *
 * This is a more efficient algorithm than discarding the fragment, but in some circumstances,
 * such as effects that rely on the depth buffer, like fog, can be less flexible.
 */
//void setGLFragColor() {
//	if (fragColor.a < u_cc3MaterialMinimumDrawnAlpha) fragColor.a = 0.0;
//
//	gl_FragColor = fragColor;
//}

