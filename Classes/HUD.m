//
//  HUD.m
//  PuzzleCities
//
//  Created by Jon taylor on 11-01-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HUD.h"
#import "RateApp.h"

@implementation HUD

- (void)initHUD:(NSString*)text;
{
    points = 0;
    direction = 0;
    changeLevelIndex = 0;
    levelNames = [[NSMutableArray alloc] init];
    windowWidth = 0;
    windowHeight = 0;
    
	[titleTexture release];
	titleTexture = [[Texture2D alloc] initWithString:text
										dimensions:CGSizeMake(30., 200.0) 
										alignment:UITextAlignmentCenter
										font:[UIFont systemFontOfSize:20.0]];
	
    deadTexture = nil;
	
	NSString *thumbpadpath = [[NSBundle mainBundle] pathForResource:@"thumbpad" ofType:@"png"];
	thumbpadTexture = [[Texture2D alloc] initWithImagePath:thumbpadpath sizeToFit:NO   ];
	// UIImageOrientationRightMirrored
	
	NSString *buttonapath = [[NSBundle mainBundle] pathForResource:@"button_a" ofType:@"png"];
	buttonATexture = [[Texture2D alloc] initWithImagePath:buttonapath];
	
	NSString *buttonbpath = [[NSBundle mainBundle] pathForResource:@"button_b" ofType:@"png"];
	buttonBTexture = [[Texture2D alloc] initWithImagePath:buttonbpath];
	
    
    NSString *thumbpadhighlightpath = [[NSBundle mainBundle] pathForResource:@"thumb_highlight" ofType:@"png"];
	thumbpadHighlightTexture = [[Texture2D alloc] initWithImagePath:thumbpadhighlightpath sizeToFit:NO   ];
    
    
    
	NSString *hudpath = [[NSBundle mainBundle] pathForResource:@"hud" ofType:@"png"];
	hudTexture = [[Texture2D alloc] initWithImagePath:hudpath];
	
	NSString *dirPath = [[NSBundle mainBundle] pathForResource:@"arrow" ofType:@"png"];
    //directionTexture = [[MyTexture2D alloc] initWithImagePath:dirPath];
    UIImage * dirImg = [[UIImage alloc] initWithContentsOfFile:dirPath];
    directionTexture = [[MyTexture2D alloc] initWithImage:dirImg];
    
    
    
	//NSLog(@"init HUD");
    
    
    //
	// load XML file
	//
    
    // Development mode only
    //NSString * gameXmlUrl = [NSString stringWithFormat:@"http://subjectreality.appspot.com/getGameXML.jsp"];
    //NSData * nsData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:gameXmlUrl]];
    //  NSString * t = [[NSString alloc] initWithData:nsData encoding:NSASCIIStringEncoding]; 
    //NSLog(t);
    
    
	NSString *path = [[NSBundle mainBundle] pathForResource:@"game-definition" ofType:@"xml"];  
        //NSString *fileText = [NSString stringWithContentsOfFile:path];
	NSData *nsData = [NSData dataWithContentsOfFile: path ];
	
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc]  initWithData:nsData ];
	//XMLParser *parser = [[XMLParser alloc] initXMLParser];
	[xmlParser setDelegate:self];
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];
	[xmlParser parse];
	[xmlParser release];
    
}


/**
 * drawHUD
 *
 * Description: draw hud and thumpad controls.
 */
- (void)drawHUD:(GLView*)view;
{
    [self switchToOrtho:view];
    
    windowWidth = (float)view.bounds.size.width;
    windowHeight = (float)view.bounds.size.height;
    //glColor4f(1.0, 1.0, 1.0, 0.0); //
    
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
    glBlendFunc (GL_ONE, GL_ONE);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); // hmm darker but not right
	//glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA); // no
	
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    //glColor4f(0.5, 0.5, 0.5, 0.2); // very light
	//glColor4f(0.85, 0.85, 0.85, 0.8);
    //glLoadIdentity();
	//float cameraTiltZSmooth = 1.6;
	//glRotatef(  ((-cameraTiltZSmooth) * 180.0 / M_PI)  , 0.0, 1.0, 0.0); // Tilt  
	
	
	if(titleTexture == nil){
		titleTexture = [[Texture2D alloc] initWithString:@""
											dimensions:CGSizeMake(30.0, 200.0) 
											alignment:UITextAlignmentLeft  // UITextAlignmentCenter
											font:[UIFont systemFontOfSize:20.0  ]];
		// boldSystemFontOfSize
	}
	
    
	//[menuTexture drawAtPoint:CGPointMake(305.0, 460.0) depth:-1]; // y, -x
	
	//[titleTexture drawAtPoint:CGPointMake(305.0, 460.0) depth:-1]; // y, -x
	
	
	if(hudTexture != nil){
		glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
        
        // Small
        //float x = windowWidth - 12;
        //float y = windowHeight - 124;
        
        
        float x = windowWidth - 12;
        float y = windowHeight - 144;
        
        
		[hudTexture drawAtPoint:CGPointMake(x, y) depth:-1]; // y, -x  //308.0, 356.0
		glBlendFunc (GL_ONE, GL_ONE);
	}
	
	if(fpsTexture != nil){
        float x = windowWidth - 15;
        float y = 50;
		//[fpsTexture drawAtPoint:CGPointMake(x, y) depth:-1]; // y, -x  
	}
	
	if (healthTexture == nil) {
		[self setHealth: 100 ];
	}
    {
        float x = windowWidth - 18;
        float y = windowHeight - 138;
        [healthTexture drawAtPoint:CGPointMake(x, y) depth:-1]; // y, -x //302.0, 340.0
	}
	
    {
        float x = windowWidth - 18;
        float y = windowHeight - 198;
        if(pointsTexture == nil) { [self setPoints:0]; }
        float pointsXOffset = 0.0;
        if(points > 100){ pointsXOffset = 10; }
        [pointsTexture drawAtPoint:CGPointMake(x, y - pointsXOffset) depth:-1]; // y, -x //302.0, 285.0
	}
	
	if(dialogTexture == nil){ // && ![dialogText isEqualToString: [dialogObject text]] 
		//[self setDialog:[dialogObject text]];
		//[self setDialog:@""];
		//dialogText = [dialogObject text];
		//NSLog(@" dialogs ");
	}
	if(dialogTexture != nil){
	//	[dialogTexture drawAtPoint:CGPointMake(280.0, 310.0) depth:-1]; // y, -x
	}
	
	glColor4f(1, 1, 1, 1.0);
	
	if(thumbpadTexture != nil){
		glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
        float y = (float)view.bounds.size.height - 70;
		[thumbpadTexture drawAtPoint: CGPointMake(73.0, y) depth:-1];
		glBlendFunc (GL_ONE, GL_ONE);
	}
	
	if(buttonATexture != nil){
		glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
		[buttonATexture drawAtPoint: CGPointMake(105.0, 45.0) depth:-1];  // gun
		glBlendFunc (GL_ONE, GL_ONE);
	}
	
    /*
	if(buttonBTexture != nil){
		glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
		[buttonBTexture drawAtPoint: CGPointMake(40.0, 100.0) depth:-1];  // hand
		glBlendFunc (GL_ONE, GL_ONE);
	}
    */
    
    if(thumbpadHighlightTexture != nil && leftTouchX > -1){
        //thumbpadTexture
        glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
        float x = leftTouchX;
        float y = (float)view.bounds.size.height - leftTouchY;
        
        
		[thumbpadHighlightTexture drawAtPoint: CGPointMake(x, y) depth:-1];
		glBlendFunc (GL_ONE, GL_ONE);
    }
    
    
    
    //
    // Direction arrow
    //
    
    if(directionTexture != nil){
		glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
        float x = windowWidth - 12;
        //float y = windowHeight - 236;
    
        float y = windowHeight - 236 - 22;
        
        //y = 14; // right corner
        
        direction += 90;
        [directionTexture drawAtPoint:CGPointMake(x, y) rotatedBy:-direction];
        
		glBlendFunc (GL_ONE, GL_ONE);
	}
    
	
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glBlendFunc(GL_ONE, GL_ONE); // normal for other textures
	
    [self switchBackToFrustum];
}


/**
 * drawInGameMenu
 *
 */
- (void)drawInGameMenu:(GLView*)view;
{
    [self switchToOrtho:view];
    
    windowWidth = (float)view.bounds.size.width;
    windowHeight = (float)view.bounds.size.height;
    
	glColor4f(1, 1, 1, 1.0);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
    glBlendFunc (GL_ONE, GL_ONE);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); // hmm darker but not right
	//glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA); // no
	
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
   
	
    // background image
	if(inGameMenuTexture == nil){ 
		NSString *inGameTexturePath = [[NSBundle mainBundle] pathForResource:@"pause_menu" ofType:@"png"];
		inGameMenuTexture = [[Texture2D alloc] initWithImagePath:inGameTexturePath];
	}
	
	if(inGameMenuTexture != nil){
		glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
        
        // small img
        //float x = (float)view.bounds.size.width -160;
        //float y = (float)view.bounds.size.height - 261;
        float x = (float)view.bounds.size.width - 384;
        float y = (float)view.bounds.size.height - 512;
        
		[inGameMenuTexture drawAtPoint: CGPointMake(x, y) depth:-1];  // y, -x  160.0, 219.0
		glBlendFunc (GL_ONE, GL_ONE);
	}
	
	
	// draw items ...
    /*
	if(inGameLevelTexture == nil){
        [self setLevelString:@"Level"];
    }
	if(inGameLevelTexture != nil){
		[inGameLevelTexture drawAtPoint:CGPointMake(260.0, 370.0) depth:-1];
	}
    */
    
    if(inGameChangeLevelTexture == nil){
        [self setChangeLevelString:@"-  "];
    }
    if(inGameChangeLevelTexture != nil){
	
        float x = (windowWidth / 2) + 60;
        float y = (windowHeight / 2) + 130;
        
        [inGameChangeLevelTexture drawAtPoint:CGPointMake(x, y) depth:-1]; // y, -x  220.0, 370.0
	}
    
    // back next  load buttons
    if(inGameMenuChangeTexture == nil){ 
		NSString *inGameTexturePath = [[NSBundle mainBundle] pathForResource:@"pause_next_load" ofType:@"png"];
		inGameMenuChangeTexture = [[Texture2D alloc] initWithImagePath:inGameTexturePath];
	}
	if(inGameMenuChangeTexture != nil){
		glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
		
        float x = windowWidth / 2;
        float y = windowHeight / 2;
        
        [inGameMenuChangeTexture drawAtPoint: CGPointMake(x, y) depth:-1];  // y, -x   160.0, 240.0
		glBlendFunc (GL_ONE, GL_ONE);
	}
    
    
    // Rate Share
    if(rateShareTexture == nil){ 
        NSString *inGameTexturePath = [[NSBundle mainBundle] pathForResource:@"rate" ofType:@"png"];
		rateShareTexture = [[Texture2D alloc] initWithImagePath:inGameTexturePath];
    }
    if(rateShareTexture != nil){
		glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
		
        float x = (windowWidth / 2) - 110;
        float y = windowHeight / 2;
        
        [rateShareTexture drawAtPoint: CGPointMake(x, y) depth:-1];  // y, -x   160.0, 240.0
		glBlendFunc (GL_ONE, GL_ONE);
	}
    
    
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glBlendFunc(GL_ONE, GL_ONE); // normal for other textures
	
    [self switchBackToFrustum];
}


/**
 * reloadAccessableLevels
 *
 * Description: load accessable level data from preferences.
 *  only display available levels on selection menu.
 */
- (void)reloadAccessableLevels {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];                
    //if (defaults) 
    //    resumeLevel = [defaults objectForKey:@"lastPlayedLevel"];
    
    for(int i = 0; i < [levelNames count]; i++){
        NSString* currLevel = [levelNames objectAtIndex:i];
        //NSLog(@"  compare: %@   %@ ", currLevel, levelString );
        
        NSString * levelVisible = nil;
        
        if(defaults){
            NSString * key = [[NSString alloc] initWithFormat:@"available_%@", currLevel];
            levelVisible = [defaults objectForKey:key];
        }
        
        if([currLevel isEqualToString:levelString]){
    
        }
    }
}



/**
 * drawLoading
 *
 *
 */
- (void)drawLoading:(GLView*)view;
{
    [self switchToOrtho:view];
	glColor4f(1, 1, 1, 1.0);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
    glBlendFunc (GL_ONE, GL_ONE);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    windowWidth = (float)view.bounds.size.width; // 768
    windowHeight = (float)view.bounds.size.height; // 1024
    
	
    // background
    /*
	if(inGameMenuTexture == nil){ 
		NSString *inGameTexturePath = [[NSBundle mainBundle] pathForResource:@"pause_menu" ofType:@"png"];
		inGameMenuTexture = [[Texture2D alloc] initWithImagePath:inGameTexturePath];
	}
	if(inGameMenuTexture != nil){
		glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
		[inGameMenuTexture drawAtPoint: CGPointMake(160.0, 219.0) depth:-1];  // y, -x
		glBlendFunc (GL_ONE, GL_ONE);
	}
	*/

	// draw items ...
	if(loadingTexture == nil){
        loadingTexture = [[Texture2D alloc] initWithString:@"Loading"
                                                    dimensions:CGSizeMake(70, 230.0) // y, x    
                                                     alignment:UITextAlignmentLeft
                                                      font:[UIFont systemFontOfSize:34.0] offset:10 ];   
    }
	if(loadingTexture != nil){
        
        float x = (windowWidth / 2) + 20;
        float y = (windowHeight / 2) - 40; 
        
		[loadingTexture drawAtPoint:CGPointMake(x, y) depth:-1];   // 180.0, 200.0
	}
	
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glBlendFunc(GL_ONE, GL_ONE); // normal for other textures
	
    [self switchBackToFrustum];
}



/**
 * drawDeadScreen
 *
 * Description:
 */
- (void)drawDeadScreen:(GLView*)view
{
    
    [self switchToOrtho:view];
	glColor4f(1, 1, 1, 1.0);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
    glBlendFunc (GL_ONE, GL_ONE);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    
    float windowWidth = (float)view.bounds.size.width; // 768
    float windowHeight = (float)view.bounds.size.height; // 1024
	
    // background
    /*
     if(inGameMenuTexture == nil){ 
     NSString *inGameTexturePath = [[NSBundle mainBundle] pathForResource:@"pause_menu" ofType:@"png"];
     inGameMenuTexture = [[Texture2D alloc] initWithImagePath:inGameTexturePath];
     }
     if(inGameMenuTexture != nil){
     glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA); 
     [inGameMenuTexture drawAtPoint: CGPointMake(160.0, 219.0) depth:-1];  // y, -x
     glBlendFunc (GL_ONE, GL_ONE);
     }
     */
    
	// draw items ...
	if(deadTexture == nil){
        deadTexture = [[Texture2D alloc] initWithString:@"You Died"
                                                dimensions:CGSizeMake(70, 230.0) // y, x
                                                 alignment:UITextAlignmentLeft
                                                      font:[UIFont systemFontOfSize:34.0] offset:10 ];   
    }
	if(deadTexture != nil){
        
        float x = (windowWidth / 2) + 20;
        float y = (windowHeight / 2) - 40; 
        
		[deadTexture drawAtPoint:CGPointMake(x, y) depth:-1];  
	}
	
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glBlendFunc(GL_ONE, GL_ONE); // normal for other textures
	
    [self switchBackToFrustum];
}



- (void)setHealth:(int)h
{
	if(h != points || healthTexture == nil){
        [healthTexture release];
        NSString* healthString = [[NSString alloc] initWithFormat:@"%d", h];
        healthTexture = [[Texture2D alloc] initWithString:healthString
                                            dimensions:CGSizeMake(30, 200.0) 
                                             alignment:UITextAlignmentCenter
                                                  font:[UIFont systemFontOfSize:16.0]];
        [healthString release];
	}
}

- (void)setPoints:(int)p
{
    if(p != points || pointsTexture == nil){
        [pointsTexture release];
        NSString* pointsString = [[NSString alloc] initWithFormat:@"%d", p];
        pointsTexture = [[Texture2D alloc] initWithString:pointsString
                                               dimensions:CGSizeMake(30., 200.0) 
                                                alignment:UITextAlignmentCenter
                                                     font:[UIFont systemFontOfSize:16.0]];
        [pointsString release];
        
        points = p;
    }
}

- (void)setDialog:(NSNumber*)text
{
	[dialogTexture release];
	NSString* dialogString = [[NSString alloc] initWithFormat:@"%@", text];
	dialogTexture = [[Texture2D alloc] initWithString:dialogString
										   dimensions:CGSizeMake(30, 200.0) // y, x
											alignment:UITextAlignmentCenter
												 font:[UIFont systemFontOfSize:20.0]];
	[dialogString release];
}

- (void) setLevelString:(NSString*)v
{
    [v retain];
    [levelString release];
    levelString = v; //[[NSString alloc] initWithFormat:@"Current Level: %@", v];
    
    [inGameLevelTexture release];
    inGameLevelTexture = [[Texture2D alloc] initWithString:levelString
                                    dimensions:CGSizeMake(30, 200.0) 
                                     alignment:UITextAlignmentLeft
                                          font:[UIFont systemFontOfSize:20.0]];
    
    
    // find index value
    for(int i = 0; i < [levelNames count]; i++){
        NSString* currLevel = [levelNames objectAtIndex:i];
        //NSLog(@"  compare: %@   %@ ", currLevel, levelString );
        if([currLevel isEqualToString:levelString]){
            changeLevelIndex = i;
            [self setChangeLevelString:@""];
            i = [levelNames count];
        }
    }
    //NSLog(@" changeLevelIndex  %d ", changeLevelIndex);
}



/**
 * setChangeLevelString
 *
 */
- (void) setChangeLevelString:(NSString*)v
{
    //[v retain];
    //[changeLevelString release];
    //changeLevelString = [[NSString alloc] initWithFormat:@"Load: %@", v];
    
    // changeLevelIndex
    NSString* currLevel = [levelNames objectAtIndex:changeLevelIndex];
    //NSEnumerator* levelNameIterator = [levelNames objectEnumerator];
	//NSString* currLevel;
	//while(currLevel = [levelNameIterator nextObject])
	//{
        NSLog(@"currLevel: %@", currLevel); 
        
        changeLevelString = [NSString stringWithFormat: @"%@" ,  currLevel ];
    //}
    
    [inGameChangeLevelTexture release];
    inGameChangeLevelTexture = [[Texture2D alloc] initWithString:changeLevelString
                                                dimensions:CGSizeMake(35, 200.0) // 
                                                 alignment:UITextAlignmentLeft
                                                      font:[UIFont systemFontOfSize:34.0] 
                                                          offset:10];
}


- (void)setFps:(NSNumber*)fps
{
	[fps retain];
	[fpsTexture release];
	NSString* fpsString = [[NSString alloc] initWithFormat:@"FPS: %d", [fps intValue]];
	fpsTexture = [[Texture2D alloc] initWithString:fpsString
										  dimensions:CGSizeMake(30, 180.0) 
										   alignment:UITextAlignmentCenter
												font:[UIFont systemFontOfSize:16.0]];
	//NSLog(@"FPS: %f ",[fps floatValue] );
	[fpsString release];
	[fps release];
}


- (void) setDirection:(float)dir
{
    direction = dir;
}


/**
 * touch
 *
 */
- (NSString*) touch:(int)touchX  y:(int)touchY
{
    // rotate 90 degres
    int temp = touchX;
    touchX = touchY;
    touchY = temp;
    NSString* result = nil;
    
    
    float x = 0; //windowWidth / 2;
    float y = 0; //windowHeight / 2;
    if(windowHeight == 1024){
        x = 270; // 80  //(windowHeight / 2) - 480;
        y = 225; //  (windowWidth / 2) -320 ;
    }
    if(windowHeight == 960){ // 3.5 Retina
        x = 260;
        y = 157;
    }
    if(windowHeight == 1136){ // 4 Retina
        x = 350;
        y = 157;
    }
    
    // 350 384
    
    NSLog(@" touch  x: %d  y: %d ", touchX, touchY);
    //NSLog(@" levels: %d ", [levelNames count]);
    
    if(touchX > 17 + x && touchX < 139 + x && touchY > 135 + y && touchY < 182 + y){
        NSLog(@"Back");
        if(changeLevelIndex > 0){
            changeLevelIndex--;
        }
        //[self setChangeLevelString:[levelNames objectAtIndex:changeLevelIndex]];
        [self setChangeLevelString:@""];
        //NSLog(@"   changeLevelIndex  %@ ", [levelNames objectAtIndex:changeLevelIndex] );
    }
    if(touchX > 163 + x && touchX < 286 + x && touchY > 135 + y && touchY < 182 + y){
        NSLog(@"Next");
        
        if(changeLevelIndex < [levelNames count] -1){
            changeLevelIndex++;
        }
        
        // is next layer available? (unlocked)
        bool available = true;
        NSString * nextLevelName = [levelNames objectAtIndex:changeLevelIndex];
        if([nextLevelName compare:@"Main Menu"] != 0 && [nextLevelName compare:@"The End"] != 0){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if(defaults){
                NSString * availableKey = [[NSString alloc] initWithFormat:@"available_%@", nextLevelName];
                NSString * levelVisible = [defaults objectForKey:availableKey];
                if(levelVisible == nil){
                    available = false;
                    changeLevelIndex--;
                    NSLog(@"level not available: %@", nextLevelName);
                }
            }
        }
        
        if(available){
            [self setChangeLevelString:[levelNames objectAtIndex:changeLevelIndex]];
        }
    }
    if(touchX > 343 + x && touchX < 464 + x && touchY > 135 + y && touchY < 182 + y){
        NSLog(@"Load");
        
        result = [levelNames objectAtIndex:changeLevelIndex];
    }
    
    
    if(touchX > 15 + x && touchX < 206 + x && touchY > 12 + y && touchY < 84 + y){
        NSLog(@"Rate");
        RateApp * rate = [[RateApp alloc] init];
        [rate rateApp];
    }
    
    if(touchX > 271 + x && touchX < 467 + x && touchY > 12 + y && touchY < 84 + y){
        NSLog(@"Share");
        RateApp * rate = [[RateApp alloc] init];
        [rate shareWithFriends];
    }
    
    return result;
}



- (void) setLeftTouch:(int)x y:(int)y {
    leftTouchX = x;
    leftTouchY = y;
}





/**
 * Parse XML for layer configuration.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
	if([elementName isEqualToString:@"level"] ){
		
        NSString * readingLevel = [attributeDict objectForKey: @"name" ];
        [readingLevel retain];
        NSLog(@"        elementName %@ ", readingLevel);
        
        if( ![readingLevel isEqualToString:@"Main Menu"] ){
            [levelNames addObject:readingLevel];
        }
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qNam {     
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
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

- (void)dealloc 
{
	[titleTexture release];
	[healthTexture release];
	[dialogTexture release];
	[pointsTexture release];
	[fpsTexture release];
	
	[thumbpadTexture release];
    
    [loadingTexture release];
    [deadTexture release];
	
    [super dealloc];
}

@end
