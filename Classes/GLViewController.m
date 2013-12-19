//
//  GLViewController.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "GLViewController.h"
#import "ConstantsAndMacros.h"
#import "OpenGLCommon.h"
#import "Piece.h"
#import "glu.h"
#import "Tools.h"
#import "Level.h"
#import "Texture2D.h"
#import <AVFoundation/AVFoundation.h>


@implementation GLViewController


//
// Setup 3d 
//
-(void)setupView:(GLView*)viewX  
{
    initTime = [NSDate timeIntervalSinceReferenceDate]; // trace startup time loadLevelTime
    NSLog(@"Starting game");
    
    //if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    //{
    //    [self setNeedsStatusBarAppearanceUpdate];
    //}
    
    [viewX retain];
    [self.view release];
	self.view = viewX;
	
	pieces = [[NSMutableArray alloc] init ]; 
	pieceLifted = 0;
	
	levels = [[NSMutableArray alloc] init ];
	currentLevelIndex = -1;
	
	const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0; 
	GLfloat size; 
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION); 
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0); 
	CGRect rect = self.view.bounds; 
    
    
    
    bool iPad = false;
    if(rect.size.width >= 768){
        iPad = true;
    }
    
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / 
			   (rect.size.width / rect.size.height), zNear, zFar); 
	
    rect = self.view.bounds; 
    
    glViewport(0, 0, rect.size.width, rect.size.height);
    
	glMatrixMode(GL_MODELVIEW);
    
    //
    // Lighting
    //
    [self setLighting];
    
    //sound = [[Sound alloc] init];
    
    [self.view setMultipleTouchEnabled:TRUE];
	
	[self load:((GLView *)self.view)];  // Cast, it thinks view is a UIView, don't know why.
}


/**
 * setLighting
 *
 *
 */
- (void) setLighting {
    //glEnable(GL_LIGHTING);  // breaks main menu texture
    
    float ambient = 0.65;
    if(levelLoader != nil){
        ambient = [levelLoader ambientLight];
        ambient = ambient * 0.65;
    }
    
    //ambient = 0.30;
    
    // Turn the first light on
    glEnable(GL_LIGHT0);
    
    // Define the ambient component of the first light
    const GLfloat light0Ambient[] = {ambient, ambient, ambient, 1.0}; //{0.7, 0.7, 0.7, 1.0}; // define ambient light ***
    glLightfv(GL_LIGHT0, GL_AMBIENT, light0Ambient);
    
    // Define the diffuse component of the first light
    const GLfloat light0Diffuse[] = {0.6, 0.6, 0.6, 1.0};
    glLightfv(GL_LIGHT0, GL_DIFFUSE, light0Diffuse);
    
    // Define the specular component and shininess of the first light
    const GLfloat light0Specular[] = {0.7, 0.7, 0.7, 1.0};
    //const GLfloat light0Shininess = 0.4;
    glLightfv(GL_LIGHT0, GL_SPECULAR, light0Specular);
    
    // Define the position of the first light
    const GLfloat light0Position[] = {0.0, 15.0, 0.0, 0.0}; 
    glLightfv(GL_LIGHT0, GL_POSITION, light0Position); 
    
    // Define a direction vector for the light, this one points right down the Z axis
    const GLfloat light0Direction[] = {0.0, -1.0, 0.0};
    glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, light0Direction);
    
    // Define a cutoff angle. This defines a 90° field of vision, since the cutoff
    // is number of degrees to each side of an imaginary line drawn from the light's
    // position along the vector supplied in GL_SPOT_DIRECTION above
    glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 45.0);
    
    
    //
    
    //glEnable(GL_LIGHT1);
    const GLfloat light1Ambient[] = {0, 0, 0, 1.0}; 
    glLightfv(GL_LIGHT1, GL_AMBIENT, light1Ambient);
    const GLfloat light1Diffuse[] = {1, 1, 1, 1.0};
    glLightfv(GL_LIGHT1, GL_DIFFUSE, light1Diffuse);
    const GLfloat light1Specular[] = {1, 1, 1, 1.0};
    glLightfv(GL_LIGHT1, GL_SPECULAR, light1Specular);
    const GLfloat light1Position[] = {5, 1.0, 5, /*point*/1.0};  
    glLightfv(GL_LIGHT1, GL_POSITION, light1Position);
    //const GLfloat light1Direction[] = {5, -1.0, 5};
    //glLightfv(GL_LIGHT1, GL_SPOT_DIRECTION, light1Direction);
    //glLightf(GL_LIGHT1, GL_SPOT_CUTOFF, 45.0);
    glLightf(GL_LIGHT1, GL_QUADRATIC_ATTENUATION, 0.025); // GL_CONSTANT_ATTENUATION GL_LINEAR_ATTENUATION GL_QUADRATIC_ATTENUATION
    
    
    // Log load time
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    double loadTime = now - loadLevelTime;
    NSLog(@"Load Time: %f ", loadTime);
}


//
// Load world from xml and textures 
//
-(void)load:(GLView*)view {
	
    loadLevelTime = [NSDate timeIntervalSinceReferenceDate]; // trace time 
    
    CGRect rect = self.view.bounds; 
    bool iPad = false;
    if(rect.size.width == 1216){
        iPad = true;
    }
	
	reachedLevel = 0;
	//NSNumber* savedLevel = [[NSUserDefaults standardUserDefaults] stringForKey:@"reachedLevel"];
	//if(savedLevel != nil){
	//	reachedLevel = [savedLevel intValue];
	//}
	
	if(currentLevelIndex < 0){
		currentLevelIndex = reachedLevel;
	}
	
	//NSLog(@" Load at level: %d ", currentLevelIndex );
	
	// load XML file
	
	[levels removeAllObjects];
	
	//if([levels count] == 0 ){
	NSString *nsPath = [[NSBundle mainBundle] pathForResource:@"levels" ofType:@"xml"];  
	//NSString *fileText = [NSString stringWithContentsOfFile:path];
	NSData *nsData = [NSData dataWithContentsOfFile: nsPath ];
	NSXMLParser *xmlParser = [[NSXMLParser alloc]  initWithData:nsData ];
	//XMLParser *parser = [[XMLParser alloc] initXMLParser];
	[xmlParser setDelegate:self];
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];
	[xmlParser parse];
	[xmlParser release];
	//}
	
	if([levels count] <= currentLevelIndex){
		currentLevelIndex = ([levels count] - 1);
	}
	//NSLog(@" going to load level %d ", reachedLevel);
	currentLevel = [levels objectAtIndex:currentLevelIndex];
	//NSLog(@" level %d   ", reachedLevel);
	
	
	//NSLog(@"??? %@ " , currentLevel  );
	//NSLog(@"??? %@ " , [currentLevel getImageName]  );
	
	
	
	glLoadIdentity(); 
	
	
	glGetIntegerv( GL_VIEWPORT, __viewport );
	glGetFloatv( GL_MODELVIEW_MATRIX, __modelview );
	glGetFloatv( GL_PROJECTION_MATRIX, __projection );
	
	/*
	[self initalizePieces:view, 
	 [[currentLevel getPiecesWide] intValue], 
	 [[currentLevel getPiecesHigh] intValue]];
	*/
	
	s = [Sprites alloc];
	[s init];
	hud = [HUD alloc];
	[hud initHUD:[currentLevel getTitle]];   // What is Level? ***
	
	controls = [[GameControls alloc] init];
    [controls setScreenX:rect.size.width Y:rect.size.height];
	//[controls setVisible:true];
	[controls setVisible:false];
	
	glGenTextures(10, textures);
	//[self loadTexture:@"grass256.png" intoLocation:textures[0]];
	
	levelLoader = [[LevelLoader alloc] init];
    [levelLoader setCallback:self];
	
	
	// for now just load a level
	//[levelLoader preLoadLevel:@"intro" ];
	[levelLoader preLoadLevel:@"Main Menu" ];
    [hud setLevelString:[levelLoader getLevelLoaded]];
	
	
	menu = [[Menu alloc] init];
	[menu load:@"mainmenu"];
	
	// 
	eye[0] = -5.0;
	eye[1] = 1.5;
	eye[2] = 2.0;
	
	center[0] = -4.0;
	center[1] = 1.5;
	center[2] = -3.0;
	
	//center[0] = -4.0;
	//center[1] = 1.5;
	//center[2] = 3.0;
	/*
	eye[0] = [[levelLoader getInitalLocationX] floatValue];
	eye[1] = [[levelLoader getInitalLocationY] floatValue];
	eye[2] = [[levelLoader getInitalLocationZ] floatValue];
	
	center[0] = [[levelLoader getInitalLocationX] floatValue];
	center[1] = [[levelLoader getInitalLocationY] floatValue];
	center[2] = [[levelLoader getInitalLocationZ] floatValue];
	*/
	// [levelLoader  load start location
	
	up[0] = 0;
	up[1] = 1;
	up[2] = 0;
	
	// Avatar
	avatarLocation = [[ObjectContainer alloc] init];
	[avatarLocation setLocX:0];
	[avatarLocation setLocY:0];
	[avatarLocation setLocZ:0];
	 
	thirdPerson = 1;
	thirdPersonBack = 2.3;
	thirdPersonTilt = -2.5;  // -3.0
	thirdPersonHeight = 15;
    
    if(iPad){
       // thirdPersonHeight = 30;
    }
	
	//thirdPersonBack = 2.3;
	//thirdPersonTilt = -0.4;
	//thirdPersonHeight = 4;
	
	[self updateHeightOnTerrain];
	
	
	avatarLocY =  - thirdPersonHeight;
	avatar = [[BlenderObject alloc] init];
	NSError *error = [avatar loadBlenderObject:@"female"];
	if (error != nil) {
		NSLog(@"Opps: %@", [error localizedDescription]);
	}
    
    avatar2 = [[Avatar alloc] init];
	[avatar2 setSound:[levelLoader sound]];
    
	currentMovement = MTNone;
	thumbPadTouched = 0;
	
	//network = [[Network alloc] init];
	//[network setCallback:levelLoader ]; // reloadLevel:XMLData
	//[network startMyThread];
	//[network send];
	
	fps = 0;
	lastFps = 0;
	lastFpsSample = 0;
    lastFrameTime = 0;
    frameRate = 0;
    frameRateScale = 1;
	
	health = 100;
	points = 0;
	
	bullets = [[NSMutableArray alloc] init];
	[levelLoader setBullets:bullets];
	
	swipeTilt = 0;
	swipeTurn = 0;
    swipeMove = 0;
	swipeTurnMotion = 0;
    //moveMomentum = 0;
    moveMomentumSpeed = 0;
    turnMomentumSpeed = 0;
    
	avatarTerrainHeight = 0;
    jumpHeight = 0;
    jumpingStage = 0;
    jumpUp = FALSE;
    
	paused = FALSE;
    dead = FALSE;
    
    leftHand = true;
    //saveGame = [[SaveGame alloc] init];
    
    
    //NSLog(@" Loaded ");
}



/**
 * drawView
 *
 * Description
 */
- (void)drawView:(GLView*)view;
{
	// FPS
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    //NSLog(@" tome %f ", now);
	if(lastFpsSample < now - 1){
		//NSLog(@" FPS: %d ", fps);
		lastFps = fps;
		fps = 0;
		lastFpsSample = now;
		
		[hud setFps: [NSNumber numberWithFloat:lastFps ]];
		//[hud setHealth: [NSNumber numberWithInt: health ]];
		//[hud setPoints:points];
        [levelLoader setFps: lastFps];
	}
	fps++; 
    
    bool iPad = false;
    if(self.view.bounds.size.width == 1216){
        iPad = true;
    }
    
    // 
    // Frame rate used to calculate movement and turn rates.
    //
    frameRate = (double)now - (double)lastFrameTime;
    lastFrameTime = (double)now;
    frameRateScale =  1 - (( 0.0166666666 - frameRate ) * 60);
    if(frameRateScale > 10){frameRateScale = 10;}
    //NSLog(@" Frame rate: %f    %f   %f " , frameRate, now , lastFrameTime);
    [levelLoader setFrameRateScale: frameRateScale];
    
    
    // jump
    if(jumpingStage > 0 || jumpHeight >= 0.3){
        jumpingStage  -=  0.1 * frameRateScale;
        if(jumpUp && jumpingStage <= 0.1){
            jumpUp = FALSE;
        }
        if(jumpUp){
            jumpHeight += 0.3 * frameRateScale;
        } else {
            jumpHeight -= 0.3 * frameRateScale;
        }
    } else if(jumpHeight > 0){
        jumpHeight -= 0.01;
    } else if(jumpHeight < 0){
        jumpHeight += 0.01;
    } 
	
	/* 
	GLfloat vector[3];
    vector[0] = center[0] - eye[0];
    vector[1] = center[1] - eye[1];
    vector[2] = center[2] - eye[2];
	if(thirdPerson){
		eye[0] += vector[0] * -thirdPersonBack;
		eye[2] += vector[2] * -thirdPersonBack;
		center[0] += vector[0] * -thirdPersonBack;
		center[2] += vector[2] * -thirdPersonBack;
	}
	*/
	
	// glRotatef(  ((-cameraTiltZSmooth) * 180.0 / M_PI)  , 0.0, 0.0, 1.0); // Tilt   cameraTiltZSmooth
	
	[self handleTouches];
	//gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], 0.0, 1.0, 0.0); 
	
	
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	/*
	if([levelLoader getLevelLoaded] != nil && ![[levelLoader getLevelLoaded] isEqualToString:@"Main Menu"]){
		[self drawPieces: view, 
		 [[currentLevel getPiecesWide] intValue], 
		 [[currentLevel getPiecesHigh] intValue]];
	}
	*/ 
	//[self drawWorld:view ];
	
	
	//
	// Display the navigation control
	//
	//[controls drawControls:view];
	
	//[s drawSprites:view];
	
	
	
	// world box
	float cameraTiltZSmooth = 1.6;
	
	//GLfloat xOffset = eye[0];
	//GLfloat yOffset = eye[1];
	//GLfloat zOffset = eye[2];
	//NSLog(@" %f  %f  %f ", xOffset, eye[1], zOffset);
	//NSNumber* x = [NSNumber numberWithFloat:xOffset];
	//NSNumber* y = [NSNumber numberWithFloat:yOffset];
	//NSNumber* z = [NSNumber numberWithFloat:zOffset];
	
	//glLoadIdentity();
	
	//glRotatef(  ((-cameraTiltZSmooth) * 180.0 / M_PI)  , 0.0, 0.0, 1.0); // Tilt 
	//glRotatef(  (M_PI/2)  , 0.0, 1.0, 0.0); // rotate for up[]
	
	//gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], up[0], up[1], up[2]);// 
	//[levelLoader setPlayerX:x playerY:y playerZ:z]; // wrong
	 
	
	ObjectContainer * avatarLoc = [self getAvatarLocation];
	//NSLog(@"  avatar:  %f   %f ", [avatarLoc locX], [avatarLoc locZ]);
	[levelLoader setPlayerX:[avatarLoc locX] playerY:[avatarLoc locY] playerZ:[avatarLoc locZ]];
	
    ObjectContainer * cameraLoc = [self getCameraLocation];
    [levelLoader setCameraX:[cameraLoc locX]  y:[cameraLoc locY] z:[cameraLoc locZ] ];
    //[cameraLoc release];
    
	//[levelLoader getTerrainHeightX:x  z:z ];
	//NSLog(@"new Height: %f ", newHeight);
	//NSLog(@" x z: %f %f ", xOffset, zOffset);
	
	[levelLoader drawWorldBox:[avatarLoc locX] setZ:[avatarLoc locZ]];
	//[levelLoader displayLoading:view]; // doesn't work, using hud to display
	[levelLoader drawWorldObjects:view];
	
    
    
    
	//[avatarLoc release];
	
	// send location to server
	//[network setAvatarLocationX:x y:y z:z]; // is actually camera location.
	
	//NSLog(@" loc A %f %f %f" , xOffset, yOffset, zOffset);
	
	//
	// Avatar
	//
	//[self drawAvatar:view];
    float avatarX = 0;
    float avatarY = 0;
    float avatarZ = 0;
	if([levelLoader getLevelLoaded] != nil && ![[levelLoader getLevelLoaded] isEqualToString:@"Main Menu"]){
		glLoadIdentity();
		glRotatef(((-cameraTiltZSmooth) * 180.0 / M_PI)  , 0.0, 0.0, 1.0); // Tilt 
		
		//glRotatef(  (M_PI/2)  , 1.0, 0.0, 0.0); // rotate for up[] (M_PI/2)
		
		gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], up[0], up[1], up[2]);// 
		[self moveForward];
		GLfloat xOffset = eye[0];
		GLfloat yOffset = eye[1];
		GLfloat zOffset = eye[2];
		[levelLoader setAvatarX:xOffset playerY:yOffset playerZ:zOffset];
        
        // in front (scene center)
        {
            [self moveForwardBy:2.5];
            GLfloat xFront = eye[0]; GLfloat yFront = eye[1]; GLfloat zFront = eye[2];
            [levelLoader setInFrontOfAvatarX:xFront locY:yFront locZ:zFront];
            [self moveBackBy:2.5];
        }
        
        //NSLog(@" loc   B %f %f %f" , xOffset, yOffset, zOffset);
        //NSLog(@" front B %f %f %f" , xFront, yFront, zFront);
		
		//float yOff = -avatarLocY - avatarTerrainHeight;
		float yOff = thirdPersonHeight - jumpHeight - 0.1;// - avatarTerrainHeight;
		glTranslatef(xOffset, yOffset - yOff, zOffset); // avatarLocY
		
		//NSLog(@" loc B %f %f %f" , xOffset, yOffset, zOffset);
		
		//glTranslatef( -1 , 0, 0);
		glRotatef(-90, 1.0, 0.0, 0.0);
		float orientAvatarY = [self getAngle];
		// for fun turn player Y while turning.
		if(currentMovement != MTNone && [controls thumbPad:thumbPadTouchX y:thumbPadTouchY] == 1){
			int padSize = 120;
            //int padOffset = 8;
            if(touchY < padSize + 10){
                GLfloat turnControlPosition = ((padSize+10) - (padSize/2) ) - touchY ;
                GLfloat scaledSpeed = (14.5 * ( turnControlPosition / (padSize/2) ) );
                orientAvatarY += scaledSpeed;
            }
		}
        //NSLog(@"currentMovement  %d ", currentMovement);
        
        // Turn avatar while turning direction. Exaduration.
        if( swipeTurnMotion != 0 ){ // currentMovement != MTNone &&
            //NSLog(@"swipeTurnMotion  %d ", swipeTurnMotion);
            //GLfloat turnControlPosition = ((padSize+10) - (padSize/2) ) - touchY ;
            //GLfloat scaledSpeed = (14.5 * ( turnControlPosition / (padSize/2) ) );
            
            float turn = (swipeTurnMotion / 2);
            
            orientAvatarY += turn;
        }
        
		glRotatef(orientAvatarY, 0.0, 0.0, 1.0); // orient player to view direction
		
        
        if([levelLoader loading] == 0){ // don't draw when loading
            
            // running avatar
            if(dead){
                glRotatef( -90, 1.0, 0.0, 0.0); // orient
            }
            
            float walkingSpeed = moveMomentumSpeed / 20; 
            [avatar2 draw:frameRateScale  isWalking:walkingSpeed];
            
            
            //glRotatef( -90 , 1.0, 0.0, 0.0); // orient
            //glScalef(.2, .2, .45);
            //[avatar draw]; // Replace with object deligate    
            
		}
            
		// send location to server
		avatarX = xOffset; // [NSNumber numberWithFloat:xOffset];
		avatarY = (yOffset - thirdPersonHeight + 3); // [NSNumber numberWithFloat:(yOffset - thirdPersonHeight + 3)];
		avatarZ = zOffset; //[NSNumber numberWithFloat:zOffset];
		
		//[network setAvatarLocationX:avatarX y:avatarY z:avatarZ level: [levelLoader getLevelLoaded] angle:orientAvatarY ];
        //NSLog(@" loc %f   %f  %f  ", avatarX, avatarY, avatarZ);
		
		// test
		//[levelLoader getTerrainHeightX:avatarX  z:avatarZ];
		[self moveBack];
	}
	
	//
	// bullets
	//
    if([bullets count] > 0){
        
        glEnable(GL_LIGHT1); // bullet light
        
        glPushMatrix();	// preserve state of matrix
        glLoadIdentity();
        glRotatef(((-cameraTiltZSmooth) * 180.0 / M_PI)  , 0.0, 0.0, 1.0); // Tilt 
        gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], up[0], up[1], up[2]);
        NSEnumerator* bulletIterator = [bullets objectEnumerator];
        Bullet* bullet;
        NSMutableArray *discardedItems = [NSMutableArray array];
        while((bullet = [bulletIterator nextObject]))
        {
            
            const GLfloat light1Position[] = { [bullet locX], [bullet locY], [bullet locZ], /*point*/1.0}; 
            glLightfv(GL_LIGHT1, GL_POSITION, light1Position);
            
            if(!paused){
                [bullet move: frameRateScale];
            }
            [bullet draw:view];
            if([bullet active] == 0){
                [discardedItems addObject:bullet];
            }
        }
        [bullets removeObjectsInArray:discardedItems];
        glPopMatrix();	// Return matrix to origional state	 
    } else {
        glDisable(GL_LIGHT1);
    }
    
    //
    // Direction to finish
    //
    float finishAngle = 0;
    if(levelLoader != nil){
        float endX = [levelLoader completeLocationX];
        float endZ = [levelLoader completeLocationZ];
        // avatarX
        // avatarZ
        // orientAvatarY
        
        ObjectContainer * o = [[ObjectContainer alloc] init];
        [o setLocX:avatarX];
        [o setLocZ:avatarZ];
        [o setRotY:[self getAngle]]; 
        
        finishAngle = [o angleToPoint:endX y:endZ];
        //NSLog(@"finishAngle %f ", finishAngle);
        [hud setDirection:finishAngle];
    }
    
    
	
	// Last
	if([levelLoader getLevelLoaded] != nil && 
		![[levelLoader getLevelLoaded] isEqualToString:@"Main Menu"] &&
		!paused &&
       [levelLoader loading] == 0){ 
		
        int collectedItems = [levelLoader collectedItems];
        [hud setPoints:collectedItems];
        int healthPoints = [levelLoader healthPoints];
        [hud setHealth:healthPoints];
        
        // Set thumb pad move highlight if control is maxed out
        if(leftSide && ( swipeMove == 20 || swipeMove == -20 || swipeTurnMotion == 40 || swipeTurnMotion == -40)){
            [hud setLeftTouch:leftTouchX y:leftTouchY]; // DEV
        } else if(!leftSide && (swipeMove == 20 || swipeMove == -20 || swipeTurnMotion == 40 || swipeTurnMotion == -40)) {
            [hud setLeftTouch:rightTouchX y:rightTouchY];
        } else {
            [hud setLeftTouch:-1 y:-1];
        }
        
		[hud drawHUD:view];
	}
	if(paused){
		[hud drawInGameMenu:view];
	}
	//[self drawUI:view]; // Puzzle UI
    if( [levelLoader loading] > 0 && 
            [levelLoader getLevelLoaded] != nil && 
            ![[levelLoader getLevelLoaded] isEqualToString:@"Main Menu"]){
        [hud drawLoading:view]; 
        
    }
    
    int h = [levelLoader healthPoints];
    if(h == 0){
        dead = true;
    } else {
        dead = false;
    }
    if(dead && [levelLoader loading] == 0){
        [hud drawDeadScreen:view];
    }
    
	//
	// Display Menu Items
	//
	[menu displayMenu:view];
	
	
	//
	// check for level complete
	//
	if(
        [levelLoader levelCompleted:avatarX
								  y:avatarY 
								  z:avatarZ] == true){
		NSLog(@" Level complete, loading next level: %@ ", [levelLoader completeLoad]);
		
		[levelLoader preLoadLevel: [levelLoader completeLoad]];
        [hud setLevelString:[levelLoader getLevelLoaded]];
	}
	
	//
    // move player on level load
    //
    ObjectContainer* resetLocation = [levelLoader resetPlayerLocation];
    if(resetLocation != nil  ){
        
        [self setAvatarLocation:resetLocation];      
        
        [levelLoader setResetPlayerLocation:nil];
        
        
        // Set avatar angle
        float currAngle = [self getAngle];
        float newAngle = [resetLocation rotY];   // BAD ACCESS
        float angleDelta = newAngle - currAngle;
        if(angleDelta < 0){
            angleDelta += 360;
        }
        angleDelta = angleDelta * (M_PI/180);
        [self turnAvatar: angleDelta];
    }
    
	
	// Spin main menu
	if( [levelLoader getLevelLoaded] != nil &&  [[levelLoader getLevelLoaded] isEqualToString:@"Main Menu" ] ){
		[self turn: [NSNumber numberWithFloat: (-0.01 * frameRateScale)] ];
	}
	
	/*
	if(thirdPerson){ 
		eye[0] += vector[0] * thirdPersonBack;
		eye[2] += vector[2] * thirdPersonBack;
		center[0] += vector[0] * thirdPersonBack;
		center[2] += vector[2] * thirdPersonBack;
	}
	 */
}
 


/*
-(void)drawAvatar:(GLView*)view;
{
	int dotSize = 3;
	glPointSize(dotSize);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glLoadIdentity();
	glTranslatef( 0.0, 0, -0.5); 
	
    glColor4f(1.0f,1.0f,1.0f,1.0f);
	
	Vertex3D sprites[1];
	CGPoint vertices2[1];
		vertices2[0] = CGPointMake(0, 0);
		Vertex3D v = sprites[0];
		sprites[0] = v;
	
	
	glVertexPointer(3, GL_FLOAT, 0, sprites);
	glDrawArrays(GL_POINTS, 0, 100);
	
	
	//glEnableClientState(GL_VERTEX_ARRAY);
	//glVertexPointer(2, GL_FLOAT, 0, vertcies);
	//glDrawArrays(GL_LINE_STRIP, 0, 2);
	
	//glDisableClientState(GL_VERTEX_ARRAY);
}
*/






/**
 * getCameraLocation
 * 
 * Description: get location of camera
 */
-(ObjectContainer *)getCameraLocation {
	ObjectContainer * avatarObj = [[ObjectContainer alloc] init];
    
	glLoadIdentity();
	float cameraTiltZSmooth = 1.6;
	glRotatef(((-cameraTiltZSmooth) * 180.0 / M_PI), 0.0, 0.0, 1.0); // Tilt 
	gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], up[0], up[1], up[2]);// 
	//[self moveForward];
	float xOffset = eye[0];
	float yOffset = eye[1];
	float zOffset = eye[2];
	
	//NSNumber* avatarX = [NSNumber numberWithFloat:xOffset];
	//NSNumber* avatarY = [NSNumber numberWithFloat:yOffset];
	//NSNumber* avatarZ = [NSNumber numberWithFloat:zOffset];
	
	[avatarObj setLocX:xOffset];
	[avatarObj setLocY:yOffset];
	[avatarObj setLocZ:zOffset];
	
	//[self moveBack];
	//glLoadIdentity();
	return avatarObj;
}



/**
 * getAvatarLocation
 * 
 * Description: get location of avatar
 */
-(ObjectContainer *)getAvatarLocation {
	ObjectContainer * avatarObj = [[ObjectContainer alloc] init];

	glLoadIdentity();
	float cameraTiltZSmooth = 1.6;
	glRotatef(((-cameraTiltZSmooth) * 180.0 / M_PI), 0.0, 0.0, 1.0); // Tilt 
	gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], up[0], up[1], up[2]);// 
	[self moveForward];
	float xOffset = eye[0];
	float yOffset = eye[1];
	float zOffset = eye[2];
	
	//NSNumber* avatarX = [NSNumber numberWithFloat:xOffset];
	//NSNumber* avatarY = [NSNumber numberWithFloat:yOffset];
	//NSNumber* avatarZ = [NSNumber numberWithFloat:zOffset];
	
	[avatarObj setLocX:xOffset];
	[avatarObj setLocY:yOffset];
	[avatarObj setLocZ:zOffset];
	
	[self moveBack];
	//glLoadIdentity();
	return avatarObj;
}


/**
 * setAvatarLocation
 *
 * Description: Set avatar location x,z. Not Y.
 */
-(void)setAvatarLocation:(ObjectContainer*)loc {
    
    //if(loc == nil){
    //    NSLog(@"setAvatarLocation loc is nil");
    //}
    
    float xDelta = [loc locX] - center[0];   
    //float yDelta = [loc locY] - center[1];
    float zDelta = [loc locZ] - center[2];
    
    eye[0] += xDelta;
	//eye[1] += yDelta;
	eye[2] += zDelta;
	
	center[0] += xDelta;
	//center[1] += yDelta;
	center[2] += zDelta;
}






//
// Update height on terrain (memory leak)
//
- (void)updateHeightOnTerrain
{
	ObjectContainer * avatarLoc = [self getAvatarLocation];
	//float x = [[loc getX] floatValue];
	//float z = [[loc getZ] floatValue];
	
	//
	float height = [levelLoader getTerrainHeightX:[avatarLoc locX]  z:[avatarLoc locZ]];
	
    //NSLog(@"height on terrain: %f ", height);
    
	if(height < -900){
		return;
	}
	
	avatarTerrainHeight = height;
	//avatarLocY = -1.6 + [height floatValue];
	// move camera up/down
	eye[1] =  height + thirdPersonHeight;
	center[1] = height + thirdPersonHeight - (1.5 - thirdPersonTilt);
	
	//[loc release];
}




//
// 
//
- (void)moveForward
{
	GLfloat vector[3];
	vector[0] = center[0] - eye[0];
	vector[1] = center[1] - eye[1];
	vector[2] = center[2] - eye[2];
	eye[0] += vector[0] * thirdPersonBack;
	eye[2] += vector[2] * thirdPersonBack;
	center[0] += vector[0] * thirdPersonBack;
	center[2] += vector[2] * thirdPersonBack;
	//center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
	//center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
}

- (void)moveBack
{
	GLfloat vector[3];
	vector[0] = center[0] - eye[0];
	vector[1] = center[1] - eye[1];
	vector[2] = center[2] - eye[2];
	eye[0] += vector[0] * -thirdPersonBack;
	eye[2] += vector[2] * -thirdPersonBack;
	center[0] += vector[0] * -thirdPersonBack;
	center[2] += vector[2] * -thirdPersonBack;
	//center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
	//center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
}


- (void)moveForwardBy:(float)d
{
	GLfloat vector[3];
	vector[0] = center[0] - eye[0];
	vector[1] = center[1] - eye[1];
	vector[2] = center[2] - eye[2];
	eye[0] += vector[0] * d;
	eye[2] += vector[2] * d;
	center[0] += vector[0] * d;
	center[2] += vector[2] * d;
	//center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
	//center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
}

- (void)moveBackBy:(float)d
{
	GLfloat vector[3];
	vector[0] = center[0] - eye[0];
	vector[1] = center[1] - eye[1];
	vector[2] = center[2] - eye[2];
	eye[0] += vector[0] * -d;
	eye[2] += vector[2] * -d;
	center[0] += vector[0] * -d;
	center[2] += vector[2] * -d;
	//center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
	//center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
}


// Main menu
- (void)turn:(NSNumber*)a
{
	[a retain];
	float angle = [a floatValue];
	GLfloat vector[3];
    
    vector[0] = center[0] - eye[0];
    vector[1] = center[1] - eye[1];
    vector[2] = center[2] - eye[2];
	
	// turn
	center[0] = eye[0] + cos(-angle)*vector[0] - sin(-angle)*vector[2];
	center[2] = eye[2] + sin(-angle)*vector[0] + cos(-angle)*vector[2];
	vector[0] = center[0] - eye[0];
	vector[1] = center[1] - eye[1];
	vector[2] = center[2] - eye[2];
	[a release];
}

- (void)turnAvatar:(float)angle
{
	//[angle retain];
	GLfloat vector[3];
    vector[0] = center[0] - eye[0];
    vector[1] = center[1] - eye[1];
    vector[2] = center[2] - eye[2];
	float scaledTrun = angle; //[angle floatValue];
	if(thirdPerson){ 
		eye[0] += vector[0] * thirdPersonBack;
		eye[2] += vector[2] * thirdPersonBack;
		center[0] += vector[0] * thirdPersonBack;
		center[2] += vector[2] * thirdPersonBack;
		//center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
		//center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
		vector[0] = center[0] - eye[0];
		vector[1] = center[1] - eye[1];
		vector[2] = center[2] - eye[2];
	}
	
	// forward
	//eye[0] += vector[0] * scaledSpeed;
	//eye[2] += vector[2] * scaledSpeed;
	//center[0] += vector[0] * scaledSpeed;
	//center[2] += vector[2] * scaledSpeed;
	// turn
	center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
	center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
	vector[0] = center[0] - eye[0];
	vector[1] = center[1] - eye[1];
	vector[2] = center[2] - eye[2];
	
	if(thirdPerson){ 
		eye[0] += vector[0] * -thirdPersonBack;
		eye[2] += vector[2] * -thirdPersonBack;
		center[0] += vector[0] * -thirdPersonBack;
		center[2] += vector[2] * -thirdPersonBack;
		//center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
		//center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
		vector[0] = center[0] - eye[0];
		vector[1] = center[1] - eye[1];
		vector[2] = center[2] - eye[2];
	}
	//[angle release];
}

// should go in avatar class
-(float) getAngle
{
	float angle = atan2(center[2] - eye[2], center[0] - eye[0]);// * 180 / M_PI;
	if(angle < 0){
		angle = (M_PI *2) + angle;
	}
	angle = ((M_PI*2) - angle ); // invert
	angle -= (M_PI/2);
	
	while(angle > (M_PI*2)){
		angle -= (M_PI*2);
	}
	while(angle < 0){
		angle += (M_PI*2);
	}
	angle = angle * 180 / M_PI;
	return angle;
}


-(float) getAngleR
{
	float angle = atan2(center[2] - eye[2], center[0] - eye[0]);// * 180 / M_PI;
	if(angle < 0){
		angle = (M_PI *2) + angle;
	}
//	angle = ((M_PI*2) - angle ); // invert
	//angle -= (M_PI/2);
	
	angle += (M_PI/2);
	
	while(angle > (M_PI*2)){
		angle -= (M_PI*2);
	}
	while(angle < 0){
		angle += (M_PI*2);
	}
	//angle = angle * 180 / M_PI;
	return angle;
}



//
// Touch handler
//
- (void)handleTouches {
    
    if (currentMovement == MTNone) {
        // We're going nowhere, nothing to do here
        //return;
    }
    
    // Don't move in main menu
	if([levelLoader getLevelLoaded] != nil && [[levelLoader getLevelLoaded] isEqualToString:@"Main Menu"]){
        return;
	}
    
    bool isIPad = false;
    UIDevice* thisDevice = [UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        isIPad = true;
    }
    else
    {
        isIPad = false; // iPhone
    }
    
    GLfloat vector[3];
    vector[0] = center[0] - eye[0];
    vector[1] = center[1] - eye[1];
    vector[2] = center[2] - eye[2];
	
    
    float move = (float)swipeMove;
    float turn = (float)swipeTurnMotion;
    
	//
    // Momentum
    //
    if(((int)moveMomentumSpeed) != ((int)swipeMove)){ 
        //moveMomentum--;
        //swipeMove = moveMomentumSpeed;
        if(moveMomentumSpeed > move){
            moveMomentumSpeed -= 0.3 * frameRateScale;
        } else if(moveMomentumSpeed < move) {
            moveMomentumSpeed += 0.3 * frameRateScale;
        }
        move = moveMomentumSpeed;
    }  
    if(((int)turnMomentumSpeed) != ((int)swipeTurn)){  // && (int)turnMomentumSpeed != 0 && swipeTurn != 0
        //NSLog(@"   turnMomentumSpeed: %f   %f ", turnMomentumSpeed, turn);
        if(turnMomentumSpeed > turn + 0){
            turnMomentumSpeed -= 0.45 * frameRateScale;
        } else if(turnMomentumSpeed < turn - 0) {
            turnMomentumSpeed += 0.45 * frameRateScale;
        }
        turn = turnMomentumSpeed;
    } 
    
    if(isIPad){
        turn = turn * 0.80;
    }
    
    //NSLog(@"swipeMove: %d ", swipeMove);
    //NSLog(@"turn: %f  %d   swipeTurn  %d ", turn, swipeTurnMotion, swipeTurn);
    
    
	//int inBounds = 0;
	//if(eye[0] < 80 && eye[0] > -50 && eye[2] < 60 && eye[2] > -70){
	//	inBounds = 1;
	//}
	
	int padOffset = 8;
	int padSize = 120;
	//GLfloat forwardControlPosition = (480 - (padSize/2) ) - touchY ;
	//GLfloat turnControlPosition = (padSize/2) - touchX + padOffset;
	GLfloat forwardControlPosition = (padSize/2) - thumbPadTouchX + padOffset;
    // If moved above thumbpad, still move
    if(thumbPadTouchX > padSize + padOffset){
        forwardControlPosition = -(padSize/2);
    }
	
    
	GLfloat turnControlPosition = ((padSize+10) - (padSize/2) ) - thumbPadTouchY;
    if(thumbPadTouchY > padSize){
        turnControlPosition = ((padSize+10) - (padSize/2) ) - padSize;
    }
	
    bool collisionFront = false;
    bool collisionBack = false;
    bool collisionLeft = false;
    bool collisionRight = false;
    if([levelLoader avatarCollision]){
        float collisionAngle = [levelLoader avatarCollisionAngle:[self getAngle]]; 
        //NSLog(@"collisionAngle: %f ", collisionAngle);
        if(collisionAngle > 270 - 90 && collisionAngle < 270 + 90){
            collisionFront = true;
        } else {
            collisionBack = true;
        }
        
        // 90 - 200 left collision
        // right <50   250>
        if(collisionAngle > 90 && collisionAngle < 200){
            collisionLeft = true;
        } else if ( (collisionAngle > 0 && collisionAngle < 40) || 
                   (collisionAngle < 360 && collisionAngle > 235)) {
            collisionRight = true;
        }
    }
    
	//NSLog(@" thumbPadTouchX %d %d  %d ", thumbPadTouchX, thumbPadTouchY, currentMovement);
	
    // thumbPadTouchY > padOffset && thumbPadTouchX > padOffset && 
    // thumbPadTouchY < (padSize) && thumbPadTouchX < padSize &&
    
	if( currentMovement != MTNone 
       &&
         ([controls thumbPad:thumbPadTouchX y:thumbPadTouchY] == 1 || thumbPadTouched == 1 )
       &&
	   !paused
       &&
       !dead)
	{
        //NSLog(@"  thumbPadTouched %d   t: %d    %d  %d ", thumbPadTouched , 
        //      [controls thumbPad:thumbPadTouchX y:thumbPadTouchY], thumbPadTouchX, thumbPadTouchY );
        
        
        
        //NSLog(@" frameRateScale: %f   %f ", frameRateScale, frameRate);  
		GLfloat scaledSpeed = (frameRateScale * WALK_SPEED * (  forwardControlPosition /  (padSize/2)  ) );
		scaledSpeed = -scaledSpeed; // invert
        
        bool walkIsAllowed = true;
        if(scaledSpeed > 0 && collisionFront){ // walking forward and colided with object in front
            walkIsAllowed = false;
        }
        if(scaledSpeed < 0 && collisionBack){ // walking backward and collided with object in back
            walkIsAllowed = false;
        }
        
        //if(scaledSpeed > 0 && [levelLoader avatarCollision]  && collisionFront  ){
        if(!walkIsAllowed){
            scaledSpeed = 0;
        }
        
		GLfloat scaledTrun = (TURN_SPEED * (  turnControlPosition / (padSize/2)  ));
        scaledTrun *= frameRateScale;
		if(thirdPerson){ 
			eye[0] += vector[0] * thirdPersonBack;
			eye[2] += vector[2] * thirdPersonBack;
			center[0] += vector[0] * thirdPersonBack;
			center[2] += vector[2] * thirdPersonBack;
			//center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
			//center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
			vector[0] = center[0] - eye[0];
			vector[1] = center[1] - eye[1];
			vector[2] = center[2] - eye[2];
		}
		
		// forward
        //if(![levelLoader avatarCollision]){
        if(walkIsAllowed){    
            eye[0] += vector[0] * scaledSpeed;
            eye[2] += vector[2] * scaledSpeed;
            center[0] += vector[0] * scaledSpeed;
            center[2] += vector[2] * scaledSpeed;
            // turn
            center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
            center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
            vector[0] = center[0] - eye[0];
            vector[1] = center[1] - eye[1];
            vector[2] = center[2] - eye[2];
        } else { // collision - strife
            float turn = M_PI / 2;
            
            // turn
            center[0] = eye[0] + cos(-turn)*vector[0] - sin(-turn)*vector[2];
            center[2] = eye[2] + sin(-turn)*vector[0] + cos(-turn)*vector[2];
            vector[0] = center[0] - eye[0];
            vector[1] = center[1] - eye[1];
            vector[2] = center[2] - eye[2];
            
            eye[0] += vector[0] * scaledTrun;  // side step instead or turn
            eye[2] += vector[2] * scaledTrun;
            center[0] += vector[0] * scaledTrun;
            center[2] += vector[2] * scaledTrun;
            vector[0] = center[0] - eye[0];
            vector[1] = center[1] - eye[1];
            vector[2] = center[2] - eye[2];
            
            // turn
            center[0] = eye[0] + cos(turn)*vector[0] - sin(turn)*vector[2];
            center[2] = eye[2] + sin(turn)*vector[0] + cos(turn)*vector[2];
            vector[0] = center[0] - eye[0];
            vector[1] = center[1] - eye[1];
            vector[2] = center[2] - eye[2];
        }
		
		if(thirdPerson){ 
			eye[0] += vector[0] * -thirdPersonBack;
			eye[2] += vector[2] * -thirdPersonBack;
			center[0] += vector[0] * -thirdPersonBack;
			center[2] += vector[2] * -thirdPersonBack;
			//center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
			//center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
			vector[0] = center[0] - eye[0];
			vector[1] = center[1] - eye[1];
			vector[2] = center[2] - eye[2];
		}
		
		//NSLog(@" %f  %f  %f  " , ( vector[0] ),vector[2] , (vector[0] -vector[2] )  );
		//NSLog(@"  %f  %f   " , center[0] , center[2] );
		
		
		//NSLog(@" center[1]  %f " , center[1]);
		//center[1] = 2.5;
		// up 
		
		//	float vRadians = 0.9;
		//	float hRadians = [[self getAngleR] floatValue];
		
		//up[0] = sin(vRadians) * sin(hRadians);
		//up[1] = cos(vRadians);
		//up[2] = sin(vRadians) * cos(hRadians);
		//	up[0] = sin(vRadians) * sin(hRadians);
		//	up[1] = cos(vRadians);
		//	up[2] = sin(vRadians) * cos(hRadians);
		//NSLog(@" %f    " , hRadians );
		
		
		// temp
		/*
		 glLoadIdentity();
		 float cameraTiltZSmooth = 1.6;
		 glRotatef(  ((-cameraTiltZSmooth) * 180.0 / M_PI)  , 0.0, 0.0, 1.0); // Tilt Landscape
		 gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], 0.0, 1.0, 0.0); 
		 glRotatef(  -hRadians  , 0.0, 1.0, 0.0); //
		 glRotatef(  0.2  , 0.0, 0.0, 1.0); // Tilt Down
		 glRotatef(  hRadians  , 0.0, 1.0, 0.0); //
		 GLfloat modelMatrix[16];
		 glGetFloatv(GL_MODELVIEW, modelMatrix);
		 up[0] = modelMatrix[4];
		 up[1] = modelMatrix[5];
		 up[2] = modelMatrix[6];
		 */
		
		
		//NSLog(@"             %f  %f  %f  " , up[0],up[1], up[2]);
		
		
		//
		// Update height on terrain
		//
		[self updateHeightOnTerrain];
	}  
    
    
    if ( ((int)move != 0 || (int)turn != 0) && !paused && !dead) { // Swipe move/turn
    
        //NSLog(@"  swipeMove %d  swipeTurnMotion %d ", swipeMove , swipeTurnMotion);
        
        float scaledSpeed = (frameRateScale * WALK_SPEED * ( (float)-move  / 30   ) );
        
        bool walkIsAllowed = true;
        if(scaledSpeed > 0 && collisionFront){ // walking forward and colided with object in front
            walkIsAllowed = false;
        }
        if(scaledSpeed < 0 && collisionBack){ // walking backward and collided with object in back
            walkIsAllowed = false;
        }
        
        //if(scaledSpeed > 0 && [levelLoader avatarCollision]){
        if(!walkIsAllowed){
            scaledSpeed = 0;
        }
        
        // / 30 truns too fast
        GLfloat scaledTrun = (frameRateScale * TURN_SPEED * ( (float)turn / 50 )); // / 30
        
        //NSLog(@"swipeTurnMotion %f  scaledTrun %f ", (float)swipeTurnMotion, scaledTrun);
        
        if(thirdPerson){ 
			eye[0] += vector[0] * thirdPersonBack;
			eye[2] += vector[2] * thirdPersonBack;
			center[0] += vector[0] * thirdPersonBack;
			center[2] += vector[2] * thirdPersonBack;
			//center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
			//center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
			vector[0] = center[0] - eye[0];
			vector[1] = center[1] - eye[1];
			vector[2] = center[2] - eye[2];
		}
		
		// forward
        //if(![levelLoader avatarCollision]){
        if(walkIsAllowed){
            // move forward
            {
                eye[0] += vector[0] * scaledSpeed;
                eye[2] += vector[2] * scaledSpeed;
                center[0] += vector[0] * scaledSpeed;
                center[2] += vector[2] * scaledSpeed;
                // turn
                center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
                center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
                vector[0] = center[0] - eye[0];
                vector[1] = center[1] - eye[1];
                vector[2] = center[2] - eye[2];
            }
            
            // strif to the side (minimal)
            {/*
                float turn = M_PI / 2;
                float sideStep = (scaledTrun/4);
                
                // turn 
                center[0] = eye[0] + cos(-turn)*vector[0] - sin(-turn)*vector[2];
                center[2] = eye[2] + sin(-turn)*vector[0] + cos(-turn)*vector[2];
                vector[0] = center[0] - eye[0];
                vector[1] = center[1] - eye[1];
                vector[2] = center[2] - eye[2];
                
                eye[0] += vector[0] * sideStep;  // side step instead or turn
                eye[2] += vector[2] * sideStep;
                center[0] += vector[0] * sideStep;
                center[2] += vector[2] * sideStep;
                vector[0] = center[0] - eye[0];
                vector[1] = center[1] - eye[1];
                vector[2] = center[2] - eye[2];
                
                // turn
                center[0] = eye[0] + cos(turn)*vector[0] - sin(turn)*vector[2];
                center[2] = eye[2] + sin(turn)*vector[0] + cos(turn)*vector[2];
                vector[0] = center[0] - eye[0];
                vector[1] = center[1] - eye[1];
                vector[2] = center[2] - eye[2];
            */}
            
        } else { // collision - strife
            
            // strif to the side
            {
                float turn = M_PI / 2;
                
                // Don't side step into object
                // scaledTrun -is right
                bool sideStepAllowed = true;
                if(scaledTrun < 0 && collisionRight){ // right
                    sideStepAllowed = false;
                }
                if(scaledTrun > 0 && collisionLeft){ // left
                    sideStepAllowed = false;
                }
                
                if(sideStepAllowed){
                    // turn 
                    center[0] = eye[0] + cos(-turn)*vector[0] - sin(-turn)*vector[2];
                    center[2] = eye[2] + sin(-turn)*vector[0] + cos(-turn)*vector[2];
                    vector[0] = center[0] - eye[0];
                    vector[1] = center[1] - eye[1];
                    vector[2] = center[2] - eye[2];
                    
                    eye[0] += vector[0] * scaledTrun;  // side step instead or turn
                    eye[2] += vector[2] * scaledTrun;
                    center[0] += vector[0] * scaledTrun;
                    center[2] += vector[2] * scaledTrun;
                    vector[0] = center[0] - eye[0];
                    vector[1] = center[1] - eye[1];
                    vector[2] = center[2] - eye[2];
                    
                    // turn
                    center[0] = eye[0] + cos(turn)*vector[0] - sin(turn)*vector[2];
                    center[2] = eye[2] + sin(turn)*vector[0] + cos(turn)*vector[2];
                    vector[0] = center[0] - eye[0];
                    vector[1] = center[1] - eye[1];
                    vector[2] = center[2] - eye[2];
                }
            }
        }
		
		if(thirdPerson){ 
			eye[0] += vector[0] * -thirdPersonBack;
			eye[2] += vector[2] * -thirdPersonBack;
			center[0] += vector[0] * -thirdPersonBack;
			center[2] += vector[2] * -thirdPersonBack;
			//center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
			//center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
			vector[0] = center[0] - eye[0];
			vector[1] = center[1] - eye[1];
			vector[2] = center[2] - eye[2];
		}
        //
		// Update height on terrain
		//
		[self updateHeightOnTerrain];
    }
	
    
    //
    // emergency bounds checking
    //
    ObjectContainer * avatarLoc = [self getAvatarLocation];
    //NSLog(@" player  %f   %f ", [avatarLoc locX], [avatarLoc locZ]);
    float worldSize = 250;
    if([avatarLoc locX] > worldSize){ 
        float jump = -15;
        eye[0] += jump; 
        center[0] += jump; 
    }
    if( [avatarLoc locX] < -worldSize ){
        float jump = 15;
        eye[0] += jump; 
        center[0] += jump; 
    }
    if( [avatarLoc locZ] > worldSize ){ 
        float jump = -15;
        eye[2] += jump; 
        center[2] += jump;
    }
    if( [avatarLoc locZ] < -worldSize ){
        float jump = 15;
        eye[2] += jump; 
        center[2] += jump;
    }
}


//
// touch events
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//UITouch *touch = [[event allTouches] anyObject];
	//CGPoint touchPoint = [touch locationInView:touch.view];
	
    touchCount += [[touches allObjects] count]; // track number of touch points
    //NSLog(@"touchCount: %d ", touchCount);
    
    CGRect rect = self.view.bounds;
    int screenHeight = rect.size.height;
    
    
    
    NSArray *multipleTouches = [touches allObjects];
    for(int i = 0; i < [multipleTouches count]; i++){
        UITouch *touch = [multipleTouches objectAtIndex:0];
        CGPoint touchPoint = [touch locationInView:touch.view];
        
        // Retina
        if(rect.origin.y != 0){
            touchPoint.x = touchPoint.x * 2;
            touchPoint.y = touchPoint.y * 2;
        }
        
        if(touchPoint.y < (screenHeight/2)){
            leftTouchX = touchPoint.x;
            leftTouchY = touchPoint.y;
            leftTouchBeginX = leftTouchX;
            leftTouchBeginY = leftTouchY;
        } else if(touchPoint.y >= (screenHeight/2)){
            rightTouchX = touchPoint.x;
            rightTouchY = touchPoint.y;
            rightTouchBeginX = rightTouchX;
            rightTouchBeginY = rightTouchY;
        }
        
        if(touchPoint.y < (screenHeight/2)){ // touchCount == 1 && 
            leftHand = true;
        } else if(touchPoint.y >= (screenHeight/2)){ // 
            leftHand = false;
        }
        
        bool isFirstTouch = false;
        if( touchPoint.x < touchX + 10 && touchPoint.x > touchX - 10 
           &&touchPoint.y < touchY + 10 && touchPoint.y > touchY - 10 ){
            isFirstTouch = true;
        } 
        if(touchX == 0 && touchY == 0){
            isFirstTouch = true;
        }
    
        //NSLog(@" Touch ! %f %f ", touchPoint.x, touchPoint.y );
        
        // don't move if button push
        //if( [controls redButton:touchPoint.x y:touchPoint.y] != 1 && 
        //   [controls blueButton:touchPoint.y y:touchPoint.x] != 1 ){  // no buttons
            //swipeTilt = touchX - touchPoint.x;
        //}
        
        if( (leftHand && touchPoint.y < (screenHeight/2)) || (!leftHand && touchPoint.y >= (screenHeight/2)) ){ // touchCount < 2 
            touchX = touchPoint.x;
            touchY = touchPoint.y;
        }
        
        
        // Retina
        if(rect.origin.y != 0){
        //    touchX = touchX * 2;
        //    touchY = touchY * 2;
        }
	
        
        NSNumber* xn = [NSNumber numberWithInt:touchX];
        NSNumber* yn = [NSNumber numberWithInt:touchY];
        
        NSLog(@"     touchX %d   touchY %d ", touchX, touchY);
        
        
        //
        // Menu
        //
        NSString* menuResult = [menu touch:xn y:yn];
        //NSLog(@" touch menu item: %@ ", menuResult);
        if(![menuResult isEqualToString:@""]){
            //[self startAnimation];
            NSString* action = [menu clickedAction];
            if([action isEqualToString:@"loadLevel"]){
                NSLog(@"  load level: %@ ", [menu clickedLoad]);
                
                //[levelLoader preLoadLevel:@"intro" ];
                [levelLoader preLoadNextLevel];
                
                //[levelLoader preLoadLevel:  [menu clickedLoad]];
                [hud setLevelString:[levelLoader getLevelLoaded]];
                [controls setVisible:true];
            }
            if([action isEqualToString:@"resume"]){
                // restores saved game
                
                NSString * resumeLevel = nil;
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];                
                if (defaults) 
                    resumeLevel = [defaults objectForKey:@"lastPlayedLevel"];
                
                if(resumeLevel != nil){
                    [levelLoader preLoadLevel: resumeLevel ];
                    NSLog(@"  resume level: %@ ", resumeLevel);
                } else { 
                    [levelLoader preLoadNextLevel];
                }
                
                //[[levelLoader saveGame] loadGame];
                //[levelLoader setHealthPoints: [[levelLoader saveGame] health] ];
                //[levelLoader preLoadLevel: [[levelLoader saveGame] level]  ];
                
                //  
                [hud setLevelString:[levelLoader getLevelLoaded]];
                [controls setVisible:true];
            }
        }
        
        //
        // HUD Pause Screen
        //
        if(paused){
            NSString* result = [hud touch:touchX y:touchY];
            if(result != nil){
                [levelLoader preLoadLevel:result];
                
                // dismiss paused menu
                paused = FALSE;
                if(levelLoader != nil){
                    [levelLoader setPaused:paused];
                }
            }
        }
        
        /*
        if([controls touch:xn y:yn] == controls->CONTROLS_FORWARD ){
            //NSLog(@"Forward ");
        }
        if([controls touch:xn y:yn] == controls->CONTROLS_RIGHT ){
            //NSLog(@"Right ");
            
            // turn
            GLfloat scaledTrun = (TURN_SPEED * (  2  ));
            //center[0] = eye[0] + cos(-scaledTrun)*vector[0] - sin(-scaledTrun)*vector[2];
            //center[2] = eye[2] + sin(-scaledTrun)*vector[0] + cos(-scaledTrun)*vector[2];
            
        }
         */
        
        //NSLog(@" controls %d ", [controls touch:xn y:yn]);
        
        //
        // Touch objects/enimies...
        //
        if(!paused && !dead){
            NSMutableArray* touchableObjects = [levelLoader touchableObjects];
            NSEnumerator* touchIterator = [touchableObjects objectEnumerator];
            ObjectContainer* touchObject;
            while( touchObject = [touchIterator nextObject])
            {
                if([self objectTouched:touchPoint object:touchObject]) // checkCollission
                {
                    //NSLog(@" touch: %@  %f  ", [touchObject name], [touchObject locY]);
                    [levelLoader objectTouched:touchObject];
                }
            }
        }
            
        /*	
        for(int i=0; i < [pieces count]; i++)
        {
            Piece* p = [pieces objectAtIndex:i];
            if([self checkCollission:touchPoint object:p])
            {
                
                //[interactiveObject fireAction];
                NSLog(@" Touched Piece %d  t: %f %f   ", i, touchPoint.x, touchPoint.y );
                
                movingPiece = p;
                touchX = touchPoint.x;
                touchY = touchPoint.y;
                
                //NSLog(@" mp1 %d ", [[movingPiece getIndex] intValue]  );
                
                // Find offset of piece
                Piece* worldPoint = [self getLocationOfTouch:touchPoint];
                //NSLog(@" p   %f %f   XXX   %f  %f ", 
                //	  [[p getLocationX] floatValue],  
                //	  [[p getLocationY] floatValue] , 
                //	  [[worldPoint getLocationX] floatValue], 
                //	  [[worldPoint getLocationY] floatValue]);
                
                pieceTouchOffsetX = [[p getLocationX] floatValue] - [[worldPoint getLocationX] floatValue];
                pieceTouchOffsetY = [[p getLocationY] floatValue] - [[worldPoint getLocationY] floatValue];
                
            }
        }
        */ 
	
    }
	//NSLog(@" touch ");
	//[super touchesBegin:touches withEvent:event];
}



//
// Moved
//
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@" Move ");
	//UITouch *touch = [[event allTouches] anyObject];
	//CGPoint touchPoint = [touch locationInView:touch.view];
    
    CGRect rect = self.view.bounds;
    int screenHeight = rect.size.height; 
    
    bool leftMovement = false;
    bool rightMovement = false;
    
    NSArray *multipleTouches = [touches allObjects];
    for(int i = 0; i < [multipleTouches count]; i++){
        UITouch *touch = [multipleTouches objectAtIndex:0];
        CGPoint touchPoint = [touch locationInView:touch.view];
        
        // Retina
        if(rect.origin.y != 0){
            touchPoint.x = touchPoint.x * 2;
            touchPoint.y = touchPoint.y * 2;
        }
    
        bool isFirstTouch = false;
        //if( touchPoint.x < touchX + 10 && touchPoint.x > touchX - 10 &&touchPoint.y < touchY + 10 && touchPoint.y > touchY - 10 ){
        if( (leftHand && touchPoint.y < (screenHeight/2)) || (!leftHand && touchPoint.y >= (screenHeight/2)) ){
            isFirstTouch = true;
        }
        
        leftSide = false;
        if(touchPoint.y < (screenHeight/2)){  // Left side
            leftSide = true;
            leftMovement = true;
            
            leftSwipeTilt = leftTouchX - touchPoint.x;
            leftSwipeTurn = leftTouchY - touchPoint.y;
            
            leftTouchX = touchPoint.x;
            leftTouchY = touchPoint.y;
            
        } else if(touchPoint.y >= (screenHeight/2)){  // Right 
            leftSide = false;
            rightMovement = true;
         
            rightSwipeTilt = rightTouchX - touchPoint.x;
            rightSwipeTurn = rightTouchY - touchPoint.y;
            
            rightTouchX = touchPoint.x;
            rightTouchY = touchPoint.y;
        }
        
        
        // don't swipe move on button push  ||| DEPRICATE |||
        if( 
           //([controls redButton:touchPoint.y y:touchPoint.x] != 1 && 
           // [controls blueButton:touchPoint.x y:touchPoint.y] != 1)
            isFirstTouch // only swipe on first touch
           ){
        //    swipeTilt = touchX - touchPoint.x;
        //    swipeTurn = touchY - touchPoint.y;
        }
        
        //if(touchCount < 2){
        if(isFirstTouch){ // only move if first touch
            touchX = touchPoint.x;
            touchY = touchPoint.y;
        }
        
        bool objectPicked = false;
        
        
        /*
        if( [controls thumbPad:thumbPadTouchX y:thumbPadTouchY] == 1  &&
            [controls thumbPad:touchX y:touchY] != 1 && 
           [controls redButton:touchPoint.y y:touchPoint.x] != 1 && 
           [controls blueButton:touchPoint.x y:touchPoint.y] != 1
           ){
                                                                // Moved off thumbpad and not button
            thumbPadTouchX = 0;
            thumbPadTouchY = 0;
            
            currentMovement = MTNone;
            thumbPadTouched = 0;
        
        } else if([controls thumbPad:touchX y:touchY] == 1){        // thumbpad moved
            thumbPadTouchX = touchPoint.x;
            thumbPadTouchY = touchPoint.y;
            //currentMovement = MTWalkForward;
        } else {
        //	thumbPadTouchX = 0;
        //	thumbPadTouchY = 0;
        }
        */
        
        
        if(//isFirstTouch && 
           (swipeTilt != 0 || leftSwipeTilt != 0 || rightSwipeTilt != 0) 
           //[controls redButton:touchPoint.y y:touchPoint.x] != 1 && 
           //[controls blueButton:touchPoint.x y:touchPoint.y] != 1 
           && !paused && !dead){
            //NSLog(@" swipeTilt: %d ", swipeTilt);
            //swipeMove += swipeTilt;
            swipeMove = swipeMove + leftSwipeTilt + rightSwipeTilt ; // swipeTilt
            
            if(swipeMove > 20){
                swipeMove = 20;
            } else if(swipeMove < -20){
                swipeMove = -20;
            }
            moveMomentumSpeed = swipeMove;
           
            //NSLog(@" swipeMove: %d ", swipeMove);
        }
        
        if(//isFirstTouch &&
           (swipeTurn != 0 || leftSwipeTurn != 0 || rightSwipeTurn != 0)
           //[controls redButton:touchPoint.y y:touchPoint.x] != 1 && 
           //[controls blueButton:touchPoint.x y:touchPoint.y] != 1 &&
           && !paused && !dead){
            //swipeTurnMotion += swipeTurn;
            swipeTurnMotion = swipeTurnMotion + leftSwipeTurn + rightSwipeTurn; // + swipeTurn;
            
            if(swipeTurnMotion > 40){
                swipeTurnMotion = 40;
            } else if(swipeTurnMotion < -40){
                swipeTurnMotion = -40;
            }
            turnMomentumSpeed = swipeTurnMotion;
            //float scaledTurn = ( (float)swipeTurnMotion / 100.0  );
            //[self turnAvatar: [NSNumber numberWithFloat:scaledTurn] ];
            
            //[self updateHeightOnTerrain]; // update view with new tilt (*** needs refactoring)
            
            //NSLog(@" turnMomentumSpeed   %f ", turnMomentumSpeed);
        }
        
        // Update camera swipe tilt
        // DISABLED
        if(( swipeTurn != 0)  // swipeTilt != 0
            && [controls thumbPad:touchX y:touchY] != 1 
            && objectPicked == false &&
            [levelLoader getLevelLoaded] != nil && 
            ![[levelLoader getLevelLoaded] isEqualToString:@"Main Menu"] &&
            !paused && !dead
            && FALSE){
            
            if(swipeTilt != 0){
                //NSLog(@" swipeTilt: %f ", swipeTilt);
            }
            /*
            thirdPersonTilt -= ( (float)swipeTilt / 80.0  );
            thirdPersonHeight += ( (float)swipeTilt / 80.0  );
            // bounds
            if(thirdPersonTilt > 2){
                thirdPersonTilt = 2;
            } else if(thirdPersonTilt < - 3.0) {
                thirdPersonTilt = -3.0;
            }
            if(thirdPersonHeight < 1.2){
                thirdPersonHeight = 1.2;
            } else if(thirdPersonHeight > 15) {
                thirdPersonHeight = 15;
            }
            */ 
            
            // turn
            float scaledTurn = ( (float)swipeTurn / 100.0  );
            [self turnAvatar:scaledTurn ];
            [self updateHeightOnTerrain]; // update view with new tilt (*** needs refactoring)
        }
	}
    
    if(!leftMovement){
        leftSwipeTilt = 0;
        leftSwipeTurn = 0;
    }
    if(!rightMovement){
        rightSwipeTilt = 0;
        rightSwipeTurn = 0;
    }
    
    
	//[super touchesMoved:touches withEvent:event];
}


/**
 * touchesEnded
 *
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//UITouch *touch = [[event allTouches] anyObject];
	//CGPoint touchPoint = [touch locationInView:touch.view];
	
    touchCount -= [[touches allObjects] count]; // track number of touch points
    //NSLog(@" end touchCount: %d ", touchCount);
    
    //int tc = [touches count];
    //int tapCount = [[touches anyObject] tapCount];
    
    NSSet *touchSet = [event allTouches];
    int count = [touchSet count];
    
    //NSLog(@" touches:  %d   ", count );
    if(count == 1){ // stop moving if no fingers are touching the screen
        moveMomentumSpeed = swipeMove;
        turnMomentumSpeed = swipeTurnMotion;
        swipeMove = 0;
        swipeTurnMotion = 0; // no
        //NSLog(@"   stop  %d  %f ", swipeMove, moveMomentumSpeed);
    }
    
    //NSLog(@" leftSwipeTurn: %d  leftSwipeTilt: %d  rightSwipeTurn: %d   rightSwipeTilt: %d  swipeMove: %d   swipeTurnMotion: %d  ", 
    //      leftSwipeTurn, leftSwipeTilt, rightSwipeTurn, rightSwipeTilt, swipeMove, swipeTurnMotion );
    
    CGRect rect = self.view.bounds;
    int screenHeight = rect.size.height; 
    
    // dead, restart level
    if(dead){
        [levelLoader preLoadLevel:  [levelLoader getLevelLoaded]];
    }
    
    NSArray *multipleTouches = [touches allObjects];
    for(int i = 0; i < [multipleTouches count]; i++){
        UITouch *touch = [multipleTouches objectAtIndex:0];
        CGPoint touchPoint = [touch locationInView:touch.view];
        
        // Retina
        if(rect.origin.y != 0){
            touchPoint.x = touchPoint.x * 2;
            touchPoint.y = touchPoint.y * 2;
        }
    
        bool isFirstTouch = false;
        //if( touchPoint.x < touchX + 10 && touchPoint.x > touchX - 10 && touchPoint.y < touchY + 10 && touchPoint.y > touchY - 10 ){
        if( (leftHand && touchPoint.y < (screenHeight/2)) || (!leftHand && touchPoint.y >= (screenHeight/2)) ){
            isFirstTouch = true;
        }
        
        bool fireGun = false;
        bool leftSide = false;
        if(touchPoint.y < (screenHeight/2)){
            leftSide = true;
            
            leftTouchX = touchPoint.x;
            leftTouchY = touchPoint.y;
            
            if(leftTouchX > leftTouchBeginX - 8 && leftTouchX < leftTouchBeginX + 8 &&
               leftTouchY > leftTouchBeginY - 8 && leftTouchY < leftTouchBeginY + 8){
                fireGun = true;
            }
            
            leftSwipeTurn = 0;
            leftSwipeTilt = 0;
            
        } else if(touchPoint.y >= (screenHeight/2)){
            leftSide = false;
            
            rightTouchX = touchPoint.x;
            rightTouchY = touchPoint.y;
            
            if(rightTouchX > rightTouchBeginX - 8 && rightTouchX < rightTouchBeginX + 8 &&
               rightTouchY > rightTouchBeginY - 8 && rightTouchY < rightTouchBeginY + 8){
                fireGun = true;
            }
            
            rightSwipeTurn = 0;
            rightSwipeTilt = 0;
        }
        
        //bool buttonPressed = false;
        if(isFirstTouch){
            touchX = touchPoint.x;
            touchY = touchPoint.y;
        }
    
    
        /*
        if([controls thumbPad:touchPoint.x y:touchPoint.y] == 1){   // release thumpad press FAIL!!!
            //thumbPadTouchX = touchPoint.x;
            //thumbPadTouchY = touchPoint.y;
            thumbPadTouchX = 0;
            thumbPadTouchY = 0;
            currentMovement = MTNone;
            thumbPadTouched = 0;
            //NSLog(@"  ***             thumbpad off     %f  %f  " , touchPoint.x ,  touchPoint.y );
        } 
        */
        
        // Release but not from another button
        //if([controls redButton:touchPoint.x y:touchPoint.y] != 1){
            //currentMovement = MTNone;
            //thumbPadTouched = 0;
        //}
        
        
        if([controls redButton:touchPoint.y y:touchPoint.x] == 1 || 
           [controls blueButton:touchPoint.x y:touchPoint.y] == 1 ){
        //    buttonPressed = true;
        }
        
        
        if(isFirstTouch){
            if(((int)swipeMove) != 0 ){
                moveMomentumSpeed = swipeMove; 
            }
            if(((int)swipeTurnMotion) != 0){
                turnMomentumSpeed = swipeTurnMotion;
            }
        //    swipeMove = 0;
        //    swipeTurnMotion = 0;
            
            /*
            if(leftSide){
                leftSwipeTilt = 0;
                leftSwipeTurn = 0;
            } else {
                rightSwipeTilt = 0;
                rightSwipeTurn = 0;
            }*/
        }
        
        if(touchCount == 0){ // Last touch
            swipeMove = 0;
            swipeTurnMotion = 0;
        }
         
        
        //
        // Gun
        //
        if((fireGun || 
            [controls redButton:touchPoint.y y:touchPoint.x] == 1) &&
            !paused && !dead &&
           [levelLoader loading] == 0 && [[levelLoader getLevelLoaded] compare:@"Main Menu"] != 0 // doesn't work
           ){
            //NSLog(@"Red");
            
            //int x = [controls redButton:touchX y:touchY];
            //NSLog(@"Red  %d",x);
            
            // fire gun
            ObjectContainer * avatarLoc = [self getAvatarLocation];
            float angle = [self getAngleR];
            Bullet* bullet = [[Bullet alloc] init];
            
            // Shift bullet on X axis of player to line up with weapon
            float xShift = -0.55; // todo make this an xml attribute
            float bulletOffsetX = 0;
            float bulletOffsetZ = 0;
            bulletOffsetX = cos(angle) * (bulletOffsetX-xShift) - sin(angle) * (bulletOffsetZ-0) + bulletOffsetX;
            bulletOffsetZ = sin(angle) * (bulletOffsetX-xShift) + cos(angle) * (bulletOffsetZ-0) + bulletOffsetZ;
            
            [bullet setLocX:[avatarLoc locX] + bulletOffsetX];
            //[bullet y:[[NSNumber alloc] initWithFloat: [[avatar getY] floatValue]] ];
            [bullet setLocY:[avatarLoc locY] - thirdPersonHeight + 3]; 
            [bullet setLocZ:[avatarLoc locZ] + bulletOffsetZ];
            [bullet setAngle:angle];
            [bullets addObject:bullet];
            
            // sound
            [[levelLoader sound] playGunshot];
            
            //1NSLog(@" bullets %d x %f  z %f ", [bullets count], [[avatarLocation getX] floatValue] , [[avatarLocation getZ] floatValue]);
            //[avatarLoc release];
        }
        
        /*
        if([controls blueButton:touchPoint.x y:touchPoint.y] == 1 &&
           !paused){
            NSLog(@"jumpHeight: %f ", jumpHeight);
            if(jumpHeight <= 0.08 ){
                //jumpHeight += 3;
                jumpingStage = 2;
                
                jumpUp = TRUE;
                NSLog(@"  Jump " );
            }
        }
        */
        
        
        //pieceLifted = 0;
        
        // Menu Button
        // 
        if([controls gameMenu:touchPoint.x y:touchPoint.y] == 1 &&
            [levelLoader getLevelLoaded] != nil &&
            ![[levelLoader getLevelLoaded] isEqualToString:@"Main Menu"] ){
            //NSLog(@"  Menu  ");
            if(paused){
                paused = FALSE;
            } else {
                paused = TRUE;
            }
            if(levelLoader != nil){
                [levelLoader setPaused:paused];
            }
        }
        
        // Button Push
        //[self buttonPush:touchPoint]; // depricate (HUD/Menu is now 2d)
    }
	//[super touchesEnded:touches withEvent:event];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@" Canceled ");
	
    
    
	//[super touchesCancelled:touches withEvent:event];
}




//http://www.opengl-doc.com/Sams-OpenGL.SuperBible.Third/0672326019/ch04lev1sec5.html
- (Piece*)multPointByMatrix:(float)x y:(float)y z:(float)z
{
	GLfloat pointX = x; //[x floatValue];
	GLfloat pointY = y; //[y floatValue];
	GLfloat pointZ = z; //[z floatValue];
	
	//glLoadIdentity();
	
	//
    // transform point by matrix
    //
	GLfloat pointMatrix[16];
	glGetFloatv(GL_MODELVIEW, pointMatrix);
    //__gluMakeIdentityf(&pointMatrix[0][0]);
	//glMatrixMode(GL_MODELVIEW);
	//glLoadMatrixf(pointMatrix); // no
	
	//pointMatrix[3] = pointX;
    //pointMatrix[7] = pointY;
    //pointMatrix[11] = pointZ;
	pointMatrix[12] = pointX;
    pointMatrix[13] = pointY;
    pointMatrix[14] = pointZ;
	/*
	 NSLog(@" 1 [ %f %f %f %f ]", pointMatrix[0], pointMatrix[4], pointMatrix[8], pointMatrix[12]);
	 NSLog(@"   [ %f %f %f %f ]", pointMatrix[1], pointMatrix[5], pointMatrix[9], pointMatrix[13]);
	 NSLog(@"   [ %f %f %f %f ]", pointMatrix[2], pointMatrix[6], pointMatrix[10], pointMatrix[14]);
	 NSLog(@"   [ %f %f %f %f ]", pointMatrix[3], pointMatrix[7], pointMatrix[11], pointMatrix[15]);
	 */
    
    glMultMatrixf(&pointMatrix[0]);
    //glTranslatef(pointX, pointY, pointZ);
	
	if(thirdPerson){
		//glTranslatef(pointX, pointY, pointZ); thirdPersonBack
	}
	
    GLfloat modelMatrix[16];
    glGetFloatv(GL_MODELVIEW, modelMatrix);
    
    //pointX = modelMatrix[3];
    //pointY = modelMatrix[7];
    //pointY = modelMatrix[11];
	pointX = modelMatrix[12];
    pointY = modelMatrix[13];
    pointZ = modelMatrix[14];
    
	/*
	 NSLog(@" 2 [ %f %f %f %f ]", modelMatrix[0], modelMatrix[4], modelMatrix[8], modelMatrix[12]);
	 NSLog(@"   [ %f %f %f %f ]", modelMatrix[1], modelMatrix[5], modelMatrix[9], modelMatrix[13]);
	 NSLog(@"   [ %f %f %f %f ]", modelMatrix[2], modelMatrix[6], modelMatrix[10], modelMatrix[14]);
	 NSLog(@"   [ %f %f %f %f ]", modelMatrix[3], modelMatrix[7], modelMatrix[11], modelMatrix[15]);
	 */
    glLoadIdentity();
	
	Piece * p = [[Piece alloc] init];
	[p setLocationX: [ NSNumber numberWithFloat: pointX]];
	[p setLocationY: [ NSNumber numberWithFloat: pointY]];
	[p setLocationZ: [ NSNumber numberWithFloat: pointZ]];
    // create point object and return it.
	
	return p;
}



/*
 * accelerometer
 * input received
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{ 
	// Get the current device angle
	float xx = -[acceleration x]; 
	float yy = [acceleration y]; 
	float angle = atan2(yy, xx); 
	
	NSLog(@" %f ", angle);

}


/**
 * swapPieces
 * 
 * Description: Interchange positions of two pieces.
 *
 */
/*
-(void)swapPieces:(Piece*)a with:(Piece*)b {
	NSNumber* x = [NSNumber numberWithFloat: [[a getHomeX] floatValue]];
	NSNumber* y = [NSNumber numberWithFloat: [[a getHomeY] floatValue]];
	NSNumber* z = [NSNumber numberWithFloat: [[a getHomeZ] floatValue]];
	NSNumber* inPlace = [NSNumber numberWithInt: [[a getInPlace] intValue]];
	
	[a setHomeX: [NSNumber numberWithFloat: [[b getHomeX] floatValue]]   ];
	[a setHomeY: [NSNumber numberWithFloat: [[b getHomeY] floatValue]]   ];
	[a setHomeZ: [NSNumber numberWithFloat: [[b getHomeZ] floatValue]]   ];
	[a setLocationX: [NSNumber numberWithFloat: [[b getHomeX] floatValue]]   ];
	[a setLocationY: [NSNumber numberWithFloat: [[b getHomeY] floatValue]]   ];
	[a setLocationZ: [NSNumber numberWithFloat: [[b getHomeZ] floatValue]]   ];
	[a setInPlace: [NSNumber numberWithInt: [[b getInPlace] intValue]]   ];
	
	[b setHomeX: x ];
	[b setHomeY: y ];
	[b setHomeZ: z ];
	[b setLocationX: x ];
	[b setLocationY: y ];
	[b setLocationZ: z ];
	[b setInPlace: inPlace ];
}
*/




/**
 * done
 *
 * Description: returns true when all the pieces are in the right place.
 *
 */
/*
-(BOOL) done {
	BOOL done = true;
	
	for(int i=0; i < [pieces count]; i++)
	{
		Piece* p = [pieces objectAtIndex:i];
		if( [[p getIndex] intValue] != [[p getInPlace] intValue]  ){
			done = false;
		}
	}
	
	if(done){
		if(currentLevelIndex == reachedLevel){ // if the last level completed 
			reachedLevel++;
		}
		if([levels count] <= reachedLevel){
			reachedLevel = ([levels count] - 1);
		}
		//NSLog(@" reachedLevel: %d ", reachedLevel);
		
		// Save level reached
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		[defaults setObject:[NSNumber numberWithInt: reachedLevel] forKey: @"reachedLevel"];
		[defaults synchronize];
		
		// load
		//currentLevel = [levels objectAtIndex:reachedLevel];
		
		
		AVAudioPlayer * audioPlayer;
		NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound1" ofType:@"caf"]]; 
		audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
		[audioPlayer play];
	}
	return done;
}
*/ 


#define RAY_ITERATIONS 1000
#define COLLISION_RADIUS 1.0f


/**
 * objectTouched
 *
 * Description: Given an object and a point, cast a ray to see if it collides.
 */
-(Boolean) objectTouched:(CGPoint)winPos object:(ObjectContainer*) unprojectedObject
{	
	Piece * projectedPiece;
	//ObjectContainer * projectedObject;
	
	// Project piece location based on camera location/angle
	glLoadIdentity();
	float cameraTiltZSmooth = 1.6;
	glRotatef(  ((-cameraTiltZSmooth) * 180.0 / M_PI)  , 0.0, 0.0, 1.0); // Tilt 
	gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], 0.0, 1.0, 0.0); 
	projectedPiece = [self multPointByMatrix:[unprojectedObject locX] 
										   y:[unprojectedObject locY] + 1.0 // 1.6  
										   z:[unprojectedObject locZ] ];
	
	/*
	 NSLog(@" 2 %f %f %f ", [[projectedPiece getLocationX] floatValue], 
	 [[projectedPiece getLocationY] floatValue], 
	 [[projectedPiece getLocationZ] floatValue]);
	 */
	
	//gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], 0.0, 1.0, 0.0); 
	
	winPos.y = (float)__viewport[3] - winPos.y;
	
	Point3D nearPoint;
	Point3D farPoint;
	Point3D rayVector;
	
	//Retreiving position projected on near plan
	gluUnProject( winPos.x, winPos.y , 0, __modelview, __projection, __viewport, &nearPoint.x, &nearPoint.y, &nearPoint.z);
	
	//Retreiving position projected on far plan
	gluUnProject( winPos.x, winPos.y,  1, __modelview, __projection, __viewport, &farPoint.x, &farPoint.y, &farPoint.z);
	
	//Processing ray vector
	rayVector.x = farPoint.x - nearPoint.x;
	rayVector.y = farPoint.y - nearPoint.y;
	rayVector.z = farPoint.z - nearPoint.z;
	
	float rayLength = sqrtf(POW2(rayVector.x) + POW2(rayVector.y) + POW2(rayVector.z));
	
	//normalizing ray vector
	rayVector.x /= rayLength;
	rayVector.y /= rayLength;
	rayVector.z /= rayLength;
	
	
	Point3D collisionPoint;
	NSNumber* locX = [projectedPiece getLocationX];
	NSNumber* locY = [projectedPiece getLocationY];
	NSNumber* locZ = [projectedPiece getLocationZ];
	Point3D objectCenter = {[locX floatValue], [locY floatValue], [locZ floatValue]};
	
	//Iterating over ray vector to check collisions
	for(int i = 0; i < RAY_ITERATIONS; i++)
	{
		collisionPoint.x = rayVector.x * rayLength/RAY_ITERATIONS*i;
		collisionPoint.y = rayVector.y * rayLength/RAY_ITERATIONS*i;
		collisionPoint.z = rayVector.z * rayLength/RAY_ITERATIONS*i;
		
		//Checking collision 
		if([Tools poinSphereCollision:collisionPoint center:objectCenter radius:COLLISION_RADIUS])
		{
            // distance
            // *******
            
			return TRUE;
		}
	}
	return FALSE;	
}

-(Boolean) checkCollission:(CGPoint)winPos object:(Piece*) unprojectedPiece
{	
	Piece * projectedPiece;
	
	// Project piece location based on camera location/angle
	glLoadIdentity();
	float cameraTiltZSmooth = 1.6;
	glRotatef(  ((-cameraTiltZSmooth) * 180.0 / M_PI)  , 0.0, 0.0, 1.0); // Tilt 
	gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], 0.0, 1.0, 0.0); 
	projectedPiece = [self multPointByMatrix:[[unprojectedPiece getLocationX] floatValue] 
									   y:[[unprojectedPiece getLocationY] floatValue] 
									   z:[[unprojectedPiece getLocationZ] floatValue]];
	
	/*
	NSLog(@" 2 %f %f %f ", [[projectedPiece getLocationX] floatValue], 
			[[projectedPiece getLocationY] floatValue], 
		  [[projectedPiece getLocationZ] floatValue]);
	*/
	
	//gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2], 0.0, 1.0, 0.0); 
	
	winPos.y = (float)__viewport[3] - winPos.y;
	
	Point3D nearPoint;
	Point3D farPoint;
	Point3D rayVector;
	
	//Retreiving position projected on near plan
	gluUnProject( winPos.x, winPos.y , 0, __modelview, __projection, __viewport, &nearPoint.x, &nearPoint.y, &nearPoint.z);
	
	//Retreiving position projected on far plan
	gluUnProject( winPos.x, winPos.y,  1, __modelview, __projection, __viewport, &farPoint.x, &farPoint.y, &farPoint.z);
	
	//Processing ray vector
	rayVector.x = farPoint.x - nearPoint.x;
	rayVector.y = farPoint.y - nearPoint.y;
	rayVector.z = farPoint.z - nearPoint.z;
	
	float rayLength = sqrtf(POW2(rayVector.x) + POW2(rayVector.y) + POW2(rayVector.z));
	
	//normalizing ray vector
	rayVector.x /= rayLength;
	rayVector.y /= rayLength;
	rayVector.z /= rayLength;
	
	
	Point3D collisionPoint;
	NSNumber* locX = [projectedPiece getLocationX];
	NSNumber* locY = [projectedPiece getLocationY];
	NSNumber* locZ = [projectedPiece getLocationZ];
	Point3D objectCenter = {[locX floatValue], [locY floatValue], [locZ floatValue]};
	
	//Iterating over ray vector to check collisions
	for(int i = 0; i < RAY_ITERATIONS; i++)
	{
		collisionPoint.x = rayVector.x * rayLength/RAY_ITERATIONS*i;
		collisionPoint.y = rayVector.y * rayLength/RAY_ITERATIONS*i;
		collisionPoint.z = rayVector.z * rayLength/RAY_ITERATIONS*i;
		
		//Checking collision 
		if([Tools poinSphereCollision:collisionPoint center:objectCenter radius:COLLISION_RADIUS])
		{
			return TRUE;
		}
	}
	return FALSE;	
}

/**
 * Depricate???
 */
/*
-(void) buttonPush:(CGPoint)winPos // object:(Piece*) _object
{	
	winPos.y = (float)__viewport[3] - winPos.y;
	
	Point3D nearPoint;
	Point3D farPoint;
	Point3D rayVector;
	
	//Retreiving position projected on near plan
	gluUnProject( winPos.x, winPos.y , 0, __modelview, __projection, __viewport, &nearPoint.x, &nearPoint.y, &nearPoint.z);
	
	//Retreiving position projected on far plan
	gluUnProject( winPos.x, winPos.y,  1, __modelview, __projection, __viewport, &farPoint.x, &farPoint.y, &farPoint.z);
	
	//Processing ray vector
	rayVector.x = farPoint.x - nearPoint.x;
	rayVector.y = farPoint.y - nearPoint.y;
	rayVector.z = farPoint.z - nearPoint.z;
	
	float rayLength = sqrtf(POW2(rayVector.x) + POW2(rayVector.y) + POW2(rayVector.z));
	
	//normalizing ray vector
	rayVector.x /= rayLength;
	rayVector.y /= rayLength;
	rayVector.z /= rayLength;
	
	
	Point3D collisionPoint;
	//NSNumber* locX = [_object getLocationX];
	//NSNumber* locY = [_object getLocationY];
	//NSNumber* locZ = [_object getLocationZ];
	

	Point3D objectCenter = {3.35, 3.88,  -7};
	//Iterating over ray vector to check collisions
	for(int i = 0; i < RAY_ITERATIONS; i++)
	{
		collisionPoint.x = rayVector.x * rayLength/RAY_ITERATIONS*i;
		collisionPoint.y = rayVector.y * rayLength/RAY_ITERATIONS*i;
		collisionPoint.z = rayVector.z * rayLength/RAY_ITERATIONS*i;
		
		//Checking collision 
		if([Tools poinSphereCollision:collisionPoint center:objectCenter radius:COLLISION_RADIUS])
		{
			currentLevelIndex--;
			//reachedLevel--;
			//if([levels count] <= reachedLevel){
			//	reachedLevel = ([levels count] - 1);
			//}
			if(currentLevelIndex < 0){
				currentLevelIndex = 0;
			}
			
			// Save level reached
			//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			//[defaults setObject:[NSNumber numberWithInt: reachedLevel] forKey: @"reachedLevel"];
			//[defaults synchronize];
			
			// load
			[self load:view];			
		}
	}
	
	
	Point3D nextButtonCenter = {3.35, -3.9,  -7};
	//Iterating over ray vector to check collisions
	for(int i = 0; i < RAY_ITERATIONS; i++)
	{
		collisionPoint.x = rayVector.x * rayLength/RAY_ITERATIONS*i;
		collisionPoint.y = rayVector.y * rayLength/RAY_ITERATIONS*i;
		collisionPoint.z = rayVector.z * rayLength/RAY_ITERATIONS*i;
		
		//Checking collision 
		if([Tools poinSphereCollision:collisionPoint center:nextButtonCenter radius:COLLISION_RADIUS])
		{
			if(currentLevelIndex == ([levels count] - 1)){ // Restart
				currentLevelIndex = 0;
				reachedLevel = 0;
				
				// Save level reached
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setObject:[NSNumber numberWithInt: reachedLevel] forKey: @"reachedLevel"];
				[defaults synchronize];
				
			} else {	// next
			
				//NSLog(@"Next");
				currentLevelIndex++;
				if(currentLevelIndex > reachedLevel){
					currentLevelIndex = reachedLevel;
				}
				//if([levels count] <= reachedLevel){
				//	reachedLevel = ([levels count] - 1);
				//}
				
			}
			
			// load
			[self load:view];
		}
	}
	
	
	
	
}
*/


/**
* getLocationOfTouch
* 
* Description: used to find 3d point of 2d touch location.
*    // d:(NSNumber*)d
*/
-(Piece *) getLocationOfTouch:(CGPoint)winPos  
{	
	NSNumber * d = [NSNumber numberWithFloat:[[movingPiece getLocationZ] floatValue] ];
	

	//CGPoint point = [CGPoint alloc];
	Piece * p = [[Piece alloc] autorelease];
	winPos.y = (float)__viewport[3] - winPos.y;
	
	Point3D nearPoint;
	Point3D farPoint;
	Point3D rayVector;
	
	//Retreiving position projected on near plan
	gluUnProject( winPos.x, winPos.y , 0, __modelview, __projection, __viewport, &nearPoint.x, &nearPoint.y, &nearPoint.z);
	
	//Retreiving position projected on far plan
	gluUnProject( winPos.x, winPos.y,  1, __modelview, __projection, __viewport, &farPoint.x, &farPoint.y, &farPoint.z);
	
	//Processing ray vector
	rayVector.x = farPoint.x - nearPoint.x;
	rayVector.y = farPoint.y - nearPoint.y;
	rayVector.z = farPoint.z - nearPoint.z;
	
	float rayLength = sqrtf(POW2(rayVector.x) + POW2(rayVector.y) + POW2(rayVector.z));
	
	//normalizing ray vector
	rayVector.x /= rayLength;
	rayVector.y /= rayLength;
	rayVector.z /= rayLength;
	
	
	Point3D collisionPoint;
	//NSNumber* locX = [_object getLocationX];
	//NSNumber* locY = [_object getLocationY];
	//NSNumber* locZ = [_object getLocationZ];
	//Point3D objectCenter = {[locX floatValue], [locY floatValue], [locZ floatValue]};
	
	//Iterating over ray vector to check collisions
	for(int i = 0; i < RAY_ITERATIONS; i++)
	{
		collisionPoint.x = rayVector.x * rayLength/RAY_ITERATIONS*i;
		collisionPoint.y = rayVector.y * rayLength/RAY_ITERATIONS*i;
		collisionPoint.z = rayVector.z * rayLength/RAY_ITERATIONS*i;
	
		if(collisionPoint.z < [d floatValue]){
			//NSLog(@"  %f %f %f "  , collisionPoint.x, collisionPoint.y, collisionPoint.z );
		
			//point.x = collisionPoint.x;
			//point.y = collisionPoint.y;
			
			i = RAY_ITERATIONS;
			
			//[p setLocationX: [NSNumber numberWithFloat: collisionPoint.x]];
			//[p setLocationY: [NSNumber numberWithFloat: collisionPoint.y]];
			
			// While tilted right angle
			[p setLocationX: [NSNumber numberWithFloat: -collisionPoint.y]];
			[p setLocationY: [NSNumber numberWithFloat: collisionPoint.x]];
			
		}
		
		//Checking collision 
		//if([Tools poinSphereCollision:collisionPoint center:objectCenter radius:COLLISION_RADIUS])
		//{
		//	return TRUE;
		//}
	}
	return p;
}


-(void)shutdownWarning {
    NSLog(@" Shutdown warning ");
    
    [levelLoader shutdownWarning];
    
    //[saveGame save];
    //if([[levelLoader saveGame] isTimeToGetUpdate]){
    //    NSLog(@"")
    //}
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
	NSString* name = [attributeDict objectForKey: @"name" ];
	NSString* image = [attributeDict objectForKey: @"image" ];
	NSNumber* piecesWide = [attributeDict objectForKey: @"piecesWide" ];
	NSNumber* piecesHigh = [attributeDict objectForKey: @"piecesHigh" ];
	//NSLog(@" parse %@ ", name);
	if(name != nil ){
		Level* level = [[[Level alloc] init] autorelease];
		[level setTitle: [NSString stringWithString: name]];
		[level setImageName: [NSString stringWithString: image ]];
		[level setPiecesWide:piecesWide];
		[level setPiecesHigh:piecesHigh];
		
		[levels addObject:level]; 
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
}



- (void)dealloc 
{
	//[sectionTitlesArray release];
	[s release];
	[hud release];
	[bullets release];
	
	[avatarLocation release];
	//[saveGame release];
    
    [super dealloc];
}
@end
