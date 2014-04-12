/*
 * CC3LibLightProbeIllumination.fsh
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
 * This fragment shader library adds an environment reflection on the model.
 *
 * This library declares and uses the following attribute and uniform variables:
 *   - uniform bool			u_cc3LightIsUsingLightProbes;		// Whether the model is using light probes for lighting, instead of lights.
 *   - uniform lowp vec3	u_cc3MaterialEmissionColor;			// Emission color of the material.
 *   - uniform samplerCube	s_cc3LightProbeTexture				// Single light probe texture sampler.
 *
 * This library requires the following local variables be declared and populated outside this library:
 *   - lowp vec4			fragColor;					// The fragment color
 *   - vec3					fragNormalGlobal;			// Local normal in global coordinates.
 */

uniform bool		u_cc3LightIsUsingLightProbes;	/**< Whether the model is using light probes for lighting, instead of lights. */
uniform lowp vec3	u_cc3MaterialEmissionColor;		/**< Emission color of the material. */
uniform samplerCube	s_cc3LightProbeTexture;			/**< Single light probe texture sampler. */

/** 
 * If light probes are being used, modulate the fragment color with a texture lookup representing
 * diffuse and ambient illumination, then add emission color. Otherwise, do nothing.
 */
void illuminateWithLightProbes() {
	if (u_cc3LightIsUsingLightProbes)
		fragColor = vec4(u_cc3MaterialEmissionColor, 0.0) + (textureCube(s_cc3LightProbeTexture, fragNormalGlobal) * fragColor);
}
