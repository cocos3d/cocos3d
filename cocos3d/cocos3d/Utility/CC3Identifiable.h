/*
 * CC3Identifiable.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Cache.h"


#pragma mark CC3Identifiable

/**
 * This is a base subclass for any class that uses tags or names to identify individual instances.
 * Instances can be initialized with either or both a tag and a name. Instances initialized without
 * an explcit tag will have a unique tag automatically generated and assigned.
 *
 * You can assign your own data to instances of CC3Identifiable or its subclasses through the
 * userData property.
 *
 * When overriding initialization, subclasses typically need only override the most generic
 * initializer, initWithTag:withName:.
 */
@interface CC3Identifiable : NSObject <CC3Cacheable, NSCopying> {
	GLuint _tag;
	NSString* _name;
	GLvoid* _userData;
}

/**
 * An arbitrary identification. Useful for keeping track of instances. Unique tags are not explicitly
 * required, but are highly recommended. In most cases, it is best to just let the tag be assigned
 * automatically by using an initializer that does not explicitly set the tag.
 */
@property(nonatomic, assign) GLuint tag;

/**
 * An arbitrary name for this object. It is not necessary to give all identifiable objects
 * a name, but can be useful for retrieving objects at runtime, and for identifying objects
 * during development. 
 *
 * In general, names need not be unique, are not automatically assigned, and leaving the name
 * as nil is acceptable.
 *
 * Some subclasses are designed so that their instances can be cached. For instances of those
 * subclasses, the name is required, and must be unique.
 */
@property(nonatomic, retain) NSString* name;

/**
 * If this instance does not already have a name, it is derived from the name of the specified
 * other CC3Identifiable, if it has one. If this instance has a name already, or if the other
 * CC3Identifiable does not have a name, the name of this instance is not changed.
 *
 * Typically, this is invoked when one CC3Identifiable is added as a component to another.
 *
 * This implementation concatenates the value of the nameSuffix property of this instance onto
 * the name of the specified CC3Identifiable, and sets that into the name property of this
 * instance. If a subclass returns nil from the nameSuffix property, no name is generated.
 *
 * Returns whether the name of this instance was changed.
 */
-(BOOL) deriveNameFrom: (CC3Identifiable*) another;

/**
 * If this instance does not already have a name, it is derived from the name of the specified
 * other CC3Identifiable, if it has one. If this instance has a name already, or if the other
 * CC3Identifiable does not have a name, the name of this instance is not changed.
 *
 * Typically, this is invoked when one CC3Identifiable is added as a component to another.
 *
 * This implementation concatenates the value of the specified suffix onto the name of the
 * specified CC3Identifiable, and sets that into the name property of this instance.
 *
 * Returns whether the name of this instance was changed.
 */
-(BOOL) deriveNameFrom: (CC3Identifiable*) another usingSuffix: (NSString*) suffix;

/**
 * Returns a string to concatenate to the name of another CC3Identifiable to automatically
 * create a useful name for this instance.
 *
 * This property is used by the deriveNameFrom: method.
 * 
 * This implementation simply raises an assertion exception. Each concrete subclass should
 * override this property to return a useful identifiable name suffix. A subclass can return
 * nil from this property to indicate that automatic naming should not be performed.
 */
@property(nonatomic, readonly) NSString* nameSuffix;


#pragma mark User data

/**
 * Application-specific data associated with this object.
 *
 * You can use this property to add any data you want to an instance of CC3Identifiable or its
 * concrete subclasses (CC3Node, CC3Mesh, CC3Material, CC3Texture, etc.). Since this is a generic
 * pointer, you can store any type of data, such as an object, structure, primitive, or array.
 *
 * The data in this property is retained by this instance, and will automatically be freed
 * by the releaseUserData method when this instance is deallocated. If you have instances
 * that share access to common user data, you should use the sharedUserData property instead,
 * which does not automatically free the shared data on deallocation.
 *
 * To assist in managing this data, the methods initUserData and releaseUserData are invoked
 * automatically during the initialization and deallocation of each instance of this class.
 * You can override these methods by subclassing, or by adding extention categories to the
 * concrete subclasses of CC3Identifiable, (CC3Node, CC3Mesh, CC3Material, CC3Texture, etc.),
 * to create, retain and dispose of the data.
 *
 * When copying instances of CC3Identifiable and its subclasses, the copyUserDataFrom: method
 * is invoked in the new copy so that it can copy the data in the original instance to the new
 * instance copy. In this abstract class, the copyUserDataFrom: method does nothing, but, if
 * appropriate, you can override the method by subclassing or by adding extention categories
 * to the concrete subclasses of CC3Identifiable, (CC3Node, CC3Mesh, CC3Material, CC3Texture,
 * etc.), to copy whatever data you have in the userData property.
 */
@property(nonatomic, assign) GLvoid* userData;

/**
 * Application-specific data associated with this object, that is shared between multiple
 * instances and objects.
 *
 * This property is similar to the userData property (and makes use of the userData property),
 * but differs in that the user data is not automatically freed when this instance is deallocated.
 * This makes it suitable to reference user data that is shared between many objects.
 *
 * When this property is set to point to user data, the user data is wrapped in a container
 * pointer, which is set into the userData property. When this instance is deallocated, the
 * container pointer is automatically freed, but the underlying shared data is not.
 *
 * When retrieving the user data via this property, the container pointer is automatically
 * dereferenced, and this property returns a pointer to the the actual underlying user data.
 *
 * When copying instances of CC3Identifiable and its subclasses, the copyUserDataFrom: method
 * is invoked in the new copy so that it can copy the data in the original instance to the new
 * instance copy. In this abstract class, the copyUserDataFrom: method does nothing, but, if
 * appropriate, you can override the method by subclassing or by adding extention categories
 * to the concrete subclasses of CC3Identifiable, (CC3Node, CC3Mesh, CC3Material, CC3Texture,
 * etc.), to copy whatever data you have in the userData property.
 */
@property(nonatomic, assign) GLvoid* sharedUserData;

/**
 * Invoked automatically from the init* family of methods to initialize the userData property.
 *
 * This implementation simply sets the userData property to NULL. You can override this method
 * in a subclass or by creating extension categories for the concrete subclasses, (CC3Node,
 * CC3Mesh, CC3Material, CC3Texture, etc.), if the userData can be initialized and retained
 * in a self-contained manner.
 *
 * Alternately, you can leave this method unimplemented, and add accessor methods (eg- property
 * methods) that work with the user data content that you define, and have the setter accessor
 * allocate the appropriate content, and then use the userData property to set a pointer to
 * that content in the userData property.
 */
-(void) initUserData;

/**
 * Invoked automatically from the dealloc method to release or dispose of the data referenced
 * in the userData property.
 *
 * This implementation frees the memory pointed to by the userData property, and sets the
 * property to NULL. You can override this method in a subclass or by creating extension
 * categories for the concrete subclasses (CC3Node, CC3Mesh, CC3Material, CC3Texture, etc.),
 * if releasing the user data requires more sophisticated behaviour.
 */
-(void) releaseUserData;

/**
 * Invoked automatically when this instance has been created as a copy of the specified instance.
 *
 * In this abstract class, this method does nothing. You can override this method by creating
 * extension categories for the concrete subclasses (CC3Node, CC3Mesh, CC3Material, CC3Texture,
 * etc.), to copy the userData referenced in the userData property of the specified
 * instance to the userData property of this instance.
 *
 * When implementing this method, you must take into consideration whether the data is shared
 * between the original instance and this instance. If the data is to be shared, use the
 * sharedUserData property to set the user data into this instance. If the user data is not
 * to be shared, and a fresh copy of the user data is to be assigned to this instance, use
 * the userData property to set the user data, so that it will automatically be freed when
 * this instance is deallocated.
 */
-(void) copyUserDataFrom: (CC3Identifiable*) another;


#pragma mark Allocation and initialization

/**
 * Initializes this unnamed instance with an automatically generated unique tag value.
 * The tag value will be generated automatically via the method nextTag.
 */
-(id) init;

/** Initializes this unnamed instance with the specified tag. */
-(id) initWithTag: (GLuint) aTag;

/**
 * Initializes this instance with the specified name and an automatically generated unique
 * tag value. The tag value will be generated automatically via the method nextTag.
 */
-(id) initWithName: (NSString*) aName;

/**
 * Initializes this instance with the specified tag and name.
 * When overriding initialization, subclasses typically need only override this initializer.
 */
-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy will have
 * the same name as this instance, but will have a unique tag.
 *
 * The returned instance is retained. It is the responsiblity of the caller to manage
 * the lifecycle of the returned instance and perform the corresponding invocation of
 * the release method at the appropriate time.
 *
 * This copy operation is a deep copy. Copies of most of the content of the original
 * will be created as well. For structural subclasses, such as CC3Node, copies will
 * be made of each structual element (eg- child nodes). Some exceptions are made.
 * For instance, copies are generally not made for fixed, voluminous content such as
 * mesh data. In addition, subclasses may excuse themselves from being copied through
 * the shouldIncludeInDeepCopy property.
 *
 * This copy operation is a deep copy. Copies of most of the content of the original
 * will be created as well. For structural subclasses, such as CC3Node, copies will
 * be made of each structual element (eg- child nodes). Some exceptions are made.
 * For instance, copies are generally not made for fixed, voluminous content such as
 * mesh data. In addition, subclasses may excuse themselves from being copied through
 * the shouldIncludeInDeepCopy property.
 *
 * The copy... methods may often be used to duplicate an instance many times, to create
 * large number of similar instances to populate a game. To help you verify that you are
 * correctly releasing and deallocating all these copies, you can use the instanceCount
 * class method to get a current count of the total number of instances of all subclasses
 * of CC3Identifiable,
 *
 * Subclasses that extend copying should not override this method, but should override
 * the populateFrom: method instead.
 */
 -(id) copy;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy
 * will have its name set to the specified name, and will have a unique tag.
 *
 * The returned instance is retained. It is the responsiblity of the caller to manage
 * the lifecycle of the returned instance and perform the corresponding invocation of
 * the release method at the appropriate time.
 *
 * This copy operation is a deep copy. Copies of most of the content of the original
 * will be created as well. For structural subclasses, such as CC3Node, copies will
 * be made of each structual element (eg- child nodes). Some exceptions are made.
 * For instance, copies are generally not made for fixed, voluminous content such as
 * mesh data. In addition, subclasses may excuse themselves from being copied through
 * the shouldIncludeInDeepCopy property.
 *
 * The copy... methods may often be used to duplicate an instance many times, to create
 * large number of similar instances to populate a game. To help you verify that you are
 * correctly releasing and deallocating all these copies, you can use the instanceCount
 * class method to get a current count of the total number of instances of all subclasses
 * of CC3Identifiable,
 *
 * Subclasses that extend copying should not override this method, but should override
 * the populateFrom: method instead.
 */
-(id) copyWithName: (NSString*) aName;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy will be an instance
 * of the specified class, will have the same name as this instance, and will have a unique tag.
 *
 * Care should be taken when choosing the class to be instantiated. If the class is different
 * than that of this instance, the populateFrom: method of that class must be compatible with
 * the contents of this instance.
 *
 * The returned instance is retained. It is the responsiblity of the caller to manage the
 * lifecycle of the returned instance and perform the corresponding invocation of the release
 * method at the appropriate time.
 *
 * This copy operation is a deep copy. Copies of most of the content of the original will be created
 * as well. For structural subclasses, such as CC3Node, copies will be made of each structual element
 * (eg- child nodes). Some exceptions are made. For instance, copies are generally not made for fixed,
 * voluminous content such as mesh data. In addition, subclasses may excuse themselves from being
 * copied through the shouldIncludeInDeepCopy property.
 *
 * The copy... methods may often be used to duplicate an instance many times, to create large number
 * of similar instances to populate a game. To help you verify that you are correctly releasing and
 * deallocating all these copies, you can use the instanceCount class method to get a current count
 * of the total number of instances of all subclasses of CC3Identifiable,
 *
 * Subclasses that extend copying should not override this method, but should override the
 * populateFrom: method instead.
 */
-(id) copyAsClass: (Class) aClass;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy
 * will be an instance of the specified class, will have its name set to the
 * specified name, and will have a unique tag.
 *
 * Care should be taken when choosing the class to be instantiated. If the class is
 * different than that of this instance, the populateFrom: method of that class must
 * be compatible with the contents of this instance.
 *
 * The returned instance is retained. It is the responsiblity of the caller to manage
 * the lifecycle of the returned instance and perform the corresponding invocation of
 * the release method at the appropriate time.
 *
 * This copy operation is a deep copy. Copies of most of the content of the original
 * will be created as well. For structural subclasses, such as CC3Node, copies will
 * be made of each structual element (eg- child nodes). Some exceptions are made.
 * For instance, copies are generally not made for fixed, voluminous content such as
 * mesh data. In addition, subclasses may excuse themselves from being copied through
 * the shouldIncludeInDeepCopy property.
 *
 * The copy... methods may often be used to duplicate an instance many times, to create
 * large number of similar instances to populate a game. To help you verify that you are
 * correctly releasing and deallocating all these copies, you can use the instanceCount
 * class method to get a current count of the total number of instances of all subclasses
 * of CC3Identifiable,
 *
 * Subclasses that extend copying should not override this method, but should override
 * the populateFrom: method instead.
 */
-(id) copyWithName: (NSString*) aName asClass: (Class) aClass;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy
 * will have its name set to the specified name, and will have a unique tag.
 *
 * The returned instance is retained. It is the responsiblity of the caller to manage
 * the lifecycle of the returned instance and perform the corresponding invocation of
 * the release method at the appropriate time.
 *
 * This copy operation is a deep copy. Copies of most of the content of the original
 * will be created as well. For structural subclasses, such as CC3Node, copies will
 * be made of each structual element (eg- child nodes). Some exceptions are made.
 * For instance, copies are generally not made for fixed, voluminous content such as
 * mesh data. In addition, subclasses may excuse themselves from being copied through
 * the shouldIncludeInDeepCopy property.
 *
 * The copy... methods may often be used to duplicate an instance many times, to create
 * large number of similar instances to populate a game. To help you verify that you are
 * correctly releasing and deallocating all these copies, you can use the instanceCount
 * class method to get a current count of the total number of instances of all subclasses
 * of CC3Identifiable,
 *
 * Subclasses that extend copying should not override this method, but should override
 * the populateFrom: method instead.
 */
-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy
 * will be an instance of the specified class, will have its name set to the
 * specified name, and will have a unique tag.
 *
 * Care should be taken when choosing the class to be instantiated. If the class is
 * different than that of this instance, the populateFrom: method of that class must
 * be compatible with the contents of this instance.
 *
 * The returned instance is retained. It is the responsiblity of the caller to manage
 * the lifecycle of the returned instance and perform the corresponding invocation of
 * the release method at the appropriate time.
 *
 * This copy operation is a deep copy. Copies of most of the content of the original
 * will be created as well. For structural subclasses, such as CC3Node, copies will
 * be made of each structual element (eg- child nodes). Some exceptions are made.
 * For instance, copies are generally not made for fixed, voluminous content such as
 * mesh data. In addition, subclasses may excuse themselves from being copied through
 * the shouldIncludeInDeepCopy property.
 *
 * The copy... methods may often be used to duplicate an instance many times, to create
 * large number of similar instances to populate a game. To help you verify that you are
 * correctly releasing and deallocating all these copies, you can use the instanceCount
 * class method to get a current count of the total number of instances of all subclasses
 * of CC3Identifiable,
 *
 * Subclasses that extend copying should not override this method, but should override
 * the populateFrom: method instead.
 */
-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName asClass: (Class) aClass;

/**
 * Template method that populates this instance from the specified other instance.
 *
 * This method is invoked automatically during object copying via the copy or
 * copyWithZone: method. In most situations, the application should use the
 * copy method, and should never need to invoke this method directly.
 * 
 * Subclasses that add additional instance state (instance variables) should extend
 * copying by overriding this method to copy that additional state. Superclass that
 * override this method should be sure to invoke the superclass implementation to
 * ensure that superclass state is copied as well.
 */
-(void) populateFrom: (CC3Identifiable*) another;

/**
 * Returns whether this instance should be included in a deep copy.
 *
 * This method simply returns YES by default, and in most cases this is sufficient.
 * However, for some structural subclasses (notably subclasses of CC3Node) it may
 * be desirable to not copy some components.
 *
 * This property is not universally automatically applied or honoured. It is
 * up to the invoker and invokee to agree on when to make use of this property.
 */
@property(nonatomic, readonly) BOOL shouldIncludeInDeepCopy;
	
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


