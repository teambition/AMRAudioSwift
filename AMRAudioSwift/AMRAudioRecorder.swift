//
//  AMRAudioRecorder.swift
//  AMRAudioSwift
//
//  Created by Xin Hong on 16/3/2.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import AVFoundation

public class AMRAudioRecorder: NSObject {
    public static let sharedRecorder = AMRAudioRecorder()
    public weak var delegate: AMRAudioRecorderDelegate?

    public private(set) var recorder: AVAudioRecorder? {
        didSet {
            if let _ = recorder {
                recorder?.delegate = self
            } else {
                recorder?.delegate = nil
            }
        }
    }
    public private(set) var player: AVAudioPlayer? {
        didSet {
            if let _ = player {
                player?.delegate = self
            } else {
                player?.delegate = nil
            }
        }
    }
    public var recording: Bool {
        return recorder?.recording ?? false
    }
    public var playing: Bool {
        return player?.playing ?? false
    }
    public var volume: Float = 1
    public var proximityMonitoringEnabled = true

    // MARK: - Life cycle
    public override init () {
        super.init()
        commonInit()
    }

    deinit {
        recorder = nil
        player?.stop()
        player = nil
    }
}

extension AMRAudioRecorder {
    // MARK: - Record
    public func startRecord() {
        recorder = initRecorder()
        recorder?.prepareToRecord()
        recorder?.record()
        delegate?.audioRecorderDidStartRecording(self)
    }

    public func cancelRecord() {
        recorder?.stop()
        recorder?.deleteRecording()
        delegate?.audioRecorderDidCancelRecording(self)
    }

    public func stopRecord() {
        let url = recorder?.url
        recorder?.stop()
        recorder = nil
        delegate?.audioRecorderDidStopRecording(self, url: url)
    }
}

extension AMRAudioRecorder {
    // MARK: - Play
    /**
    Plays a WAVE audio asynchronously.

    If is playing, stop play, else start play.

    - parameter data: WAVE audio data
    */
    public func play(data: NSData) {
        if player == nil {
            // is not playing, start play
            player = initPlayer(data)
            addProximitySensorObserver()
            guard let success = player?.play() else {
                return
            }
            if success {
                delegate?.audioRecorderDidStartPlaying(self)
            } else {
                player = nil
                delegate?.audioRecorderDidStopPlaying(self)
                inactiveAudioSession()
            }
        } else {
            // is playing, stop play
            stopPlay()
        }
    }

    /**
     Plays an AMR audio asynchronously.

     If is playing, stop play, else start play.

     - parameter data: AMR audio data
     */
    public func playAmr(amrData: NSData) {
        let decodedData = AMRAudio.decodeAMRDataToWAVEData(amrData)
        play(decodedData)
    }

    public func stopPlay() {
        removeProximitySensorObserver()
        player?.stop()
        player = nil
        delegate?.audioRecorderDidStopPlaying(self)
        inactiveAudioSession()
    }

    /**
     Get the duration of a WAVE audio data.

     - parameter data: WAVE audio data

     - returns: an optional NSTimeInterval instance.
     */
    public class func audioDuration(data: NSData) -> NSTimeInterval? {
        do {
            let player = try AVAudioPlayer(data: data)
            return player.duration
        } catch {

        }
        return nil
    }

    /**
     Get the duration of an AMR audio data.

     - parameter data: AMR audio data

     - returns: an optional NSTimeInterval instance.
     */
    public class func amrAudioDuration(amrData: NSData) -> NSTimeInterval? {
        let decodedData = AMRAudio.decodeAMRDataToWAVEData(amrData)
        return audioDuration(decodedData)
    }
}

extension AMRAudioRecorder {
    // MARK: - Helpers
    private func commonInit() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: [.DefaultToSpeaker])
        } catch let error as NSError {
            print("audio session set category error: \(error)")
        }
        inactiveAudioSession()
    }

    private func updateAudioSessionCategory(category: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(category)
        } catch let error as NSError {
            print("audio session set category error: \(error)")
        }
    }

    private func inactiveAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, withOptions: [.NotifyOthersOnDeactivation])
        } catch let error as NSError {
            print("audio session set active error: \(error)")
        }
    }

    private func initRecorder() -> AVAudioRecorder? {
        var recorder: AVAudioRecorder?
        do {
            try recorder = AVAudioRecorder(URL: AudioRecorder.recordLocationURL(), settings: AudioRecorder.recordSettings)
            recorder?.meteringEnabled = true
            recorder?.prepareToRecord()
        } catch let error as NSError {
            print("init recorder error: \(error)")
        }
        return recorder
    }

    private func initPlayer(data: NSData) -> AVAudioPlayer? {
        var player: AVAudioPlayer?
        do {
            try player = AVAudioPlayer(data: data)
            player?.volume = volume
            player?.prepareToPlay()
        } catch let error as NSError {
            print("init player error: \(error)")
        }
        return player
    }
}

extension AMRAudioRecorder {
    // MARK: - Device Observer
    private func addProximitySensorObserver() {
        UIDevice.currentDevice().proximityMonitoringEnabled = proximityMonitoringEnabled
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deviceProximityStateDidChange(_:)), name: UIDeviceProximityStateDidChangeNotification, object: nil)
    }

    private func removeProximitySensorObserver() {
        UIDevice.currentDevice().proximityMonitoringEnabled = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceProximityStateDidChangeNotification, object: nil)
    }

    func deviceProximityStateDidChange(notification: NSNotification) {
        if UIDevice.currentDevice().proximityState {
            // Device is close to user
            updateAudioSessionCategory(AVAudioSessionCategoryPlayAndRecord)
        } else {
            // Device is not close to user
            updateAudioSessionCategory(AVAudioSessionCategoryPlayback)
        }
    }
}

extension AMRAudioRecorder: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    // MARK: - AVAudioRecorderDelegate and AVAudioPlayerDelegate
    public func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if let weakSelf = self {
                weakSelf.delegate?.audioRecorderDidFinishRecording(weakSelf, successfully: flag)
            }
        }
    }

    public func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if let weakSelf = self {
                weakSelf.delegate?.audioRecorderEncodeErrorDidOccur(weakSelf, error: error)
            }
        }
    }

    public func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if let weakSelf = self {
                weakSelf.removeProximitySensorObserver()
                weakSelf.player = nil
                weakSelf.delegate?.audioRecorderDidStopPlaying(weakSelf)
                weakSelf.delegate?.audioRecorderDidFinishPlaying(weakSelf, successfully: flag)
                weakSelf.inactiveAudioSession()
            }
        }
    }

    public func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if let weakSelf = self {
                weakSelf.removeProximitySensorObserver()
                weakSelf.delegate?.audioRecorderDecodeErrorDidOccur(weakSelf, error: error)
                weakSelf.inactiveAudioSession()
            }
        }
    }
}
