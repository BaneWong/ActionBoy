//
//  ObjectContainer.h
//  OpenGLES13
//
//  Created by Jon taylor on 12/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "BlenderObject.h"
#import "OpenGLWaveFrontObject.h"


#define MAX(a,b) (a > b) ? a : b  // yes this is needed
#define MIN(a,b) (a < b) ? a : b

@interface ObjectContainer : NSObject {
	int objId;
	
	BlenderObject* blenderObject;
	OpenGLWaveFrontObject *wavefrontObject;
	
	NSString* wavefrontFile;
	NSString* name;
	NSString* file;
	NSString* type;
	
	float locX;
	float locY;
	float locZ;
	
	float rotX;
	float rotY;
	float rotZ;
	
	float scaleX;
	float scaleY;
	float scaleZ;
	
	NSString* colour;
	float red;
	float green;
	float blue;
	
	float size;
	float tileYSideX;
	float tileYSideZ;
	float tileYSideXZ;
	
	NSString* text;
	int touched;
    BOOL collision;
    int hits;
    int health;
    int cost;
    int damage;
    double stunDistance;
}

//@property (nonatomic, retain) NSNumber * objId;
@property (nonatomic, retain) BlenderObject * blenderObject;
@property (nonatomic, retain) OpenGLWaveFrontObject *wavefrontObject;
@property (nonatomic, retain) NSString * wavefrontFile;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * file;
@property (nonatomic, retain) NSString * text;

@property (nonatomic) double stunDistance;


//- (id)init;
- (id)initMe;

//- (void)name(NSString*)n;

- (void) setObjId:(int)v;
- (int) objId;

- (NSString*) type;

// Float
- (void) setLocX:(float)v;
- (void) setLocY:(float)v;
- (void) setLocZ:(float)v;
- (float) locX;
- (float) locY;
- (float) locZ;

//Float
- (void) setRotX:(float)v;
- (void) setRotY:(float)v;
- (void) setRotZ:(float)v;
- (float) rotX;
- (float) rotY;
- (float) rotZ;

//Float
- (void) setScaleX:(float)v;
- (void) setScaleY:(float)v;
- (void) setScaleZ:(float)v;
- (float) scaleX;
- (float) scaleY;
- (float) scaleZ;


//- (void) colour:(NSString*)c;
//- (NSString*) getColour;
- (void) setRed:(float)v;
- (void) setGreen:(float)v;
- (void) setBlue:(float)v;
- (float) red;
- (float) green;
- (float) blue;

- (float) size;
- (float) tileYSideX;
- (float) tileYSideZ;
- (float) tileYSideXZ;

- (float) setSize:(float)v;
- (float) setTileYSideX:(float)v;
- (float) setTileYSideZ:(float)v;
- (float) setTileYSideXZ:(float)v;


- (void) forward:(float)v;
- (void) turn:(float)v;
- (void) moveToSide:(float)v;
- (double) angleToPoint:(double)xp y:(double)yp;

- (void) blenderObject:(BlenderObject*)n;
- (void) wavefrontObject:(OpenGLWaveFrontObject*)n;

- (NSString*) name;
- (void) setName:(NSString*)n;

- (void) setTouched:(int)v;
- (int) touched;

- (void) setCollision:(BOOL)v;
- (BOOL) collision;

- (void) setColour:(NSString*)c;
- (NSString*) colour;

- (void) file:(NSString*)f;

-(void) setHits:(int)v;
-(int) hits;

-(void) setDamage:(int)v;
-(int) damage;

-(void) setHealth:(int)v;
-(int) health;

-(void) setCost:(int)v;
-(int) cost;

@end
