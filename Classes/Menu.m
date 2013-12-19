//
//  Menu.m
//  OpenGLES13
//
//  Created by Jon taylor on 15/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "Menu.h"

@implementation Menu

- (id)init {
    self = [super init];
    if (self) {
        visible = true;
        currentMenu = @"";
        readingMenu = @"";
        
        titleText = @"";
        
        textures = [[NSMutableArray alloc] init];
        menuNames = [[NSMutableArray alloc] init];
        menuActions = [[NSMutableArray alloc] init];
        menuLoads = [[NSMutableArray alloc] init];
        
        clickedName = @"";
        clickedAction = @"";
        clickedLoad = @"";
	}
	return self;
}

/**
 * Load desired menu items from xml
 *
 */
- (void)load:(NSString*)menuName {
	currentMenu = menuName;
	
	// set main as default
	if(currentMenu == nil || [currentMenu isEqualToString:@""] ){
		currentMenu = @"mainmenu";
	}
	
	// remove old menu items
	[textures removeAllObjects];
	[menuNames removeAllObjects];
	[menuActions removeAllObjects];
	[menuLoads removeAllObjects];
	
	//
	// load XML file
	//
	NSString *path2 = [[NSBundle mainBundle] pathForResource:@"game-definition" ofType:@"xml"];  
	NSData *nsData2 = [NSData dataWithContentsOfFile: path2 ];
	NSXMLParser *xmlParser2 = [[NSXMLParser alloc]  initWithData:nsData2 ];
	[xmlParser2 setDelegate:self];
	[xmlParser2 setShouldProcessNamespaces:NO];
	[xmlParser2 setShouldReportNamespacePrefixes:NO];
	[xmlParser2 setShouldResolveExternalEntities:NO];
	[xmlParser2 parse];
	[xmlParser2 release];
}


/**
 * display the menu items currently loaded.
 *
 */
- (void) displayMenu:(GLView*)view;
{
	if(visible ){
		[self switchToOrtho:view];
	
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
		glEnable(GL_BLEND);
		
		//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 
		glBlendFunc (GL_ONE, GL_ONE);
		
		glColor4f(1.0, 1.0, 1.0, 0.0);
        
        float windowWidth = (float)mView.bounds.size.width; // 768
        float windowHeight = (float)mView.bounds.size.height; // 1024
		
		if(menuNames != nil){
			NSEnumerator* objectIterator = [menuNames objectEnumerator];
			NSString* currMenuName;
			int index = 0;
			while((currMenuName = [objectIterator nextObject]))
			{
				// load texture from cache
				Texture2D* texture = nil;
				if( [textures count] > index ){
					texture = [textures objectAtIndex:index];
				}
				if(texture == nil){
					texture = [[Texture2D alloc] initWithString:currMenuName dimensions:CGSizeMake(50.0, 256.0) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:28.0];
					[textures addObject:texture];
				}
				
                float x = (windowWidth / 2) + 44;  // height in portrait
                float y = (windowHeight / 2) - 15;  // inverted horizontal 
                
				// draw texture
				//[texture drawAtPoint:CGPointMake(-100, (-index * 64) + 54)];
				[texture drawAtPoint:CGPointMake(  (-index * 64) + x, y)]; // (-index * 64) + 204, 230
				index++;
			}
		}
		
		// Title
		if(titleTexture == nil){
			titleTexture = [[Texture2D alloc] initWithString:titleText 
												  dimensions:CGSizeMake(50.0, 246.0) // 
												   alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:28.0];
		}
		//glColor4f(0.4f,0.4f,0.4f,1.0f);
        
        float x = (windowWidth / 2) + 130; 
        float y = (windowHeight / 2) - 15; 
		[titleTexture drawAtPoint:CGPointMake(x, y)]; // y, -x    290,  230
		
		glDisable(GL_BLEND);
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisable(GL_TEXTURE_2D);
		
		
		[self switchBackToFrustum];
	}
}



- (void) setVisible:(bool)vis
{
	//NSLog(@" menu setVisible() ") ;
	if(vis == true){
		visible = true;
	} else {
		visible = false;
	}
}

/**
 * Calling class askes if click was on a menu item.
 *
 */
- (NSString*) touch:(NSNumber*)touchX  y:(NSNumber*)touchY
{
    int x = [touchY intValue];
	int y = [touchX intValue];
    NSLog(@"Menu.touch %d  %d ", x, y);
    
    //CGRect rect = mView.bounds;
    float windowWidth = (float)mView.bounds.size.width; // 768
    float windowHeight = (float)mView.bounds.size.height; // 1024
    
	NSString* result = @"";
	if(visible){
		NSEnumerator* objectIterator = [menuNames objectEnumerator];
		NSString* currMenuName;
		int index = 0;
		while((currMenuName = [objectIterator nextObject]))
		{
            float buttonX = (windowWidth / 2) + 44;  // height in portrait
			int menuHeight = (-index * 64) + buttonX; // + 124;
            
            NSLog(@" x %d   %d ", x, (int)(windowHeight/2));
            NSLog(@" y %d   %d ", y, (int)(menuHeight));
            
            if(x > (windowHeight/2) - 80 && x < (windowHeight/2) + 80 && y > menuHeight -35 && y < menuHeight +10){
				result = currMenuName;
				clickedName = currMenuName;
				clickedAction = [menuActions objectAtIndex:index];
				clickedLoad = [menuLoads objectAtIndex:index];
				visible = false;	
                NSLog(@" menu item selected %@ ", currMenuName);
			}
            
			index++;
		}
	}
	return result;
}


- (NSString*) clickedAction {
	return clickedAction;
}

- (NSString*) clickedLoad {
	return clickedLoad;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
	
	if([elementName isEqualToString:@"mainmenu"] ){
		readingMenu = @"mainmenu";
	}
	if([elementName isEqualToString:@"pausemenu"] ){
		readingMenu = @"pausemenu";
	}
	
	if([elementName isEqualToString:@"game"] ){
		titleText = [[NSString alloc] initWithString: [attributeDict objectForKey: @"title" ]];
	}
	
	//NSLog(@"qName: %@  %@  ", elementName , currentMenu);
	if([elementName isEqualToString:@"menuitem"] && [readingMenu isEqualToString:currentMenu]){
		NSString* name = @"";
		if([attributeDict objectForKey: @"name" ] != nil){
			name = [[NSString alloc] initWithString: [attributeDict objectForKey: @"name" ]];
		}
		if(name == nil){
			name = @"";
		}
		NSString* action = @"";
		if([attributeDict objectForKey: @"action" ] != nil){
			action = [[NSString alloc] initWithString: [attributeDict objectForKey: @"action" ]]; 
		}
		if(action == nil){
			action = @"";
		}
		NSString* load = @"";
		if([attributeDict objectForKey: @"load" ] != nil){
			load = [[NSString alloc] initWithString: [attributeDict objectForKey: @"load" ]];  
		}
		if(load == nil){
			load = @"";
		}
		
		NSLog(@" Add menu item   name: %@  action: %@   load: %@ ", name, action, load);
		[menuNames addObject:name];
		[menuActions addObject:action];
		[menuLoads addObject:load];
		
		//[objects addObject:attributeDict];
		//NSLog(@" Add Object   name: %@   file: %@    x: %f  y: %f z: %f ", name, file, [[object getX] floatValue], [[object getY] floatValue], [[object getZ] floatValue]);
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
}

-(void)switchToOrtho:(GLView*)view 
{
    mView = view;
    
    glDisable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
	
    
    CGRect rect = view.bounds;
    if(rect.size.width > 1216){
        //rect.size.width = 608;
        //rect.size.height = 784;
        //rect.size.width = 320;
        //rect.size.height = 480;
    }
    
    
    glOrthof(0, rect.size.width, 0, rect.size.height, -5, 1);       
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
