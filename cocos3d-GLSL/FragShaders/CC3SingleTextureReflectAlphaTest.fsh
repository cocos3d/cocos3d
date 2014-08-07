/*
 * CC3SingleTextureReflectAlphaTest.fsh
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
 * This fragment shader creates an environmental reflection on a model that has a single visible texture.
 *
 * The shader actually expects two textures. One is the visible texture. The other is a cube-map
 * textures used to provide the environmental reflection.
 *
 * If the alpha component of the fragment is lower than a specified level, the fragment is discarded.
 *
 * This fragment shader can be paired with the following vertex shaders:
 *   - CC3Texturable.vsh
 *   - CC3TexturableBones.vsh
 *   - CC3TexturableRigidBones.vsh
 *
 * The semantics of the variables in this shader can be mapped using a
 * CC3ShaderSemanticsByVarName instance.
 */

#import "CC3LibDefaultPrecision.fsh"
#import "CC3LibDualSidedFragmentColor.fsh"
#import "CC3LibLightProbeIllumination.fsh";
#import "CC3LibEnvironmentReflection.fsh"
#import "CC3LibSingleTexture2D.fsh"
#import "CC3LibSetGLFragColorAlphaTest.fsh"

void main() {
	initFragmentColor();
	illuminateWithLightProbes();
	applyTexture2D();
	addEnvironmentReflection();
	setGLFragColor();
}
