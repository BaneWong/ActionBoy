//
//  Level.h
//  ___PROJECTNAME___
//
//  Created by Jon taylor on 11-01-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Level : NSObject {
	NSString* title;
	NSString* imageName;
	int piecesWide;
	int piecesHigh;
	
}

-(void)setTitle:(NSString*)x;
-(NSString*)getTitle;
-(void)setImageName:(NSString*)x;
-(NSString*)getImageName;
-(void)setPiecesWide:(NSNumber*)x;
-(NSNumber*)getPiecesWide;
-(void)setPiecesHigh:(NSNumber*)x;
-(NSNumber*)getPiecesHigh;

@end
