//
//  AVFBasePlayer.h
//  AVFPlayer
//
//  Created by Han Sloetjes.
//  Copyright (c) 2019 MPI. All rights reserved.
//
#ifndef AVFPlayer_AVFBasePlayer_h
#define AVFPlayer_AVFBasePlayer_h

#import <jni.h>
#import <AVFoundation/AVFoundation.h>

/*
 * A base class that encapsulates an AVPlayer and an AVURLAsset from which the
 * first video track is used.
 * The clock and the audio of the AVPlayer are used for basic media player behavior.
 */

@class AVPlayer;
@class AVURLAsset;
//@class AVPlayerLayer;
// Could consider not to use @property and @synthesize but instead declare members
// directly in the interface (public, protected etc) and create getters (and setters?)
// "manually"
@interface AVFBasePlayer : NSObject {
    id intervalEndObserver;
}

@property (retain, readonly) AVPlayer   *player;
@property (retain, readonly) AVURLAsset *mediaAsset;
@property (atomic) NSError              *lastError;

@property (nonatomic, readonly) BOOL hasVideo;
@property (nonatomic, readonly) BOOL hasAudio;

@property (nonatomic, readonly) CGFloat videoWidth;
@property (nonatomic, readonly) CGFloat videoHeight;

@property (nonatomic, readonly) float nominalFrameRate;// the encoded frames per second
@property (nonatomic, readonly) float frameDurationMs; // the duration per frame in millisecond
@property (nonatomic, readonly) float frameDurationSeconds; // the duration per frame in seconds

/*
 * Initializes the player and all necessary objects for playback and frame extraction.
 */
- (id) initWithURL: (NSURL *) url;

/*
 * Checks the audio and video tracks of the asset and stores some information in properties.
 */
- (void) detectTracks;

/*
 * Called when the player is being destroyed.
 */
- (void) releasePlayer;

/*
 * Sets the stop time in milliseconds for playing a selection.
 */
- (void) setStopTime: (long) stopTime;

/*
 * Sets the stop time in seconds for playing a selection.
 */
- (void) setStopTimeSeconds: (double) stopTimeSeconds;

/*
 * Unsets the stop time, removes the stop time observer.
 */
- (void) removeStopTime;

/*
 * Class methods for creating, storing and retrieving players
 */
+ (long) createIdAndStorePlayer: (id) avfPlayer;

+ (id) getPlayerWithId: (long) playerId;

+ (void) removePlayerWithId: (long) playerId;

@end

/*
 * A struct to connect a global reference to the Java instance and the
 * corresponding AVFBasePlayer. A way to retain the configured
 * image generator for repeated calls from the Java counterpart.
 */
typedef struct {
    jobject jRef;
    AVFBasePlayer *player;
} PlayerConnector;

#endif
