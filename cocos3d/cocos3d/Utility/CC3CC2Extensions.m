/*
 * CC3CC2Extensions.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3CC2Extensions.h for full API documentation.
 */

#import "CC3CC2Extensions.h"
#import "CC3IOSExtensions.h"
#import "CC3Logging.h"
#import "CCDirectorIOS.h"
#import "CGPointExtension.h"
#import "CCTouchDispatcher.h"
#import "CCConfiguration.h"
#import "CCFileUtils.h"
#import "cocos2d.h"
#import "uthash.h"


#pragma mark -
#pragma mark CC3CCSizeTo action

@implementation CC3CCSizeTo

-(id) initWithDuration: (ccTime) dur sizeTo: (CGSize) endSize {
	if( (self = [super initWithDuration: dur]) ) {
		endSize_ = endSize;
	}
	return self;
}

+(id) actionWithDuration: (ccTime) dur sizeTo: (CGSize) endSize {
	return [[[self alloc] initWithDuration: dur sizeTo: endSize] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration]
														 sizeTo: endSize_];
}

-(id) reverse { return [[self class] actionWithDuration: self.duration  sizeTo: endSize_]; }

-(void) startWithTarget: (CCNode*) aTarget {
	[super startWithTarget: aTarget];
	startSize_ = aTarget.contentSize;
	sizeChange_ = CGSizeMake(endSize_.width - startSize_.width, endSize_.height - startSize_.height);
}

-(void) update: (ccTime) t {
	CCNode* tNode = (CCNode*)self.target;
	tNode.contentSize = CGSizeMake(startSize_.width + (sizeChange_.width * t),
								   startSize_.height + (sizeChange_.height * t));
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ start: %@, end: %@, time change: %@", [self class],
			NSStringFromCGSize(startSize_), NSStringFromCGSize(endSize_), NSStringFromCGSize(sizeChange_)];
}

@end


#pragma mark -
#pragma mark CCNode extension

@implementation CCNode (CC3)

- (CGRect) globalBoundingBoxInPixels {
	CGRect rect = CGRectMake(0, 0, contentSizeInPixels_.width, contentSizeInPixels_.height);
	return CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
}

-(void) updateViewport {
	[children_ makeObjectsPerformSelector:@selector(updateViewport)];	
}

-(CGPoint) cc3ConvertUIPointToNodeSpace: (CGPoint) viewPoint {
	CGPoint glPoint = [[CCDirector sharedDirector] convertToGL: viewPoint];
	return [self convertToNodeSpace: glPoint];
}

-(CGPoint) cc3ConvertNodePointToUISpace: (CGPoint) glPoint {
	CGPoint gblPoint = [self convertToWorldSpace: glPoint];
	return [[CCDirector sharedDirector] convertToUI: gblPoint];
}

-(CGPoint) cc3ConvertUIMovementToNodeSpace: (CGPoint) uiMovement {
	switch ( [[CCDirector sharedDirector] deviceOrientation] ) {
		case CCDeviceOrientationLandscapeLeft:
			return ccp( uiMovement.y, uiMovement.x );
		case CCDeviceOrientationLandscapeRight:
			return ccp( -uiMovement.y, -uiMovement.x );
		case CCDeviceOrientationPortraitUpsideDown:
			return ccp( -uiMovement.x, uiMovement.y );
		case CCDeviceOrientationPortrait:
		default:
			return ccp( uiMovement.x, -uiMovement.y );
	}
}

-(CGPoint) cc3NormalizeUIMovement: (CGPoint) uiMovement {
	CGSize cs = self.contentSize;
	CGPoint glMovement = [self cc3ConvertUIMovementToNodeSpace: uiMovement];
	return ccp(glMovement.x / cs.width, glMovement.y / cs.height);
}

-(BOOL) cc3IsTouchEnabled { return NO; }

/**
 * Based on cocos2d Gesture Recognizer ideas by Krzysztof Zabłocki at:
 * http://www.merowing.info/2012/03/using-gesturerecognizers-in-cocos2d/
 */
-(BOOL) cc3WillConsumeTouchEventAt: (CGPoint) viewPoint {
	
	if (self.cc3IsTouchEnabled &&
		self.visible &&
		self.isRunning &&
		[self cc3ContainsTouchPoint: viewPoint] ) return YES;
	
	CCArray* myKids = self.children;
	for (CCNode* child in myKids) {
		if ( [child cc3WillConsumeTouchEventAt: viewPoint] ) return YES;
	}

	LogTrace(@"%@ will NOT consume event at %@", [self class], NSStringFromCGPoint(viewPoint));

	return NO;
}

-(BOOL) cc3ContainsTouchPoint: (CGPoint) viewPoint {
	CGPoint nodePoint = [self cc3ConvertUIPointToNodeSpace: viewPoint];
	CGSize cs = self.contentSize;
	CGRect nodeBounds = CGRectMake(0, 0, cs.width, cs.height);
	if (CGRectContainsPoint(nodeBounds, nodePoint)) {
		LogTrace(@"%@ will consume event at %@ in bounds %@",
					  [self class],
					  NSStringFromCGPoint(nodePoint),
					  NSStringFromCGRect(nodeBounds));
		return YES;
	}
	return NO;
}

-(BOOL) cc3ValidateGesture: (UIGestureRecognizer*) gesture {
	if ( [self cc3WillConsumeTouchEventAt: gesture.location] ) {
		[gesture cancel];
		return NO;
	} else {
		return YES;
	}
}

@end


#pragma mark -
#pragma mark CCLayer extension

@implementation CCLayer (CC3)

-(BOOL) cc3IsTouchEnabled { return self.isTouchEnabled; }

@end


#pragma mark -
#pragma mark CCMenu extension

@implementation CCMenu (CC3)

-(BOOL) cc3ContainsTouchPoint: (CGPoint) viewPoint {
	CCArray* myKids = self.children;
	for (CCNode* child in myKids) {
		if ( [child cc3ContainsTouchPoint: viewPoint] ) return YES;
	}
	return NO;
}

@end


#pragma mark -
#pragma mark CCDirector extension

@implementation CCDirector (CC3)

-(ccTime) frameInterval { return dt; }

-(ccTime) frameRate { return frameRate_; }

@end


#pragma mark -
#pragma mark CC3BMFontConfiguration

/** Structure holding character kerning data. Copied from identical definition in CCLabelBMFont.m. */
typedef struct _KerningHashElement {	
	int key;		// key for the hash. 16-bit for 1st element, 16-bit for 2nd element
	int amount;
	UT_hash_handle hh;
} tKerningHashElement;

@interface CCBMFontConfiguration (TemplateMethods)
-(void) parseConfigFile:(NSString*)controlFile;
-(void) parseCharacterDefinition:(NSString*)line;
-(void) parseCharacterDefinition:(NSString*)line charDef:(ccBMFontDef*)characterDefinition;
-(void) parseInfoArguments:(NSString*)line;
-(void) parseCommonArguments:(NSString*)line;
-(void) parseImageFileName:(NSString*)line fntFile:(NSString*)fntFile;
-(void) parseKerningCapacity:(NSString*)line;
-(void) parseKerningEntry:(NSString*)line;
-(void) purgeKerningDictionary;
@end

@implementation CC3BMFontConfiguration

-(ccBMFontDef*) characterSpecFor: (unichar) c {
// cocos2d 1.0 and below use an array to hold the font definitions.
// cocos2d 1.1 and above use a hash list.
#if COCOS2D_VERSION < 0x010100
	return (c < kCCBMFontMaxChars) ? &BMFontArray_[c] : NULL;
#else
	ccBMFontDef *charSpec = NULL;
	unsigned int charKey = c;
	HASH_FIND_INT(BMFontHash_, &charKey, charSpec);
	return charSpec;
#endif
}

-(NSInteger) kerningBetween: (unichar) firstChar and: (unichar) secondChar {
	if(kerningDictionary_) {
		unsigned int key = (firstChar << 16) | (secondChar & 0xffff);
		tKerningHashElement* element = NULL;
		HASH_FIND_INT(kerningDictionary_, &key, element);		
		if(element) return element->amount;
	}
	return 0;
}

/** Overridden to parse info line. */
- (void)parseConfigFile: (NSString*) fntFile {	
	NSString *fullpath = [CCFileUtils fullPathFromRelativePath:fntFile];
	NSError *error;
	NSString *contents = [NSString stringWithContentsOfFile:fullpath encoding:NSUTF8StringEncoding error:&error];
	
	NSAssert1( contents, @"cocos2d: Error parsing FNTfile: %@", error);
	
	// Move all lines in the string, which are denoted by \n, into an array
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
	
	// Create an enumerator which we can use to move through the lines read from the control file
	NSEnumerator *nse = [lines objectEnumerator];
	
	// Create a holder for each line we are going to work with
	NSString *line;
	
	// Loop through all the lines in the lines array processing each one
	while( (line = [nse nextObject]) ) {
		// parse spacing / padding
		if([line hasPrefix:@"info face"]) {
			[self parseInfoArguments:line];
		}
		// Check to see if the start of the line is something we are interested in
		else if([line hasPrefix:@"common lineHeight"]) {
			[self parseCommonArguments:line];
		}
		else if([line hasPrefix:@"page id"]) {
			[self parseImageFileName:line fntFile:fntFile];
		}
		else if([line hasPrefix:@"chars c"]) {
			// Ignore this line
		}
		else if([line hasPrefix:@"char"]) {
			[self parseCharacterDefinition:line];
		}
		else if([line hasPrefix:@"kernings count"]) {
			[self parseKerningCapacity:line];
		}
		else if([line hasPrefix:@"kerning first"]) {
			[self parseKerningEntry:line];
		}
	}
	// Finished with lines so release it
	[lines release];
}

// cocos2d 1.0 and below use an array to hold the character configs and, from the parseConfigFile:
// method, invoke the parseCharacterDefinition:charDef: method instead of the parseCharacterDefinition:
// method. Create a suitable replacement for the parseCharacterDefinition:.
#if COCOS2D_VERSION < 0x010100
-(void) parseCharacterDefinition: (NSString*) line {
	ccBMFontDef characterDefinition;
	[self parseCharacterDefinition:line charDef: &characterDefinition];
	BMFontArray_[ characterDefinition.charID ] = characterDefinition;
}
#endif

/*
- (void)parseConfigFile: (NSString*) fntFile {
	NSString *fullpath = [CCFileUtils fullPathFromRelativePath:fntFile];
	NSError *error;
	NSString *contents = [NSString stringWithContentsOfFile:fullpath encoding:NSUTF8StringEncoding error:&error];
	
	NSAssert1( contents, @"cocos2d: Error parsing FNTfile: %@", error);
	
	// Move all lines in the string, which are denoted by \n, into an array
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
	
	// Create an enumerator which we can use to move through the lines read from the control file
	NSEnumerator *nse = [lines objectEnumerator];
	
	// Create a holder for each line we are going to work with
	NSString *line;
	
	// Loop through all the lines in the lines array processing each one
	while( (line = [nse nextObject]) ) {
		// parse spacing / padding
		if([line hasPrefix:@"info face"]) {
			[self parseInfoArguments:line];
		}
		// Check to see if the start of the line is something we are interested in
		else if([line hasPrefix:@"common lineHeight"]) {
			[self parseCommonArguments:line];
		}
		else if([line hasPrefix:@"page id"]) {
			[self parseImageFileName:line fntFile:fntFile];
		}
		else if([line hasPrefix:@"chars c"]) {
			// Ignore this line
		}
		else if([line hasPrefix:@"char"]) {
			// Parse the current line and create a new CharDef
			ccBMFontDef characterDefinition;
			[self parseCharacterDefinition:line charDef:&characterDefinition];
			
			// Add the CharDef returned to the charArray
			BMFontArray_[ characterDefinition.charID ] = characterDefinition;
		}
		else if([line hasPrefix:@"kernings count"]) {
			[self parseKerningCapacity:line];
		}
		else if([line hasPrefix:@"kerning first"]) {
			[self parseKerningEntry:line];
		}
	}
	// Finished with lines so release it
	[lines release];
}
*/

/** Overridden with copied superclass method, modified to parse size into fontSize iVar. */
-(void) parseInfoArguments: (NSString*) line {
	//
	// possible lines to parse:
	// info face="Script" size=32 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,4,3,2 spacing=0,0 outline=0
	// info face="Cracked" size=36 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1
	//
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue = nil;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// face (ignore)
	[nse nextObject];
	
	// Font size
	propertyValue = [nse nextObject];
	fontSize = [propertyValue floatValue];
	
	// bold (ignore)
	[nse nextObject];
	
	// italic (ignore)
	[nse nextObject];
	
	// charset (ignore)
	[nse nextObject];
	
	// unicode (ignore)
	[nse nextObject];
	
	// strechH (ignore)
	[nse nextObject];
	
	// smooth (ignore)
	[nse nextObject];
	
	// aa (ignore)
	[nse nextObject];
	
	// padding (ignore)
	propertyValue = [nse nextObject];
	{
		
		NSArray *paddingValues = [propertyValue componentsSeparatedByString:@","];
		NSEnumerator *paddingEnum = [paddingValues objectEnumerator];
		// padding top
		propertyValue = [paddingEnum nextObject];
		padding_.top = [propertyValue intValue];
		
		// padding right
		propertyValue = [paddingEnum nextObject];
		padding_.right = [propertyValue intValue];
		
		// padding bottom
		propertyValue = [paddingEnum nextObject];
		padding_.bottom = [propertyValue intValue];
		
		// padding left
		propertyValue = [paddingEnum nextObject];
		padding_.left = [propertyValue intValue];
		
		CCLOG(@"cocos2d: padding: %d,%d,%d,%d", padding_.left, padding_.top, padding_.right, padding_.bottom);
	}
	
	// spacing (ignore)
	[nse nextObject];	
}

/** Overridden with copied superclass method, modified to parse scale W & H into textureSize iVar. */
-(void) parseCommonArguments: (NSString*) line {
	//
	// line to parse:
	// common lineHeight=104 base=26 scaleW=1024 scaleH=512 pages=1 packed=0
	//
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue = nil;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// line height
	propertyValue = [nse nextObject];
	commonHeight_ = [propertyValue intValue];
	
	// baseline
	propertyValue = [nse nextObject];
	baseline = [propertyValue intValue];
	
	// scaleW
	propertyValue = [nse nextObject];
	textureSize.x = [propertyValue intValue];
	NSAssert(textureSize.x <= [[CCConfiguration sharedConfiguration] maxTextureSize], @"CCLabelBMFont: page can't be larger than supported");
	
	// scaleH
	propertyValue = [nse nextObject];
	textureSize.y = [propertyValue intValue];
	NSAssert(textureSize.y <= [[CCConfiguration sharedConfiguration] maxTextureSize], @"CCLabelBMFont: page can't be larger than supported");
	
	// pages. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] == 1, @"CCBitfontAtlas: only supports 1 page");
	
	// packed (ignore) What does this mean ??
}

static NSMutableDictionary* cc3BMFontConfigurations = nil;

+(id) configurationFromFontFile: (NSString*) fontFile {
	CC3BMFontConfiguration *fontConfig = nil;
	
	if( cc3BMFontConfigurations == nil )
		cc3BMFontConfigurations = [[NSMutableDictionary dictionaryWithCapacity: 4] retain];
	
	fontConfig = [cc3BMFontConfigurations objectForKey: fontFile];
	if(!fontConfig) {
		fontConfig = [super configurationWithFNTFile: fontFile];
		[cc3BMFontConfigurations setObject: fontConfig forKey: fontFile];
	}
	return fontConfig;
}

+(void) clearFontConfigurations { [cc3BMFontConfigurations removeAllObjects]; }

@end


#pragma mark -
#pragma mark CCArray extension

@implementation CCArray (CC3)

-(NSUInteger) indexOfObjectIdenticalTo: (id) anObject {
	return [self indexOfObject: anObject];
}

-(void) removeObjectIdenticalTo: (id) anObject {
	[self removeObject: anObject];
}

-(void) fastReplaceObjectAtIndex: (NSUInteger) index withObject: (id) anObject {
	NSAssert(index < data->num, @"Invalid index. Out of bounds");

	id oldObj = data->arr[index];
	data->arr[index] = [anObject retain];
	[oldObj release];						// Release after in case new is same as old
}

-(BOOL) setCapacity: (NSUInteger) newCapacity {
	if (data->max == newCapacity) return NO;

	// Release any current elements that are beyond the new capacity.
	if (self.count > 0) {	// Reqd so count - 1 can't be done on NSUInteger of zero
		for (NSUInteger i = self.count - 1; i >= newCapacity; i--) {
			[self removeObjectAtIndex: i];
		}
	}

	// Returned newArrs will be non-zero on successful allocation,
	// but will be zero on either successful deallocation or on failed allocation
	id* newArr = realloc( data->arr, (newCapacity * sizeof(id)) );

	// If we wanted to allocate, but it failed, log an error and return without changing anything.
	if ( (newCapacity != 0) && !newArr ) {
		LogError(@"Could not change %@ to a capacity of %u elements", self, newCapacity);
		return NO;
	}
	
	// Otherwise, set the new array pointer and size.
	data->arr = newArr;
	data->max = newCapacity;
	LogTrace(@"Changed %@ to a capcity of %u elements", [self class], newCapacity);
	return YES;
}


#pragma mark Allocation and initialization

- (id) initWithZeroCapacity {
	if ( (self = [super init]) ) {
		data = (ccArray*)malloc( sizeof(ccArray) );
		data->num = 0;
		data->max = 0;
		data->arr = NULL;
	}
	return self;
}

+(id) arrayWithZeroCapacity { return [[[self alloc] initWithZeroCapacity] autorelease]; }


#pragma mark Support for unretained objects

- (void) addUnretainedObject: (id) anObject {
	ccCArrayAppendValueWithResize(data, anObject);
}

- (void) insertUnretainedObject: (id) anObject atIndex: (NSUInteger) index {
	ccCArrayEnsureExtraCapacity(data, 1);
	ccCArrayInsertValueAtIndex(data, anObject, index);
}

- (void) removeUnretainedObjectIdenticalTo: (id) anObject {
	ccCArrayRemoveValue(data, anObject);
}

- (void) removeUnretainedObjectAtIndex: (NSUInteger) index {
	ccCArrayRemoveValueAtIndex(data, index);
}

- (void) removeAllObjectsAsUnretained {
	ccCArrayRemoveAllValues(data);
}

-(void) releaseAsUnretained {
	[self removeAllObjectsAsUnretained];
	[self release];
}

- (NSString*) fullDescription {
	NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ (", [self class]];
	if (data->num > 0) {
		[desc appendFormat:@"\n\t%@", data->arr[0]];
	}
	for (NSUInteger i = 1; i < data->num; i++) {
		[desc appendFormat:@",\n\t%@", data->arr[i]];
	}
	[desc appendString:@")"];
	return desc;
}

@end


#pragma mark -
#pragma mark Miscellaneous extensions and functions

NSString* NSStringFromTouchType(uint tType) {
	switch (tType) {
		case kCCTouchBegan:
			return @"kCCTouchBegan";
		case kCCTouchMoved:
			return @"kCCTouchMoved";
		case kCCTouchEnded:
			return @"kCCTouchEnded";
		case kCCTouchCancelled:
			return @"kCCTouchCancelled";
		default:
			return [NSString stringWithFormat: @"unknown touch type (%u)", tType];
	}
}

