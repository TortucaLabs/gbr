//
//  ACAudioPlayer.h
//  GBR
//
//  Created by Andrew J Cavanagh on 8/13/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum {
    kIntro = 3,
    kTimeWarp = 6,
    kShiningMoment = 5,
    kPuzzler = 4,
    kHeavenlyMonks= 2,
    kEasyPresentation = 1,
    kCrixus = 0
} musicType;

typedef enum {
    kButtonDown = 0,
    kButtonUp = 1,
    kcoinDrop = 2,
    kwrong = 3,
    kcorrect = 4,
    ktimer = 5
} soundType;

@interface ACAudioPlayer : NSObject <AVAudioPlayerDelegate>
{
    SystemSoundID downPressed;
    SystemSoundID upPressed;
    SystemSoundID coinDrop;
    SystemSoundID correct;
    SystemSoundID wrong;
    SystemSoundID timer;
}

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSArray *musicURLArray;

+ (ACAudioPlayer *)sharedAudioPlayer;
- (void)configureAudioPlayerWithMusic:(musicType)music;
- (void)playInterfaceSoundType:(soundType)sound;
- (void)playMusic;
- (void)stopMusic;
- (void)pauseMusic;

@end
