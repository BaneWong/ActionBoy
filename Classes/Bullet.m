//
//  Bullet.m
//  Vampires
//
//  Created by Jon taylor on 11-02-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Bullet.h"


@implementation Bullet

-(id)init;
{
    self = [super init];
    if (self) {
        active = 1;
        count = 0;
        x = 0;
        y = 0;
        z = 0;	
        angle = 0;
        
        Vertex3D v = Vertex3DMake(0, 0, 0);
        points[0] = v;
            
        //[super init];
    }
	return self;
}

-(void)move:(double)frameRateScale;
{
	float distance = 0.5 * frameRateScale;
	x = x + distance * sin(angle);
	z = z + distance * -cos(angle);
    
    //y = y - 0.03; // gravity
	
	count++;
	if(count > 200){
		active = 0;
	}
}


/**
 * draw
 *
 * Description: paint bullet
 */
-(void)draw:(GLView*)view;
{
	float dotSize = 5;
	
	glEnableClientState(GL_VERTEX_ARRAY);
	
    float gb = 0.2; 
    float backx = x;
    float backz = z;
    float distance = 0.3;
    for(int i = 0; i < 6; i++){
        if(i == 0 || count > 2){
            glPushMatrix();
        
            glPointSize(dotSize);
            
            backx = backx - distance * sin(angle);
            backz = backz - distance * -cos(angle);
            
            glTranslatef(backx, y, backz);
            
            gb += 0.11; if(gb > 1){gb = 1;}
            dotSize -= 0.5;
            
            glColor4f(1.0f, gb, gb, 0.2f);
            glVertexPointer(3, GL_FLOAT, 0, points);
            glDrawArrays(GL_POINTS, 0, 1);
            
            glPopMatrix();	// Return matrix to origional state
        }
    }
    
    
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
}


- (void) setLocX:(float)v {
	x = v;
}

- (void) setLocY:(float)v {
	y = v;
}

- (void) setLocZ:(float)v {
	z = v;
}


- (float)locX; {
    return x;
}

- (float)locY; {
    return y;
}

- (float)locZ; {
    return z;
}


- (bool) active {
	return active;
}

- (void) setActive:(int)v; 
{
    active = v;
}

- (void) setAngle:(float)v {
	
	angle = v;
	
	//angle -= (M_PI/2);
	/*
	while(angle > (M_PI*2)){
		angle -= (M_PI*2);
	}
	while(angle < 0){
		angle += (M_PI*2);
	}
	*/
	//angle = angle * (180);
	
	//NSLog(@"  angle %f", angle);
}

- (float) angle {
	return angle;
}

- (void)dealloc {
	
	[super dealloc];
}


@end
