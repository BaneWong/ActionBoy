//
//  HUD.h
//  PuzzleCities
//
//  Created by Jon taylor on 11-01-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLView.h"
#import "Texture2D.h"
#import "MyTexture2D.h"

@interface HUD : NSObject {

	Texture2D *titleTexture;
	Texture2D *healthTexture;
	Texture2D *pointsTexture;
	Texture2D *dialogTexture;
	Texture2D *fpsTexture;
	Texture2D *hudTexture;
	
	Texture2D *thumbpadTexture;
	Texture2D *buttonATexture;
	Texture2D *buttonBTexture;
    Texture2D *thumbpadHighlightTexture;
	
	Texture2D *inGameMenuTexture;
    Texture2D *inGameLevelTexture;
    NSString * levelString;
    
    Texture2D *inGameChangeLevelTexture;
    NSString * changeLevelString;
    int changeLevelIndex;
    Texture2D *inGameMenuChangeTexture;
    
    
    Texture2D * rateShareTexture;
    
    Texture2D *loadingTexture;
    Texture2D *deadTexture;
    
    MyTexture2D *directionTexture;
    
    NSMutableArray* levelNames;
    
    int points;
    float direction;
    
    float windowWidth;
    float windowHeight;
    
    int leftTouchX;
    int leftTouchY;
}

- (void)initHUD:(NSString*)text;
- (void)drawHUD:(GLView*)view;
- (void)setFps:(NSNumber*)fps;

-(void)switchToOrtho:(GLView*)view;
-(void)switchBackToFrustum;

- (void)setHealth:(int)h;
- (void)setPoints:(int)p;

- (void) setLevelString:(NSString*)v;
- (void) setChangeLevelString:(NSString*)v;

- (NSString*) touch:(int)touchX  y:(int)touchY;

- (void)drawLoading:(GLView*)view;
- (void)drawDeadScreen:(GLView*)view;
- (void) setDirection:(float)dir;

- (void) reloadAccessableLevels;

- (void) setLeftTouch:(int)x y:(int)y;

@end
