/*
 * CC3OSExtensions.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OSExtensions.h for full API documentation.
 */

#import "CC3OSExtensions.h"
#import "CC3OpenGL.h"


#pragma mark -
#pragma mark NSObject extensions

@implementation NSObject (CC3)

-(BOOL) isNull { return NO; }

-(NSString*) fullDescription { return [self description]; }

-(id) asWeakReference { return [NSValue valueWithNonretainedObject: self]; }

-(id) resolveWeakReference { return self; }

// Deprecated
-(id) autoreleasedCopy { return [[self copy] autorelease]; }
-(id) copyAutoreleased { return [self autoreleasedCopy]; }

@end


#pragma mark -
#pragma mark NSNull extensions

@implementation NSNull (CC3)

-(BOOL) isNull { return YES; }

@end


#pragma mark NSValue extension+

@implementation NSValue (CC3)

-(id) resolveWeakReference { return self.nonretainedObjectValue; }

@end


#pragma mark -
#pragma mark NSArray extensions

@implementation NSArray (CC3)

-(NSString*) fullDescription {
	NSUInteger elemCnt = self.count;
	NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ (", [self class]];
	if (elemCnt > 0) [desc appendFormat: @"\n\t[%i]: %@", 0, [self objectAtIndex: 0]];
	for (NSUInteger i = 1; i < elemCnt; i++) [desc appendFormat: @"\n\t[%lu]: %@", (unsigned long)i, [self objectAtIndex: i]];
	[desc appendString:@")"];
	return desc;
}

@end


#pragma mark -
#pragma mark NSThread extensions

@implementation NSThread (CC3)

-(void) runBlockAsync: (void (^)(void)) block { [self runBlock: block waitUntilDone: NO]; }

-(void) runBlockSync: (void (^)(void)) block { [self runBlock: block waitUntilDone: NO]; }

-(void) runBlock: (void (^)(void)) block waitUntilDone: (BOOL) wait {
	[self performSelector: @selector(runBlockNow:)
				 onThread: self
			   withObject: [block copy]
			waitUntilDone: wait];
}

-(void) runBlock: (void (^)(void)) block after: (NSTimeInterval) seconds {
	[self runBlockAsync: ^{
		[self performSelector: @selector(runBlockNow:)
				   withObject: [block copy]
				   afterDelay: seconds];
	}];
}

-(void) runBlockNow: (void (^)(void)) block {
	@autoreleasepool {
		block();
		[block release];
	}
}

@end


#pragma mark -
#pragma mark NSRunLoop extensions

@implementation NSRunLoop (CC3)

-(void) runBlockOnNextIteration: (void (^)(void)) block {
	[self performSelector: @selector(runBlockNow:)
				   target: self
				 argument: [block copy]
					order: 0
					modes: [NSArray arrayWithObject: NSDefaultRunLoopMode]];
}

-(void) runBlockNow: (void (^)(void)) block {
	@autoreleasepool {
		block();
		[block release];
	}
}

@end


#pragma mark -
#pragma mark NSString extensions

@implementation NSString (CC3)

-(NSUInteger) lineCount {
	NSUInteger lineCount, charIdx, strLen = self.length;
	for (charIdx = 0, lineCount = 0; charIdx < strLen; lineCount++)
		charIdx = NSMaxRange([self lineRangeForRange: NSMakeRange(charIdx, 0)]);
	return lineCount;
}

-(NSArray*) lines {
	NSArray* rawLines = [self componentsSeparatedByString: @"\n"];
	NSMutableArray* trimmedLines = [NSMutableArray arrayWithCapacity: rawLines.count];
	for (NSString* line in rawLines)
		[trimmedLines addObject: [line stringByTrimmingCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
	return trimmedLines;
}

-(NSArray*) terminatedLines {
	NSString* terminator = @"\n";
	NSArray* rawLines = [self componentsSeparatedByString: terminator];
	NSMutableArray* terminatedLines = [NSMutableArray arrayWithCapacity: rawLines.count];
	for (NSString* line in rawLines)
		[terminatedLines addObject: [line stringByAppendingString: terminator]];
	return terminatedLines;
}

@end


