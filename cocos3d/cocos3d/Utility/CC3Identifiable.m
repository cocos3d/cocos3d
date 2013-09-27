/*
 * CC3Identifiable.m
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
 * See header file CC3Identifiable.h for full API documentation.
 */

#import "CC3Identifiable.h"

@implementation CC3Identifiable

@synthesize tag=_tag, name=_name;

static GLint instanceCount = 0;

-(void) dealloc {
	[self releaseUserData];
	[_name release];
	instanceCount--;
	[super dealloc];
}

-(BOOL) deriveNameFrom: (CC3Identifiable*) another {
	return [self deriveNameFrom: another usingSuffix: self.nameSuffix];
}

-(BOOL) deriveNameFrom: (CC3Identifiable*) another usingSuffix: (NSString*) suffix {
	if (_name) return NO;
	NSString* otherName = another.name;
	if ( !otherName ) return NO;
	if ( !suffix ) return NO;
	self.name = [NSString stringWithFormat: @"%@-%@", otherName, suffix];
	return YES;
}

-(NSString*) nameSuffix {
	CC3Assert(NO, @"%@ must override the nameSuffix property.", [self class]);
	return nil;
}

-(GLvoid*) userData { return _userData; }

-(void) setUserData: (GLvoid*) userData {
	[self releaseUserData];
	_userData = userData;
}

-(GLvoid*) sharedUserData { return _userData ? *((GLvoid**)_userData) : NULL; }

-(void) setSharedUserData: (GLvoid*) sharedUserData {
	GLvoid** udp = malloc(sizeof(GLvoid*));
	*udp = sharedUserData;
	self.userData = udp;
}


#pragma mark Allocation and initialization

-(id) init { return [self initWithName: nil]; }

-(id) initWithTag: (GLuint) aTag { return [self initWithTag: aTag withName: nil]; }

-(id) initWithName: (NSString*) aName {
	return [self initWithTag: [self nextTag] withName: aName];
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super init]) ) {
		instanceCount++;
		self.tag = aTag;
		self.name = aName;
		[self initUserData];
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// Subclasses that extend copying will override this method.
-(void) populateFrom: (CC3Identifiable*) another {
	[self copyUserDataFrom: another];
}

// Implementation to keep compiler happy so this method can be included in interface for documentation.
-(id) copy { return [super copy]; }

-(id) copyWithZone: (NSZone*) zone { return [self copyWithZone: zone withName: self.name]; }

-(id) copyWithName: (NSString*) aName { return [self copyWithZone: nil withName: aName]; }

-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName {
	return [self copyWithZone: zone withName: aName asClass: [self class]];
}

-(id) copyAsClass: (Class) aClass { return [self copyWithName: self.name asClass: aClass]; }

-(id) copyWithName: (NSString*) aName asClass: (Class) aClass {
	return [self copyWithZone: nil withName: aName asClass: aClass];
}

-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName asClass: (Class) aClass {
	CC3Identifiable* aCopy = [[aClass allocWithZone: zone] initWithName: aName];
	[aCopy populateFrom: self];
	return aCopy;
}

-(BOOL) shouldIncludeInDeepCopy { return YES; }

-(void) initUserData { _userData = NULL; }

-(void) releaseUserData {
	free(_userData);
	_userData = NULL;
}

-(void) copyUserDataFrom: (CC3Identifiable*) another {}

// Class variable tracking the most recent tag value assigned. This class variable is 
// automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedTag;

-(GLuint) nextTag { return ++lastAssignedTag; }

+(void) resetTagAllocation { lastAssignedTag = 0; }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@:%u", [self class], (_name ? _name : @"Unnamed"), _tag];
}

-(NSString*) fullDescription { return [self description]; }

+(GLint) instanceCount { return instanceCount; }

@end
