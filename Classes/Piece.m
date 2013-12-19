//
//  Piece.m
//  ___PROJECTNAME___
//
//  Created by Jon taylor on 10-12-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Piece.h"


@implementation Piece


- (id)init {
	highlight = 0;
	return self;
}

-(void)setIndex:(NSNumber*)i {
	index = [i intValue];
}
-(NSNumber*)getIndex {
	return [NSNumber numberWithInt:index];
}

-(void)setInPlace:(NSNumber*)i {
	inPlace = [i intValue];
}
-(NSNumber*)getInPlace {
	return [NSNumber numberWithInt:inPlace];
}

-(void)setHighlight:(NSNumber*)i {
	highlight = [i intValue];
}
-(NSNumber*)getHighlight {
	return [NSNumber numberWithInt:highlight];
}

-(void)setLocationX:(NSNumber*)x {
	locationX = [x floatValue];
}
-(NSNumber*)getLocationX {
	return [NSNumber numberWithFloat:locationX];
}

-(void)setLocationY:(NSNumber*)y {
	locationY = [y floatValue];
}
-(NSNumber*)getLocationY {
	return [NSNumber numberWithFloat:locationY];
}

-(void)setLocationZ:(NSNumber*)z {
	locationZ = [z floatValue];
}
-(NSNumber*)getLocationZ {
	return [NSNumber numberWithFloat:locationZ];
}


-(void)setHomeX:(NSNumber*)x {
	homeX = [x floatValue];
}
-(NSNumber*)getHomeX {
	return [NSNumber numberWithFloat:homeX];
}

-(void)setHomeY:(NSNumber*)y {
	homeY = [y floatValue];
}
-(NSNumber*)getHomeY {
	return [NSNumber numberWithFloat:homeY];
}

-(void)setHomeZ:(NSNumber*)z {
	homeZ = [z floatValue];
}
-(NSNumber*)getHomeZ {
	return [NSNumber numberWithFloat:homeZ];
}


-(void)setTextureLeft:(NSNumber*)v {
	textureLeft = [v floatValue];
}
-(NSNumber*)getTextureLeft {
	return [NSNumber numberWithFloat:textureLeft];
}

-(void)setTextureRight:(NSNumber*)v {
	textureRight = [v floatValue];
}
-(NSNumber*)getTextureRight {
	return [NSNumber numberWithFloat:textureRight];
}

-(void)setTextureTop:(NSNumber*)v {
	textureTop = [v floatValue];
}
-(NSNumber*)getTextureTop {
	return [NSNumber numberWithFloat:textureTop];
}

-(void)setTextureBottom:(NSNumber*)v {
	textureBottom = [v floatValue];
}
-(NSNumber*)getTextureBottom {
	return [NSNumber numberWithFloat:textureBottom];
}

- (void)dealloc {
	//NSLog(@" Piece dealloc ");
	[super dealloc];
}

@end
