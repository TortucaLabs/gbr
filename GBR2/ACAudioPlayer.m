//
//  ACAudioPlayer.m
//  GBR
//
//  Created by Andrew J Cavanagh on 8/13/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import "ACAudioPlayer.h"

@implementation ACAudioPlayer

+ (ACAudioPlayer *)sharedAudioPlayer
{
    static ACAudioPlayer *sharedAudioPlayer;
    @synchronized(self)
    {
        if (!sharedAudioPlayer) {
            sharedAudioPlayer = [[ACAudioPlayer alloc] init];
            [sharedAudioPlayer configureInterfaceSounds];
        }
        return sharedAudioPlayer;
    }
}

- (void)configureInterfaceSounds
{
    NSURL *downPressedURL = [[NSBundle mainBundle] URLForResource:@"pressDown" withExtension:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(downPressedURL), &downPressed);
    
    NSURL *upPressedURL = [[NSBundle mainBundle] URLForResource:@"pressUp" withExtension:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(upPressedURL), &upPressed);
    
    NSURL *coinDropURL = [[NSBundle mainBundle] URLForResource:@"coin" withExtension:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(coinDropURL), &coinDrop);

    NSURL *correctURL = [[NSBundle mainBundle] URLForResource:@"correct" withExtension:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(correctURL), &correct);
    
    NSURL *wrongURL = [[NSBundle mainBundle] URLForResource:@"wrong" withExtension:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(wrongURL), &wrong);
    
    NSURL *timerURL = [[NSBundle mainBundle] URLForResource:@"correct" withExtension:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(timerURL), &timer);
}

- (void)playInterfaceSoundType:(soundType)sound
{
    switch (sound) {
        case kButtonDown:
            AudioServicesPlaySystemSound(downPressed);
            break;
            
        case kButtonUp:
            AudioServicesPlaySystemSound(upPressed);
            break;
            
        case kcoinDrop:
            AudioServicesPlaySystemSound(coinDrop);
            break;
            
        case kcorrect:
            AudioServicesPlaySystemSound(correct);
            break;
            
        case kwrong:
            AudioServicesPlaySystemSound(wrong);
            break;
            
        case ktimer:
            AudioServicesPlaySystemSound(timer);
            break;
            
        default:
            break;
    }
}

- (void)configureAudioPlayerWithMusic:(musicType)music
{
    if (!self.musicURLArray)
    {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"plist"];
        NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        self.musicURLArray = (NSArray *)[NSPropertyListSerialization
                                         propertyListFromData:plistData
                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                         format:NULL
                                         errorDescription:NULL];
    }
    
    NSString *musicBundlePath = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"bundle"];
    NSBundle *musicBundle = [NSBundle bundleWithPath:musicBundlePath];
    NSURL *musicURL = [musicBundle URLForResource:[self.musicURLArray objectAtIndex:music] withExtension:@"mp3"];
    
    if (self.audioPlayer.isPlaying)
    {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    self.audioPlayer.delegate = self;
    self.audioPlayer.numberOfLoops = -1;
    [self.audioPlayer prepareToPlay];
}

- (void)playMusic
{
    [self.audioPlayer play];
}

- (void)stopMusic
{
    [self.audioPlayer stop];
}

- (void)pauseMusic
{
    [self.audioPlayer pause];
}




@end

