/*
 * CC3PureColor.vsh
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
 * When running under OpenGL ES 2, this vertex shader is used to paint a node with a pure color.
 *
 * This shader is used during node picking and when a node does not have a material.
 *
 * The semantics of the variables in this shader can be mapped using a
 * CC3GLProgramSemanticsDelegateByVarNames instance created with the
 * populateWithPureColorSemanticMappings method.
 */

precision mediump float;

//-------------- UNIFORMS ----------------------

uniform mat4 u_cc3MtxMVP;						/**< Current modelview-projection matrix. */
attribute highp vec4 a_cc3Position;				/**< Vertex position. */


//-------------- ENTRY POINT ----------------------
void main() {
	gl_Position = u_cc3MtxMVP * a_cc3Position;
}

