/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class nl_mpi_avf_frame_AVFFrameGrabber */

#ifndef _Included_nl_mpi_avf_frame_AVFFrameGrabber
#define _Included_nl_mpi_avf_frame_AVFFrameGrabber
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     nl_mpi_avf_frame_AVFFrameGrabber
 * Method:    initLog
 * Signature: (Ljava/lang/String;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_frame_AVFFrameGrabber_initLog
  (JNIEnv *, jclass, jstring, jstring);

/*
 * Class:     nl_mpi_avf_frame_AVFFrameGrabber
 * Method:    initNativeAsset
 * Signature: (Ljava/lang/String;)J
 */
JNIEXPORT jlong JNICALL Java_nl_mpi_avf_frame_AVFFrameGrabber_initNativeAsset
  (JNIEnv *, jobject, jstring);

/*
 * Class:     nl_mpi_avf_frame_AVFFrameGrabber
 * Method:    grabVideoFrame
 * Signature: (JJLjava/nio/ByteBuffer;)I
 */
JNIEXPORT jint JNICALL Java_nl_mpi_avf_frame_AVFFrameGrabber_grabVideoFrame
  (JNIEnv *, jobject, jlong, jlong, jobject);

/*
 * Class:     nl_mpi_avf_frame_AVFFrameGrabber
 * Method:    grabVideoFrameBA
 * Signature: (JJ[B)I
 */
JNIEXPORT jint JNICALL Java_nl_mpi_avf_frame_AVFFrameGrabber_grabVideoFrameBA
  (JNIEnv *, jobject, jlong, jlong, jbyteArray);

/*
 * Class:     nl_mpi_avf_frame_AVFFrameGrabber
 * Method:    saveFrameNativeAVF
 * Signature: (JLjava/lang/String;J)Z
 */
JNIEXPORT jboolean JNICALL Java_nl_mpi_avf_frame_AVFFrameGrabber_saveFrameNativeAVF
  (JNIEnv *, jobject, jlong, jstring, jlong);

/*
 * Class:     nl_mpi_avf_frame_AVFFrameGrabber
 * Method:    release
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_frame_AVFFrameGrabber_release
  (JNIEnv *, jobject, jlong);

/*
 * Class:     nl_mpi_avf_frame_AVFFrameGrabber
 * Method:    setDebugMode
 * Signature: (Z)V
 */
JNIEXPORT void JNICALL Java_nl_mpi_avf_frame_AVFFrameGrabber_setDebugMode
  (JNIEnv *, jclass, jboolean);

#ifdef __cplusplus
}
#endif
#endif
