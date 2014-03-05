/*
 * CC3BitmapLabelNode.m
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
 * See header file CC3BitmapLabelNode.h for full API documentation.
 */

#import "CC3BitmapLabelNode.h"
#import "CC3CC2Extensions.h"
#import "CC3ParametricMeshNodes.h"
#import "CGPointExtension.h"


#pragma mark -
#pragma mark CC3BitmapFontConfiguration

@implementation CC3BitmapFontConfiguration

@synthesize atlasName=_atlasName, fontSize=_fontSize, baseline=_baseline;
@synthesize commonHeight=_commonHeight, padding=_padding, textureSize=_textureSize;

-(void) dealloc {
	[self purgeCharDefDictionary];
	[self purgeKerningDictionary];
	[_characterSet release];
	[_atlasName release];

	[super dealloc];
}

-(void) purgeCharDefDictionary {
	CC3BitmapCharDefHashElement *current, *tmp;
	HASH_ITER(hh, _charDefDictionary, current, tmp) {
		HASH_DEL(_charDefDictionary, current);
		free(current);
	}
}

-(void) purgeKerningDictionary {
	CC3KerningHashElement *current;
	while(_kerningDictionary) {
		current = _kerningDictionary;
		HASH_DEL(_kerningDictionary, current);
		free(current);
	}
}


#pragma mark Character definitions

-(CC3BitmapCharDef*) characterSpecFor: (unichar) c {
	CC3BitmapCharDefHashElement *element = NULL;
	GLuint key = (GLuint)c;
	HASH_FIND_INT(_charDefDictionary , &key, element);
	return element ? &(element->charDef) : NULL;
}

-(NSInteger) kerningBetween: (unichar) firstChar and: (unichar) secondChar {
	if(_kerningDictionary) {
		unsigned int key = (firstChar << 16) | (secondChar & 0xffff);
		CC3KerningHashElement* element = NULL;
		HASH_FIND_INT(_kerningDictionary, &key, element);
		if(element) return element->amount;
	}
	return 0;
}


#pragma mark Allocation and initialization

-(id) initFromFontFile: (NSString*) fontFile {
	if( (self = [super init]) ) {
		_kerningDictionary = NULL;
		_charDefDictionary = NULL;
		NSString *validChars = [self parseConfigFile: fontFile];
		if( !validChars ) return nil;
		_characterSet = [[NSCharacterSet characterSetWithCharactersInString: validChars] retain];
	}
	return self;
}

static NSMutableDictionary* _fontConfigurations = nil;

+(id) configurationFromFontFile: (NSString*) fontFile {
	CC3BitmapFontConfiguration *fontConfig = nil;
	
	if( _fontConfigurations == nil )
		_fontConfigurations = [[NSMutableDictionary alloc] initWithCapacity: 4];	// retained
	
	fontConfig = [_fontConfigurations objectForKey: fontFile];
	if( !fontConfig ) {
		fontConfig = [[self alloc] initFromFontFile: fontFile];
		if (fontConfig) [_fontConfigurations setObject: fontConfig forKey: fontFile];
		[fontConfig release];
	}
	return fontConfig;
}

+(void) clearFontConfigurations { [_fontConfigurations removeAllObjects]; }

- (NSString*) description {
	return [NSString stringWithFormat:@"%@ with glphys: %d, kernings:%d, image = %@",
			[self class],
			HASH_COUNT(_charDefDictionary),
			HASH_COUNT(_kerningDictionary),
			_atlasName];
}


#pragma mark Parsing

/** Parses the configuration file, line by line. */
-(NSString*) parseConfigFile: (NSString*) fontFile {
	NSString* fullpath = [CCFileUtils.sharedFileUtils fullPathFromRelativePath: fontFile];
	NSError* error;
	NSMutableString* validCharsString = [NSMutableString stringWithCapacity: 512];
	
	NSString* contents = [NSString stringWithContentsOfFile: fullpath encoding: NSUTF8StringEncoding error: &error];
	CC3Assert(contents, @"Could not load font file %@ because %@", fullpath, error);
    
	// Separate the lines into an array and create an enumerator on it
	NSArray* lines = [[NSArray alloc] initWithArray: [contents componentsSeparatedByString:@"\n"]];
	NSEnumerator* nse = [lines objectEnumerator];
	NSString* line;
    
	// Loop through all the lines in the lines array processing each one based on its first chars
	while( (line = [nse nextObject]) ) {
		if([line hasPrefix:@"char id"]) [self parseCharacterDefinition: line validChars: validCharsString];
		else if([line hasPrefix:@"kerning"]) [self parseKerningEntry: line];
		else if([line hasPrefix:@"info"]) [self parseInfoArguments: line];
		else if([line hasPrefix:@"common"]) [self parseCommonArguments: line];
		else if([line hasPrefix:@"page"]) [self parseImageFileName: line fntFile: fontFile];
		else if([line hasPrefix:@"chars count"]) {}
	}
	[lines release];	// Finished with lines so release it
	
	return validCharsString;
}

/** Parses a character definition line. */
-(void) parseCharacterDefinition:(NSString*)line validChars: (NSMutableString*) validChars {
	CC3BitmapCharDefHashElement *element = calloc(sizeof(CC3BitmapCharDefHashElement), 1);

	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue;
    
	[nse nextObject];		// Skip line header
    
	propertyValue = [nse nextObject];							// Character unicode value
	propertyValue = [propertyValue substringToIndex: [propertyValue rangeOfString: @" "].location];
	element->charDef.charCode = [propertyValue intValue];
    
	propertyValue = [nse nextObject];							// Character rect x
	element->charDef.rect.origin.x = [propertyValue intValue];
	
	propertyValue = [nse nextObject];							// Character rect y
	element->charDef.rect.origin.y = [propertyValue intValue];
	
	propertyValue = [nse nextObject];							// Character rect width
	element->charDef.rect.size.width = [propertyValue intValue];
	
	propertyValue = [nse nextObject];							// Character rect height
	element->charDef.rect.size.height = [propertyValue intValue];
	
	propertyValue = [nse nextObject];							// Character xoffset
	element->charDef.xOffset = [propertyValue intValue];
	
	propertyValue = [nse nextObject];							// Character yoffset
	element->charDef.yOffset = [propertyValue intValue];
	
	propertyValue = [nse nextObject];							// Character xadvance
	element->charDef.xAdvance = [propertyValue intValue];
	
	element->key = element->charDef.charCode;
	HASH_ADD_INT(_charDefDictionary, key, element);
	
	[validChars appendString: [NSString stringWithFormat: @"%C", element->charDef.charCode]];
}

/** Parses a kerning line. */
-(void) parseKerningEntry:(NSString*) line {
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue;
    
	[nse nextObject];		// Skip line header
    
	propertyValue = [nse nextObject];				// First character
	int first = [propertyValue intValue];
    
	propertyValue = [nse nextObject];				// Second character
	int second = [propertyValue intValue];
    
	propertyValue = [nse nextObject];				// Kerning amount
	int amount = [propertyValue intValue];
    
	CC3KerningHashElement *element = calloc(sizeof(CC3KerningHashElement), 1);
	element->key = (first<<16) | (second&0xffff);
	element->amount = amount;
	HASH_ADD_INT(_kerningDictionary,key, element);
}

/** Parses the info line. */
-(void) parseInfoArguments: (NSString*) line {
	//
	// possible lines to parse:
	// info face="Script" size=32 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,4,3,2 spacing=0,0 outline=0
	// info face="Cracked" size=36 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1
	//
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue = nil;
	
	[nse nextObject];		// Skip line header
	
	[nse nextObject];								// Font face (ignore)
	
	propertyValue = [nse nextObject];				// Font size
	_fontSize = [propertyValue floatValue];
	
	[nse nextObject];								// Bold flag (ignore)
	[nse nextObject];								// Italic (ignore)
	[nse nextObject];								// Character set (ignore)
	[nse nextObject];								// Unicode (ignore)
	[nse nextObject];								// Horizontal stretch (ignore)
	[nse nextObject];								// Smoothing (ignore)
	[nse nextObject];								// aa (ignore)
	
	// Padding is a combined element. Create a parser for it.
	propertyValue = [nse nextObject];
	NSArray *paddingValues = [propertyValue componentsSeparatedByString:@","];
	NSEnumerator *paddingEnum = [paddingValues objectEnumerator];
	
	propertyValue = [paddingEnum nextObject];		// Padding top
	_padding.top = [propertyValue intValue];
	
	propertyValue = [paddingEnum nextObject];		// Padding right
	_padding.right = [propertyValue intValue];
	
	propertyValue = [paddingEnum nextObject];		// Padding bottom
	_padding.bottom = [propertyValue intValue];
	
	propertyValue = [paddingEnum nextObject];		// Padding left
	_padding.left = [propertyValue intValue];
	
	[nse nextObject];								// Spacing (ignore)
}

/** Parses the common line. */
-(void) parseCommonArguments: (NSString*) line {
	//
	// line to parse:
	// common lineHeight=104 base=26 scaleW=1024 scaleH=512 pages=1 packed=0
	//
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue = nil;
	
	[nse nextObject];		// Skip line header
	
	propertyValue = [nse nextObject];				// Line height
	_commonHeight = [propertyValue intValue];
	
	propertyValue = [nse nextObject];				// Baseline
	_baseline = [propertyValue intValue];
	
	propertyValue = [nse nextObject];				// Width scale
	_textureSize.width = [propertyValue intValue];
	
	propertyValue = [nse nextObject];				// Height scale
	_textureSize.height = [propertyValue intValue];

	CC3Assert(_textureSize.width <= CCConfiguration.sharedConfiguration.maxTextureSize &&
			  _textureSize.height <= CCConfiguration.sharedConfiguration.maxTextureSize,
			  @"Font texture can't be larger than supported");
	
	propertyValue = [nse nextObject];				// Pages sanity check
	CC3Assert( [propertyValue intValue] == 1, @"%@ does not support font files with multiple pages", self);
	
	// packed (ignore) What does this mean ??
}


/** Parses the image file line. */
-(void) parseImageFileName: (NSString*) line fntFile: (NSString*) fontFile {
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue = nil;
    
	[nse nextObject];		// Skip line header
    
	propertyValue = [nse nextObject];			// Page ID. Sanity check
	CC3Assert( [propertyValue intValue] == 0, @"%@ does not support font files with multiple pages", self);
    
	propertyValue = [nse nextObject];			// Texture file na,e
	NSArray *array = [propertyValue componentsSeparatedByString: @"\""];
	propertyValue = [array objectAtIndex: 1];
	CC3Assert(propertyValue, @"%@ could not extract font atlas file name", self.class);
    
	// Supports subdirectories
	NSString *dir = [fontFile stringByDeletingLastPathComponent];
	[_atlasName release];
	_atlasName = [[dir stringByAppendingPathComponent: propertyValue] retain];	// retained
}

@end


#pragma mark -
#pragma mark CC3MeshNode bitmapped label extension

@implementation CC3MeshNode (BitmapLabel)


#pragma mark Populating for bitmapped font textures

-(void) populateAsBitmapFontLabelFromString: (NSString*) lblString
							   fromFontFile: (NSString*) fontFileName
							  andLineHeight: (GLfloat) lineHeight
						   andTextAlignment: (NSTextAlignment) textAlignment
						  andRelativeOrigin: (CGPoint) origin
							andTessellation: (CC3Tessellation) divsPerChar {
	
	CC3BitmapFontConfiguration* fontConfig = [CC3BitmapFontConfiguration configurationFromFontFile: fontFileName];
	
	[[self prepareParametricMesh] populateAsBitmapFontLabelFromString: lblString
															  andFont: fontConfig
														andLineHeight: lineHeight
													 andTextAlignment: textAlignment
													andRelativeOrigin: origin
													  andTessellation: divsPerChar];

	// Set texture after mesh to avoid mesh setter from clearing texture
	self.texture = [CC3Texture textureFromFile: fontConfig.atlasName];

	// By definition, characters have significant transparency, so turn alpha blending on.
	// Since characters can overlap with kerning, don't draw the transparent parts to avoid Z-fighting
	// between the characters. Set the alpha tolerance higher than zero so that non-zero alpha at
	// character edges due to anti-aliasing won't be drawn.
	self.isOpaque = NO;
	self.shouldDrawLowAlpha = NO;
	self.material.alphaTestReference = 0.05;
}

@end


#pragma mark -
#pragma mark CC3BitmapLabelNode

@implementation CC3BitmapLabelNode

-(void) dealloc {
	[_labelString release];
	[_fontFileName release];
	[_fontConfig release];
	[super dealloc];
}

-(GLfloat) lineHeight { return _lineHeight ? _lineHeight : _fontConfig.commonHeight; }

-(void) setLineHeight: (GLfloat) lineHt {
	if (lineHt != _lineHeight) {
		_lineHeight = lineHt;
		[self populateLabelMesh];
	}
}

-(NSString*) labelString { return _labelString; }

-(void) setLabelString: (NSString*) aString {
	if ( [aString isEqualToString: _labelString] ) return;
	
	[_labelString release];
	_labelString = [aString retain];
	
	[self populateLabelMesh];
}

-(NSString*) fontFileName { return _fontFileName; }

-(void) setFontFileName: (NSString*) aFileName {
	if ( [aFileName isEqualToString: _fontFileName] ) return;

	[_fontFileName release];
	_fontFileName = [aFileName retain];

	[_fontConfig release];
	_fontConfig = [[CC3BitmapFontConfiguration configurationFromFontFile: _fontFileName] retain];
	
	[self populateLabelMesh];
}

-(NSTextAlignment) textAlignment { return _textAlignment; }

-(void) setTextAlignment: (NSTextAlignment) alignment {
	if (alignment == _textAlignment) return;

	_textAlignment = alignment;
	[self populateLabelMesh];
}

-(CGPoint) relativeOrigin { return _relativeOrigin; }

-(void) setRelativeOrigin: (CGPoint) relOrigin {
	if ( CGPointEqualToPoint(relOrigin, _relativeOrigin) ) return;
	
	_relativeOrigin = relOrigin;
	[self populateLabelMesh];
}

-(CC3Tessellation) tessellation { return _tessellation; }

-(void) setTessellation: (CC3Tessellation) aGrid {
	if ( (aGrid.x == _tessellation.x) && (aGrid.y == _tessellation.y) ) return;

	_tessellation = aGrid;
	[self populateLabelMesh];
}

-(GLfloat) fontSize { return _fontConfig ? _fontConfig.fontSize : 0; }

-(GLfloat) baseline {
	if ( !_fontConfig ) return 0.0f;
	return 1.0f - (GLfloat)_fontConfig.baseline / (GLfloat)_fontConfig.commonHeight;
}

#pragma mark Mesh population

-(void) populateLabelMesh {
	if ( !(_fontFileName && _labelString) ) return;

	// If using GL buffers, delete them now, because the population mechanism triggers updates
	// to existing buffers with the new vertex count (which will not match the buffers).
	BOOL isUsingGLBuffers = _mesh.isUsingGLBuffers;
	[_mesh deleteGLBuffers];

	[self populateAsBitmapFontLabelFromString: self.labelString
								 fromFontFile: self.fontFileName
								andLineHeight: self.lineHeight
							 andTextAlignment: self.textAlignment
							andRelativeOrigin: self.relativeOrigin
							  andTessellation: self.tessellation];
	
	// If using GL buffers, recreate them now.
	if (isUsingGLBuffers) [_mesh createGLBuffers];

	[self markBoundingVolumeDirty];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.labelString = @"hello, world";		// Fail-safe to display if nothing set
		_fontFileName = nil;
		_fontConfig = nil;
		_lineHeight = 0;
		_textAlignment = NSTextAlignmentLeft;
		_relativeOrigin = ccp(0,0);
		_tessellation = CC3TessellationMake(1,1);
	}
	return self;
}

-(void) populateFrom: (CC3BitmapLabelNode*) another {
	[super populateFrom: another];

	_relativeOrigin = another.relativeOrigin;
	_textAlignment = another.textAlignment;
	_tessellation = another.tessellation;
	_lineHeight = another.lineHeight;
	self.fontFileName = another.fontFileName;
	self.labelString = another.labelString;		// Will trigger repopulation
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ '%@'", super.description, self.labelString];
}

@end


#pragma mark -
#pragma mark CC3Mesh bitmapped label extension

typedef struct {
	GLfloat lineWidth;
	GLuint lastVertexIndex;
} CC3BMLineSpec;

/** CC3MeshNode extension to support bitmapped labels. */
@implementation CC3Mesh (BitmapLabel)

-(void) populateAsBitmapFontLabelFromString: (NSString*) lblString
									andFont: (CC3BitmapFontConfiguration*) fontConfig
							  andLineHeight: (GLfloat) lineHeight
						   andTextAlignment: (NSTextAlignment) textAlignment
						  andRelativeOrigin: (CGPoint) origin
							andTessellation: (CC3Tessellation) divsPerChar {
	
	CGPoint charPos, adjCharPos;
	CGSize layoutSize;
	NSInteger kerningAmount;
	unichar prevChar = -1;
	NSUInteger strLen = [lblString length];
	
	if (lineHeight == 0.0f) lineHeight = fontConfig.commonHeight;
	GLfloat fontScale = lineHeight / (GLfloat)fontConfig.commonHeight;
	
	// Line count needs to be calculated before parsing the lines to get Y position
	GLuint charCount = 0;
	GLuint lineCount = 1;
	for(NSUInteger i = 0; i < strLen; i++)
		([lblString characterAtIndex: i] == '\n') ? lineCount++ : charCount++;
	
	// Create a local array to hold the dimensional characteristics of each line of text
	CC3BMLineSpec lineSpecs[lineCount];
	
	// We now know the height of the layout. Width will be determined as the lines are laid out.
	layoutSize.width =  0;
	layoutSize.height = lineHeight * lineCount;
	
	// Prepare the vertex content and allocate space for the vertices and indexes.
	[self ensureVertexContent];
	GLuint vtxCountPerChar = (divsPerChar.x + 1) * (divsPerChar.y + 1);
	GLuint triCountPerChar = divsPerChar.x * divsPerChar.y * 2;
	self.allocatedVertexCapacity = vtxCountPerChar * charCount;
	self.allocatedVertexIndexCapacity = triCountPerChar * 3 * charCount;
	
	LogTrace(@"Creating label %@ with %i (%i) vertices and %i (%i) vertex indices from %i chars on %i lines in text %@",
			 self, self.vertexCount, self.allocatedVertexCapacity,
			 self.vertexIndexCount, self.allocatedVertexIndexCapacity, charCount, lineCount, lblString);
	
	// Start at the top-left corner of the label, above the first line.
	// Place the first character at the left of the first line.
	charPos.x = 0;
	charPos.y = lineCount * lineHeight;
	
	GLuint lineIndx = 0;
	GLuint vIdx = 0;
	GLuint iIdx = 0;
	
	// Iterate through the characters
	for (NSUInteger i = 0; i < strLen; i++) {
		unichar c = [lblString characterAtIndex: i];
		
		// If the character is a newline, don't draw anything and move down a line
		if (c == '\n') {
			lineIndx++;
			charPos.x = 0;
			charPos.y -= lineHeight;
			continue;
		}
		
		// Get the font specification and for the character, the kerning between the previous
		// character and this character, and determine a positioning adjustment for the character.
		CC3BitmapCharDef* charSpec = [fontConfig characterSpecFor: c];
		CC3Assert(charSpec, @"%@: no font specification loaded for character %i", self, c);
		
		kerningAmount = [fontConfig kerningBetween: prevChar and: c] * fontScale;
		adjCharPos.x = charPos.x + (charSpec->xOffset * fontScale) + kerningAmount;
		adjCharPos.y = charPos.y - (charSpec->yOffset * fontScale);
		
		// Determine the size of each tesselation division for this character.
		// This is specified in terms of the unscaled font config. It will be scaled later.
		CGSize divSize = CGSizeMake(charSpec->rect.size.width / divsPerChar.x,
									charSpec->rect.size.height / divsPerChar.y);
		
		// Initialize the current line spec
		lineSpecs[lineIndx].lastVertexIndex = 0;
		lineSpecs[lineIndx].lineWidth = 0.0f;
		
		// Populate the tesselated vertex locations, normals & texture coordinates for a single
		// character. Iterate through the rows and columns of the tesselation grid, from the top-left
		// corner downwards. This orientation aligns with the texture coords in the font file.
		// Set the location of each vertex and tex coords to be proportional to its position in the
		// grid, and set the normal of each vertex to point up the Z-axis.
		for (GLuint iy = 0; iy <= divsPerChar.y; iy++) {
			for (GLuint ix = 0; ix <= divsPerChar.x; ix++, vIdx++) {
				
				// Cache the index of the last vertex of this line. Since the vertices are accessed
				// in consecutive, ascending order, this is done by simply setting it each time.
				lineSpecs[lineIndx].lastVertexIndex = vIdx;
				
				// Vertex location
				GLfloat vx = adjCharPos.x + (divSize.width * ix * fontScale);
				GLfloat vy = adjCharPos.y - (divSize.height * iy * fontScale);
				[self setVertexLocation: cc3v(vx, vy, 0.0) at: vIdx];
				
				// If needed, expand the line and layout width to account for the vertices
				lineSpecs[lineIndx].lineWidth = MAX(lineSpecs[lineIndx].lineWidth, vx);
				layoutSize.width = MAX(layoutSize.width, vx);
				
				// Vertex normal. Will do nothing if this mesh does not include normals.
				[self setVertexNormal: kCC3VectorUnitZPositive at: vIdx];
				
				// Vertex texture coordinates, inverted vertically, because we're working top-down.
				CGSize texSize = fontConfig.textureSize;
				GLfloat u = (charSpec->rect.origin.x + (divSize.width * ix)) / texSize.width;
				GLfloat v = (charSpec->rect.origin.y + (divSize.height * iy)) / texSize.height;
				[self setVertexTexCoord2F: cc3tc(u, (1.0f - v)) at: vIdx];
				
				// In the grid of division quads for each character, each vertex that is not
				// in either the top-most row or the right-most column is the bottom-left corner
				// of a division. Break the division into two triangles.
				if (iy < divsPerChar.y && ix < divsPerChar.x) {
					
					// First triangle of face wound counter-clockwise
					[self setVertexIndex: vIdx at: iIdx++];							// TL
					[self setVertexIndex: (vIdx + divsPerChar.x + 1) at: iIdx++];	// BL
					[self setVertexIndex: (vIdx + divsPerChar.x + 2) at: iIdx++];	// BR
					
					// Second triangle of face wound counter-clockwise
					[self setVertexIndex: (vIdx + divsPerChar.x + 2) at: iIdx++];	// BR
					[self setVertexIndex: (vIdx + 1) at: iIdx++];					// TR
					[self setVertexIndex: vIdx at: iIdx++];							// TL
				}
			}
		}
		
		// Horizontal position of the next character
		charPos.x += (charSpec->xAdvance * fontScale) + kerningAmount;
		
		prevChar = c;	// Remember the current character before moving on to the next
	}
	
	// Iterate through the lines, calculating the width adjustment to correctly align each line,
	// and applying that adjustment to the X-component of the location of each vertex that is
	// contained within that text line.
	for (GLuint i = 0; i < lineCount; i++) {
		GLfloat widthAdj;
		switch (textAlignment) {
			case NSTextAlignmentCenter:
				// Adjust vertices so half the white space is on each side
				widthAdj = (layoutSize.width - lineSpecs[i].lineWidth) * 0.5f;
				break;
			case NSTextAlignmentRight:
				// Adjust vertices so all the white space is on the left side
				widthAdj = layoutSize.width - lineSpecs[i].lineWidth;
				break;
			case NSTextAlignmentLeft:
			default:
				// Leave all vertices where they are
				widthAdj = 0.0f;
				break;
		}
		if (widthAdj) {
			GLuint startVtxIdx = (i > 0) ? (lineSpecs[i - 1].lastVertexIndex + 1) : 0;
			GLuint endVtxIdx = lineSpecs[i].lastVertexIndex;
			LogTrace(@"%@ adjusting line %i by %.3f (from line width %i in layout width %i) from vertex %i to %i",
					 self, i, widthAdj, lineSpecs[i].lineWidth, layoutSize.width, startVtxIdx, endVtxIdx);
			for (vIdx = startVtxIdx; vIdx <= endVtxIdx; vIdx++) {
				CC3Vector vtxLoc = [self vertexLocationAt: vIdx];
				vtxLoc.x += widthAdj;
				[self setVertexLocation: vtxLoc at: vIdx];
			}
		}
	}
	
	// Move all vertices so that the origin of the vertex coordinate system is aligned
	// with a location derived from the origin factor.
	GLuint vtxCnt = self.vertexCount;
	CC3Vector originLoc = cc3v((layoutSize.width * origin.x), (layoutSize.height * origin.y), 0);
	for (vIdx = 0; vIdx < vtxCnt; vIdx++) {
		CC3Vector locOld = [self vertexLocationAt: vIdx];
		CC3Vector locNew = CC3VectorDifference(locOld, originLoc);
		[self setVertexLocation: locNew at: vIdx];
	}
}

@end