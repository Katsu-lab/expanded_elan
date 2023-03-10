#import "nl_mpi_avf_player_AVFBasePlayer.h"
#import "AVFBasePlayer.h"
#import "AVFLog.h"
#import <jni.h>
#import <mpi_jni_util.h>

/*
 * Sets the logging level. The levels are loosely based on the
 * java.util.logging levels. The default level is AVFLogLevel.AVFLogInfo.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    setJAVFLogLevel
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_setJAVFLogLevel
(JNIEnv *env, jclass callerClass, jint logLevel) {
    [AVFLog setLogLevel: (long) logLevel];
    if ([AVFLog isLoggable:AVFLogInfo]) {
        mjlogfWE(env, "N_AVFBasePlayer.setJAVFLogLevel: level: %ld", logLevel);
    }
}

/* 
 * Returns the current logging level. The default level is AVFLogLevel.AVFLogInfo.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getJAVFLogLevel
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getJAVFLogLevel
(JNIEnv * env, jclass callerClass) {
    return (jint) [AVFLog getLogLevel];
}

/*
 * Tries to setup a class and methodID reference for native code to log to.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    initLog
 * Signature: (Ljava/lang/String;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_initLog
(JNIEnv *env, jclass callerClass, jstring clDescriptor, jstring methName) {
    const char *clChars = env->GetStringUTFChars(clDescriptor, NULL);
    if (clChars == NULL) {
        return; // OutOfMemory thrown
    }
    const char *methChars = env->GetStringUTFChars(methName, NULL);
    if (methChars == NULL) {
        return; // OutOfMemory thrown
    }
    mpijni_initLog(env, clChars, methChars);
    if ([AVFLog isLoggable:AVFLogFine]) {
        mjlogfWE(env, "N_AVFBasePlayer.initLog: set Java log method: %s - %s", clChars, methChars);
    }
    
    // free the allocated memory
    env->ReleaseStringUTFChars(clDescriptor, clChars);
    env->ReleaseStringUTFChars(methName, methChars);
}

/*
 * This initializes a base player which can be used for audio only.
 * Creates a AVFBasePlayer for the specified media url (url as a string). This player
 * can be used for audio only.
 * Returns an id which is used for store and retrieve of the player in a global
 * dictionary. If a player cannot be created 0 is returned.
 * Note: in case of a local file, remove file: protocol (otherwise there is a
 * problem with white spaces in the path)
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    initPlayer
 * Signature: (Ljava/lang/String;)J
 */
JNIEXPORT jlong JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_initPlayer
(JNIEnv * env, jobject callerObject, jstring mediaURL) {
    jlong nextId = 0;
    jboolean isCopy;
    const char *mediaURLChars = env->GetStringUTFChars(mediaURL, &isCopy);
    // convert jstring to NSString
    NSString *urlString = [NSString stringWithUTF8String:mediaURLChars];
    if ([AVFLog isLoggable:AVFLogInfo]) {
        mjlogfWE(env, "N_AVFBasePlayer.initPlayer: media URL: %s", [urlString UTF8String]);
    }
    
    NSURL *mediaNSURL = NULL;
    /*
     NSURL *mediaNSURL = [NSURL fileURLWithPath:urlString isDirectory:NO];
    //NSURL *mediaNSURL = [NSURL URLWithString:urlString]; // works with http:// url's as opposed to the above
    NSError *error = NULL;
    NSRegularExpression *fileRegex = [NSRegularExpression regularExpressionWithPattern:@"file:\\/.+"  options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numMatches = [fileRegex numberOfMatchesInString:urlString options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [urlString length])];
     */
    BOOL fileProt = [urlString hasPrefix:@"file:"];
    BOOL absFile = [urlString hasPrefix:@"/"];
    if ([AVFLog isLoggable:AVFLogInfo]) {
        mjlogfWE(env, "N_AVFBasePlayer.initPlayer: media URL has file protocol: %i, is absolute: %i", fileProt, absFile);
    }
    if (fileProt || absFile) {
        mediaNSURL = [NSURL fileURLWithPath:urlString isDirectory:NO];
    } else {
        mediaNSURL = [NSURL URLWithString:urlString];
    }
    
    id avfPlayer = [[AVFBasePlayer alloc] initWithURL:mediaNSURL];
    // check success
    if (avfPlayer == NULL || (![avfPlayer hasAudio] && ![avfPlayer hasVideo])) {
        // throw file not supported exception
        //jclass exClass;
        const char *mess = "Could not create an AV Foundation player: the file has no audio or video tracks.";
        jclass exClass = env->FindClass("nl/mpi/avf/player/JAVFPlayerException");
        
        if (exClass != NULL) {
            env->ThrowNew(exClass, mess);
        }
        if (avfPlayer != NULL) {
            [avfPlayer releasePlayer];
        }
    }
    // store in global map
    if (avfPlayer != NULL) {
        if ([avfPlayer lastError] != NULL) {//??
            nextId = 0;
            [avfPlayer releasePlayer];// clean up?
        } else {
            //nextId = [AVFBasePlayer createIdAndStorePlayer:avfPlayer];
            PlayerConnector *playConnect = new PlayerConnector();
            playConnect->jRef = env->NewGlobalRef(callerObject);
            playConnect->player = avfPlayer;
            
            nextId = (jlong) playConnect;
        }
    }
    
    env->ReleaseStringUTFChars(mediaURL, mediaURLChars);
    
    if ([AVFLog isLoggable:AVFLogInfo]) {
        mjlogfWE(env, "N_AVFBasePlayer.initPlayer: id of new player: %ld, has audio: %s, has video: %s", nextId, ([avfPlayer hasAudio] ? "yes" : "no"), ([avfPlayer hasVideo] ? "yes" : "no"));
    }
    
    return nextId;
}

/*
 * Returns the player load status, not used at the moment, returns 0.
 * See: getState
 
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getPlayerLoadStatus
 * Signature: (J)I
 */
JNIEXPORT jint JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getPlayerLoadStatus
(JNIEnv *env, jobject callerObject, jlong playerId) {
    return 0;
}

/*
 * Returns the last error that occured and was stored in the 'last error'
 * field. Can be NULL.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getPlayerError
 * Signature: (J)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getPlayerError
(JNIEnv *env, jobject callerObject, jlong playerId) {
    // implementation in sub classes/functions
    return NULL;
}

/*
 * Removes the player from the map, making it inaccesible.
 * Triggers the release of resources.
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    deletePlayer
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_deletePlayer
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        if ([AVFLog isLoggable:AVFLogInfo]) {
            mjlogfWE(env, "N_AVFBasePlayer.deletePlayer: deleting player with id: %ld", playerId);
        }

        [avfPlayer releasePlayer];
        env->DeleteGlobalRef(playConnect->jRef);
        delete(playConnect);
    }
}

/*
 * Starts the player with id playerId.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    start
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_start
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        [[avfPlayer player] play];
    }
}

/*
 * Stops the player with id playerId, equivalent to pause (calls the pause method).
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    stop
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_stop
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        [[avfPlayer player] pause];
    }
}

/*
 * Pauses the player with the specified id.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    pause
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_pause
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        [[avfPlayer player] pause];
    }
}

/*
 * Returns whether the specified player is playing. The implementation tests
 * if the playback rate is greater than 0 and returns true if it is, false
 * if it is 0 or if the player does not exist.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    isPlaying
 * Signature: (J)Z
 */
JNIEXPORT jboolean JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_isPlaying
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        return [[avfPlayer player] rate] > 0;
    }
    
    return JNI_FALSE;
}

/*
 * Returns the state of the player, one of the AVPlayerStatus constants,
 * (AVPlayerStatusUnknown, AVPlayerStatusReadyToPlay or AVPlayerStatusFailed).
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getState
 * Signature: (J)I
 */
JNIEXPORT jint JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getState
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    //     AVPlayerStatusUnknown, AVPlayerStatusReadyToPlay or AVPlayerStatusFailed
    if (avfPlayer != NULL) {
        return [[avfPlayer player] status];
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getState: no player with id: %ld", playerId);
        }
    }
    
    return 0;// unknown
}

/*
 * Sets the playback rate, 0 is paused, 1 is normal playback rate,
 * > 1 is faster playback.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    setRate
 * Signature: (JF)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_setRate
(JNIEnv *env, jobject callerObject, jlong playerId, jfloat rate) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        [[avfPlayer player] setRate: rate];
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.setRate: new rate %.2f", rate);
        }
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.setRate: no player with id: %ld", playerId);
        }
    }
}

/*
 * Returns the current playback rate.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getRate
 * Signature: (J)F
 */
JNIEXPORT jfloat JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getRate
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.getRate: get rate %.2f", [[avfPlayer player] rate]);
        }
        return [[avfPlayer player] rate];
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getRate: no player with id: %ld", playerId);
        }
    }
    
    return 1;
}

/*
 * Sets the audio volume, a value between 0 (muted) and 1 (normal volume).
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    setVolume
 * Signature: (JF)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_setVolume
(JNIEnv *env, jobject callerObject, jlong playerId, jfloat volume) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        if (volume >= 0 && volume <= 1) {
            [[avfPlayer player] setVolume: volume];
        }
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.setVolume: new volume %.2f", volume);
        }
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.setVolume: no player with id: %ld", playerId);
        }
    }
}

/*
 * Returns the current volume.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getVolume
 * Signature: (J)F
 */
JNIEXPORT jfloat JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getVolume
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.getVolume: get volume %.2f", [[avfPlayer player] volume]);
        }
        return (jfloat) [[avfPlayer player] volume];
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getVolume: no player with id: %ld", playerId);
        }
    }
    
    return 1;
}

/*
 * Returns the current media time (media position) of the player as a value
 * in milliseconds (rounded down).
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getMediaTime
 * Signature: (J)J
 */
JNIEXPORT jlong JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getMediaTime
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        // don't log on any level?
        return (jlong) 1000 * CMTimeGetSeconds([[avfPlayer player] currentTime]);
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getMediaTime: no player with id: %ld", playerId);
        }
    }
    
    return 0;
}

/*
 * Returns the current media time (media position) of the player in seconds.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getMediaTimeSeconds
 * Signature: (J)D
 */
JNIEXPORT jdouble JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getMediaTimeSeconds
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        // don't log on any level?
        return CMTimeGetSeconds([[avfPlayer player] currentTime]);
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getMediaTimeSeconds: no player with id: %ld", playerId);
        }
    }
    
    return (jdouble) 0.0;
}

/*
 * Sets the media time (media position) to the time expressed in milliseconds.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    setMediaTime
 * Signature: (JJ)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_setMediaTime
(JNIEnv *env, jobject callerObject, jlong playerId, jlong mediaTime) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        CMTime seekTime = CMTimeMake(mediaTime, 1000);
        [[avfPlayer player] seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.setMediaTime: media time: %ld (ms)", mediaTime);
        }
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.setMediaTime: no player with id: %ld", playerId);
        }
    }
}

/*
 * Sets the media time (media position) to the time expressed in seconds.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    setMediaTimeSeconds
 * Signature: (JD)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_setMediaTimeSeconds
(JNIEnv *env, jobject callerObject, jlong playerId, jdouble mediaTimeSec) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        CMTime seekTime = CMTimeMakeWithSeconds(mediaTimeSec, 1000);
        [[avfPlayer player] seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.setMediaTimeSeconds: media time: %.4f (sec)", mediaTimeSec);
        }
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.setMediaTimeSeconds: no player with id: %ld", playerId);
        }
    }
}

/*
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    setStopTime
 * Signature: (JJ)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_setStopTime
(JNIEnv *env, jobject callerObject, jlong playerId, jlong stopTime) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        [avfPlayer setStopTime:stopTime];
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.setStopTime: set stop time: %ld (ms)", stopTime);
        }
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.setStopTime: no player with id: %ld", playerId);
        }
    }
}

/*
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    setStopTimeSeconds
 * Signature: (JD)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_setStopTimeSeconds
(JNIEnv *env, jobject callerObject, jlong playerId, jdouble stopTimeSec) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        [avfPlayer setStopTimeSeconds:stopTimeSec];
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.setStopTimeSeconds: set stop time: %.4f (sec)", stopTimeSec);
        }
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.setStopTimeSeconds: no player with id: %ld", playerId);
        }
    }
}

/*
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    removeStopTime
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_removeStopTime
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        [avfPlayer removeStopTime];
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogWE(env, "N_AVFBasePlayer.removeStopTime: remove stop time.");
        }
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.removeStopTime: no player with id: %ld", playerId);
        }
    }
}

/*
 * Returns whether the player (the media asset) has any video tracks.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    hasVideo
 * Signature: (J)Z
 */
JNIEXPORT jboolean JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_hasVideo
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.hasVideo: media has video: %d", [avfPlayer hasVideo]);
        }
        return [avfPlayer hasVideo];
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.hasVideo: no player with id: %ld", playerId);
        }
    }
    
    return JNI_FALSE;
}

/*
 * Returns whether the player (the media asset) has any audio tracks.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    hasAudio
 * Signature: (J)Z
 */
JNIEXPORT jboolean JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_hasAudio
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.hasAudio: media has audio: %d", [avfPlayer hasAudio]);
        }
        return [avfPlayer hasAudio];
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.hasAudio: no player with id: %ld", playerId);
        }
    }
    
    return JNI_FALSE;
}

/*
 * Returns the duration of the media in milliseconds.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getDuration
 * Signature: (J)J
 */
JNIEXPORT jlong JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getDuration
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        // uses the separate asset. Sometimes [[avfPlayer player] currentItem] duration] returns
        // NaN while [[avfPlayer mediaAsset] duration] returns the correct number of seconds
        //NSLog(@"Duration sec %.2f", CMTimeGetSeconds([[avfPlayer mediaAsset] duration]));
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.getDuration: media duration: %.2f (ms)", (1000 * CMTimeGetSeconds([[avfPlayer mediaAsset] duration])));
        }
        return (jlong) (1000 * CMTimeGetSeconds([[avfPlayer mediaAsset] duration]));
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getDuration: no player with id: %ld", playerId);
        }
    }
    
    return 0;
}

/*
 * Returns the duration of the player in seconds.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getDurationSeconds
 * Signature: (J)D
 */
JNIEXPORT jdouble JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getDurationSeconds
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        // uses the separate media asset
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.getDurationSeconds: media duration: %.4f (sec)", CMTimeGetSeconds([[avfPlayer mediaAsset] duration]));
        }
        
        return CMTimeGetSeconds([[avfPlayer mediaAsset] duration]);
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getDurationSeconds: no player with id: %ld", playerId);
        }
    }
    
    return 0.0;
}

/*
 * Returns the encoded or nominal frame rate (frames per second) of the media.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getFrameRate
 * Signature: (J)D
 */
JNIEXPORT jdouble JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getFrameRate
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.getFrameRate: nominal frame rate: %.4f", [avfPlayer nominalFrameRate]);
        }
        return [avfPlayer nominalFrameRate];
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getFrameRate: no player with id: %ld", playerId);
        }
    }
    
    return 1.0;
}

/*
 * Returns the duration of a single (video) frame.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getTimePerFrame
 * Signature: (J)D
 */
JNIEXPORT jdouble JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getTimePerFrame
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL) {
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.getTimePerFrame: time per frame: %.2f (ms)", [avfPlayer frameDurationMs]);
        }
        return [avfPlayer frameDurationMs];
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getTimePerFrame: no player with id: %ld", playerId);
        }
    }
    
    return 0.0;
}

/*
 * Returns the aspect ratio of the video (width : height) or 1.0 in case of an error.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getAspectRatio
 * Signature: (J)F
 */
JNIEXPORT jfloat JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getAspectRatio
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL && [avfPlayer hasVideo]) {
        CGFloat videoWidth = [avfPlayer videoWidth];
        CGFloat videoHeight = [avfPlayer videoHeight];
        
        if (videoHeight > 0) {
            if ([AVFLog isLoggable:AVFLogFine]) {
                mjlogfWE(env, "N_AVFBasePlayer.getAspectRatio: aspect ratio (w:%.2f-h:%.2f): %.2f", videoWidth, videoHeight, (videoWidth / videoHeight));
            }
            return (jfloat) (videoWidth / videoHeight);
        } else {
            if ([AVFLog isLoggable:AVFLogInfo]) {
                mjlogfWE(env, "N_AVFBasePlayer.getAspectRatio: aspect ratio (w:%.2f-h:%.2f): NaN (1.0)", videoWidth, videoHeight);
            }
        }
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getAspectRatio: no player with id: %ld", playerId);
        }
    }
    
    return 1.0;
}

/*
 * Returns the original, encoded size (dimension, w x h) of the video or NULL
 * if there is no video.
 *
 * Class:     nl_mpi_avf_player_AVFBasePlayer
 * Method:    getOriginalSize
 * Signature: (J)Ljava/awt/Dimension;
 */
JNIEXPORT jobject JNICALL Java_nl_mpi_avf_player_AVFBasePlayer_getOriginalSize
(JNIEnv *env, jobject callerObject, jlong playerId) {
    PlayerConnector *playConnect = (PlayerConnector *) playerId;//ptr should be valid
    AVFBasePlayer *avfPlayer = playConnect->player;
    
    if (avfPlayer != NULL && [avfPlayer hasVideo]) {
        CGFloat videoWidth = [avfPlayer videoWidth];
        CGFloat videoHeight = [avfPlayer videoHeight];
        
        if ([AVFLog isLoggable:AVFLogFine]) {
            mjlogfWE(env, "N_AVFBasePlayer.getOriginalSize: width: %.2f - height: %.2f", videoWidth, videoHeight);
        }
        
        // cast to int
        jclass clazz = env->FindClass("java/awt/Dimension");
        jmethodID mid = env->GetMethodID(clazz, "<init>", "(II)V");
        
        return env->NewObject(clazz, mid, (jint) videoWidth, (jint) videoHeight);
    } else {
        if ([AVFLog isLoggable:AVFLogWarning]) {
            mjlogfWE(env, "N_AVFBasePlayer.getOriginalSize: no player with id: %ld", playerId);
        }
    }
    
    return NULL;
}

