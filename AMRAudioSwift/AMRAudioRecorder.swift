//
//  AMRAudioRecorder.swift
//  AMRAudioSwift
//
//  Created by Xin Hong on 16/3/2.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import AVFoundation

public protocol AMRAudioRecorderDelegate {
    func audioRecorderDidStartRecording(audioRecorder: AMRAudioRecorder)
    func audioRecorderDidCancelRecording(audioRecorder: AMRAudioRecorder)
    func audioRecorderDidStopRecording(audioRecorder: AMRAudioRecorder, url: NSURL?)
    func audioRecorderEncodeErrorDidOccur(audioRecorder: AMRAudioRecorder, error: NSError?)
    func audioRecorderDidFinishRecording(audioRecorder: AMRAudioRecorder, successfully flag: Bool)

    func audioRecorderDidStartPlaying(audioRecorder: AMRAudioRecorder)
    func audioRecorderDidStopPlaying(audioRecorder: AMRAudioRecorder)
    func audioRecorderDecodeErrorDidOccur(audioRecorder: AMRAudioRecorder, error: NSError?)
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

public class AMRAudioRecorder: NSObject {
    public static let sharedRecorder = AMRAudioRecorder()
    public var delegate: AMRAudioRecorderDelegate?
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

    // MARK: - Play
    /**
    Plays an AMR audio asynchronously.

    If is playing, stop play, else start play.

    - parameter data: AMR audio data
    */
    public func play(data: NSData) {
        if player == nil {
            // is not playing, start play
            let decodedData = AMRAudio.decodeAMRDataToWAVEData(data)
            player = initPlayer(decodedData)
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

    public func stopPlay() {
        player?.stop()
        player = nil
        delegate?.audioRecorderDidStopPlaying(self)
        inactiveAudioSession()
    }

    /**
     Get the duration of an audio data.

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
}

extension AMRAudioRecorder {
    // MARK: - Helper
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceProximityStateDidChange:", name: UIDeviceProximityStateDidChangeNotification, object: nil)
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
    public func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        delegate?.audioRecorderDidFinishRecording(self, successfully: flag)
    }

    public func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        delegate?.audioRecorderEncodeErrorDidOccur(self, error: error)
    }

    public func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        removeProximitySensorObserver()
        self.player = nil
        delegate?.audioRecorderDidStopPlaying(self)
        delegate?.audioRecorderDidFinishPlaying(self, successfully: flag)
        inactiveAudioSession()
    }

    public func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        removeProximitySensorObserver()
        delegate?.audioRecorderDecodeErrorDidOccur(self, error: error)
        inactiveAudioSession()
    }
}

private struct AudioRecorder {
    static let recordSettings:[String: AnyObject] = [AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatLinearPCM),
                                                     AVSampleRateKey: NSNumber(float: 8000.0),
                                                     AVNumberOfChannelsKey: NSNumber(int: 1),
                                                     AVLinearPCMBitDepthKey: NSNumber(int: 16),
                                                     AVLinearPCMIsNonInterleaved: false,
                                                     AVLinearPCMIsFloatKey: false,
                                                     AVLinearPCMIsBigEndianKey: false,]
    static func recordLocationURL() -> NSURL {
        let recordLocationURL = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingFormat("%.0f.%@", NSDate.timeIntervalSinceReferenceDate() * 1000, "caf"))
        return recordLocationURL
    }
}

