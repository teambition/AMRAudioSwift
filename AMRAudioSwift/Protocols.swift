//
//  Protocols.swift
//  AMRAudioSwift
//
//  Created by Xin Hong on 16/8/19.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public protocol AMRAudioRecorderDelegate: class {
    func audioRecorderDidStartRecording(_ audioRecorder: AMRAudioRecorder)
    func audioRecorderDidCancelRecording(_ audioRecorder: AMRAudioRecorder)
    func audioRecorderDidStopRecording(_ audioRecorder: AMRAudioRecorder, withURL url: URL?)
    /**
     Called when an audio recorder encounters an encoding error during recording.

     - parameter audioRecorder: The AMRAudioRecorder that encountered the encoding error.
     - parameter error:         Returns, by-reference, a description of the error, if an error occurs.
     */
    func audioRecorderEncodeErrorDidOccur(_ audioRecorder: AMRAudioRecorder, error: Error?)
    /**
     Called by the system when a recording is stopped or has finished due to reaching its time limit.

     This method is not called by the system if the audio recorder stopped due to an interruption.

     - parameter audioRecorder: The AMRAudioRecorder that has finished recording.
     - parameter flag:          true on successful completion of recording; false if recording stopped because of an audio encoding error.
     */
    func audioRecorderDidFinishRecording(_ audioRecorder: AMRAudioRecorder, successfully flag: Bool)

    func audioRecorderDidStartPlaying(_ audioRecorder: AMRAudioRecorder)
    func audioRecorderDidStopPlaying(_ audioRecorder: AMRAudioRecorder)
    /**
     Called when an audio player encounters a decoding error during playback.

     - parameter audioRecorder: The AMRAudioRecorder that encountered the decoding error.
     - parameter error:         The decoding error.
     */
    func audioRecorderDecodeErrorDidOccur(_ audioRecorder: AMRAudioRecorder, error: Error?)
    /**
     Called when a sound has finished playing.

     This method is not called upon an audio interruption. Rather, an audio player is paused upon interruption—the sound has not finished playing.

     - parameter audioRecorder: The AMRAudioRecorder that finished playing.
     - parameter flag:          true on successful completion of playback; false if playback stopped because the system could not decode the audio data.
     */
    func audioRecorderDidFinishPlaying(_ audioRecorder: AMRAudioRecorder, successfully flag: Bool)

    func audioRecorderDidPausePlaying(_ audioRecorder: AMRAudioRecorder)
}

public extension AMRAudioRecorderDelegate {
    func audioRecorderDidStartRecording(_ audioRecorder: AMRAudioRecorder) {

    }

    func audioRecorderDidCancelRecording(_ audioRecorder: AMRAudioRecorder) {

    }

    func audioRecorderDidStopRecording(_ audioRecorder: AMRAudioRecorder, withURL url: URL?) {

    }

    func audioRecorderEncodeErrorDidOccur(_ audioRecorder: AMRAudioRecorder, error: Error?) {

    }

    func audioRecorderDidFinishRecording(_ audioRecorder: AMRAudioRecorder, successfully flag: Bool) {

    }

    func audioRecorderDidStartPlaying(_ audioRecorder: AMRAudioRecorder) {

    }

    func audioRecorderDidStopPlaying(_ audioRecorder: AMRAudioRecorder) {

    }

    func audioRecorderDecodeErrorDidOccur(_ audioRecorder: AMRAudioRecorder, error: Error?) {

    }

    func audioRecorderDidFinishPlaying(_ audioRecorder: AMRAudioRecorder, successfully flag: Bool) {

    }

    func audioRecorderDidPausePlaying(_ audioRecorder: AMRAudioRecorder) {

    }
}
