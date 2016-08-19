//
//  Protocols.swift
//  AMRAudioSwift
//
//  Created by Xin Hong on 16/8/19.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public protocol AMRAudioRecorderDelegate: class {
    func audioRecorderDidStartRecording(audioRecorder: AMRAudioRecorder)
    func audioRecorderDidCancelRecording(audioRecorder: AMRAudioRecorder)
    func audioRecorderDidStopRecording(audioRecorder: AMRAudioRecorder, url: NSURL?)
    /**
     Called when an audio recorder encounters an encoding error during recording.

     - parameter audioRecorder: The AMRAudioRecorder that encountered the encoding error.
     - parameter error:         Returns, by-reference, a description of the error, if an error occurs.
     */
    func audioRecorderEncodeErrorDidOccur(audioRecorder: AMRAudioRecorder, error: NSError?)
    /**
     Called by the system when a recording is stopped or has finished due to reaching its time limit.

     This method is not called by the system if the audio recorder stopped due to an interruption.

     - parameter audioRecorder: The AMRAudioRecorder that has finished recording.
     - parameter flag:          true on successful completion of recording; false if recording stopped because of an audio encoding error.
     */
    func audioRecorderDidFinishRecording(audioRecorder: AMRAudioRecorder, successfully flag: Bool)

    func audioRecorderDidStartPlaying(audioRecorder: AMRAudioRecorder)
    func audioRecorderDidStopPlaying(audioRecorder: AMRAudioRecorder)
    /**
     Called when an audio player encounters a decoding error during playback.

     - parameter audioRecorder: The AMRAudioRecorder that encountered the decoding error.
     - parameter error:         The decoding error.
     */
    func audioRecorderDecodeErrorDidOccur(audioRecorder: AMRAudioRecorder, error: NSError?)
    /**
     Called when a sound has finished playing.

     - parameter audioRecorder: The AMRAudioRecorder that finished playing.
     - parameter flag:          true on successful completion of playback; false if playback stopped because the system could not decode the audio data.
     */
    func audioRecorderDidFinishPlaying(audioRecorder: AMRAudioRecorder, successfully flag: Bool)
}

public extension AMRAudioRecorderDelegate {
    func audioRecorderDidStartRecording(audioRecorder: AMRAudioRecorder) {

    }

    func audioRecorderDidCancelRecording(audioRecorder: AMRAudioRecorder) {

    }

    func audioRecorderDidStopRecording(audioRecorder: AMRAudioRecorder, url: NSURL?) {

    }

    func audioRecorderEncodeErrorDidOccur(audioRecorder: AMRAudioRecorder, error: NSError?) {

    }

    func audioRecorderDidFinishRecording(audioRecorder: AMRAudioRecorder, successfully flag: Bool) {

    }

    func audioRecorderDidStartPlaying(audioRecorder: AMRAudioRecorder) {

    }

    func audioRecorderDidStopPlaying(audioRecorder: AMRAudioRecorder) {

    }

    func audioRecorderDecodeErrorDidOccur(audioRecorder: AMRAudioRecorder, error: NSError?) {

    }

    func audioRecorderDidFinishPlaying(audioRecorder: AMRAudioRecorder, successfully flag: Bool) {

    }
}
