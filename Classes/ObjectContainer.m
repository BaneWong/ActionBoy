//
//  ObjectContainer.m
//  OpenGLES13
//
//  Created by Jon taylor on 12/07/09.
//  Copyright 2009 Subject Reality Software. All rights reserved.
//

#import "ObjectContainer.h"


@implementation ObjectContainer

@synthesize name, file;
@synthesize blenderObject;
//@synthesize red, green, blue;
//@synthesize	size, tileYSideX, tileYSideZ, tileYSideXZ;
@synthesize	text;
@synthesize wavefrontFile, wavefrontObject;
@synthesize stunDistance;

- (id)init {
    self = [super init];
    if (self) {
        name = @"default";
        locX = 0;
        locY = 0;
        locZ = 0;
        rotX = 0;
        rotY = 0;
        rotZ = 0;
        scaleX = 0;
        scaleY = 0;
        scaleZ = 0;
        
        colour = @"";
        red = -1;
        green = -1;
        blue = -1;
        
        size = 16;
        tileYSideX = -9999;
        tileYSideZ = -9999;
        tileYSideXZ = -9999;
        
        text = nil;
        touched = 0;
        collision = FALSE;
        blenderObject = nil;
        hits = 1;
        health = 100;
        cost = 0;
        
        wavefrontFile = nil;
        
        stunDistance = 0;
	
        //[super init];
     
    }
    return self;
}

- (id)initMe {
    [self init];
    return self;
}

- (void) setObjId:(int)v {
	objId = v;
}

- (int) objId {
	return objId;
}

- (void) blenderObject:(BlenderObject*)n {
	[n retain];
	[blenderObject release];
	blenderObject = n;
}

- (void) wavefrontObject:(OpenGLWaveFrontObject*)n {
	[n retain];
	[wavefrontObject release];
	wavefrontObject = n;
}

- (void) setName:(NSString*)n {
	[n retain];
	[name release];
	name = n;
}
- (NSString*) name {
	return name;
}

- (void) file:(NSString*)f {
	[f retain];
	[file release];
	file = f;
}

- (void) wavefrontFile:(NSString*)f {
	[f retain];
	[wavefrontFile release];
	wavefrontFile = f;
}

- (void) setLocX:(float)v {
	locX = v;
}

- (void) setLocY:(float)v {
	locY = v;
}

- (void) setLocZ:(float)v {
	locZ = v;
}

- (float) locX {
	return locX;
}

- (float) locY {
	return locY;
}

- (float) locZ {
	return locZ;
}



- (void) setRotX:(float)v {
	rotX = v;
}
- (void) setRotY:(float)v {
	rotY = v;
}
- (void) setRotZ:(float)v {
	rotZ = v;
}

- (float) rotX {
	return rotX;
}
- (float) rotY {
	return rotY;
}
- (float) rotZ {
	return rotZ;
}


- (void) setScaleX:(float)v {
	scaleX = v;
}
- (void) setScaleY:(float)v {
	scaleY = v;
}
- (void) setScaleZ:(float)v {
	scaleZ = v;
}

- (float) scaleX {
	return scaleX;
}
- (float) scaleY {
	return scaleY;
}
- (float) scaleZ {
	return scaleZ;
}


- (void) setColour:(NSString*)c {
	[c retain];
	[colour release];
	colour = c;
}
- (NSString*) colour {
	return colour;
}

- (void) setRed:(float)v {
	red = v;
}
- (void) setGreen:(float)v {
	green = v;
}
- (void) setBlue:(float)v {
	blue = v;
}

- (float) red {
	return red;
}
- (float) green {
	return green;
}
- (float) blue {
	return blue;
}




- (float) size {
	return size;
}
- (float) tileYSideX {
	return tileYSideX;
}
- (float) tileYSideZ {
	return tileYSideZ;
}
- (float) tileYSideXZ {
	return tileYSideXZ;
}

- (float) setSize:(float)v {
	size = v;
}

- (float) setTileYSideX:(float)v {
	tileYSideX = v;
}
- (float) setTileYSideZ:(float)v {
	tileYSideZ = v;
}
- (float) setTileYSideXZ:(float)v {
	tileYSideXZ = v;
}


- (void) setText:(NSString*)t {
	[t retain];
	[text release];
	text = t;
}
- (NSString*) getText {
	return text;
}


- (void) setTouched:(int)v {
	touched = v;
}

- (int) touched {
	return touched;
}

- (void) setCollision:(BOOL)v {
	collision = v;
}

- (BOOL) collision {
	return collision;
}

-(void) setHits:(int)v {
    hits = v;
}

-(int) hits {
    return hits;
}


-(void) setDamage:(int)v {
    damage = v;
}

-(int) damage {
    return damage;
}

-(void) setHealth:(int)v {
    health = v;
}

-(int) health {
    return health;
}


-(void) setCost:(int)v {
    cost = v;
}

-(int) cost {
    return cost;
}

- (NSString*) type 
{    
    return type;
}

- (void) forward:(float)v { // change to float
	//[v 
	if(rotY  > 360){
		rotY = 0;
	}
	//rotY = [[NSNumber alloc] initWithFloat: [rotY floatValue] + 0.3 ];  
	
	if(touched){
		return;
	}
	
	double rotYRadians = -3.14 * rotY / 180;
	rotYRadians -= (3.14 / 2);
	
	//x = [[NSNumber alloc] initWithFloat: [x floatValue] +  (cos( rotYRadians ) * [v floatValue]) ]; 
	//z = [[NSNumber alloc] initWithFloat: [z floatValue] +  sin( rotYRadians ) * [v floatValue] ]; 
	locX = locX + (cos( rotYRadians ) * v); 
	locZ = locZ + sin( rotYRadians ) * v;
	//NSLog(@"rotY  %f    %f %f - %f " , [rotY floatValue] , [x floatValue], [z floatValue], [[self getX] floatValue] );
	//NSLog(@" x offset:  %f  %f",  (cos( rotYRadians )), [v floatValue]);
	
	//x = x + cos(n) * d
	//z = z + sin(n) * d
	
	//[x release];
	//x = [NSNumber numberWithFloat:1];
	//x = x + 1;
}


- (void) moveToSide:(float)v { // change to float
	//[v 
	if(rotY > 360){
		rotY = 0;
	}
	//rotY = [[NSNumber alloc] initWithFloat: [rotY floatValue] + 0.3 ];  
	
	if(touched){
		return;
	}
	
	double rotYRadians = -3.14 * rotY / 180;
	//rotYRadians -= (3.14 / 2);
	
	//x = [[NSNumber alloc] initWithFloat: [x floatValue] +  (cos( rotYRadians ) * [v floatValue]) ]; 
	//z = [[NSNumber alloc] initWithFloat: [z floatValue] +  sin( rotYRadians ) * [v floatValue] ]; 
	locX = locX + (cos( rotYRadians ) * v); 
	locZ = locZ + sin( rotYRadians ) * v;
	//NSLog(@"rotY  %f    %f %f - %f " , [rotY floatValue] , [x floatValue], [z floatValue], [[self getX] floatValue] );
	//NSLog(@" x offset:  %f  %f",  (cos( rotYRadians )), [v floatValue]);
}

- (void) turn:(float)v {
	///[rotY release];
	//rotY = [[NSNumber alloc] initWithFloat: [rotY floatValue] + [v floatValue] ];
	//[self rotY: [self getRotY] + [v floatValue] ];
	rotY = rotY + v;
	
	if(rotY > 360){
		 
		//rotY = [[NSNumber alloc] initWithFloat: [rotY floatValue] - 360 ];
		//[self setRotY: [NSNumber numberWithFloat: [rotY floatValue] - 360 ]];
		rotY = rotY - 360;
	}
	if(rotY < 0){
		
		//rotY = [[NSNumber alloc] initWithFloat: [rotY floatValue] + 360 ];
		//[self setRotY: [NSNumber numberWithFloat: [rotY floatValue] + 360 ]];
		rotY = rotY + 360;
	}
}


/**
 * Calculate the angle this object faces a given point
 *
 */
- (double) angleToPoint:(double)xp y:(double)yp {
	//NSLog(@" loc  %f   %f  point:  %f   %f ",locX,  locZ, xp, yp);
	//double currX = [x doubleValue];
	//double currY = [z doubleValue];
	xp -= MAX(locX, xp) - MIN(locX, xp);
	yp -= MAX(locZ, yp) - MIN(locZ, yp);
	
	//NSLog(@" rel   : %f %f    : %f  %f   " , xp, yp, currX, currY  );
	double objectAngle = ( atan2(yp, xp) ) * 180.0 / 3.14;
	
	if(objectAngle < 0){
		objectAngle = objectAngle + 360;
	}
	
	//NSLog(@"                 angle2  : %f " , objectAngle );
	//NSLog(@"   %f ", atan2(currY, currX));
	
	objectAngle += (90);
	if(objectAngle > 360){
		objectAngle = objectAngle - 360;
	}
	if(objectAngle < 0){
		objectAngle = objectAngle + 360;
	}
	
	double r = (objectAngle) - (360 - rotY);
	
	if(r > 360){
		r = r - 360;
	}
	if(r < 0){
		r = r + 360;
	}
	return r;
	//return objectAngle;
}


- (void)dealloc {
	//NSLog(@" dealloc ObjectContainer");
	[name release];
	[file release];
	[type release];
	//[x release];
	//[y release];
	//[z release];
	//[rotX release];
	//[rotY release];
	//[rotZ release];
	//[scaleX release];
	//[scaleY release];
	//[scaleZ release];
	
	[colour release];
	//[red release];
	//[green release];
	//[blue release];
	
	//[size release];
	//[tileYSideX release];
	//[tileYSideZ release];
	//[tileYSideXZ release];
	
	[super dealloc];
}

@end
