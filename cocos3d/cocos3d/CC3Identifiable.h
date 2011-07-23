/*
 * CC3Identifiable.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Foundation.h"

/**
 * This is a base subclass for any class that uses tags or names to identify individual instances.
 * Instances can be initialized with either or both a tag and a name. Instances initialized without
 * an explcit tag will have a unique tag automatically generated and assigned.
 *
 * When overriding initialization, subclasses typically need only override the most generic
 * initializer, initWithTag:withName:.
 */
@interface CC3Identifiable : NSObject <NSCopying> {
	GLuint tag;
	NSString* name;
}

/**
 * An arbitrary identification. Useful for keeping track of instances. Unique tags are not explicitly
 * required, but are highly recommended. In most cases, it is best to just let the tag be assigned
 * automatically by using an initializer that does not explicitly set the tag.
 */
@property(nonatomic, assign) GLuint tag;

/**
 * An arbitrary name for this node. It is not necessary to give all identifiable objects a name,
 * but can be useful for retrieving objects at runtime, and for identifying objects during development.
 * Names need not be unique, are not automatically assigned, and leaving the name as nil is acceptable.
 */
@property(nonatomic, retain) NSString* name;


#pragma mark Allocation and initialization

/**
 * Initializes this unnamed instance with an automatically generated unique tag value.
 * The tag value will be generated automatically via the method nextTag.
 */
-(id) init;

/** Initializes this unnamed instance with the specified tag. */
-(id) initWithTag: (GLuint) aTag;

/**
 * Initializes this instance with the specified name and an automatically generated unique tag value.
 * The tag value will be generated automatically via the method nextTag.
 */
-(id) initWithName: (NSString*) aName;

/**
 * Initializes this instance with the specified tag and name.
 * When overriding initialization, subclasses typically need only override this initializer.
 */
-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy will have the
 * same name as this instance, but will have a unique tag.
 *
 * This method may often be used to duplicate an instance many times, to create large
 * number of similar instances to populate a game. To help you verify that you are correctly
 * releasing and deallocating all these copies, you can use the instanceCount class method
 * to get a current count of the total number of instances of all subclasses of CC3Identifiable,
 */
 -(id) copy;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy will have its
 * name set to the specified name, and will have a unique tag.
 */
-(id) copyWithName: (NSString*) aName;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy will have its
 * name set to the specified name, and will have a unique tag.
 */
-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName;
	
/**
 * Returns a unique tag value to identify instances. This value is unique across all instances
 * of all subclasses. The initial value returned will be one, and subsequent calls will increment
 * the value retuned on each call. The starting value can be reset back to one via the
 * resetTagAllocation method.
 */
-(GLuint) nextTag;

/** Resets the allocation of new tags to resume at one again. */
+(void) resetTagAllocation;

/**
 * Indicates the total number of active instances, over all subclasses, that have been allocated
 * and initialized, but not deallocated. This can be useful when creating hordes of 3D objects,
 * to verify that your application is properly deallocating them again when you are done with them.
 */
+(GLint) instanceCount;

/**
 * Returns a string containing a more complete description of this object.
 *
 * This implementation simply invokes the description method. Subclasses with more
 * substantial content can override to provide much more information.
 */
-(NSString*) fullDescription;

@end
