//
//  Sound.h
//  Vampires
//
//  Created by Jon Taylor on 11-04-25.
//  Copyright 2011 Subject Reality Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Sound : NSObject {
    
    NSString * musicMode;
    
    AVAudioPlayer * collectAudioPlayer;
    AVAudioPlayer * gunshotAudioPlayer;
    AVAudioPlayer * hurtAudioPlayer;
    AVAudioPlayer * painAudioPlayer;
    
    AVAudioPlayer * menuAudioPlayer;
    AVAudioPlayer * funAudioPlayer;
    float funVolume;
    AVAudioPlayer * dangerAudioPlayer;
    float dangerVolume;
    float danger2Volume;
    AVAudioPlayer * danger2AudioPlayer;
    float sunnyDayVolume;
    AVAudioPlayer * sunnyDayAudioPlayer;
    
    AVAudioPlayer * panicAudioPlayer;
    AVAudioPlayer * patAudioPlayer;
    
    float fade;
}

// events
- (void)setMusicMode:(NSString *)m;
- (void)playerDied;
- (void)playerWalking;
- (void)playerAttacked;


// sounds
- (void)safe;
- (void)danger;

- (void)playCollect;
- (void)playGunshot;
- (void)stopMusic;

- (void)playMenu;
- (void)stopMenu;
- (void)playFun;
- (void)stopFun;
- (void)playDanger;
- (void)stopDanger;
- (void)playHurt;

- (void)levelLoaded:(NSString*)name;

- (void)dangerFadeIn;
- (void)dangerFadeOut;
- (void)danger2FadeIn;
- (void)danger2FadeOut;

- (void)sunnyDayFadeIn;
- (void)sunnyDayFadeOut;
- (void)funFadeIn;
- (void)funFadeOut;

@end
