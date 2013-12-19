//
//  Sound.m
//  Vampires
//
//  Created by Jon Taylor on 11-04-25.
//  Copyright 2011 Subject Reality Software. All rights reserved.
//

#import "Sound.h"
#import <AVFoundation/AVFoundation.h>

@implementation Sound


- (id)init {
    self = [super init];
    if (self) {
        
        musicMode = @"danger";
        
        //NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"diatonis_traj_one-to-be_sur" ofType:@"mp3"]]; 
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound1" ofType:@"caf"]]; 
        collectAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
         
        
        // gunshot.wav Skorpion.mp3
        NSURL *url2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Skorpion" ofType:@"wav"]]; 
        gunshotAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url2 error:nil];
        [gunshotAudioPlayer setVolume: 0.4];
        
        
        NSURL *urlHurt = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Punch_HD" ofType:@"wav"]]; 
        hurtAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlHurt error:nil];
        
        
        NSURL *painUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Buzzer" ofType:@"wav"]]; 
        painAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:painUrl error:nil];
        [painAudioPlayer setVolume: 0.05];
        
        
        
        NSURL *url3 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fun" ofType:@"mp3"]]; 
        menuAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url3 error:nil];
        [menuAudioPlayer setVolume: 0.1];
        [menuAudioPlayer setNumberOfLoops: -1];
        
        funVolume = 0.1;
        NSURL *url4 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fun" ofType:@"mp3"]]; 
        funAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url4 error:nil];
        [funAudioPlayer setVolume: funVolume];
        [funAudioPlayer setNumberOfLoops: -1];
        
        
        NSURL *url5 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"danger" ofType:@"mp3"]]; 
        dangerAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url5 error:nil];
        [dangerAudioPlayer setVolume: 0.1];
        [dangerAudioPlayer setNumberOfLoops: -1];
        dangerVolume = 0.1;
        
        NSURL *danger2Url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"danger2" ofType:@"mp3"]]; 
        danger2AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:danger2Url error:nil];
        [danger2AudioPlayer setVolume: 0.1];
        [danger2AudioPlayer setNumberOfLoops: -1];
        danger2Volume = 0.1;
        
        
        NSURL *sunnydayUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SunnyDay" ofType:@"mp3"]]; 
        sunnyDayAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:sunnydayUrl error:nil];
        [sunnyDayAudioPlayer setVolume: 0.1];
        [sunnyDayAudioPlayer setNumberOfLoops: -1];
        sunnyDayVolume = 0.1;
        
        
        // Panic.mps - play when dead
        NSURL *panicUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Panic" ofType:@"mp3"]]; 
        panicAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:panicUrl error:nil];
        [panicAudioPlayer setVolume: 1.0];
        [panicAudioPlayer setNumberOfLoops: 0];
        
        
        // Pat.mp3 - play when walking
        NSURL *patUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Pat" ofType:@"wav"]]; 
        patAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:patUrl error:nil];
        [patAudioPlayer setVolume: 0.15];
        [patAudioPlayer setNumberOfLoops: 0];
        
        
        //  - avatar being attacked
        
        
        
    }
    return self;
}


/**
 * setMusicMode
 *
 * Description: 
 */
- (void)setMusicMode:(NSString *) m {
    if([musicMode compare:m] != 0){ // mode changed
        NSLog(@" Music Mode Changed ");
        
        [self stopMusic];
        
        if([m compare:@"danger"] == 0){
            // dangerAudioPlayer
            // danger2AudioPlayer
            // Haunting
            
            int ind = arc4random() % 2;
            if(ind == 0){
                //[dangerAudioPlayer play];
                [self dangerFadeIn];
            }
            if(ind == 1){
                //[danger2AudioPlayer play];
                [self danger2FadeIn];
            }
            
        }
        if([m compare:@"safe"] == 0){
            // fun funAudioPlayer
            // suny day sunnyDayAudioPlayer
            int ind = arc4random() % 2;
            if(ind == 0){
                //[sunnyDayAudioPlayer play];
                [self sunnyDayFadeIn];
            }
            if(ind == 1){
                //[funAudioPlayer play];
                [self funFadeIn];
            }
        }    
        
    }
    musicMode = m;
}

- (void) stopMusic {
    //[sunnyDayAudioPlayer stop];
    if([sunnyDayAudioPlayer isPlaying]){
        [self sunnyDayFadeOut];
    }
    
    //[funAudioPlayer stop];
    if([funAudioPlayer isPlaying]){
        [self funFadeOut];
    }
    
    //[danger2AudioPlayer stop];
    if([danger2AudioPlayer isPlaying]){
        [self danger2FadeOut];
    }
    
    //[dangerAudioPlayer stop];
    if([dangerAudioPlayer isPlaying]){
        [self dangerFadeOut];
    }
}


/**
 * dangerAudioPlayerFadeIn
 *
 * Description: play low volume and increase
 */
- (void)dangerFadeIn {
    float volume = [dangerAudioPlayer volume];
    if(volume == dangerVolume){ 
        volume = 0;
    }
    volume += (dangerVolume/10.0); // increase
    //NSLog(@"danger volume: %f ", volume);
    [dangerAudioPlayer setVolume:volume];
    if(![dangerAudioPlayer isPlaying]){
        [dangerAudioPlayer play];
    }
    if(volume < dangerVolume){
        [self performSelector:@selector(dangerFadeIn) withObject:nil afterDelay:0.1];
    } else {
        volume = dangerVolume; // done
    }
}

- (void)dangerFadeOut {
    float volume = [dangerAudioPlayer volume];
    if(volume == 0){ 
        volume = dangerVolume;
    }
    volume -= (dangerVolume/10.0); // decrease
    if(volume < 0){
        volume = 0;
    }
    //NSLog(@"danger volume: %f ", volume);
    [dangerAudioPlayer setVolume:volume];
    
    if(volume > 0){
        [self performSelector:@selector(dangerFadeOut) withObject:nil afterDelay:0.1];
    } else {
        volume = 0; // done
        
        if([dangerAudioPlayer isPlaying]){
            [dangerAudioPlayer stop];
            //NSLog(@"danger stop");
        }
    }
}



- (void)danger2FadeIn {
    float volume = [danger2AudioPlayer volume];
    if(volume == danger2Volume){ 
        volume = 0;
    }
    volume += (danger2Volume/10.0); // increase
    //NSLog(@"danger volume: %f ", volume);
    [danger2AudioPlayer setVolume:volume];
    if(![danger2AudioPlayer isPlaying]){
        [danger2AudioPlayer play];
    }
    if(volume < danger2Volume){
        [self performSelector:@selector(danger2FadeIn) withObject:nil afterDelay:0.1];
    } else {
        volume = danger2Volume; // done
    }
}

- (void)danger2FadeOut {
    float volume = [danger2AudioPlayer volume];
    if(volume == 0){ 
        volume = danger2Volume;
    }
    volume -= (danger2Volume/10.0); // decrease
    if(volume < 0){
        volume = 0;
    }
    //NSLog(@"danger volume: %f ", volume);
    [danger2AudioPlayer setVolume:volume];
    
    if(volume > 0){
        [self performSelector:@selector(danger2FadeOut) withObject:nil afterDelay:0.1];
    } else {
        volume = 0; // done
        
        if([danger2AudioPlayer isPlaying]){
            [danger2AudioPlayer stop];
            //NSLog(@"danger stop");
        }
    }
}





- (void)sunnyDayFadeIn {
    float volume = [sunnyDayAudioPlayer volume];
    if(volume == sunnyDayVolume){ 
        volume = 0;
    }
    volume += (sunnyDayVolume/10.0); // increase
    //NSLog(@"sunnyday in volume: %f ", volume);
    [sunnyDayAudioPlayer setVolume:volume];
    if(![sunnyDayAudioPlayer isPlaying]){
        [sunnyDayAudioPlayer play];
    }
    if(volume < sunnyDayVolume){
        [self performSelector:@selector(sunnyDayFadeIn) withObject:nil afterDelay:0.1];
    } else {
        volume = sunnyDayVolume; // done
    }
}

- (void)sunnyDayFadeOut {
    float volume = [sunnyDayAudioPlayer volume];
    if(volume == 0){ 
        volume = sunnyDayVolume;
    }
    volume -= (sunnyDayVolume/10.0); // decrease
    if(volume < 0){
        volume = 0;
    }
    //NSLog(@"sunnyday out volume: %f ", volume);
    [sunnyDayAudioPlayer setVolume:volume];
    
    if(volume > 0){
        [self performSelector:@selector(sunnyDayFadeOut) withObject:nil afterDelay:0.1];
    } else {
        volume = 0; // done
        if([sunnyDayAudioPlayer isPlaying]){
            [sunnyDayAudioPlayer stop];
        }
    }
}




- (void)funFadeIn {
    float volume = [funAudioPlayer volume];
    if(volume == funVolume){ 
        volume = 0;
    }
    volume += (funVolume/10.0); // increase
    //NSLog(@"sunnyday in volume: %f ", volume);
    [funAudioPlayer setVolume:volume];
    if(![funAudioPlayer isPlaying]){
        [funAudioPlayer play];
    }
    if(volume < funVolume){
        [self performSelector:@selector(funFadeIn) withObject:nil afterDelay:0.1];
    } else {
        volume = sunnyDayVolume; // done
    }
}

- (void)funFadeOut {
    float volume = [funAudioPlayer volume];
    if(volume == 0){ 
        volume = funVolume;
    }
    volume -= (funVolume/10.0); // decrease
    if(volume < 0){
        volume = 0;
    }
    //NSLog(@"sunnyday out volume: %f ", volume);
    [funAudioPlayer setVolume:volume];
    
    if(volume > 0){
        [self performSelector:@selector(funFadeOut) withObject:nil afterDelay:0.1];
    } else {
        volume = 0; // done
        if([funAudioPlayer isPlaying]){
            [funAudioPlayer stop];
        }
    }
}





- (void)playerDied {
    [menuAudioPlayer stop];
    [dangerAudioPlayer stop];
    
    [panicAudioPlayer play];
}

- (void)playerWalking {
    [patAudioPlayer play];
}


- (void)playerAttacked {
    if(![painAudioPlayer isPlaying]){
        [painAudioPlayer play];
    }
}


// 

- (void)playMenu {
    
    [menuAudioPlayer play];
}

- (void)stopMenu {
    [menuAudioPlayer stop];
}

- (void)playFun {
    //[funAudioPlayer play];
}

- (void)stopFun {
    [funAudioPlayer stop];
    [funAudioPlayer setVolume:0];
}

- (void)playDanger {
    [dangerAudioPlayer play];
}

- (void)stopDanger {
    [dangerAudioPlayer stop];
    [dangerAudioPlayer setVolume:0];
}


- (void)playCollect {
	[collectAudioPlayer play];
}


- (void)playGunshot {
	[gunshotAudioPlayer play];
}

- (void)playHurt {
	[hurtAudioPlayer play];
}


- (void) levelLoaded:(NSString*)name {
    if([name compare:@"Main Menu"] != 0){
        [self stopMenu];
        
        [self stopMusic];
        [self dangerFadeIn];
        //[self playDanger];
    }
}


- (void)dealloc {
    [collectAudioPlayer release];
    [gunshotAudioPlayer release];
    
    [super dealloc];
}

@end
