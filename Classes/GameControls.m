//
//  GameControls.m
//  OpenGLES13
//
//  Created by Jon taylor on 11/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>
//#import <OpenGLES/EAGLDrawable.h>

#import "GameControls.h"

@implementation GameControls


void GLDrawEllipse2 (int segments, CGFloat width, CGFloat height, CGPoint center, bool filled);
void GLDrawCircle2 (int circleSegments, CGFloat circleSize, CGPoint center, bool filled);
float degreesToRadian2(float angle);


- (id)init {
    self = [super init];
    if (self) {
        controlsVisible		= true;
        mView = nil;
        
        CONTROLS_NOTHING	= 0;
        CONTROLS_FORWARD	= 10;
        CONTROLS_BACKWARD	= 20;
        CONTROLS_LEFT		= 30;
        CONTROLS_RIGHT		= 40;
        CONTROLS_A			= 50;
        CONTROLS_B			= 60;
        CONTROLS_MENU		= 100;
        
        /*
        NSString *thumbpadpath = [[NSBundle mainBundle] pathForResource:@"thumbpad" ofType:@"png"];
        thumbpadTexture = [[Texture2D alloc] initWithImagePath:thumbpadpath];
        
        NSString *buttonapath = [[NSBundle mainBundle] pathForResource:@"button_a" ofType:@"png"];
        buttonATexture = [[Texture2D alloc] initWithImagePath:buttonapath];
        
        NSString *buttonbpath = [[NSBundle mainBundle] pathForResource:@"button_b" ofType:@"png"];
        buttonBTexture = [[Texture2D alloc] initWithImagePath:buttonbpath];
        */
        
        screenX = 320;
        screenY = 480;
	}
    return self;
}


/**
 * drawControls
 *
 * Description:
 *   Draw navigation controls on the screen.
 *   3d geometry appears in front of camera in a 
 *   stationary position.
 *
 *
 *  *********** NOT CALLED ***********
 */
- (void)drawControls:(GLView*)view {
    mView = view;
	//NSLog(@"cont %d ", controlsVisible);
	if(controlsVisible == true && false ) // || true
	{
		glLoadIdentity();
		
		glEnableClientState(GL_NORMAL_ARRAY);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		float depth = -0.02;
		
		glTranslatef(0.0, 0.0, depth);
		
		//CGFloat circleSize = 0.15;
		CGPoint location;
		location.x = -0.2;  // is y vertical
		location.y = 0.4;  // is x vertical
		//glColor4f(0.5f,0.5f,1.0f,1.0f);	 // Set color to blue
		//GLDrawCircle2 (30, circleSize, location , false);
		
		glLoadIdentity();
		glTranslatef(-0.05, 0.05, -1.0);
		glColor4f(0.5f,0.5f,1.0f,0.2f);	 // Set color to blue
		//GLDrawCircle2 (30, circleSize, location, false);
		
		
		
		glLoadIdentity();
		glTranslatef(-0.05, 0.05, -1.0);
		//glTranslatef(0.0, 0.0, depth);
		CGFloat actionButtonCircleSize = 0.08;
		CGPoint actionButtonLocation;
		actionButtonLocation.x = -0.25;
		actionButtonLocation.y = -0.42;
		glColor4f(1.0f,0.2f,0.2f,1.0f);	 // Set color to red
		GLDrawCircle2 (30, actionButtonCircleSize, actionButtonLocation, false);
		/*
		glLoadIdentity();
		glTranslatef(0.0, 0.0, -1.0);
		glColor4f(1.0f,0.2f,0.2f,1.0f);	 // Set color to red
		actionButtonCircleSize = 0.292;
		GLDrawCircle2 (30, actionButtonCircleSize, actionButtonLocation, false);
		
		glLoadIdentity();
		glTranslatef(0.0, 0.0, -3.0);
		glColor4f(1.0f,0.2f,0.2f,1.0f);	 // Set color to red
		actionButtonCircleSize = 0.284;
		GLDrawCircle2 (30, actionButtonCircleSize, actionButtonLocation, false);
		*/
		
		glLoadIdentity();
		glTranslatef(-0.05, 0.05, -1.0);
		glTranslatef(0.0, 0.0, depth);
		CGFloat auxButtonCircleSize = 0.08;
		CGPoint auxButtonLocation;
		auxButtonLocation.x = -0.10;
		auxButtonLocation.y = -0.58;
		glColor4f(1.0f,1.0f,0.3f,1.0f);	 // Set color to yellow
		GLDrawCircle2 (30, auxButtonCircleSize, auxButtonLocation, false);
		/*
		glLoadIdentity();
		glTranslatef(0.0, 0.0, -3.0);
		glColor4f(1.0f,1.0f,0.3f,1.0f);	 // Set color to yellow
		auxButtonCircleSize = 0.292;
		GLDrawCircle2 (30, auxButtonCircleSize, auxButtonLocation, false);
		glLoadIdentity();
		glTranslatef(0.0, 0.0, -3.0);
		glColor4f(1.0f,1.0f,0.3f,1.0f);	 // Set color to yellow
		auxButtonCircleSize = 0.284;
		GLDrawCircle2 (30, auxButtonCircleSize, auxButtonLocation, false);
		*/
		// Draw button graphic
		//[self drawImageButton];
		
		
		
		// Main menu
		glLoadIdentity();
		glTranslatef(0.0, 0.0, depth);
		CGFloat pButtonCircleSize = 0.008;
		CGPoint pButtonLocation;
		pButtonLocation.x = -0.068;
		pButtonLocation.y = 0.0;
		glColor4f(0.2f,0.2f,0.2f,1.0f);	 // Set color to yellow
		GLDrawCircle2 (30, pButtonCircleSize, pButtonLocation, false);
		
		
		// reset color
		glColor4f(1.0f,1.0f,1.0f,1.0f);
		
		
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_NORMAL_ARRAY);
		
		
		
		// Images
		/*
		[self switchToOrtho:view];
		glLineWidth(3.0);
		glColor4f(1.0, 1.0, 1.0, 0.0); // blue
		//glTranslatef(5.0, 0.0, 0.0);
		//glVertexPointer(2, GL_FLOAT, 0, squareVertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
		glBlendFunc (GL_ONE, GL_ONE);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		if(thumbpadTexture != nil){
			[thumbpadTexture drawAtPoint: CGPointMake(100.0, 380.0) depth:-1];
		}
		
		if(buttonATexture != nil){
			[buttonATexture drawAtPoint: CGPointMake(105.0, 45.0) depth:-1];  // gun
		}
		
		if(buttonBTexture != nil){
			[buttonBTexture drawAtPoint: CGPointMake(40.0, 100.0) depth:-1];  // hand
		}
		
		glDisable(GL_BLEND);
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		[self switchBackToFrustum];
		*/
	}
	
	// reset color
	glColor4f(1.0f,1.0f,1.0f,1.0f);
}

- (void)setVisible:(bool)v
{
	NSLog(@"         setVisible %d ", v);
	if(v == true){
		controlsVisible = true;
	} else {
		controlsVisible = false;
	}
}
- (void)hide
{
	controlsVisible = false;
}



/**
 * touch handler
 *
 */
- (int) touch:(NSNumber *)touchX y:(NSNumber *)touchY {
	int result = 0;
	//NSLog(@" cont touch  %d  %d ", [touchX intValue]  , [touchY intValue]);
	
	
	if([touchX intValue] > 20 && [touchX intValue] < 60 && [touchY intValue] > 130 && [touchY intValue] < 300){
		result = CONTROLS_MENU;
	}
	
	if([touchX intValue] > 11 && [touchX intValue] < 160 && [touchY intValue] > 15 && [touchY intValue] < 150){
		result = CONTROLS_RIGHT;
	}
	
	return result;
}

- (int) redButton:(int)touchX y:(int)touchY {
	int result = 0;
    
    // iPhone
	if(touchX > 402 && touchX < 468 && touchY > 95 && touchY < 128){
		result = 1;
	}
    
    // iPad
    if(touchX > 955 && touchX < 1010 && touchY > 67 && touchY < 128){
		result = 1;
	}
    
    //NSLog(@" Red: %d     x %d   y %d", result, touchX , touchY );
	
    return result;
}

- (int) blueButton:(int)touchX y:(int)touchY;
{
	int result = 0;
    //NSLog(@"  x %d   y %d", touchX , touchY );
	if(touchX > 12 && touchX < 73 && touchY > 353 && touchY < 417){
		result = 1;
	}
    
    
    //NSLog(@" Blue: %d     x %d   y %d", result, touchX , touchY );
	return result;
}


- (int) thumbPad:(int)touchX y:(int)touchY {
	int result = 0;
	
	int padOffset = 8;
	int padSize = 120;
	
	if(touchY > padOffset && touchX > padOffset && 
	   touchY < (padSize) && touchX < padSize){
		result = 1;
	}
	return result;
}


/**
 * gameMenu
 *
 */
- (int) gameMenu:(int)touchX y:(int)touchY {
	//NSLog(@" gameMenu touch  %d  %d ", touchX , touchY );
	int result = 0;
    
    // x 291 y  
    
    // 
	if( touchX > (screenX-30) && touchY < 75){
		result = 1;
	}
	return result;
}


/**
 * setScreenX
 *
 *
 */
-(void) setScreenX:(int)x Y:(int)y 
{
    screenX = x;
    screenY = y;
}


//
// Draw utilities 
//
void GLDrawEllipse2 (int segments, CGFloat width, CGFloat height, CGPoint center, bool filled)
{
	glTranslatef(center.x, center.y, 0.0);
	GLfloat vertices[segments*2];
	int count=0;
	for (GLfloat i = 0; i < 360.0f; i+=(360.0f/segments))
	{
		vertices[count++] = (cos(degreesToRadian2(i))*width);
		vertices[count++] = (sin(degreesToRadian2(i))*height);
	}
	glVertexPointer (2, GL_FLOAT , 0, vertices); 
	
	//glColor4f(1.0f,1.0f,1.0f,0.5f);
	
	glDrawArrays ((filled) ? GL_TRIANGLE_FAN : GL_LINE_LOOP, 0, segments);
	
}

void GLDrawCircle2 (int circleSegments, CGFloat circleSize, CGPoint center, bool filled) 
{
	GLDrawEllipse2(circleSegments, circleSize, circleSize, center, filled);
}

float degreesToRadian2(float angle)
{
	return (float)(M_PI * angle / 180.0f);
}


-(void)switchToOrtho:(GLView*)view 
{
    glDisable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
	
    glOrthof(0, view.bounds.size.width, 0, view.bounds.size.height, -5, 1);       
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

-(void)switchBackToFrustum 
{
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
}


@end
