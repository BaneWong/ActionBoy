//
//  GameControls.h
//  Vampires
//
//  Created by Jon taylor on 11-02-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
//#import <OpenGLES/ES1/glext.h>
#import "GLView.h"
#import "Texture2D.h"

@interface GameControls : NSObject {
	bool controlsVisible;
	
	GLfloat touchX;
	GLfloat touchY;
	
	GLuint textures[10];
	
	Texture2D *thumbpadTexture;
	Texture2D *buttonATexture;
	Texture2D *buttonBTexture;
    
    Texture2D *thumbHighlightTexture;
    
    GLView* mView;
    
    int screenX;
    int screenY;
	
@public
	int CONTROLS_NOTHING;
	int CONTROLS_FORWARD;
	int CONTROLS_BACKWARD;
	int CONTROLS_LEFT;
	int CONTROLS_RIGHT;
	
	int CONTROLS_A;
	int CONTROLS_B;
	
	int CONTROLS_MENU;
	
}

- (int) thumbPad:(int)touchX y:(int)touchY;
- (int) redButton:(int)touchX y:(int)touchY;
- (int) blueButton:(int)touchX y:(int)touchY;
-(void)switchToOrtho:(GLView*)view;
-(void)switchBackToFrustum;

- (int) gameMenu:(int)touchX y:(int)touchY;
- (void)setVisible:(bool)v;

-(void) setScreenX:(int)x Y:(int)y;

@end