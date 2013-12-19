//
//  Bullet.h
//  Vampires
//
//  Created by Jon taylor on 11-02-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLView.h"
#import "OpenGLCommon.h" // Vertex3D

@interface Bullet : NSObject {
	int active;
	int count;
	float x;
	float y;
	float z;
	float angle;
	
	Vertex3D points[1];
}

- (void) setLocX:(float)v;
- (void) setLocY:(float)v;
- (void) setLocZ:(float)v;
- (float) locX;
- (float) locY;
- (float) locZ;

- (void) setAngle:(float)v;
- (float) angle;

- (bool) active;

-(void)move:(double)frameRateScale;
-(void)draw:(GLView*)view;

- (void) setActive:(int)v;

@end
