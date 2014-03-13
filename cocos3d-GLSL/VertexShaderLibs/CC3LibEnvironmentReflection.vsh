/*
 * CC3LibEnvironmentReflection.vsh
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
 * This vertex shader library adds reflective materials.
 *
 * This library requires the following local variables be declared and populated outside this library:
 *   - highp vec4			vtxPosition;				// The vertex position. High prec to match vertex attribute.
 *   - vec3					vtxNormal;					// The vertex normal.
 *
 * This library declares and outputs the following variables:
 *   - varying vec3		v_reflectDirGlobal;				// Fragment reflection vector direction in global coordinates.
 */


#import "CC3LibModelMatrices.vsh"
#import "CC3LibCameraPosition.vsh"


varying vec3		v_reflectDirGlobal;			/**< Fragment reflection vector direction in global coordinates. */

/** 
 * For environmental mapping reflection effect, reflects the camera direction into a global-coordinate
 * reflection vector, v_reflectDirGlobal that can be used in a cube-map texture sampler.
 */
void reflectVertex() {
	vec3 camDir = vtxPosition.xyz - u_cc3CameraPositionModel;
	v_reflectDirGlobal = (u_cc3MatrixModel * vec4(reflect(camDir, vtxNormal), 0.0)).xyz;
}

