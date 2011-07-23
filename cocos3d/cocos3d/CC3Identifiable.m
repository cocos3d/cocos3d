/*
 * CC3Identifiable.m
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
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

@synthesize tag, name;

static GLint instanceCount = 0;

-(void) dealloc {
	[name release];
	instanceCount--;
	[super dealloc];
}


#pragma mark Allocation and initialization

-(id) init {
	return [self initWithName: nil];
}

-(id) initWithTag: (GLuint) aTag {
	return [self initWithTag: aTag withName: nil];
}

-(id) initWithName: (NSString*) aName {
	return [self initWithTag: [self nextTag] withName: aName];
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super init]) ) {
		instanceCount++;
		self.tag = aTag;
		self.name = aName;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// Default does nothing. Subclasses that extend copying will override this method.
-(void) populateFrom: (CC3Identifiable*) another {}

// Implementation to keep compiler happy so this method can be included in interface for documentation.
-(id) copy { return [super copy]; }

// Subclasses that extend copying should not override this method,
// but should override the populateFrom: method instead.
-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName {
	CC3Identifiable* aCopy = [[[self class] allocWithZone: zone] initWithName: aName];
	[aCopy populateFrom: self];
	return aCopy;
}

// Subclasses that extend copying should not override this method,
// but should override the populateFrom: method instead.
-(id) copyWithName: (NSString*) aName {
	return [self copyWithZone: nil withName: aName];
}

// Subclasses that extend copying should not override this method,
// but should override the populateFrom: method instead.
-(id) copyWithZone: (NSZone*) zone {
	return [self copyWithZone: zone withName: self.name];
}

// Class variable tracking the most recent tag value assigned. This class variable is 
// automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedTag;

-(GLuint) nextTag {
	return ++lastAssignedTag;
}

+(void) resetTagAllocation {
	lastAssignedTag = 0;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@-%u", [self class], (name ? name : @"Unnamed"), tag];
}

-(NSString*) fullDescription {
	return [self description];
}

+(GLint) instanceCount {
	return instanceCount;
}

@end
