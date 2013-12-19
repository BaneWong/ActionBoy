//
//  GLViewController.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLView.h"
#import "Piece.h"
#import "Level.h"
#import "Sprites.h"
#import "HUD.h"
#import "GameControls.h"
#import "LevelLoader.h"
#import "Menu.h"
#import "Network.h"
#import "Bullet.h"
#import "SaveGame.h"
#import "Sound.h"
#import "Avatar.h"

#define WALK_SPEED 0.070
#define TURN_SPEED 0.06

typedef enum __MOVMENT_TYPE {
	MTNone = 0,
	MTWalkForward,
	MTWAlkBackward,
	MTTurnLeft,
	MTTurnRight
} MovementType;

@interface GLViewController : UIViewController <GLViewDelegate>
{
	
	GLuint      texture[2];
	GLuint      uitexture[3];
	
	// Pieces
	NSMutableArray *pieces;
	Piece* movingPiece;
	
	MovementType currentMovement;
	int touchX;
	int touchY;
	float pieceTouchOffsetX;
	float pieceTouchOffsetY;
    
    int leftTouchX;
    int leftTouchY;
    int rightTouchX;
    int rightTouchY;
    
    int leftTouchBeginX;
    int leftTouchBeginY;
    int rightTouchBeginX;
    int rightTouchBeginY;
	
	int thumbPadTouchX;
	int thumbPadTouchY;
    int thumbPadTouched;
	int swipeTilt;
    
    int leftSwipeTurn;
    int rightSwipeTurn;
    int leftSwipeTilt;
    int rightSwipeTilt;
    
	int swipeTurn;
    int swipeMove;
    int swipeTurnMotion;
    //int moveMomentum;
    float moveMomentumSpeed;
    float turnMomentumSpeed;
    
    bool leftSide;
	
	GLView* view; // used to retrieve screen size
	GLfloat eye[3];					// Where we are viewing from
	GLfloat center[3];				// Where we are looking towards
	GLfloat up[3];					// 
	
	int pieceLifted;
	float pieceDropedDepth;
	NSMutableArray *levels;
	int reachedLevel;
	int currentLevelIndex;
	Level* currentLevel;
	
	// jdt - Matricies used for object picking.
	GLfloat __modelview[16];
	GLfloat __projection[16];
	GLint __viewport[4];
	
	
	Sprites * s;
	HUD * hud;
	GameControls* controls;
	LevelLoader* levelLoader;
	GLuint textures[10];
	
	Menu* menu;
	
	int thirdPerson;
	float thirdPersonBack;
	float thirdPersonTilt;
	float thirdPersonHeight;
	BlenderObject* avatar;
    Avatar* avatar2;
	float avatarLocY;
	
	Network * network;
	
	NSTimeInterval lastFpsSample;
	int fps;
	int lastFps;
    double lastFrameTime; 
    double frameRate;
    double frameRateScale;
	
	int health;
	int points;
	
	NSMutableArray* bullets;
    
    float jumpHeight;
    float jumpingStage;
    bool jumpUp;
	
	float avatarTerrainHeight;
	ObjectContainer* avatarLocation;

	bool paused;
    bool dead;
    
    //SaveGame* saveGame;
    
    //Sound *sound;
    int touchCount;
    bool leftHand;
    
    NSTimeInterval initTime; //  = [NSDate timeIntervalSinceReferenceDate]
    NSTimeInterval loadLevelTime;
}

-(void)setupView:(GLView*)v;
//-(void)load:(GLView*)v;

- (void)handleTouches;
- (void)updateHeightOnTerrain;
- (void)moveForward;
- (void)moveBack;
- (void)moveForwardBy:(float)d;
- (void)moveBackBy:(float)d;

- (ObjectContainer *)getAvatarLocation;
- (ObjectContainer *)getCameraLocation;
- (float) getAngleR;
-(float) getAngle;

- (Piece*)multPointByMatrix:(float)x y:(float)y z:(float)z;
-(void)setAvatarLocation:(ObjectContainer*)loc;


-(void)load:(GLView*)view;

-(void)shutdownWarning;

- (void)turn:(NSNumber*)a;
- (void)turnAvatar:(float)angle;
- (void) setLighting;

@end
