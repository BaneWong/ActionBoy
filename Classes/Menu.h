//
//  Menu.h
//  OpenGLES13
//
//  Created by Jon taylor on 15/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "GLView.h"
#import "Texture2D.h"

@interface Menu : NSObject {

	bool visible;
	NSMutableArray* textures;
	
	NSString* currentMenu;
	NSString* readingMenu;
	
	NSString* titleText;
	Texture2D* titleTexture;
	
	Texture2D *testTexture;
	
	NSMutableArray* menuNames;
	NSMutableArray* menuActions;
	NSMutableArray* menuLoads;
	
	NSString* clickedName;
	NSString* clickedAction;
	NSString* clickedLoad;
    GLView* mView;
}

- (void)load:(NSString*)menuName;
- (void) displayMenu:(GLView*)view;
-(void)switchToOrtho:(GLView*)view;
-(void)switchBackToFrustum;

- (NSString*) touch:(NSNumber*)touchX  y:(NSNumber*)touchY;
- (NSString*) clickedAction;
- (NSString*) clickedLoad;

@end
