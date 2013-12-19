//
//  Level.m
//  ___PROJECTNAME___
//
//  Created by Jon taylor on 11-01-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Level.h"


@implementation Level

- (id)init {
    self = [super init];
    if (self) {	
        title = [[NSString alloc] initWithString:@""];
        imageName = [[NSString alloc] initWithString:@""];
        piecesHigh = 3;
        piecesWide = 3;
    }
	return self;
}

-(void)setTitle:(NSString*)x {
	[title release];
	title = [[NSString alloc] initWithString:x];
}

-(NSString*)getTitle {
	return [NSString stringWithString: title];
}

-(void)setImageName:(NSString*)x {
	[imageName release];
	imageName = [[NSString alloc] initWithString:x];
}

-(NSString*)getImageName {
	return imageName;
}

-(void)setPiecesWide:(NSNumber*)x {
	piecesWide = [x intValue];
}

-(NSNumber*)getPiecesWide {
	return [NSNumber numberWithInt: piecesWide];
}

-(void)setPiecesHigh:(NSNumber*)x {
	piecesHigh = [x intValue];
}

-(NSNumber*)getPiecesHigh {
	return [NSNumber numberWithInt: piecesHigh];
}

- (void)dealloc 
{
	[title release];
	[imageName release];
    [super dealloc];
}

@end
