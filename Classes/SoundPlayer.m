//
//  Sound.m
//  ___PROJECTNAME___
//
//  Created by Jon taylor on 10-12-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundPlayer.h"
#import <AVFoundation/AVFoundation.h>



@implementation SoundPlayer

- (void)init
{
	NSLog(@" Sound - init ");
	[super init];
}

- (void)playMusic {
	NSLog(@" Sound - playMusic() ");
	
	//AVAudioPlayer * audioPlayer;
	
	//NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"diatonis_traj_one-to-be_sur" ofType:@"mp3"]]; 
	//audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	//[audioPlayer play];
	
	
}

- (double)test {
	NSLog(@" Sound - test ");
	
	
	return 99;
}

@end
