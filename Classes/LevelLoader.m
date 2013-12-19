//
//  LevelLoader.m
//  OpenGLES13
//
//  Created by Jon taylor on 11/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#include <Accelerate/Accelerate.h>

#import "LevelLoader.h"
#import "BlenderObject.h"

@implementation LevelLoader


void GLDrawEllipse3 (int segments, CGFloat width, CGFloat height, CGPoint center, bool filled);
void GLDrawCircle3 (int circleSegments, CGFloat circleSize, CGPoint center, bool filled);
float degreesToRadian3(float angle);


- (id)init {
	self = [super init];
    if (self) {
        levelName = @"";
        readingLevel = @"";
        levelNames = [[NSMutableArray alloc] init];
        glGenTextures(10, textures);
        
        objects = [[NSMutableArray alloc] init];
        objectsOld = [[NSMutableArray alloc] init];
        blenderObjectCache = [[NSMutableDictionary alloc] init];
        
        characters = [[NSMutableArray alloc] init];
        blenderCharacterCache = [[NSMutableDictionary alloc] init];
        
        enemies = [[NSMutableArray alloc] init];
        dialogs = [[NSMutableArray alloc] init];
        collectibles = [[NSMutableArray alloc] init];
        health = [[NSMutableArray alloc] init];
        
        wavefrontCharacterCache = [[NSMutableDictionary alloc] init];
        
        //enemyStun = [[NSMutableDictionary alloc] init];
        
        //groundTiles = [[NSMutableArray alloc] init];
        groundTiles = [[NSMutableDictionary alloc] init];
        grounTextures = [[NSMutableDictionary alloc] init];
        //glGenTextures(10, groundTexturesTemp);
        
        terrainTextureCache = [[NSMutableDictionary alloc] init];
        
        terrainVertices = nil;
        terrainTC = nil; 
        
        loading = 0;
        
        playerX = 0;
        playerY = 0;
        playerZ = 0;
        
        //completeLocationX = [NSNumber  initWithFloat:0];
        //completeLocationY = [NSNumber initWithFloat:0];
        //completeLocationZ = [NSNumber initWithFloat:0];
        
        dialogText = nil;
        paused = 0;
        
        collectedItems = 0;
        healthPoints = 100;
        
        resetPlayerLocation = nil;
        
        sound = [[Sound alloc] init];
        
        saveGame = [[SaveGame alloc] init];
        
        avatarCollision = false;
        
        callback = nil;
        
        fps = 0;
        frs = 1;
        
        damageObject = nil;
        damageObject = [self loadDamageObject];
        damageObjectRotate = 0;
        
        downArrowObject = [self loadDownArrowObject];
        downArrowObjectRotate = 0;
        
        ambientLight = 0.65;
        
        lastPlayedLevel = nil;
        maxAchivedLevel = nil;
        
        setPlayerHeight = 1; // 
	}
	return self;
}

- (void) setTextures:( GLuint [] )t {
	//self.textures = t;
}

- (void) setFps:(float)value {
    fps = value;
}

- (void) setFrameRateScale:(float)value {
    frs = value;
}

- (void)preLoadLevel:(NSString*)lvName {
	//NSLog(@"preLoadLevel lvName: %@ " , lvName);
	
	if(loading == 0){ // can only load one level at a time.
		levelName = lvName;
		loading = 1;
        
		//NSLog(@" preLoadLevel: %d " , loading);
        
        if( [lvName compare:@"Main Menu"] == 0 ){
            [sound playMenu];
        } else if ([lvName compare:@"The End"] == 0){
            
        } else {
            //[sound stopMenu];
            //[sound playFun];
            //[sound playDanger];
            
            
            //
            // Save to last played 
            // 
            lastPlayedLevel = lvName;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if (defaults) {
                [defaults setObject:lvName forKey:@"lastPlayedLevel"];
                
                NSString * availableKey = [[NSString alloc] initWithFormat:@"available_%@", lvName];
                [defaults setObject:@"true" forKey:availableKey];
                
                [defaults synchronize];
            }

        }        
	}
}

/**
 * Load the next level
 *
 */
- (void)preLoadNextLevel {
    int currIndex = 0;
    // find index value
    for(int i = 0; i < [levelNames count]; i++){
        NSString* currLevel = [levelNames objectAtIndex:i];
        //NSLog(@"  compare: %@   %@ ", currLevel, levelString );
        if([currLevel isEqualToString:levelName]){
            currIndex = i;
            //[self setChangeLevelString:@""];
            i = [levelNames count];
        }
    }
    currIndex++;
    if(currIndex < [levelNames count]){
        [self preLoadLevel:[levelNames objectAtIndex:currIndex]];
    }
}


/**
 * loadLevel
 *
 */
- (void)loadLevel:(NSString*)lvName {
	levelName = lvName;
    healthPoints = 100;
    dead = false;
	NSLog(@" loadLevel: %@ ", levelName);
	
	//
	// clear out old objects
	//
	[objects removeAllObjects];
	[characters removeAllObjects];
    [collectibles removeAllObjects];
    [health removeAllObjects];
    [dialogs removeAllObjects];
    
    // Unload dead enemy models. *************
    NSEnumerator* enemyIterator = [enemies objectEnumerator];
    ObjectContainer* enemyCharacter;
    while((enemyCharacter = [enemyIterator nextObject]))
    {
        if([enemyCharacter wavefrontObject] != nil){
            [[enemyCharacter wavefrontObject] release];
        }
    }
    [enemies removeAllObjects]; // free objects first. 
    
    //
	// Release Ground Tiles
	//
	NSEnumerator* groundTileIterator = [groundTiles objectEnumerator];
	ObjectContainer* groundTileObject;
	while((groundTileObject = [groundTileIterator nextObject]))
	{
		[groundTileObject release];
	}
	[groundTiles removeAllObjects];
    
    
    // Clear wavefront object cache
    [wavefrontCharacterCache removeAllObjects];
    
    
	//[textures release];
	//free(textures);
	glGenTextures(10, textures);
	
	//
	// load XML file
	//
    // load from web
    // 
	
    // Development mode only
    /*
    NSString *uid = [[[UIDevice currentDevice] name] stringByReplacingOccurrencesOfString: @" " withString: @"+"];
    NSString * gameXmlUrl = [NSString stringWithFormat:@"http://subjectreality.appspot.com/getGameXML.jsp?uid=", uid];
    NSData * nsData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:gameXmlUrl]];
    //  NSString * t = [[NSString alloc] initWithData:nsData encoding:NSASCIIStringEncoding]; 
    //NSLog(t);
    */
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"game-definition" ofType:@"xml"];  // In game - release
	NSData *nsData = [NSData dataWithContentsOfFile: path ];        // In Game - release
        //NSString *fileText = [NSString stringWithContentsOfFile:path];
    
    
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:nsData ];
	[xmlParser setDelegate:self];
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];
	[xmlParser parse];
	[xmlParser release];
    
    //[f_collectibles createList:collectibles]; // Create fast list from NSMutableArray
	
	//NSLog(@" collectibles %d", [collectibles count]);
    
	//
	// Load this from level XML file...
	//
	//NSLog(@" load texture1: %@_ ", skybox_front);
	[self loadTexture3:skybox_front intoLocation:1];  // @"ct-front.png"
	[self loadTexture3:skybox_right  intoLocation:2];  // @"ct-right.png"
	[self loadTexture3:skybox_left intoLocation:3];  // @"ct-left.png"
	[self loadTexture3:skybox_back intoLocation:4];   // @"ct-back.png"
	[self loadTexture3:skybox_top intoLocation:5];  // @"ct-top.png"
	[self loadTexture3:skybox_bottom intoLocation:6];
	
	// TEST ONLY 
	
	brushedcube = [[BlenderObject alloc] init];
	//NSError *error = [brushedcube loadBlenderObject:@"brushedcube"];
	//if (error != nil) {
	//	NSLog(@"Opps: %@", [error localizedDescription]);
	//}
    /*
	female = [[BlenderObject alloc] init];
	error = [female loadBlenderObject:@"female"];
	if (error != nil) {
		NSLog(@"Opps: %@", [error localizedDescription]);
	}
	*/
	 
	//[self loadTexture2:groundTextureName intoLocation:groundTexture]; // ISSUE !!!!
	[self loadTexture3:groundTextureName intoLocation:7];
	//[self loadTexture2:skybox_top intoLocation:textures[5]];
	
	
	//[self loadGroundTexture:groundTextureName ]; // temp
	//[self loadGroundTexture:@"concrete"];
	
	//
	// Load objects from level definition. 
	// 
	// Create NSMutableDictionary for Blender objects as cache...
	//
	
	[self loadStaticObjects];
	
	
	
	NSEnumerator* characterIterator = [characters objectEnumerator];
	ObjectContainer* fromCharacter;
	while((fromCharacter = [characterIterator nextObject]))
	{
		//NSString* fromName = [fromCharacter name];  //[fromObject objectForKey:@"name"];
		NSString* fileName = [fromCharacter file];
		Character* bo = [blenderCharacterCache objectForKey: fileName];
		if(bo == nil){
			bo = [[Character alloc] init];
			[blenderCharacterCache setValue:bo forKey:fileName];
			NSError *error = [bo loadBlenderObject: [fromCharacter file]];
			if (error != nil) {
				NSLog(@"Opps: %@", [error localizedDescription]);
			}
			//NSLog(@"    Loading Object Name: %@  file: %@ ", fromName, fileName);
		} else {
			//NSLog(@"    Cached  Object Name: %@  file: %@ ", fromName, fileName);
		}
		[fromCharacter blenderObject: bo];
	}
	
	
	[self loadEnemyObjects];
	[self loadCollectibleObjects];
	[self loadHealthObjects];
	
	
    
    // 
    // Set player inital location
    //
    NSLog(@" move avatar to init location %f %f %f ", [initalLocationX floatValue], 
                                                        [initalLocationY floatValue], 
                                                        [initalLocationZ floatValue] );
    resetPlayerLocation = [[ObjectContainer alloc] init];
    [resetPlayerLocation setLocX: [initalLocationX floatValue]];
    [resetPlayerLocation setLocY: [initalLocationY floatValue]];
    [resetPlayerLocation setLocZ: [initalLocationZ floatValue]];
    [resetPlayerLocation setRotY: [initalAngle floatValue]];
    
	loading = 0;
	
    if(callback != nil){
        [callback updateHeightOnTerrain]; // avatar
        [callback setLighting];
        setPlayerHeight = 1;
    }
    
    
    // debug
    float ph = [self getTerrainHeightX:avatarX z:avatarZ];
    NSLog(@"player height: %f ", ph);
    
    // set level completion
    float completionHeight = [self getTerrainHeightX:[completeLocationY  floatValue ] z:[completeLocationY floatValue]] + 0.4;
    completeLocationY = [[NSNumber alloc] initWithLong:completionHeight];
    
    
    
    
	//NSLog(@" LevelEditor init ");
	//[super init];
    
    // sound
    [sound levelLoaded: levelName];
}


/**
 * reloadLevel
 *
 * Update from network. DEPricate
 *
 */
- (void)reloadLevel:(NSData*)xmlData {
	//NSLog(@" Reload level: %@ ", levelName);
	
	if(true){
		//return;
	}
	
	//[objectsOld removeAllObjects];
	//[objectsOld addObjectsFromArray: objects];
	[self clearStaticObjects];
	//NSLog(@" a %d ", [objects count]);
	
	//
	// Release Ground Tiles
	//
	NSEnumerator* groundTileIterator = [groundTiles objectEnumerator];
	ObjectContainer* groundTileObject;
	while((groundTileObject = [groundTileIterator nextObject]))
	{
		[groundTileObject release];
	}
	[groundTiles removeAllObjects];
	
	//
	// Clear enemies
	//
	//if([enemies count] == 0){
		NSEnumerator* clearEnemyIterator = [enemies objectEnumerator];
		ObjectContainer* enemyObject;
		while((enemyObject = [clearEnemyIterator nextObject]))
		{
			[enemyObject release];
		}
		[enemies removeAllObjects];
	//}
	
	//
	// Clear collectibles
	//
	NSEnumerator* clearCollectibleIterator = [collectibles objectEnumerator];
	ObjectContainer* collectibleObject;
	while((collectibleObject = [clearCollectibleIterator nextObject]))
	{
		[collectibleObject release];
	}
	[collectibles removeAllObjects];
   
    
    [health removeAllObjects];
    
	
	//
	// Clear dialogs
	//
	NSEnumerator* clearDialogIterator = [dialogs objectEnumerator];
	ObjectContainer* dialogObject;
	while((dialogObject = [clearDialogIterator nextObject]))
	{
		[dialogObject release];
	}
	[dialogs removeAllObjects];
	
	
	// parse XML data
	NSXMLParser *xmlParser = [[NSXMLParser alloc]  initWithData:xmlData ];
	[xmlParser setDelegate:self];
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];
	[xmlParser parse];
	[xmlParser release];
    
    //[f_collectibles createList:collectibles]; // Create fast list from NSMutableArray
	
	// Load new objects
	[self loadStaticObjects];
	
	// load new enemies
	[self loadEnemyObjects];
	[self loadCollectibleObjects];
	[self loadHealthObjects];	
	
	
	//NSLog(@" a %d ", [objects count]);
}

//
// Clear objects
//
- (void)clearStaticObjects {
	NSEnumerator* clearObjectIterator = [objects objectEnumerator];
	ObjectContainer* worldObject;
	while((worldObject = [clearObjectIterator nextObject]))
	{
		[worldObject release];
	}
	[objects removeAllObjects];
}

-(void) loadStaticObjects {
	NSEnumerator* objectIterator = [objects objectEnumerator];
	ObjectContainer* fromObject;
	while((fromObject = [objectIterator nextObject]))
	{
		NSString* fileName = [fromObject name];  //[fromObject objectForKey:@"name"];
		//NSString* fileName = [fromObject file];
		
		//
		// Blender Object File
		//
		if(fileName != nil && [fileName rangeOfString:@".obj"].location == NSNotFound ){
			BlenderObject* bo = [blenderObjectCache objectForKey: fileName];
			if(bo == nil){
				bo = [[BlenderObject alloc] init];
				[blenderObjectCache setValue:bo forKey:fileName];
				NSError *error = [bo loadBlenderObject: [fromObject file]];
				if (error != nil) {
					NSLog(@"Opps: %@", [error localizedDescription]);
				}
				//NSLog(@"    Loading Object Name: %@  file: %@ ", fromName, fileName);
			} else {
				//NSLog(@"    Cached  Object Name: %@  file: %@ ", fromName, fileName);
			}
			[fromObject blenderObject: bo];
		}
		
		//
		// Wavefront Object File
		//
		//NSString* wavefrontFileName = [fromObject wavefrontFile];
		if(fileName != nil && [fileName rangeOfString:@".obj"].location != NSNotFound){
			//NSLog(@"      Wavefront Object file: %@ ", fileName);
			OpenGLWaveFrontObject* wo = [wavefrontCharacterCache objectForKey: fileName];
			if(wo == nil){
				
				int endPos = [fileName rangeOfString:@".obj"].location;
				NSString *fileShort = [fileName substringToIndex:endPos];
				//NSLog(@" Wavefront file: %@ ", fileShort);
				
				NSString *path = [[NSBundle mainBundle] pathForResource:fileShort ofType:@"obj"];
				
				//NSLog(@" objpath string: %@ ", path);
				if(path == nil){
					path = fileName; 
				}
				
				
				OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
				Vertex3D position = Vertex3DMake(0.0, 3.0, -8.0);
				theObject.currentPosition = position;
				wo = theObject;
				//[theObject release];
				[wavefrontCharacterCache setValue:wo forKey:fileName];
				
				//NSLog(@"    Loading Object Name: %@  ", fileName);
			}
			[fromObject wavefrontObject: wo];
		}
	}
}

/**
 * loadDamageObject
 *
 * Description: Load 3d object data for displaying damage to player.
 */
-(OpenGLWaveFrontObject*) loadDamageObject {
    OpenGLWaveFrontObject * obj;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"damage" ofType:@"obj"];
    if(path != nil){
        obj = [[OpenGLWaveFrontObject alloc] initWithPath:path];
        
        Vertex3D position = Vertex3DMake(0.0, 3.0, -8.0);
        obj.currentPosition = position;
    }
    return obj;
}


-(OpenGLWaveFrontObject*) loadDownArrowObject {
    OpenGLWaveFrontObject * obj;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"down_arrow" ofType:@"obj"];
    if(path != nil){
        obj = [[OpenGLWaveFrontObject alloc] initWithPath:path];
        
        Vertex3D position = Vertex3DMake(0.0, 3.0, -8.0);
        obj.currentPosition = position;
    }
    return obj;
}



/**
 * loadEnemyObjects
 *
 * Description: 
 */
-(void) loadEnemyObjects {
	NSEnumerator* enemyIterator = [enemies objectEnumerator];
	ObjectContainer* enemyCharacter;
	while((enemyCharacter = [enemyIterator nextObject]))
	{
		NSString* fileName = [enemyCharacter name];  
		//NSString* fileName = [enemyCharacter file];
		//NSLog(@"      enimy file name: %@ ", fileName);
        
        //
		// Blender Object File
		//
        if(fileName != nil && [fileName rangeOfString:@".obj"].location == NSNotFound ){
            Character* bo = [blenderCharacterCache objectForKey: fileName];
            if(bo == nil){
                bo = [[Character alloc] init];
                [blenderCharacterCache setValue:bo forKey:fileName];
                NSError *error = [bo loadBlenderObject: [enemyCharacter file]];
                if (error != nil) {
                    NSLog(@"Opps: %@", [error localizedDescription]);
                }
                //NSLog(@"    Loading Object Name: %@  file: %@ ", fromName, fileName);
            } else {
                //NSLog(@"    Cached  Object Name: %@  file: %@ ", fromName, fileName);
            }
            [enemyCharacter blenderObject: bo];
        }
        
        //
		// Wavefront Object File
		//
		//NSString* wavefrontFileName = [fromObject wavefrontFile];
		if(fileName != nil && [fileName rangeOfString:@".obj"].location != NSNotFound){
			//NSLog(@"      Wavefront Object file: %@ ", fileName);
			OpenGLWaveFrontObject* wo = [wavefrontCharacterCache objectForKey: fileName];
			if(wo == nil){
				int endPos = [fileName rangeOfString:@".obj"].location;
				NSString *fileShort = [fileName substringToIndex:endPos];
				//NSLog(@" Wavefront file: %@ ", fileShort);
				NSString *path = [[NSBundle mainBundle] pathForResource:fileShort ofType:@"obj"];
				//NSLog(@" objpath string: %@ ", path);
				if(path == nil){
					path = fileName; 
				}
				OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
				Vertex3D position = Vertex3DMake(0.0, 3.0, -8.0);
				theObject.currentPosition = position;
				wo = theObject;
				//[theObject release];
				[wavefrontCharacterCache setValue:wo forKey:fileName];
				
				//NSLog(@"    Loading Object Name: %@  file: %@ ", fromName, fileName);
			}
			[enemyCharacter wavefrontObject: wo];
		}
	}
}

/**
 * loadDeadEnemyObjects
 *
 * Description: Load a dead version of a model
 */
-(void) loadDeadEnemyObjects:(ObjectContainer*)o
{
    //NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    
    NSEnumerator* enemyIterator = [enemies objectEnumerator];
    ObjectContainer* enemyCharacter;
    while((enemyCharacter = [enemyIterator nextObject]))
    {
        NSString* fileName = [enemyCharacter name];  
        //NSString* fileName = [enemyCharacter file];
        //if([fileName isEqualToString: [o name]]){
        if(enemyCharacter == o){    
            //
            // Wavefront Object File
            //
            //NSString* wavefrontFileName = [fromObject wavefrontFile];
            if(fileName != nil && [fileName rangeOfString:@".obj"].location != NSNotFound){
                int endPos = [fileName rangeOfString:@".obj"].location;
                NSString *fileShort = [fileName substringToIndex:endPos];
                fileShort = [NSString stringWithFormat: @"%@%@", fileShort, @"_dead"];
                //NSLog(@"      Wavefront Object file: %@ ", fileName);
                //OpenGLWaveFrontObject* wo = nil; //[wavefrontCharacterCache objectForKey: fileName];
                OpenGLWaveFrontObject* wo = [wavefrontCharacterCache objectForKey: fileShort];
                if(wo == nil){
                    NSString *path = [[NSBundle mainBundle] pathForResource:fileShort ofType:@"obj"];
                    if(path == nil){
                        path = fileName; 
                    }
                    OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
                    Vertex3D position = Vertex3DMake(0.0, 3.0, -8.0);
                    theObject.currentPosition = position;
                    wo = theObject;
                    //[theObject release];
                    [wavefrontCharacterCache setValue:wo forKey:fileShort];
                }
                [enemyCharacter wavefrontObject: wo];
            }
        }
    }
    
    
    //NSTimeInterval finish = [NSDate timeIntervalSinceReferenceDate];
    //NSLog(@"loadDeadEnemyObjects time: %f  ", (finish - start) );
}


- (void) loadCollectibleObjects {
	NSEnumerator* collectibleIterator = [collectibles objectEnumerator];
	ObjectContainer* collectibleObject;
	while((collectibleObject = [collectibleIterator nextObject]))
	{
		NSString* fileName = [collectibleObject name];  
		//NSString* fileName = [collectibleObject file];
		
		//
		// Blender Object File
		//
		if(fileName != nil && [fileName rangeOfString:@".obj"].location == NSNotFound ){
			Character* bo = [blenderCharacterCache objectForKey: fileName];
			if(bo == nil){
				bo = [[Character alloc] init];
				[blenderCharacterCache setValue:bo forKey:fileName];
				NSError *error = [bo loadBlenderObject: [collectibleObject file]];
				if (error != nil) {
					NSLog(@"Opps: %@", [error localizedDescription]);
				}
				//NSLog(@"    Loading Object Name: %@  file: %@ ", fromName, fileName);
			} else {
				//NSLog(@"    Cached  Object Name: %@  file: %@ ", fromName, fileName);
			}
			[collectibleObject blenderObject: bo];
		}
		
		
		//
		// Wavefront Object File
		//
		//NSString* wavefrontFileName = [fromObject wavefrontFile];
		if(fileName != nil && [fileName rangeOfString:@".obj"].location != NSNotFound){
			//NSLog(@"      Wavefront Object file: %@ ", fileName);
			OpenGLWaveFrontObject* wo = [wavefrontCharacterCache objectForKey: fileName];
			if(wo == nil){
				int endPos = [fileName rangeOfString:@".obj"].location;
				NSString *fileShort = [fileName substringToIndex:endPos];
				//NSLog(@" Wavefront file: %@ ", fileShort);
				NSString *path = [[NSBundle mainBundle] pathForResource:fileShort ofType:@"obj"];
				//NSLog(@" objpath string: %@ ", path);
				if(path == nil){
					path = fileName; 
				}
				OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
				Vertex3D position = Vertex3DMake(0.0, 3.0, -8.0);
				theObject.currentPosition = position;
				wo = theObject;
				//[theObject release];
				[wavefrontCharacterCache setValue:wo forKey:fileName];
				
				//NSLog(@"    Loading Object Name: %@  file: %@ ", fromName, fileName);
			}
			[collectibleObject wavefrontObject: wo];
		}
	}
}



- (void) loadHealthObjects {
	NSEnumerator* healthIterator = [health objectEnumerator];
	ObjectContainer* healthObject;
	while((healthObject = [healthIterator nextObject]))
	{
		NSString* fileName = [healthObject name];  
		//NSString* fileName = [collectibleObject file];
		
		//
		// Blender Object File
		//
		if(fileName != nil && [fileName rangeOfString:@".obj"].location == NSNotFound ){
			Character* bo = [blenderCharacterCache objectForKey: fileName];
			if(bo == nil){
				bo = [[Character alloc] init];
				[blenderCharacterCache setValue:bo forKey:fileName];
				NSError *error = [bo loadBlenderObject: [healthObject file]];
				if (error != nil) {
					NSLog(@"Opps: %@", [error localizedDescription]);
				}
				//NSLog(@"    Loading Object Name: %@  file: %@ ", fromName, fileName);
			} else {
				//NSLog(@"    Cached  Object Name: %@  file: %@ ", fromName, fileName);
			}
			[healthObject blenderObject: bo];
		}
		
		
		//
		// Wavefront Object File
		//
		//NSString* wavefrontFileName = [fromObject wavefrontFile];
		if(fileName != nil && [fileName rangeOfString:@".obj"].location != NSNotFound){
			//NSLog(@"      Wavefront Object file: %@ ", fileName);
			OpenGLWaveFrontObject* wo = [wavefrontCharacterCache objectForKey: fileName];
			if(wo == nil){
				int endPos = [fileName rangeOfString:@".obj"].location;
				NSString *fileShort = [fileName substringToIndex:endPos];
				//NSLog(@" Wavefront file: %@ ", fileShort);
				NSString *path = [[NSBundle mainBundle] pathForResource:fileShort ofType:@"obj"];
				//NSLog(@" objpath string: %@ ", path);
				if(path == nil){
					path = fileName; 
				}
				OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
				Vertex3D position = Vertex3DMake(0.0, 3.0, -8.0);
				theObject.currentPosition = position;
				wo = theObject;
				//[theObject release];
				[wavefrontCharacterCache setValue:wo forKey:fileName];
				
				//NSLog(@"    Loading Object Name: %@  file: %@ ", fromName, fileName);
			}
			[healthObject wavefrontObject: wo];
		}
	}
}



/**
 * objectTouched
 *
 * Description: Touch handler notification of object touch 
 */
- (void) objectTouched:(ObjectContainer*)o 
{
    //NSLog(@" object touched: %@    %@ ", [o name], [o type] );
    
    // If enimy touched, replace with crush
    //if([[o type] isEqualToString:@"Enemy"]){
    
        if(![o touched]){
            [o setTouched:TRUE];
            [self loadDeadEnemyObjects:o];
            NSLog(@" LOAD DEAD MODEL");
        }
    //}
}




/**
 * draw objects loaded
 *
 */
- (void)drawWorldObjects:(GLView*)view; 
{
    // Update Save Game
    if([saveGame isTimeToGetUpdate]){
        //NSLog(@" Update save Game... ");
        
        // set avatar location
        // playerX
        [saveGame setAvatarLocation:playerX y:playerY z:playerZ];
        [saveGame setHealth:(int)healthPoints];
        [saveGame setCoins:(int)collectedItems];
        [saveGame setLevel:levelName];
        
        // set 
        //[levelLoader update];
    }
    
    
    double distanceDraw = 48;  // Distance from player to render world objects (28)
    
    double sceneX = inFrontX;
    double sceneZ = inFrontZ;
    
    
    // hack - set player on ground 
    if(setPlayerHeight > 0){
        if(callback != nil){
            [callback updateHeightOnTerrain]; // avatar
        }
        setPlayerHeight--;
    }
    
    
	//[saveGame saveGame];
	//NSLog(@"drawBlenderObject %d  ", loading);
    
    
    // TEMP ISSUE WITH Blender objects and lighting
    
    glPushMatrix();	// preserve state of matrix
    glTranslatef( avatarX, avatarY - 0, avatarZ); // up high
    [brushedcube draw];
    glPopMatrix();	// Return matrix to origional state
    
    
    bool collide = false;
    float collideAngle = 0;
    
    
	// Draw level objects
    //glEnable(GL_LIGHTING);
	//NSLog(@" objects: %d", [objects count] );
    //NSLog(@"objects");
    NSMutableArray * proximityObjects = [self objectsInProximity:objects x: sceneX z: sceneZ d:distanceDraw];
	NSEnumerator* objectIterator = [proximityObjects objectEnumerator];
	ObjectContainer* fromObject;
	while((fromObject = [objectIterator nextObject]))
	{
		glPushMatrix();	// preserve state of matrix
		if( fromObject != nil ){
			 
			// Filter by distance for performance
			float tX = [fromObject locX];
			float tZ = [fromObject locZ];
			double dx = tX-sceneX;
			double dz = tZ-sceneZ;
			double distance = sqrt(dx*dx + dz*dz); 
			
			if(distance < distanceDraw){
				
                // Collision detection.
                float objSize = [fromObject size];
                if(objSize > 0){
                    if( [fromObject locX] > avatarX - objSize && [fromObject locX] < avatarX + objSize &&
                       [fromObject locZ] > avatarZ - objSize && [fromObject locZ] < avatarZ + objSize){
                        collide = true;
                        collideAngle = atan2([fromObject locZ] - avatarZ, [fromObject locX] - avatarX) * 180 / 3.14159;    
                    }
                }
                
                //doubleValue 
				//glTranslatef(  [[fromObject getX] floatValue] , [[fromObject getY] floatValue], [[fromObject getZ] floatValue]);
				
				//glRotatef([[fromObject getRotX] floatValue], 1.0, 0.0, 0.0);
				//glRotatef([[fromObject getRotY] floatValue], 0.0, 1.0, 0.0);
				//glRotatef([[fromObject getRotZ] floatValue], 0.0, 0.0, 1.0);
				
				// Matrix Multiplication - translate rotate and scale
				GLfloat pointMatrix[16] = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
				//glGetFloatv(GL_MODELVIEW, pointMatrix);
				pointMatrix[12] = [fromObject locX];
				pointMatrix[13] = [fromObject locY];
				pointMatrix[14] = [fromObject locZ];
				
				//pointMatrix[0] = [fromObject rotX];
				//pointMatrix[1] = [fromObject rotY];
				//pointMatrix[2] = [fromObject rotZ];
                
                //if([fromObject rotX] > 0 || [fromObject rotY] > 0 || [fromObject rotZ] > 0){
                //    NSLog(@"rot %f %f", [fromObject rotX ], [fromObject rotY ]);
                //}
				
				glMultMatrixf(&pointMatrix[0]);
			
                
                glRotatef([fromObject rotY], 0.0, 1.0, 0.0);
                
				if([fromObject scaleX] != 0){
					glScalef([fromObject scaleX], [fromObject scaleY], [fromObject scaleZ]);
				}
                
                //GLfloat ambientAndDiffuse[] = {0.0, 0.1, 0.9, 1.0};
                //glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, ambientAndDiffuse);
                glEnable ( GL_COLOR_MATERIAL );
				glEnable(GL_LIGHTING);
                
                //glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 25.0);
                
				glColor4f(1.0f,1.0f,1.0f,1.0f);	 // Set color 
				
                BlenderObject* bo =  [fromObject blenderObject];
				if(bo != nil){
					[bo draw];
				}
				
				OpenGLWaveFrontObject* wo = [fromObject wavefrontObject];
				if(wo != nil){
					[wo drawSelf];
				}
                
                //glDisable(GL_LIGHTING);
			}
		}
		glPopMatrix();	// Return matrix to origional state
	}
    [proximityObjects release];
    //glDisable(GL_LIGHTING);
    avatarCollision = collide; // Set 
    avatarCollisionAngle = collideAngle;
	
    
    
	// Draw collectiblae 
	//NSLog(@" collectibles: %d", [collectibles count] );
    //NSLog(@"collectibles");
    NSMutableArray * proximityCollectibles = [self objectsInProximity:collectibles x: sceneX z: sceneZ d:distanceDraw];
	NSEnumerator* collectibleIterator = [proximityCollectibles objectEnumerator];
	ObjectContainer* collectibleObject;
	while((collectibleObject = [collectibleIterator nextObject]))
	{
		glPushMatrix();	// preserve state of matrix
		if( collectibleObject != nil ){
			// Filter by distance for performance
			float tX = [collectibleObject locX];
			float tZ = [collectibleObject locZ];
            
			double dx = tX-sceneX;
			double dz = tZ-sceneZ;
			double distance = sqrt(dx*dx + dz*dz); 
	
			if(distance < distanceDraw){
				//NSLog(@"  %f --", [[collectibleObject getX] floatValue]);
				glTranslatef([collectibleObject locX], 
							 [collectibleObject locY], 
							 [collectibleObject locZ]);
				
				float rotatedAngle = [collectibleObject rotY];
				rotatedAngle += 5 * frs;
				if(rotatedAngle > 360){
					rotatedAngle = 0;
				}
				//NSLog(@" a %f ", rotatedAngle);
				if(!paused){
					[collectibleObject setRotY:rotatedAngle]; 
				}
                
                // Collision detection.
                float collectionDistance = 1.5;
                if([collectibleObject locX] > avatarX - collectionDistance && 
                   [collectibleObject locX] < avatarX + collectionDistance &&
                   [collectibleObject locZ] > avatarZ - collectionDistance && 
                   [collectibleObject locZ] < avatarZ + collectionDistance){
                    //NSLog(@" coll  obj %f  %f   avatar: %f  %f ", [collectibleObject locX], [collectibleObject locZ], avatarX, avatarZ );
                    
                    // count collected items
                    if([collectibleObject collision] == FALSE){
                        collectedItems++;
                        
                        // sound
                        [sound playCollect];
                    }
                    
                    // collected
                    [collectibleObject setCollision:TRUE];
                }
                if([collectibleObject collision]){
                    [collectibleObject setLocY: [collectibleObject locY] + 0.6]; // rise
                    // TODO make inactive
                }
                    
				
				//glRotatef([[fromObject getRotX] floatValue], 1.0, 0.0, 0.0);
                glRotatef([collectibleObject rotY], 0.0, 1.0, 0.0);
				//glRotatef([[fromObject getRotZ] floatValue], 0.0, 0.0, 1.0);
				
				if([collectibleObject scaleX] != 0){
					//	glScalef([fromObject scaleX], [fromObject scaleY], [fromObject scaleZ]);
				}
				
				BlenderObject* bo = [collectibleObject blenderObject];
				if(bo != nil){
					glColor4f(1.0f,1.0f,1.0f,1.0f);	 // Set color 
					[bo draw];
				}
				
				OpenGLWaveFrontObject* wo = [collectibleObject wavefrontObject];
				if(wo != nil){
					[wo drawSelf];
				}
			}
		}
		glPopMatrix();	// Return matrix to origional state
	}
    [proximityCollectibles release];
	
    
    
    
    
    // Draw health 
    NSMutableArray * proximityHealth = [self objectsInProximity:health x: sceneX z: sceneZ d:distanceDraw];
	NSEnumerator* healthIterator = [proximityHealth objectEnumerator];
	ObjectContainer* healthObject;
	while((healthObject = [healthIterator nextObject]))
	{
		glPushMatrix();	// preserve state of matrix
		if( healthObject != nil ){
			// Filter by distance for performance
			float tX = [healthObject locX];
			float tZ = [healthObject locZ];
			double dx = tX-sceneX;
			double dz = tZ-sceneZ;
			double distance = sqrt(dx*dx + dz*dz); 
            
			if(distance < distanceDraw){
				//NSLog(@"  %f --", [[collectibleObject getX] floatValue]);
				glTranslatef([healthObject locX], 
							 [healthObject locY], 
							 [healthObject locZ]);
				
				float rotatedAngle = [healthObject rotY];
				rotatedAngle += 5 * frs;
				if(rotatedAngle > 360){
					rotatedAngle = 0;
				}
				//NSLog(@" a %f ", rotatedAngle);
				if(!paused){
					[healthObject setRotY:rotatedAngle]; 
				}
                
                // Collision detection.
                if( [healthObject locX] > avatarX - 1 && [healthObject locX] < avatarX + 1 &&
                   [healthObject locZ] > avatarZ - 1 && [healthObject locZ] < avatarZ + 1){
                    //NSLog(@" coll  obj %f  %f   avatar: %f  %f ", [collectibleObject locX], [collectibleObject locZ], avatarX, avatarZ );
                    
                    // count collected items
                    if([healthObject collision] == FALSE){
                        //if(collectedItems > 0){
                        //collectedItems--;
                        healthPoints += [healthObject health]; // 5
                        if(healthPoints > 100){
                            healthPoints = 100;
                        }
                        
                        collectedItems -= [healthObject cost];
                        if(collectedItems < 0){
                            collectedItems = 0;
                        }
                        //}
                        
                        // sound
                        [sound playCollect];
                    }
                    
                    // collected
                    [healthObject setCollision:TRUE];
                }
                if([healthObject collision]){
                    [healthObject setLocY: [healthObject locY] + 0.6]; // rise
                    // TODO make inactive
                }
                
				
				//glRotatef([[fromObject getRotX] floatValue], 1.0, 0.0, 0.0);
                glRotatef([healthObject rotY], 0.0, 1.0, 0.0);
				//glRotatef([[fromObject getRotZ] floatValue], 0.0, 0.0, 1.0);
				
				if([healthObject scaleX] != 0){
					//	glScalef([fromObject scaleX], [fromObject scaleY], [fromObject scaleZ]);
				}
				
				BlenderObject* bo = [healthObject blenderObject];
				if(bo != nil){
					glColor4f(1.0f,1.0f,1.0f,1.0f);	 // Set color 
					[bo draw];
				}
				
				OpenGLWaveFrontObject* wo = [healthObject wavefrontObject];
				if(wo != nil){
					[wo drawSelf];
				}
			}
		}
		glPopMatrix();	// Return matrix to origional state
	}
    [proximityHealth release];
    
    
    
	
	//
	// Draw level characters
	//
    //NSLog(@" characters ");
    NSMutableArray * proximityCharacters = [self objectsInProximity:characters x: playerX z: playerZ d:distanceDraw];
	NSEnumerator* characterIterator = [proximityCharacters objectEnumerator];
	ObjectContainer* fromCharacter;
	while((fromCharacter = [characterIterator nextObject]))
	{
		//glLoadIdentity();
		glPushMatrix();	// preserve state of matrix
		//glScalef(2.0, 2.0, 2.0);
		if( fromCharacter != nil ){
			BlenderObject* bo =  [fromCharacter blenderObject];
			//NSNumber * angleToPlayer = [fromCharacter angleToPoint: playerX y: playerZ ];
			
			double angleP = [fromCharacter angleToPoint:playerX y:playerZ ];
			//NSLog(@" angle  : %f  " ,angleP);
			
			
			if(angleP > 180){
				[fromCharacter turn: 0.3f ];
			} else {
				[fromCharacter turn: -0.3f ];
			}
			
			[fromCharacter forward: 0.02f ];
			
			//doubleValue 
			glTranslatef([fromCharacter locX], [fromCharacter locY], [fromCharacter locZ]);
			
			//[bo update];
			//NSNumber* n = [NSNumber numberWithFloat:( [[fromCharacter getX ]floatValue] + 0.0f)];
			//NSLog(@"  y %f" , [[fromObject getRotY] floatValue]);
			glRotatef([fromCharacter rotY], 0.0, 1.0, 0.0);
			glRotatef([fromCharacter rotX], 1.0, 0.0, 0.0);
			//glRotatef([[fromCharacter getRotZ] floatValue], 0.0, 0.0, 1.0);
			if([fromCharacter scaleX] != 0){
				glScalef([fromCharacter scaleX], [fromCharacter scaleY], [fromCharacter scaleZ]);
			}
			glColor4f(1.0f,1.0f,1.0f,1.0f);	 // Set color 
			if(bo != nil){
                [bo draw];
            }
		}
		glPopMatrix();	// Return matrix to origional state
	}
    [proximityCharacters release];
	
	
	//
	// draw enemies
	//
    //NSLog(@" enemies ");
    //NSMutableArray * proximityEnemies = [self objectsInProximity:enemies x: playerX z: playerZ d:40];
    //NSLog(@" enemies %d  %d ", [enemies count], [proximityEnemies count]);
    bool attacked = false;
    float enemyRadius = 40;
	NSEnumerator* enemyIterator = [enemies objectEnumerator];
	ObjectContainer* enimyObject;
    Enemy * enemy = [[Enemy alloc] init];
    bool enemiesNearby = false;
	while((enimyObject = [enemyIterator nextObject]))
	{
        float tX = [enimyObject locX];
        float tZ = [enimyObject locZ];
        if(tX < playerX + enemyRadius && tX > playerX - enemyRadius && tZ < playerZ + enemyRadius && tZ > playerZ - enemyRadius){
            double dx = tX-playerX;
            double dz = tZ-playerZ;
            double distance = sqrt(dx*dx + dz*dz);
            if(distance < enemyRadius){
            
                glPushMatrix();	// preserve state of matrix
                if( enimyObject != nil ){
                    
                    //NSNumber * angleToPlayer = [enimyObject angleToPoint: playerX y: playerZ ];
                    double angleP = [enimyObject angleToPoint: playerX y: playerZ ];
                    double angleCollide = 0;
                    
                    // if dead enemies walk away
                    if(dead){
                        angleP += 180;
                        if(angleP > 360){
                            angleP = angleP - 360;
                        }
                    }
                    //NSLog(@" angle  : %f  " ,angleP);
                    
                    if(!paused && ![enimyObject touched]){  // Not paused and not DEAD
                        bool collide = false;
                        //if(distance < 40){
                            
                            // collision detection...
                            NSEnumerator* objectIterator = [objects objectEnumerator];
                            ObjectContainer* fromObject;
                            while((fromObject = [objectIterator nextObject]))
                            {
                                if( fromObject != nil ){
                                    if( [fromObject locX] > [enimyObject locX] - 1.8 && 
                                       [fromObject locX] < [enimyObject locX] + 1.8 &&
                                       [fromObject locZ] > [enimyObject locZ] - 1.8 && 
                                       [fromObject locZ] < [enimyObject locZ] + 1.8){
                                        collide = true;
                                        angleCollide = [enimyObject 
                                                        angleToPoint: [fromObject locX] y: [fromObject locZ]];
                                    }
                                }
                            }
                        
                            // collide with enemy 
                            NSEnumerator* enemyColideIterator = [enemies objectEnumerator];
                            ObjectContainer* enimyColideObject;
                            while((enimyColideObject = [enemyColideIterator nextObject]))
                            {
                                if(enimyColideObject != enimyObject){
                                    if( enimyColideObject != nil ){
                                        if( [enimyColideObject locX] > [enimyObject locX] - 1.0 && 
                                           [enimyColideObject locX] < [enimyObject locX] + 1.0 &&
                                           [enimyColideObject locZ] > [enimyObject locZ] - 1.0 && 
                                           [enimyColideObject locZ] < [enimyObject locZ] + 1.0){
                                            
                                            // if distance to player is > 2 (allow closer contect with player)
                                            // quicker death as enemies don't get pushed out by others.
                                            if(distance > 2){
                                                collide = true;
                                                angleCollide = [enimyObject 
                                                                angleToPoint: [enimyColideObject locX] 
                                                                y: [enimyColideObject locZ]];
                                            }
                                        }
                                    }
                                }
                            }
                        
                            if(angleP > 180){ // point enemy at player
                                [enimyObject turn: (0.8f * frs) ];
                            } else {
                                [enimyObject turn: (-0.8f * frs) ];
                            }
                        //}
                        
                        if((distance > 1 && distance < 40 && !collide) || dead){ // enemy walk 
                            
                            double d = (0.12f * frs);   
                            
                            if(enimyObject.stunDistance > 0){ // Stall enemy movement temporarily
                                d -= enimyObject.stunDistance; 
                                if(d < 0){
                                    enimyObject.stunDistance = -d; d = 0;
                                } else {
                                    enimyObject.stunDistance -= d;
                                }
                            }
                            //if([enimyObject health] < 100){d = d * 0.7;} // perminantly slow damaged enemy
                            //if([enimyObject health] < 50){d = d * 0.7;}
                            
                            [enimyObject forward: d ]; 
                        } else if(distance < 40 && collide){ // enemy collsison - move to side 
                            
                            if(angleCollide > 180){
                                [enimyObject moveToSide: (0.10f * frs) ];
                            } else {
                                [enimyObject moveToSide: -(0.10f * frs) ];
                            }
                        }
                    }
                    
                    // set height on terrain 
                    float enimyHeight = [self getTerrainHeightX:[enimyObject locX] z:[enimyObject locZ]] + 0.4; // + [enimyObject locY];
                    // bug 
                    //NSLog(@" enimyHeight: %f   at  x: %f y: %f ", enimyHeight, [enimyObject locX], [enimyObject locY]);
                    [enimyObject setLocY:enimyHeight];
                    
                    // Collision detection.
                    if( [enimyObject locX] > avatarX - 1 && [enimyObject locX] < avatarX + 1 &&
                       [enimyObject locZ] > avatarZ - 1 && [enimyObject locZ] < avatarZ + 1 &&
                       ![enimyObject touched]){
                    
                        // update player health
                        healthPoints -= ((float)[enimyObject damage] / (float)50) * frs; // 0.1
                        if(healthPoints < 0){
                            healthPoints = 0;
                            dead = true;
                            
                            [sound playerDied];
                        }
                        attacked = true;
                        
                        // collected
                        [enimyObject setCollision:TRUE];
                    }
                    if([enimyObject collision]){
                        //[collectibleObject setLocY: [collectibleObject locY] + 0.6]; // rise
                        // TODO harm like animation
                    }
                    
                    // bullet enemy collision
                    if(![enimyObject touched]){ // not dead
                        NSEnumerator* bulletIterator = [bullets objectEnumerator];
                        Bullet* bullet;
                        while((bullet = [bulletIterator nextObject]))
                        {
                            if( [enimyObject locX] > [bullet locX] - 1.4 && [enimyObject locX] < [bullet locX] + 1.4 &&
                               [enimyObject locZ] > [bullet locZ] - 1.4 && [enimyObject locZ] < [bullet locZ] + 1.4 
                               && ![enimyObject touched]
                               ){
                                
                                int damage = (int)(100 / [enimyObject hits]);
                                [enimyObject setHealth: [enimyObject health] - damage ];
                                if([enimyObject health] <= 0){ // is dead
                                    [self objectTouched:enimyObject];
                                }
                                [enimyObject setCollision:TRUE];
                                
                                // stunEnemy
                                enimyObject.stunDistance += 2.5 * frs;
                                
                                [bullet setActive:FALSE];
                                
                                [sound playHurt];
                            }
                        }
                    }
                    //NSLog(@" Enemy %f  %f  %f ", [enimyObject locX], [enimyObject locY], [enimyObject locZ] );
                    
                    //doubleValue 
                    glTranslatef([enimyObject locX], [enimyObject locY], [enimyObject locZ]);
                    
                    //NSLog(@" height %f ", [enimyObject locY]);
                    
                    //[bo update];
                    //NSNumber* n = [NSNumber numberWithFloat:( [[fromCharacter getX ]floatValue] + 0.0f)];
                    //NSLog(@"  y %f" , [[fromObject getRotY] floatValue]);
                    
                    glRotatef([enimyObject rotY], 0.0, 1.0, 0.0);
                    glRotatef([enimyObject rotX], 1.0, 0.0, 0.0);
                    
                    //NSLog(@" enemy rot x %f  y %f  ", [enimyObject rotX], [enimyObject rotY]);
                    
                    //glRotatef([[fromCharacter getRotZ] floatValue], 0.0, 0.0, 1.0);
                    
                    if([enimyObject scaleX] != 0){
                        glScalef([enimyObject scaleX], [enimyObject scaleY], [enimyObject scaleZ]);
                    }
                    glColor4f(1.0f,1.0f,1.0f,1.0f);	 // Set color
                    
                    BlenderObject* bo = [enimyObject blenderObject];
                    if(bo != nil){
                        [bo draw];
                    }
                        
                    OpenGLWaveFrontObject* wo = [enimyObject wavefrontObject];
                    if(wo != nil){
                        [wo drawSelf];
                    }
                    
                    // in progress - draw health bar
                    if( [enimyObject health] < 100 && ![enimyObject touched] ){ // damaged && not dead
                        double angleC = [enimyObject angleToPoint: cameraX y: cameraZ ];
                        glRotatef(-angleC, 0.0, 1.0, 0.0); 
                        [enemy drawHealth: [enimyObject health] ];
                    }
                    
                    
                    // Enemies near
                    if([enimyObject health] > 0 && [enimyObject touched] == false){
                        enemiesNearby = true;
                    }
                }
                glPopMatrix();	// Return matrix to origional state
            }
        }
	} // end enimes 
	//[proximityEnemies release];
    [enemy release];
    if(sound != nil && [levelName compare:@"Main Menu"] != 0 && loading == 0){ // *****
        if(enemiesNearby){
            [sound setMusicMode:@"danger"];
        } else {
            [sound setMusicMode:@"safe"];
        }
    }
	
	
	// If being attacked draw damage object
    if(attacked){
        if(damageObject != nil && !dead){ //OpenGLWaveFrontObject
            glPushMatrix();	// preserve state of matrix
            glTranslatef(avatarX, avatarY - 13, avatarZ); 
            damageObjectRotate += (1.5f * frs);
            glRotatef( damageObjectRotate , 0.0, 1.0, 0.0);
            glScalef(2, 2, 2);
            [damageObject drawSelf];
            glPopMatrix();	// Return matrix to origional state
            
            [sound playerAttacked];
        }
    }
	
	//NSLog(@" player %f  %f  %f ", avatarX, avatarY, avatarZ );
	
	
	//
	// draw level complete 
	//
    if([levelName compare:@"Main Menu"] != 0 &&
       loading == 0 && // don't display if loading
       [self levelCompletedInRange:avatarX y:avatarY z:avatarZ]){ // don't display on main menu
        
        /*
        glPushMatrix();
        glTranslatef(-10.0, -0.0, 0.0);
        GLfloat vVertices[] = {[completeLocationX floatValue], -2 + [completeLocationY floatValue], [completeLocationZ floatValue], 
            [completeLocationX floatValue], 3 + [completeLocationY floatValue], [completeLocationZ floatValue]}; 
        glColor4f(0.0f,0.0f,1.0f,1.0f);//Change the object color to red
        glLineWidth(3.0f);
        glVertexPointer(3, GL_FLOAT, 0, vVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINES, 0, 2);
        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_VERTEX_ARRAY);
        glLineWidth(2.0f);
        glTranslatef([completeLocationX floatValue] - 10, 0.5, [completeLocationZ floatValue]);
        CGFloat circleSize = 2.0;
        CGPoint location;
        location.x = 10.0;
        location.y = 0.0;
        glColor4f(1.0f,1.0f,0.3f,1.0f);	 // Set color to blue
        glRotatef(-90.0, 1.0, 0.0, 0.0);
        glTranslatef(0.0, 0.0, -1.5);
        GLDrawCircle3 (30, circleSize, location , false);
        glTranslatef(0.0, 0.0, 0.5);
        location.x = 0.0;
        GLDrawCircle3 (30, circleSize, location , false);
        glTranslatef(0.0, 0.0, 0.5);
        GLDrawCircle3 (30, circleSize, location , false);
        glTranslatef(0.0, 0.0, 0.5);
        GLDrawCircle3 (30, circleSize, location , false);
        glTranslatef(0.0, 0.0, 0.5);
        GLDrawCircle3 (30, circleSize, location , false);
        glTranslatef(0.0, 0.0, 0.5);
        GLDrawCircle3 (30, circleSize, location , false);
        glColor4f(1.0f,1.0f,1.0f,1.0f);
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_NORMAL_ARRAY);
        glPopMatrix();	// Return matrix to origional state
        */
        
        // Draw Down Arrow
        glPushMatrix();
        float completeHeight = [self getTerrainHeightX:[completeLocationX floatValue] z:[completeLocationZ floatValue]];
        glTranslatef([completeLocationX floatValue], completeHeight + 1, [completeLocationZ floatValue]); 
        downArrowObjectRotate += (1.5f * frs);
        glRotatef( downArrowObjectRotate , 0.0, 1.0, 0.0);
        glScalef(2, 2, 2);
        [downArrowObject drawSelf];
        glPopMatrix();	// Return matrix to origional state
	}
	
	
	//
	// Display Terrain 
	//
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);	 // Set color to blue
	//glVertexPointer(3, GL_FLOAT, 0, floorVertices);
//	glEnableClientState(GL_VERTEX_ARRAY);
	//glTexCoordPointer(2, GL_FLOAT, 0, floorTC);
//	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    //NSLog(@" terrain ");
    //NSMutableArray * proximityGroundTiles = [self objectsInProximity:groundTiles x: playerX z: playerZ d:55];
	NSEnumerator* groundTileIterator = [groundTiles objectEnumerator];
	ObjectContainer* groundTileObject;
	int groundTileIndex = 0;
	while((groundTileObject = [groundTileIterator nextObject]))
	{
		if(groundTileObject != nil){
			
			// Filter by distance for performance
			float tX = [groundTileObject locX];
			float tZ = [groundTileObject locZ];
            //if(tX < locX + distance && tX > locX - distance && tZ < locZ + distance && tZ > locZ - distance){
			double dx = tX-sceneX;
			double dz = tZ-sceneZ;
			double distance = sqrt(dx*dx + dz*dz); 
			//NSLog(@" %f %f", playerX, playerZ);
			
			if(distance < 65){ // 48
				glPushMatrix();	// preserve state of matrix
				
				float xSide = 0; 
				float zSide = -1.8;
				float xzSide = 0;
				
				if([groundTileObject tileYSideX] < -999 && [groundTileObject tileYSideZ] < -999 && [groundTileObject tileYSideXZ] < -999){
					// Kills performance - calculating adjacent point heights. Cache the height data in the tile object.
					
					float tileSize = [groundTileObject size];
					
					//NSLog(@" tile x: %f  z: %f ", [[groundTileObject getX] floatValue], [[groundTileObject getZ] floatValue]  );
					NSString* leftIndex = [NSString stringWithFormat:@"%fx%f" , [groundTileObject locX] - tileSize, [groundTileObject locZ]];
					ObjectContainer* leftTile = [groundTiles objectForKey: leftIndex  ];
					
					NSString* rightIndex = [NSString stringWithFormat:@"%fx%f" , [groundTileObject locX], [groundTileObject locZ] - tileSize ];
					ObjectContainer* rightTile = [groundTiles objectForKey: rightIndex  ];
					
					NSString* xzIndex = [NSString stringWithFormat:@"%fx%f" , [groundTileObject locX] - tileSize, [groundTileObject locZ] - tileSize ];
					ObjectContainer* xzTile = [groundTiles objectForKey: xzIndex  ];
					
					if(leftTile != nil){
						xSide = [leftTile locY] - [groundTileObject locY];
					}
					if(rightTile != nil){
						zSide = [rightTile locY] - [groundTileObject locY];
					}
					if(xzTile != nil){ // diagonal
						xzSide = [xzTile locY] - [groundTileObject locY];
					} else if(leftTile != nil){ // second choice = edge of world on X axis
						xzSide = [leftTile locY] - [groundTileObject locY];
					} else if(rightTile != nil){ // third choice = edge of world on Z axis
						xzSide = [rightTile locY] - [groundTileObject locY];
					}
					[groundTileObject setTileYSideX:xSide];
					[groundTileObject setTileYSideZ:zSide];
					[groundTileObject setTileYSideXZ:xzSide];
				} else {
					xSide = [groundTileObject tileYSideX];
					zSide = [groundTileObject tileYSideZ];
					xzSide = [groundTileObject tileYSideXZ];
				}
				
				//const GLfloat floorVertices[] = {
				//	-2.0, xSide, 2.0,		// Top left
				//	-2.0, xzSide , -2.0,    // Bottom left    
				//	2.0, zSide, -2.0,		// Bottom right
				//	2.0, 0, 2.0				// Top right     
				//};
				
				float halfTile = [groundTileObject size]  /2.0;
				
				const GLfloat floorVertices[] = {
					[groundTileObject locX]-halfTile, [groundTileObject locY]+xSide, [groundTileObject locZ]+halfTile,		// Top left
					[groundTileObject locX]-halfTile, [groundTileObject locY]+xzSide, [groundTileObject locZ]-halfTile,    // Bottom left    
					[groundTileObject locX]+halfTile, [groundTileObject locY]+zSide , [groundTileObject locZ]-halfTile,		// Bottom right
					[groundTileObject locX]+halfTile, [groundTileObject locY]+0, [groundTileObject locZ]+halfTile				// Top right     
				};
				
				
				const GLfloat floorTC[] = {
					0.0, 1.0,
					0.0, 0.0,
					1.0, 0.0,
					1.0, 1.0
				};
				
				glVertexPointer(3, GL_FLOAT, 0, floorVertices);
				glEnableClientState(GL_VERTEX_ARRAY);
				glTexCoordPointer(2, GL_FLOAT, 0, floorTC);
				glEnableClientState(GL_TEXTURE_COORD_ARRAY);
				
				// Matrix Multiplication - translate 
				
				//GLfloat pointMatrix[16] = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
				//pointMatrix[12] = [[groundTileObject getX] floatValue];
				//pointMatrix[13] = [[groundTileObject getY] floatValue];
				//pointMatrix[14] = [[groundTileObject getZ] floatValue];
				//glMultMatrixf(&pointMatrix[0]);
				
				//glTranslatef([[groundTileObject getX] floatValue], 
				//				[[groundTileObject getY] floatValue], 
				//				[[groundTileObject getZ] floatValue]);
				
				
				
				//glTranslatef(10.0+(j*-size), -2, -size+(i*-size));
				
				if(![[groundTileObject colour] isEqualToString:@""] ){
					// Cache RGB values from color string
					if( [groundTileObject red] == -1 && 
						[groundTileObject green] == -1 && 
						[groundTileObject blue] == -1 ){
						NSScanner *scanner2 = [NSScanner scannerWithString:[groundTileObject colour]];
						int baseColor1;
						[scanner2 scanHexInt:&baseColor1];
						[groundTileObject setRed:((baseColor1 & 0xFF0000) >> 16) / 255.0f];
						[groundTileObject setGreen:((baseColor1 & 0x00FF00) >>  8) / 255.0f];
						[groundTileObject setBlue:(baseColor1 & 0x0000FF) / 255.0f];
					}
					glColor4f([groundTileObject red],
							  [groundTileObject green],
							  [groundTileObject blue], 1.0f);
				} 
				
				if([[groundTileObject colour] isEqualToString:@""]){
					glColor4f(1, 1, 1, 1.0);
					//GLuint groundTexture = [grounTextures objectForKey: [groundTileObject getName] ];
					//if(groundTexture == nil){
					//	[self loadGroundTexture: [groundTileObject getName] ];
					//	groundTexture = [grounTextures objectForKey: [groundTileObject getName] ];
					//}
					//glBindTexture(GL_TEXTURE_2D, textures[7]);
					
					
					NSString *textureCacheKey = [groundTileObject file]; // [groundTileObject getName]
					Texture2D *terrainTexture = [terrainTextureCache objectForKey:textureCacheKey];
					if(terrainTexture == nil){
						
                        // needs work
                        
                        NSString *extension = [textureCacheKey pathExtension];
                        NSString *baseFilenameWithExtension = [textureCacheKey lastPathComponent];
                        NSString *baseFilename = nil;
                        if([extension isEqualToString:@""]){
                            //extension = @"png";
                            extension = @"jpg";
                            baseFilename = [baseFilenameWithExtension substringToIndex:[baseFilenameWithExtension length] - [extension length] - 0];
                        } else {
                            baseFilename = [baseFilenameWithExtension substringToIndex:[baseFilenameWithExtension length] - [extension length] - 1];
                        }
                        
                        //NSLog(@"   extension %@  baseFilenameWithExtension %@  " , extension, baseFilenameWithExtension);
                        
                        
                        
                        //NSLog(@" baseFilename %@   extension %@  ", baseFilename, extension);
                        
                        NSString *texturePath = [[NSBundle mainBundle] pathForResource:textureCacheKey ofType:@"jpg"];
                        //NSString *texturePath = [[NSBundle mainBundle] pathForResource:baseFilename ofType:extension];
                        if(texturePath != nil){
                            //NSString *tp = [[NSBundle mainBundle] pathForResource:[groundTileObject getName] ofType:@"png"];
                            terrainTexture = [[Texture2D alloc] initWithImagePath:texturePath];
                            [terrainTextureCache setObject:terrainTexture forKey:textureCacheKey];
                        }
                        
                        //
                        // Development ONLY
                        //
                        /*
						if(texturePath == nil){ // load from web service
                            
                            NSString * urlFile = [NSString stringWithFormat:@"http://subjectreality.appspot.com/getfile?id=%@", 
                                                  [groundTileObject file]];
                            terrainTexture = [[Texture2D alloc] initWithImageUrl:urlFile];
                            if(terrainTexture != nil){
                                [terrainTextureCache setObject:terrainTexture forKey:textureCacheKey];
                            }
                            //NSLog(@" success??? %@ ", terrainTexture);
                            
                        }
                        */
					} 
					GLuint n = [terrainTexture getTexture];
					
					
					glEnable(GL_BLEND);
					//glBlendFunc (GL_ONE, GL_ONE);
					glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA);
				
					glBindTexture(GL_TEXTURE_2D, n);
				
					
				//	glBindTexture(GL_TEXTURE_2D, groundTexturesTemp[0]);
					//glBindTexture(GL_TEXTURE_2D, groundTexture);
					glEnable(GL_TEXTURE_2D);	
				
					float alpha = 1.0f;  //   0.82       *** transparent ground
					glColor4f(ambientLight,ambientLight,ambientLight,alpha);  
				}
				
				glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
				//glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
				
				
				if([[groundTileObject colour] isEqualToString:@""]){
					glBlendFunc (GL_ONE, GL_ONE);
					glDisable(GL_TEXTURE_2D);
					glDisable(GL_BLEND);
				}
				
				
				glDisableClientState(GL_TEXTURE_COORD_ARRAY);
				glDisableClientState(GL_VERTEX_ARRAY);
				
				glPopMatrix();	// Return matrix to origional state
				groundTileIndex++;
			}
		}
	}
    //[proximityGroundTiles release];
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	//glDisableClientState(GL_VERTEX_ARRAY);
	glColor4f(1.0f,1.0f,1.0f,1.0f); 
	
	
	//NSLog(@"tiles: %d ", tileCount);
	
	// Display terrain. OLD
    /*
	if( groundTextureName != nil  && ![groundTextureName isEqualToString:@""]){ //  
		const GLfloat floorVertices[] = {
			-4.0, 4.0, 0.0,     // Top left
			-4.0, -4.0, 0.0,    // Bottom left
			4.0, -4.0, 0.0,     // Bottom right
			4.0, 4.0, 0.0       // Top right
		};
		const GLfloat floorTC[] = {
			0.0, 1.0,
			0.0, 0.0,
			1.0, 0.0,
			1.0, 1.0
		};
		
		 //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		 
		glColor4f(1.0f,1.0f,1.0f,1.0f);	 // Set color to blue
		glVertexPointer(3, GL_FLOAT, 0, floorVertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		glTexCoordPointer(2, GL_FLOAT, 0, floorTC);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		//glBindTexture(GL_TEXTURE_2D, groundTexture);
		glBindTexture(GL_TEXTURE_2D, textures[7]);
		glEnable(GL_TEXTURE_2D);
		int size = 8;
		int blocks = 10;
	
		for (int i = -blocks; i < blocks; i++) {
			for (int j = -blocks; j < blocks; j++) {
				
				glPushMatrix();
				{
					glTranslatef(10.0+(j*-size), -2, -size+(i*-size));
					glRotatef(-90.0, 1.0, 0.0, 0.0);
					glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
				}
				glPopMatrix();
			}
		}
	
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
	}
	*/
	
	//
	// draw dialogs (Dev only)
	//
    NSEnumerator* dialogIterator = [dialogs objectEnumerator];
    ObjectContainer* dialogObject;
    while((dialogObject = [dialogIterator nextObject]))
    {
        glPushMatrix();	// preserve state of matrix
        if( dialogObject != nil ){
            //Character* bo =  [dialogObject blenderObject];
            //NSNumber * angleToPlayer = [enimyObject angleToPoint: playerX y: playerZ ];
            //double angleP = [angleToPlayer doubleValue];
            
            // Development only dialog marker
            /*
            GLfloat vVertices[] = {[dialogObject locX], 
                -8 + [dialogObject locY], 
                [dialogObject locZ], 
                [dialogObject locX], 
                3 + [dialogObject locY], 
                [dialogObject locZ]}; 
            glColor4f(0.0f,1.0f,0.0f,1.0f);//Change the object color to red
            glLineWidth(3.0f);
            glVertexPointer(3, GL_FLOAT, 0, vVertices);
            glEnableClientState(GL_VERTEX_ARRAY);
            glDrawArrays(GL_LINES, 0, 2);
            */
            
            float tX = [dialogObject locX];
            float tZ = [dialogObject locZ];
            double dx = tX-playerX;
            double dz = tZ-playerZ;
            double distance = sqrt(dx*dx + dz*dz); 
            
            if(distance <= [dialogObject size]){
                //NSLog(@" Dialog: %@ " , [dialogObject text]);
                [self switchToOrtho:view];
                
                glEnableClientState(GL_VERTEX_ARRAY);
                glEnable(GL_TEXTURE_2D);
                glEnable(GL_BLEND);
                //glBlendFunc (GL_ONE, GL_ONE);
                glEnableClientState(GL_TEXTURE_COORD_ARRAY);
                glColor4f(1, 1, 1, 0.2);
                
                if(dialogText == nil || ![dialogText isEqualToString: [dialogObject text]] ){
                    [self setDialog:[dialogObject text]];  
                    dialogText = [dialogObject text];   
                    //NSLog(@" dialogs ");
                }
                
                if(dialogTexture != nil && !paused && !dead){
                    float x = (float)view.bounds.size.width - 45;
                    float y = (float)view.bounds.size.height - 96;  
                    [dialogTexture drawAtPoint:CGPointMake(x, y) depth:-1]; // y, -x  275.0, 384.0
                }
                
                glDisable(GL_BLEND);
                glDisable(GL_TEXTURE_2D);
                glDisableClientState(GL_TEXTURE_COORD_ARRAY);
                
                [self switchBackToFrustum];
                
            } 
            glColor4f(1.0f,1.0f,1.0f,1.0f);
        }
        glPopMatrix();	// Return matrix to origional state
    }
    
	//NSLog(@" dialogs %d ", [dialogs count]);
	
	
	//
	// Cleanup
	//

	// Handle display of loading screen before loading level.
	if(loading == 2){	// if screen displayed, load level
		[self loadLevel:levelName];
		loading = 0; // if displayed then loading is done.
	}
	if(loading == 1){ // if initiated, render loading screen and continue.
		loading = 2;
	}
}




/**
 * objectsInProximity
 *
 */
- (NSMutableArray*) objectsInProximity:(NSMutableArray*)en x:(float)locX  z:(float)locZ d:(float)distance {
    //int distance = 40;
    //NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    
    //int count = [en count];
    //float xVector[count];
    //float zVector[count];
    //int index = 0;
    
    NSMutableArray * result = [[NSMutableArray alloc] init];
    NSEnumerator* enemyIterator = [en objectEnumerator];
	ObjectContainer* enimyObject;
	while((enimyObject = [enemyIterator nextObject]))
    //for(int i = 0; i < [en count]; i++)
	{
        //NSLog(@" i %d   %d", i, [en count]);
        //enimyObject = [en objectAtIndex:i];
        float tX = [enimyObject locX];
        float tZ = [enimyObject locZ];
        //xVector[index] = tX;
        //zVector[index++] = tZ;
        
        // box 
        if(tX < locX + distance && tX > locX - distance && tZ < locZ + distance && tZ > locZ - distance){
            //[result addObject: enimyObject];
        
            float dx = tX-locX;
            float dz = tZ-locZ;
            float currDistance = sqrt(dx*dx + dz*dz); // by radius (more accurate but expensive than box)
            if(currDistance < distance){
                [result addObject: enimyObject];
            }
        }
    }
    
    /*
    int n = 3; 
    float v[3] = {1, 2, 3}; 
    cblas_sscal(n, 1/cblas_snrm2(n, v, 1), v, 1);
    // 0.267261  0.534522  0.801784
    for(int i = 0; i < n; i++){
    //    NSLog(@" %d -> %f ", i, v[i]);
    }
     */
    
    //cblas_sscal - Multiplies each element of a vector by a constant (single-precision).
    //cblas_sasum - sum 
    //catlas_caxpby(count, /*alpha*/ nil, xVector, 1, /*beta*/ nil, zVector, 1);
    //vsqrtf
    
    //for(int i = 0; i < count; i++){
    //    NSLog(@" xVector %d -> %f  %f ", i, xVector[i], zVector[i]);
    //}
    
    
    //NSTimeInterval finish = [NSDate timeIntervalSinceReferenceDate];
    //NSLog(@"objectsInProximity time: %f   size: %d", (finish - start), [en count] );
    // 0.000051  in sim
    // 0.000339 0.000330  in 3gs     0.000263 0.000270
    
    return result;
}



- (bool)levelCompleted:(float)x y:(float)y z:(float)z {
	bool result = false;
	
	GLfloat buffer = 3;
	
	GLfloat xx = x; // + 10;   // wierd
	
	//[x setValue: [x floatValue] + 10];
	
	if( completeLocationX != nil && completeLocationY != nil && completeLocationZ != nil &&
	   (xx > [completeLocationX floatValue] -buffer) && (xx < [completeLocationX floatValue] + buffer) &&
	   (z > [completeLocationZ floatValue] -buffer) && (z < [completeLocationZ floatValue] + buffer) ){
		result = true;
		
	}
	
	//NSLog(@"  --- %f %f   Z %f %f   " , xx, [completeLocationX floatValue] ,[z floatValue], [completeLocationZ floatValue] );
	
	return result;
}


- (bool) levelCompletedInRange:(float)x y:(float)y z:(float)z {
	bool result = false;
	
	GLfloat buffer = 40;
	
	GLfloat xx = x; // + 10;   // wierd
	
	//[x setValue: [x floatValue] + 10];
	
	if( completeLocationX != nil && completeLocationY != nil && completeLocationZ != nil &&
	   (xx > [completeLocationX floatValue] -buffer) && (xx < [completeLocationX floatValue] + buffer) &&
	   (z > [completeLocationZ floatValue] -buffer) && (z < [completeLocationZ floatValue] + buffer) ){
		result = true;
		
	}
	
	//NSLog(@"  --- %f %f   Z %f %f   " , xx, [completeLocationX floatValue] ,[z floatValue], [completeLocationZ floatValue] );
	
	return result;
}


- (NSString*) completeLoad {
	/*
	 if(completeLoad == nil){
	 completeLoad = @"na";
	 }
	 */
	NSLog(@"completeLoad %@ ", completeLoad);
	return completeLoad;
	
	//return @"test";
}

- (void) setPlayerX:(float)px playerY:(float)py playerZ:(float)pz {
	playerX = px;
	playerY = py;
	playerZ = pz;
}

- (void) setAvatarX:(float)px playerY:(float)py playerZ:(float)pz {
	avatarX = px;
	avatarY = py;
	avatarZ = pz;
}

- (void) setInFrontOfAvatarX:(float)px locY:(float)py locZ:(float)pz {
    inFrontX = px;
	inFrontY = py;
	inFrontZ = pz;
}

- (void) setCameraX:(float)px y:(float)py z:(float)pz {
	cameraX = px;
	cameraY = py;
	cameraZ = pz;
}
    
/**
 * getTerrainHeightX
 *
 * Descriotion: get terrain height at current location.
 */
- (float) getTerrainHeightX:(float)x z:(float)z {
	float result = -1.7;
	
	int tileSize = 16;
	if(true){
		float currX = x + (tileSize/2);
		float currZ = z + (tileSize/2);
		currX = (int)currX - ((int)currX % tileSize);
		currZ = (int)currZ - ((int)currZ % tileSize);
		
		//NSLog(@" currX  %f %f " ,currX , currZ );
		if(currX < 0){
			currX -= tileSize;
		}
		
		if(currZ < 0){
			currZ -= tileSize;
		}
		
		ObjectContainer* a1 = [[ObjectContainer alloc] init];
		[a1 setLocX:x];
		[a1 setLocY:0];
		[a1 setLocZ:z];
		
		NSString* tileIndex = [[NSString alloc] initWithFormat:@"%fx%f", currX, currZ];
		ObjectContainer* groundTile = [groundTiles objectForKey: tileIndex];
		if(groundTile != nil){
			result = [groundTile locY];
		
			ObjectContainer* p1 = [[ObjectContainer alloc] init];
			//float buffy = 2;
			//[p1 setLocX: &buffy];
			//float p1X = currX-(tileSize/2);
			[p1 setLocX:currX-(tileSize/2)];
			[p1 setLocY:[groundTile locY] + ([groundTile tileYSideX])];
			[p1 setLocZ:currZ+ (tileSize/2)];
			
			ObjectContainer* p2 = [[ObjectContainer alloc] init];
			[p2 setLocX:currX-(tileSize/2)];
			[p2 setLocY:[groundTile locY] + ([groundTile tileYSideXZ])];
			[p2 setLocZ:currZ - (tileSize/2)];
			
			ObjectContainer* p3 = [[ObjectContainer alloc] init];
			[p3 setLocX:currX+(tileSize/2)];
			[p3 setLocY:[groundTile locY] + ([groundTile tileYSideZ])];
			[p3 setLocZ:currZ- (tileSize/2)];
			
			ObjectContainer* p4 = [[ObjectContainer alloc] init];
			[p4 setLocX:currX+(tileSize/2)];
			[p4 setLocY:[groundTile locY]];
			[p4 setLocZ:currZ+ (tileSize/2)];
			
			
			//float tileLocX = [x floatValue] - currX + (tileSize/2);
			//float tileLocZ = [z floatValue] - currZ + (tileSize/2);
			//NSLog(@" loc  %f %f " ,tileLocX, tileLocZ );
			
			//float a = 2;
			//float b = 3;
			//NSNumber *buffy = [self distance:&a to:&b];
			float d1 = [self distance:a1 to:p1];
			float d2 = [self distance:a1 to:p2];
			float d3 = [self distance:a1 to:p3];
			float d4 = [self distance:a1 to:p4];
			//NSLog(@" result - 2 %f   4 %f ", [d2 floatValue], [d4 floatValue] );
			
			//if( d1 < d3 ) = A=1, B=2, C=4
			//if( d1 > d3 ) = A=2, B=3, C=4
			
			float dA = 0;
			float dB = 0;
			float dC = 0;
			if(d2 < d4){
				// a = 1, b = 2, c = 3
				float totalDistance = d1 + d2 + d3;
				dA = (totalDistance-d1); // invert   55-5 = 50 / 2 = 25
				dB = (totalDistance-d2); // invert   55-20= 35 / 2 = 17.5
				dC = (totalDistance-d3); // invert   55-30= 25 / 2 = 12.5
				totalDistance = dA + dB + dC;
				
				float aP = ( dA / totalDistance);                //  55-5 / 55 = .909  5/55=.09      
				float bP = ( dB / totalDistance);                //  55-20 / 55 =        20/55=.363         
				float cP = ( dC / totalDistance);                //  1-0.54   .46    55-30/55=.45       30/55=.5454
				float height = [groundTile locY];
				float delta = 
				(
					([groundTile tileYSideX] * aP) + 
					([groundTile tileYSideXZ] * bP) + 
					([groundTile tileYSideZ] * cP)
					) ;
                if(delta > -900){   // glitch
                    height += delta;
                }
				
				//NSLog(@" d1: %f %f %f ", [d1 floatValue], [d2 floatValue], [d3 floatValue]);
				
				//NSLog(@" side: %f %f %f ", [[groundTile tileYSideX]floatValue], [[groundTile tileYSideXZ]floatValue], [[groundTile tileYSideZ]floatValue] );
				//NSLog(@" aP: %f %f %f ", aP, bP, cP);
				//NSLog(@" height: %f ", height);
				
				//result = [[NSNumber alloc] initWithFloat:height];
				result = height;
			} else {
				// a = 1, b = 3, c = 4
				float totalDistance = d1 + d3 + d4;
				dA = (totalDistance-d1); // invert   55-5 = 50 / 2 = 25
				dB = (totalDistance-d3); // invert   55-20= 35 / 2 = 17.5
				dC = (totalDistance-d4); // invert   55-30= 25 / 2 = 12.5
				totalDistance = dA + dB + dC;
				
				float aP = ( dA / totalDistance);                //  55-5 / 55 = .909  5/55=.09      
				float bP = ( dB / totalDistance);                //  55-20 / 55 =        20/55=.363         
				float cP = ( dC / totalDistance);                //  1-0.54   .46    55-30/55=.45       30/55=.5454
				float height = [groundTile locY];
				float delta = 
				( 
				([groundTile tileYSideX] * aP) + 
				([groundTile tileYSideZ] * bP) + 
				(0 * cP)
				);
                if(delta > -900){   // glitch
                    height += delta;
                }
				
				//NSLog(@" d1: %f %f %f ", [d1 floatValue], [d2 floatValue], [d3 floatValue]);
				
				//NSLog(@" side: %f %f %f ", [[groundTile tileYSideX]floatValue], [[groundTile tileYSideXZ]floatValue], [[groundTile tileYSideZ]floatValue] );
				//NSLog(@" aP: %f %f %f ", aP, bP, cP);
				//NSLog(@" height: %f ", height);
				
				//result = [[NSNumber alloc] initWithFloat:height];
				result = height;
			}
			float totalDistance = dA + dB + dC;   //  5 + 20 + 30 = 55
			
            //result += 0.6;
			
			[p4 release];
			[p3 release];
			[p2 release];
			[p1 release];
		}
		[a1 release];
		[tileIndex release];
	}
	//[x release];
	//[z release];
	if(result < -500){
		//NSLog(@" %f  %f height: %f ", x, z, result);
		//result = -1.7; // terrain not yet loaded.
	}
	return result;
}

- (float)distance:(ObjectContainer*)a to:(ObjectContainer*)b {
	float d = 0; // *a + *b;
	//NSLog(@" a - %f ",d);
	
	float tX = [a locX];
	float tZ = [a locZ];
	float uX = [b locX];
	float uZ = [b locZ];
	double dx = tX-uX;
	double dz = tZ-uZ;
	d = (float)sqrt(dx*dx + dz*dz); 
	
	return d;
	//return [[NSNumber alloc] initWithFloat:d];
}


/**
 * drawWorldBox
 *
 * Decsription:
 *		render skybox in scene
 */
- (void)drawWorldBox:(float)x  setZ:(float)z {
	GLfloat xOffset = x;
	GLfloat zOffset = z;
	
	//NSLog(@" drawWorldBox x: %f   z: %f \n\n", xOffset, zOffset);
	float size = 80;
	
	// World Box Face
	const GLfloat worldBoxVertices[] = {
        -size, size, 0.0 ,     // Top left
        -size, -size, 0.0 ,    // Bottom left
        size, -size, 0.0 ,     // Bottom right
        size, size, 0.0        // Top right
    };
	const GLfloat worldBoxFrontTC[] = {
		0.0, 1.0,
		0.0, 0.0,
		1.0, 0.0,
		1.0, 1.0
	};
	
	glVertexPointer(3, GL_FLOAT, 0, worldBoxVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, worldBoxFrontTC);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, textures[1]); // texture
	glEnable(GL_TEXTURE_2D);
	glPushMatrix();
	glTranslatef(xOffset + 0.0, 2.0, zOffset -size );
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	glPopMatrix();
	
	
	// Left Face
	glVertexPointer(3, GL_FLOAT, 0, worldBoxVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, worldBoxFrontTC);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, textures[2]); // texture   //   textures[2]
	glEnable(GL_TEXTURE_2D);
	glPushMatrix();
	glTranslatef(xOffset - size, 2.0, zOffset -0.0f );
	glRotatef(90.0, 0.0, 1.0, 0.0);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	glPopMatrix();
	
	// Right Face
	glVertexPointer(3, GL_FLOAT, 0, worldBoxVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, worldBoxFrontTC);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, textures[3]); // texture
	glEnable(GL_TEXTURE_2D);
	glPushMatrix();
	glTranslatef(xOffset + size, 2.0, zOffset -0.0f );
	glRotatef(-90.0, 0.0, 1.0, 0.0);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	glPopMatrix();
	
	// Back Face
	glVertexPointer(3, GL_FLOAT, 0, worldBoxVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, worldBoxFrontTC);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, textures[4]); // texture
	glEnable(GL_TEXTURE_2D);
	glPushMatrix();
	glTranslatef(xOffset + 0.0, 2.0, zOffset + size );
	glRotatef(-180.0, 0.0, 1.0, 0.0);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	glPopMatrix();
	
	// Top Face
	const GLfloat worldTopBoxVertices[] = {
        -size, size, 0.0  ,      // Top right
		-size, -size, 0.0  ,    // Top left
		size, -size, 0.0 ,     // Bottom left
		size, size, 0.0      // Bottom right
    };
	glVertexPointer(3, GL_FLOAT, 0, worldTopBoxVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, worldBoxFrontTC);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, textures[5]); // texture
	glEnable(GL_TEXTURE_2D);
	glPushMatrix();
	glTranslatef(xOffset + 0.0, size, zOffset + 0.0f );
	glRotatef(90.0, 1.0, 0.0, 0.0);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	glPopMatrix();
	
	
	
	// Bottom
	const GLfloat worldBottomBoxVertices[] = {
        -size, 0.0, -size,     // Top left
        -size, 0.0, size,    // Bottom left
        size, 0.0, size,     // Bottom right
        size, 0.0, -size        // Top right
    };
	glVertexPointer(3, GL_FLOAT, 0, worldBottomBoxVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, worldBoxFrontTC);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, textures[5]); // texture // 5 is top.
	glEnable(GL_TEXTURE_2D);
	glPushMatrix();
	glTranslatef(xOffset + 0.0, -size + 2, zOffset + 0.0f );
	glRotatef(90.0, 0.0, 1.0, 0.0);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	glPopMatrix();
	
}


- (void) setLoading:(bool)l{
	loading = l;
}

- (int) loading; 
{
    return loading;
}


/**
 * display the menu items currently loaded.
 *
 * *** TODO
 */
/*
- (void) displayLoading:(GLView*)view;
{
	if(loading > 0 && false){ // && false
        //[self switchToOrtho:view];
        
		glPushMatrix();
		
		glLoadIdentity();
		glTranslatef(0.0, 0.0, -0.2);
		
		// reset color
		//glColor4f(1.0f,0.0f,0.0f,1.0f);
	  
        
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glScalef(0.0008, 0.0008, 0.0008);
		
		
		// Text
		if(loadingTexture == nil){
			loadingTexture = [[Texture2D alloc] initWithString:@"Loading" dimensions:CGSizeMake(128.0, 64.0) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:28.0];
		}
		glColor4f(0.0f,0.0f,0.0f,1.0f);
        
        glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA);
		[loadingTexture drawAtPoint:CGPointMake(-10,  10)]; // -128,  100
		glBlendFunc (GL_ONE, GL_ONE);
        
		glDisable(GL_BLEND);
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisable(GL_TEXTURE_2D);
		
        
        
		glPopMatrix();
		
		// reset color
		glColor4f(1.0f,1.0f,1.0f,1.0f);
        
        //[self switchBackToFrustum];
	}
}
*/



/*
- (void)loadTexture2:(NSString *)name intoLocation:(GLuint)location {
	
	CGImageRef textureImage = [UIImage imageNamed:name].CGImage;
	if (textureImage == nil) {
        NSLog(@"Failed to load texture image");
		return;
    }
	
    NSInteger texWidth = CGImageGetWidth(textureImage);
    NSInteger texHeight = CGImageGetHeight(textureImage);
	
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
	
    CGContextRef textureContext = CGBitmapContextCreate(textureData,
														texWidth, texHeight,
														8, texWidth * 4,
														CGImageGetColorSpace(textureImage),
														kCGImageAlphaPremultipliedLast);
	
	// Rotate the image
	CGContextTranslateCTM(textureContext, 0, texHeight);
	CGContextScaleCTM(textureContext, 1.0, -1.0);
	
	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}
*/ 

- (void)loadTexture3:(NSString *)name intoLocation:(GLuint)location {
	//NSLog(@" load texture: %@_ ", name);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_SRC_COLOR);
	
	
	glGenTextures(1, &textures[location]);
	
	glBindTexture(GL_TEXTURE_2D, textures[location]);
	
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	NSString *uipath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
	NSData *uitexData = [[NSData alloc] initWithContentsOfFile:uipath];
	UIImage *uiimage = [[UIImage alloc] initWithData:uitexData];
	if (uiimage == nil)
		NSLog(@"Do real error checking here");
	
	GLuint uiwidth = CGImageGetWidth(uiimage.CGImage);
	GLuint uiheight = CGImageGetHeight(uiimage.CGImage);
	CGColorSpaceRef uicolorSpace = CGColorSpaceCreateDeviceRGB();
	void *uiimageData = malloc( uiheight * uiwidth * 4 );
	CGContextRef uicontext = CGBitmapContextCreate( uiimageData, uiwidth, uiheight, 8, 4 * uiwidth, uicolorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
	CGColorSpaceRelease( uicolorSpace );
	CGContextClearRect( uicontext, CGRectMake( 0, 0, uiwidth, uiheight ) );
	CGContextTranslateCTM( uicontext, 0, uiheight - uiheight );
	CGContextDrawImage( uicontext, CGRectMake( 0, 0, uiwidth, uiheight ), uiimage.CGImage );
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, uiwidth, uiheight, 0, GL_RGBA, GL_UNSIGNED_BYTE, uiimageData);
	CGContextRelease(uicontext);
	free(uiimageData);
	[uiimage release];
	[uitexData release];
	 
}

// needs work
- (void)loadGroundTexture:(NSString *)name  {
	NSLog(@" load ground texture: %@_ ", name);
	
	// grounTextures
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_SRC_COLOR);
	
	
	glGenTextures(1, &groundTexturesTemp[0]);
	glBindTexture(GL_TEXTURE_2D, groundTexturesTemp[0]);
	
	
	//GLuint temp[1];
	//temp[0]= [grounTextures objectForKey:name];
	//if(temp[0] == nil){
	//	glGenTextures(1, temp);
	///	[grounTextures setObject:temp[0] forKey:name];
	//}
	
	
	//glGenTextures(1, [grounTextures objectForKey:name]);
	//glBindTexture(GL_TEXTURE_2D, [grounTextures objectForKey:name]);
	
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	NSString *uipath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
	NSData *uitexData = [[NSData alloc] initWithContentsOfFile:uipath];
	UIImage *uiimage = [[UIImage alloc] initWithData:uitexData];
	if (uiimage == nil)
		NSLog(@"Do real error checking here");
	
	GLuint uiwidth = CGImageGetWidth(uiimage.CGImage);
	GLuint uiheight = CGImageGetHeight(uiimage.CGImage);
	CGColorSpaceRef uicolorSpace = CGColorSpaceCreateDeviceRGB();
	void *uiimageData = malloc( uiheight * uiwidth * 4 );
	CGContextRef uicontext = CGBitmapContextCreate( uiimageData, uiwidth, uiheight, 8, 4 * uiwidth, uicolorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
	CGColorSpaceRelease( uicolorSpace );
	CGContextClearRect( uicontext, CGRectMake( 0, 0, uiwidth, uiheight ) );
	CGContextTranslateCTM( uicontext, 0, uiheight - uiheight );
	CGContextDrawImage( uicontext, CGRectMake( 0, 0, uiwidth, uiheight ), uiimage.CGImage );
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, uiwidth, uiheight, 0, GL_RGBA, GL_UNSIGNED_BYTE, uiimageData);
	CGContextRelease(uicontext);
	free(uiimageData);
	[uiimage release];
	[uitexData release];
	
}

-(float) ambientLight {
    return ambientLight;
}

// ****
- (NSNumber*)getInitalLocationX {
	return  initalLocationX ;
}

- (NSNumber*)getInitalLocationY {
	return initalLocationY;
}

- (NSNumber*)getInitalLocationZ {
	return initalLocationZ;
}

- (NSString*)getLevelLoaded {
	return levelName;
}


-(float)completeLocationX {
    return [completeLocationX floatValue];
}
-(float)completeLocationZ {
    return [completeLocationZ floatValue];
}

- (void)setDialog:(NSString*)text
{
	[dialogTexture release];
	NSString* dialogString = [[NSString alloc] initWithFormat:@"%@", text];
	dialogTexture = [[Texture2D alloc] initWithString:dialogString
										dimensions:CGSizeMake(30., 200.0) 
										 alignment:UITextAlignmentLeft
											  font:[UIFont systemFontOfSize:16.0]];
	[dialogString release];
}


/**
 * touchableObjects
 *
 * Description: Retrieve a list of objects to check for collision.
 */
- (NSMutableArray*) touchableObjects {
	NSMutableArray* objectArray = [[NSMutableArray alloc] init];
	
	
    NSMutableArray * proximityEnemies = [self objectsInProximity:enemies x: avatarX z: avatarZ d:40];
    NSEnumerator* enemyIterator = [proximityEnemies objectEnumerator];
	ObjectContainer* enimyObject;
	while((enimyObject = [enemyIterator nextObject]))
	{
        [objectArray addObject:enimyObject];
    }
    [proximityEnemies release];
    
    //[objectArray addObjectsFromArray: enemies]; // too many
	
    
    
	return objectArray;
}

- (void)setPaused:(int)v {
	paused = v;
}

- (void)setDead:(bool)v {
	dead = v;
}

- (int) collectedItems {
    return collectedItems;
}

- (int) healthPoints {
    return (int)healthPoints;
}

- (void) setHealthPoints:(int)h {
    healthPoints = h;
}


- (ObjectContainer*) resetPlayerLocation {
    //ObjectContainer* result = resetPlayerLocation;
    
    //[resetPlayerLocation release];
    //resetPlayerLocation = nil;
    
    return resetPlayerLocation;
}

-(void) setResetPlayerLocation:(ObjectContainer*)v {
    
    [resetPlayerLocation release];
    resetPlayerLocation = nil;
    
}


- (NSMutableArray*) bullets; {
    return  bullets;
}

- (void) setBullets:(NSMutableArray*) b {
    [b retain];
    [bullets release];
    bullets = b;
}

- (Sound*) sound {
    return sound;
}

-(SaveGame*)saveGame{
    return saveGame;
}


-(void)shutdownWarning {
    NSLog(@" Level Shutdown warning ");
    
    [saveGame save];
    
}


- (bool)avatarCollision {
    return avatarCollision;
}

- (float)avatarCollisionAngle:(float)playerAngle {
    
    float result = avatarCollisionAngle + playerAngle;
    
    if(result > 360){
        result -= 360;
    }
    
    return result;
}

	
/**
 * Parse XML for layer configuration.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
	
    //NSLog(@"parse element %@ ", elementName);
    
    if([elementName isEqualToString:@"level"] ){
		readingLevel = [attributeDict objectForKey: @"name" ];
        
        [levelNames addObject:readingLevel];
	}
	
	// load level attributes
	if([elementName isEqualToString:@"level"] && [ levelName isEqualToString:readingLevel ] ){
		skybox_front = [attributeDict objectForKey: @"skybox_front" ];
		skybox_left = [attributeDict objectForKey: @"skybox_left" ];
		skybox_right = [attributeDict objectForKey: @"skybox_right" ];
		skybox_back = [attributeDict objectForKey: @"skybox_back" ];
		skybox_top = [attributeDict objectForKey: @"skybox_top" ];
		skybox_bottom = [attributeDict objectForKey: @"skybox_bottom" ];
		lowerBoundX = [attributeDict objectForKey: @"lowerBoundX" ];
		initalLocationX = [attributeDict objectForKey: @"initalLocationX" ];
		initalLocationY = [attributeDict objectForKey: @"initalLocationY" ];
		initalLocationZ = [attributeDict objectForKey: @"initalLocationZ" ];
        initalAngle = [attributeDict objectForKey: @"initalAngle" ];
		
		completeLocationX = [[NSNumber alloc] initWithFloat: [[attributeDict objectForKey: @"completeLocationX" ] floatValue]]; 
		completeLocationY = [[NSNumber alloc] initWithFloat: [[attributeDict objectForKey: @"completeLocationY" ] floatValue]];  
		completeLocationZ = [[NSNumber alloc] initWithFloat: [[attributeDict objectForKey: @"completeLocationZ" ] floatValue]]; 
		
		completeLoad = [[NSString alloc] initWithString:[attributeDict objectForKey: @"completeLoad" ]];
		
		groundTextureName = [[NSString alloc] initWithString:  [attributeDict objectForKey: @"ground-texture" ]  ];
        
        ambientLight = [[attributeDict objectForKey: @"ambientLight" ] floatValue];
        
	}
	
	// load layer objects
	if([elementName isEqualToString:@"object"] && [ levelName isEqualToString:readingLevel ] ){
        
        //NSLog(@" read Object XML %@   %@  ", levelName , readingLevel); 
        
		NSString* objId = [attributeDict objectForKey: @"id" ];
		NSString* name = [attributeDict objectForKey: @"name" ];
		NSString* file = [attributeDict objectForKey: @"file" ];
		
		NSString* xString = [attributeDict objectForKey: @"xLoc" ];
		NSString* yString = [attributeDict objectForKey: @"yLoc" ];
		NSString* zString = [attributeDict objectForKey: @"zLoc" ];
        
        //float yRot = [[attributeDict objectForKey: @"yRot" ] floatValue];
        
        //if( [file isEqualToString:@"ruins.obj"] ){
        //NSLog(@" Read Object XML %@   %@   f: %@ n: %@ ", levelName , readingLevel, file, name); 
		//}
		ObjectContainer* object = [[ObjectContainer alloc] initMe];
		//object.objId = objId;
		[object setObjId: [objId intValue]];
	
		[object setName: name];
		if(file != nil){
			[object file: file];
		}
		
		[object setLocX:[xString floatValue]]; 
		[object setLocY:[yString floatValue]];
		[object setLocZ:[zString floatValue]];
		
		[object setRotX:[[attributeDict objectForKey: @"xRot"] floatValue]];
		[object setRotY:[[attributeDict objectForKey: @"yRot" ] floatValue]];
        //[object setRotY:yRot];
        //if(yRot > 0){
        //    NSLog(@"go it  %f - %f", yRot, [object rotY] );
        //}
		[object setRotZ:[[attributeDict objectForKey: @"zRot" ] floatValue]];
	
		[object setScaleX:[[attributeDict objectForKey: @"xScale" ] floatValue]];
		[object setScaleY:[[attributeDict objectForKey: @"yScale" ] floatValue]];
		[object setScaleZ:[[attributeDict objectForKey: @"zScale" ] floatValue]];
		
        // size
        [object setSize: [[attributeDict objectForKey: @"size" ] floatValue]];
        
		[objects addObject:object];
	}
	
	
	
	// load character objects
	if([elementName isEqualToString:@"character"] && [ levelName isEqualToString:readingLevel ] ){
		NSString* name = [attributeDict objectForKey: @"name" ];
		NSString* file = [attributeDict objectForKey: @"file" ];
		NSString* xString = [attributeDict objectForKey: @"xLoc" ];
		NSString* yString = [attributeDict objectForKey: @"yLoc" ];
		NSString* zString = [attributeDict objectForKey: @"zLoc" ];
		
		ObjectContainer* object = [[ObjectContainer alloc] initMe];
		
		[object setName:name];
		[object setFile:file];
		
		[object setLocX:[xString floatValue]];
		[object setLocY:[yString floatValue]];
		[object setLocZ:[zString floatValue]];
		
		[object setRotX: [[attributeDict objectForKey: @"xRot" ] floatValue]];
		[object setRotY: [[attributeDict objectForKey: @"yRot" ] floatValue]];
		[object setRotZ: [[attributeDict objectForKey: @"zRot" ] floatValue]];
		
		[object setScaleX: [[attributeDict objectForKey: @"xScale" ] floatValue]];
		[object setScaleY: [[attributeDict objectForKey: @"yScale" ] floatValue]];
        [object setScaleZ: [[attributeDict objectForKey: @"zScale" ] floatValue]];
		
		[characters addObject:object];
	}
	
	
	// ground tile
	if([elementName isEqualToString:@"ground"] && [ levelName isEqualToString:readingLevel ] ){
		NSString* name = [attributeDict objectForKey: @"name" ];
		NSString* file = [attributeDict objectForKey: @"file" ];
		NSString* colour = [attributeDict objectForKey: @"colour" ];
		NSString* xString = [attributeDict objectForKey: @"xLoc" ];
		NSString* yString = [attributeDict objectForKey: @"yLoc" ];
		NSString* zString = [attributeDict objectForKey: @"zLoc" ];
		NSString* tileSizeString = [attributeDict objectForKey: @"size" ];
		
		if(name != nil){
			ObjectContainer* object = [[ObjectContainer alloc] initMe];
			
			[object setName:name];
			[object setFile:file];
			[object setColour:colour];
			
			[object setLocX:[xString floatValue]];
			[object setLocY: [yString floatValue]];
			[object setLocZ: [zString floatValue]];
			
			if(tileSizeString != nil){
				double tileSize = [tileSizeString doubleValue];
				if(tileSize == 0){
					tileSize = 16;
				}
				//NSNumber* tileSizeNumber = [NSNumber numberWithDouble:tileSize ];
				//NSLog(@" tile %f ", tileSize );
				[object setSize:tileSize]; 
			}
			 
			//[groundTiles addObject:object];
			NSString* index = [[NSString alloc] initWithFormat:@"%fx%f" , [xString floatValue], [zString floatValue]];
			[groundTiles setValue:object forKey:index ];
		}
	}
	
	
	// enemies 
	//if([enemies count] == 0){ // for now we cant update
	if([elementName isEqualToString:@"enemy"] && [ levelName isEqualToString:readingLevel ] ){
		NSString* name = [attributeDict objectForKey: @"name" ];
		NSString* file = [attributeDict objectForKey: @"file" ];
		NSString* xString = [attributeDict objectForKey: @"xLoc" ];
		NSString* yString = [attributeDict objectForKey: @"yLoc" ];
		NSString* zString = [attributeDict objectForKey: @"zLoc" ];
		
		ObjectContainer* object = [[ObjectContainer alloc] init];
		
		NSString* n = [[NSString alloc] initWithString:name];
		[object setName: n];
		NSString* f = [[NSString alloc] initWithString:file];
		[object file: f];
		
		[object setLocX: [xString floatValue]];
		[object setLocY: [yString floatValue]];
        //NSLog(@"  set enemy height: %f ", [object locY]);
		[object setLocZ: [zString floatValue]];
		
		[object setRotX: [[attributeDict objectForKey: @"xRot" ] floatValue]];
		[object setRotY: [[attributeDict objectForKey: @"yRot" ] floatValue]];
		[object setRotZ: [[attributeDict objectForKey: @"zRot" ] floatValue]];
		
		
		[object setScaleX: [[attributeDict objectForKey: @"xScale" ] floatValue]];
		[object setScaleY: [[attributeDict objectForKey: @"yScale" ] floatValue]];
		[object setScaleZ: [[attributeDict objectForKey: @"zScale" ] floatValue]];
        
        [object setHits: [[attributeDict objectForKey: @"hits" ] intValue]];
        [object setDamage: [[attributeDict objectForKey: @"damage" ] intValue]];
        
		[enemies addObject:object];
		
		//NSLog(@" Add Enimy ");
		
	}
	//}
	
	
	if([elementName isEqualToString:@"dialog"] && [ levelName isEqualToString:readingLevel ] ){
		NSString* name = [attributeDict objectForKey: @"name" ];
		NSString* file = [attributeDict objectForKey: @"file" ];
        NSString* text = [attributeDict objectForKey: @"text" ];
		NSString* xString = [attributeDict objectForKey: @"xLoc" ];
		NSString* yString = [attributeDict objectForKey: @"yLoc" ];
		NSString* zString = [attributeDict objectForKey: @"zLoc" ];
		NSString* size = [attributeDict objectForKey: @"size" ];
		
		
		
		ObjectContainer* object = [[ObjectContainer alloc] init];
		
		NSString* n = [[NSString alloc] initWithString:name];
		[object setName: n];
		NSString* f = [[NSString alloc] initWithString:file];
		[object setFile: f];
		
		//NSNumber* xn = [[NSNumber alloc] initWithFloat: [xString floatValue]];
		[object setLocX: [xString floatValue]];
		//NSNumber* yn = [[NSNumber alloc] initWithFloat: [yString floatValue]];
		[object setLocY: [yString floatValue]];
		//NSNumber* zn = [[NSNumber alloc] initWithFloat: [zString floatValue]];
		[object setLocZ: [zString floatValue]];
		
		[object setText:text];
		
		if(size != nil){
			float dsize = [size floatValue];
			if(dsize == 0){
				dsize = 10;
			}
			//NSNumber* sizeNumber = [[NSNumber alloc] initWithDouble:dsize];
			//NSLog(@" sizeNumber %f ", sizeNumber );
			[object setSize:dsize]; 
		}
		
		[dialogs addObject:object];
		
		//NSLog(@" Add Dialog ");
		
	}
	
	
	if([elementName isEqualToString:@"collectible"] && [ levelName isEqualToString:readingLevel ] ){
		NSString* name = [attributeDict objectForKey: @"name" ];
		NSString* file = [attributeDict objectForKey: @"file" ];
		NSString* xString = [attributeDict objectForKey: @"xLoc" ];
		NSString* yString = [attributeDict objectForKey: @"yLoc" ];
		NSString* zString = [attributeDict objectForKey: @"zLoc" ];
		//NSString* size = [attributeDict objectForKey: @"size" ];
		
		
		ObjectContainer* object = [[ObjectContainer alloc] init];
		
		NSString* n = [[NSString alloc] initWithString:name];
		[object setName: n];
		NSString* f = [[NSString alloc] initWithString:file];
		[object setFile: f];
		
		//NSNumber* xn = [[NSNumber alloc] initWithFloat: [xString floatValue]];
		[object setLocX: [xString floatValue]];
		//NSNumber* yn = [[NSNumber alloc] initWithFloat: [yString floatValue]];
		[object setLocY: [yString floatValue]];
		//NSNumber* zn = [[NSNumber alloc] initWithFloat: [zString floatValue]];
		[object setLocZ: [zString floatValue]];
		
		[collectibles addObject:object];
        //[f_collectibles addObject:object];
        
		//NSLog(@" Add Collectible ");
	}
    
    
    
    if([elementName isEqualToString:@"health"] && [ levelName isEqualToString:readingLevel ] ){
		NSString* name = [attributeDict objectForKey: @"name" ];
		NSString* file = [attributeDict objectForKey: @"file" ];
		NSString* xString = [attributeDict objectForKey: @"xLoc" ];
		NSString* yString = [attributeDict objectForKey: @"yLoc" ];
		NSString* zString = [attributeDict objectForKey: @"zLoc" ];
		//NSString* size = [attributeDict objectForKey: @"size" ];
		
		
		ObjectContainer* object = [[ObjectContainer alloc] init];
		
		NSString* n = [[NSString alloc] initWithString:name];
		[object setName: n];
		NSString* f = [[NSString alloc] initWithString:file];
		[object setFile: f];
		
		//NSNumber* xn = [[NSNumber alloc] initWithFloat: [xString floatValue]];
		[object setLocX: [xString floatValue]];
		//NSNumber* yn = [[NSNumber alloc] initWithFloat: [yString floatValue]];
		[object setLocY: [yString floatValue]];
		//NSNumber* zn = [[NSNumber alloc] initWithFloat: [zString floatValue]];
		[object setLocZ: [zString floatValue]];
        
        [object setHealth: [[attributeDict objectForKey: @"health" ] intValue]];
        [object setCost: [[attributeDict objectForKey: @"cost" ] intValue]];
		
		[health addObject:object];
        //[f_collectibles addObject:object];
        
		//NSLog(@" Add Health ");
	}
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{       
    if([elementName isEqualToString:@"xml"] ){
        if(callback != nil){
            [callback updateHeightOnTerrain]; // avatar
            [callback setLighting];
        }
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
}



 - (void) setCallback:(NSObject*)c 
{
    [callback release];
    [c retain];
    callback = c;
}
 

// NAvigation control

void GLDrawEllipse3 (int segments, CGFloat width, CGFloat height, CGPoint center, bool filled)
{
	glTranslatef(center.x, center.y, 0.0);
	GLfloat vertices[segments*2];
	int count=0;
	for (GLfloat i = 0; i < 360.0f; i+=(360.0f/segments))
	{
		vertices[count++] = (cos(degreesToRadian3(i))*width);
		vertices[count++] = (sin(degreesToRadian3(i))*height);
	}
	glVertexPointer (2, GL_FLOAT , 0, vertices); 
	
	//glColor4f(1.0f,1.0f,1.0f,1.0f);
	
	//glDrawArrays ((filled) ? GL_TRIANGLE_FAN : GL_LINE_LOOP, 0, segments); // Fails with lighting ***
	
}

void GLDrawCircle3 (int circleSegments, CGFloat circleSize, CGPoint center, bool filled) 
{
	GLDrawEllipse3(circleSegments, circleSize, circleSize, center, filled);
}

float degreesToRadian3(float angle)
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


- (void)dealloc {
	[objects release];
	[objectsOld release];
	[enemies release];
	[dialogs release];
	[collectibles release];
    //[f_collectibles release];
	
	[completeLocationX release];
	
	[terrainTextureCache release];
    [saveGame release];
    
    //[enemyStun release];
	
	[super dealloc];
}


@end
