//
//  LevelLoader.h
//  Vampires
//
//  Created by Jon taylor on 11/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "GLView.h"
#import "BlenderObject.h"
#import "Character.h"
#import "ObjectContainer.h"
#import "Texture2D.h"
#import "Bullet.h"
#import "Sound.h"
#import "SaveGame.h"
#import "Enemy.h"

@interface LevelLoader : NSObject { // NSXMLParserDelegate
	
	GLuint textures[10];
	
	NSMutableArray* objects;
	NSMutableArray* objectsOld;
	NSMutableDictionary* blenderObjectCache;
	
	NSMutableArray* characters;
	NSMutableDictionary* blenderCharacterCache;
	
	NSMutableArray* enemies;
	NSMutableArray* dialogs;
	NSMutableArray* collectibles;
    NSMutableArray* health;
    
	NSMutableDictionary* wavefrontCharacterCache;
	
	// Ground
	//NSMutableArray* groundTiles;
	NSMutableDictionary* groundTiles;
	NSMutableDictionary* grounTextures;
	
	//BlenderObject *circle;
	BlenderObject *female;
	BlenderObject *brushedcube;
	
	NSString* levelName;
	NSString* readingLevel;
	
	NSString* skybox_front;
	NSString* skybox_left;
	NSString* skybox_right;
	NSString* skybox_back;
	NSString* skybox_top;
	NSString* skybox_bottom;
	NSString* lowerBoundX; 
	NSString* initalLocationX;
	NSString* initalLocationY;
	NSString* initalLocationZ;
    NSString* initalAngle;
	NSNumber* completeLocationX;
	NSNumber* completeLocationY;
	NSNumber* completeLocationZ;
	NSString* completeLoad;
	
	int loading;
	Texture2D* loadingTexture;
	
	// Ground
	NSString*  groundTextureName;
	Texture2D* groundTexture;
	GLuint groundTexturesTemp[10]; 
	
	GLfloat* terrainVertices;
	GLfloat* terrainTC;
	
	//GLuint      testtexture[10];
	
	NSMutableDictionary* terrainTextureCache;
	
	GLfloat playerX;
	GLfloat playerY;
	GLfloat playerZ;
	
	GLfloat avatarX;
	GLfloat avatarY;
	GLfloat avatarZ;
    
    GLfloat inFrontX;
	GLfloat inFrontY;
	GLfloat inFrontZ;
    
    GLfloat cameraX;
	GLfloat cameraY;
	GLfloat cameraZ;

	Texture2D *dialogTexture;
	NSString* dialogText;
	
	int paused;
    bool dead;
    int collectedItems;
    float healthPoints;
    
    ObjectContainer* resetPlayerLocation;
    
    NSMutableArray* bullets;
    Sound* sound;
    
    SaveGame* saveGame;
    
    bool avatarCollision;
    float avatarCollisionAngle;
    
    NSObject * callback; // used to update player height on load.
    
    float fps;
    float frs;
    
    OpenGLWaveFrontObject* damageObject;
    float damageObjectRotate;
    NSMutableArray* levelNames;
    
    float ambientLight;
    
    OpenGLWaveFrontObject* downArrowObject;
    float downArrowObjectRotate;
    
    
    NSString * lastPlayedLevel;
    NSString * maxAchivedLevel;
    
    
    int setPlayerHeight;
}

- (void)drawWorldObjects:(GLView*)view;
- (NSMutableArray*) objectsInProximity:(NSMutableArray*)en x:(float)x  z:(float)z d:(float)distance;

//- (void)loadTexture2:(NSString *)name intoLocation:(GLuint)location;
- (void) setPlayerX:(float)px playerY:(float)py playerZ:(float)pz;
//- (void) setPlayerX: (NSNumber*)px Y:(NSNumber*)py Z:(NSNumber*)pz;
- (void) setAvatarX:(float)px playerY:(float)py playerZ:(float)pz;
//- (void) setPlayerX: (NSNumber*)px playerY:(NSNumber*)py playerZ:(NSNumber*)pz;
- (void) setInFrontOfAvatarX:(float)px locY:(float)py locZ:(float)pz;

- (void) setCameraX:(float)px y:(float)py z:(float)pz;

- (void) displayLoading:(GLView*)view;


- (NSNumber*)getInitalLocationX;
- (NSNumber*)getInitalLocationY;
- (NSNumber*)getInitalLocationZ;
- (NSString*)getLevelLoaded;

-(float)completeLocationX;
-(float)completeLocationZ;

- (float)getTerrainHeightX:(float)x z:(float)z;
- (float)distance:(ObjectContainer*)a to:(ObjectContainer*)b;
- (void)drawWorldBox:(float)x  setZ:(float)z;
- (void)loadStaticObjects;
- (void)loadEnemyObjects;
- (void)loadCollectibleObjects;
- (void) loadHealthObjects;

- (NSMutableArray*) touchableObjects;

- (void)setPaused:(int)v;
- (int) collectedItems;
- (int) healthPoints;
- (void) setHealthPoints:(int)h;

- (void) objectTouched:(ObjectContainer*)o;
-(void) loadDeadEnemyObjects:(ObjectContainer*)o;

- (ObjectContainer*) resetPlayerLocation;
-(void) setResetPlayerLocation:(ObjectContainer*)v;

- (void) setLoading:(bool)l;
- (int) loading; 
- (bool)levelCompleted:(float)x y:(float)y z:(float)z;
- (bool)levelCompletedInRange:(float)x y:(float)y z:(float)z;

- (NSMutableArray*) bullets;
- (void) setBullets:(NSMutableArray*) b;

- (void)loadTexture3:(NSString *)name intoLocation:(GLuint)location;
- (void)clearStaticObjects;

-(void)switchToOrtho:(GLView*)view;
-(void)switchBackToFrustum;

- (void)preLoadLevel:(NSString*)lvName;
- (void)drawWorldObjects:(GLView*)view;
- (void)preLoadNextLevel;

- (Sound*) sound;
-(SaveGame*)saveGame;
-(void)shutdownWarning;
- (bool)avatarCollision;
- (float)avatarCollisionAngle:(float)playerAngle;

- (NSString*) completeLoad;

-(void) setCallback:(NSObject*)c;

- (void) setFps:(float)value;
- (void) setFrameRateScale:(float)value;

-(OpenGLWaveFrontObject*) loadDamageObject;
-(OpenGLWaveFrontObject*) loadDownArrowObject;
-(float) ambientLight;

- (void)setDead:(bool)v;

- (void)setDialog:(NSString*)text;

@end
