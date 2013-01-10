/*
 * CC3PVRShamanGLProgramSemantics.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
 * 
 * See header file CC3PVRShamanGLProgramSemantics.h for full API documentation.
 */

#import "CC3PVRShamanGLProgramSemantics.h"


#pragma mark -
#pragma mark CC3PVRShamanGLProgramSemantics

@implementation CC3PVRShamanGLProgramSemantics

-(GLenum) semanticForPFXSemanticName: (NSString*) semanticName {
	return [self.class semanticForPVRShamanSemanticName: semanticName];
}

static NSMutableDictionary* _semanticsByPVRShamanSemanticName = nil;

+(GLenum) semanticForPVRShamanSemanticName: (NSString*) semanticName {
	[self ensurePVRShamanSemanticMap];
	NSNumber* semNum = [_semanticsByPVRShamanSemanticName objectForKey: semanticName];
	return semNum ? semNum.unsignedIntValue : kCC3SemanticNone;
}

+(void) addSemantic: (GLenum) semantic forPVRShamanSemanticName: (NSString*) semanticName {
	[self ensurePVRShamanSemanticMap];
	[_semanticsByPVRShamanSemanticName setObject: [NSNumber numberWithUnsignedInt: semantic]
										  forKey: semanticName];
}

+(void) ensurePVRShamanSemanticMap {
	if (_semanticsByPVRShamanSemanticName) return;

	_semanticsByPVRShamanSemanticName = [NSMutableDictionary new];		// retained
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"POSITION"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"NORMAL"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"TANGENT"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"BINORMAL"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"UV"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"VERTEXCOLOR"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"BONEINDEX"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"BONEWEIGHT"];

	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"WORLD"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"WORLDI"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"WORLDIT"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"VIEW"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"VIEWI"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"VIEWIT"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"PROJECTION"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"PROJECTIONI"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"PROJECTIONIT"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"WORLDVIEW"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"WORLDVIEWI"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"WORLDVIEWIT"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"WORLDVIEWPROJECTION"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"WORLDVIEWPROJECTIONI"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"WORLDVIEWPROJECTIONIT"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"VIEWPROJECTION"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"VIEWPROJECTIONI"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"VIEWPROJECTIONIT"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"OBJECT"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"OBJECTI"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"OBJECTIT"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"UNPACKMATRIX"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"MATERIALOPACITY"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"MATERIALSHININESS"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"MATERIALCOLORAMBIENT"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"MATERIALCOLORDIFFUSE"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"MATERIALCOLORSPECULAR"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"BONECOUNT"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"BONEMATRIXARRAY"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"BONEMATRIXARRAYIT"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"LIGHTCOLOR"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"LIGHTPOSMODEL"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"LIGHTPOSWORLD"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"LIGHTPOSEYE"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"LIGHTDIRMODEL"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"LIGHTDIRWORLD"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"LIGHTDIREYE"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"LIGHTATTENUATION"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"LIGHTFALLOFF"];

	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"EYEPOSMODEL"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"EYEPOSWORLD"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"TEXTURE"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"ANIMATION"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"VIEWPORTPIXELSIZE"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"VIEWPORTCLIPPING"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"TIME"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"TIMECOS"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"TIMESIN"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"TIMETAN"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"TIME2PI"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"TIME2PICOS"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"TIME2PISIN"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"TIME2PITAN"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"RANDOM"];
}

@end


