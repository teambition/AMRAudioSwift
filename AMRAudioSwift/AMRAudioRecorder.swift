//
//  AMRAudioRecorder.swift
//  AMRAudioSwift
//
//  Created by Xin Hong on 16/3/2.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import AVFoundation

open class AMRAudioRecorder: NSObject {
    public static let shared = AMRAudioRecorder()
    open weak var delegate: AMRAudioRecorderDelegate?

    open fileprivate(set) var recorder: AVAudioRecorder? {
        willSet {
            if let newValue = newValue {
                newValue.delegate = self
            } else {
                recorder?.delegate = nil
            }
        }
    }
    open fileprivate(set) var player: AVAudioPlayer? {
        willSet {
            if let newValue = newValue {
                newValue.delegate = self
            } else {
                player?.delegate = nil
            }
        }
    }
    open var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    open var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    open var volume: Float = 1
    open var isProximityMonitoringEnabled = true
    open var isScreenBrightWhenPlaying = true

    // MARK: - Life cycle
    public override init () {
        super.init()
        commonInit()
    }

    deinit {
        recorder?.stop()
        recorder = nil
        player?.stop()
        player = nil
    }
}

extension AMRAudioRecorder {
    // MARK: - Record
    public func startRecord() {
        UIApplication.shared.isIdleTimerDisabled = true
        DispatchQueue.global().async {
            DispatchQueue.main.async { [weak self] in
                self?.recorder?.record()
            }
        }

        delegate?.audioRecorderDidStartRecording(self)
    }

    public func cancelRecord() {
        if !isRecording {
            return
        }

        DispatchQueue.global().async {
            DispatchQueue.main.async { [weak self] in
                self?.recorder?.stop()
                self?.recorder?.deleteRecording()
            }
        }
        UIApplication.shared.isIdleTimerDisabled = false

        delegate?.audioRecorderDidCancelRecording(self)
    }

    public func stopRecord() {
        let url = recorder?.url
        recorder?.stop()
        UIApplication.shared.isIdleTimerDisabled = false

        delegate?.audioRecorderDidStopRecording(self, withURL: url)
    }
}

extension AMRAudioRecorder {
    // MARK: - Play
    /**
    Plays a WAVE audio asynchronously.

    If is playing, stop play, else start play.

    - parameter data: WAVE audio data
    */
    public func play(_ data: Data) {
        if player == nil {
            // is not playing, start play
            player = initPlayer(data)

            addProximitySensorObserver()
            if isScreenBrightWhenPlaying {
                UIApplication.shared.isIdleTimerDisabled = true
            }

            guard let success = player?.play() else {
                return
            }

            if success {
                delegate?.audioRecorderDidStartPlaying(self)
            } else {
                stopPlay()
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
    public func playAmr(_ amrData: Data) {
        let decodedData = AMRAudio.decodeAMRDataToWAVEData(amrData: amrData)
        play(decodedData)
    }

    public func stopPlay() {
        player?.stop()
        player = nil
        removeProximitySensorObserver()
        UIApplication.shared.isIdleTimerDisabled = false
        activateOtherInterruptedAudioSessions()

        delegate?.audioRecorderDidStopPlaying(self)
    }

    /**
     Get the duration of a WAVE audio data.

     - parameter data: WAVE audio data

     - returns: an optional NSTimeInterval instance.
     */
    public class func audioDuration(from data: Data) -> TimeInterval? {
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
    public class func amrAudioDuration(from amrData: Data) -> TimeInterval? {
        let decodedData = AMRAudio.decodeAMRDataToWAVEData(amrData: amrData)
        return audioDuration(from: decodedData)
    }
}

extension AMRAudioRecorder {
    // MARK: - Helpers
    fileprivate func commonInit() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        } catch let error {
            print("audio session set category error: \(error)")
        }
        activateOtherInterruptedAudioSessions()
        recorder = initRecorder()
    }

    fileprivate func updateAudioSessionCategory(_ category: AVAudioSession.Category, with options: AVAudioSession.CategoryOptions) {
        do {
            try AVAudioSession.sharedInstance().setCategory(category, mode: .default, options: options)
        } catch let error {
            print("audio session set category error: \(error)")
        }
    }

    fileprivate func activateOtherInterruptedAudioSessions() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch let error {
            print("audio session set active error: \(error)")
        }
    }

    fileprivate func initRecorder() -> AVAudioRecorder? {
        var recorder: AVAudioRecorder?
        do {
            try recorder = AVAudioRecorder(url: AudioRecorder.recordLocationURL(), settings: AudioRecorder.recordSettings)
            recorder?.isMeteringEnabled = true
        } catch let error {
            print("init recorder error: \(error)")
        }
        return recorder
    }

    fileprivate func initPlayer(_ data: Data) -> AVAudioPlayer? {
        var player: AVAudioPlayer?
        do {
            try player = AVAudioPlayer(data: data)
            player?.volume = volume
            player?.prepareToPlay()
        } catch let error {
            print("init player error: \(error)")
        }
        return player
    }
}

extension AMRAudioRecorder {
    // MARK: - Device Observer
    fileprivate func addProximitySensorObserver() {
        UIDevice.current.isProximityMonitoringEnabled = isProximityMonitoringEnabled
        if UIDevice.current.isProximityMonitoringEnabled {
            NotificationCenter.default.addObserver(self, selector: #selector(deviceProximityStateDidChange(_:)), name: UIDevice.proximityStateDidChangeNotification, object: nil)
        }
    }

    fileprivate func removeProximitySensorObserver() {
        if UIDevice.current.isProximityMonitoringEnabled {
            NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: nil)
        }
        UIDevice.current.isProximityMonitoringEnabled = false
    }

    @objc func deviceProximityStateDidChange(_ notification: Notification) {
        if UIDevice.current.proximityState {
            // Device is close to user
            updateAudioSessionCategory(.playAndRecord, with: [])
        } else {
            // Device is not close to user
            updateAudioSessionCategory(.playAndRecord, with: .defaultToSpeaker)
        }
    }
}

extension AMRAudioRecorder: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    // MARK: - AVAudioRecorderDelegate and AVAudioPlayerDelegate
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                let url = weakSelf.recorder?.url
                UIApplication.shared.isIdleTimerDisabled = false
                weakSelf.activateOtherInterruptedAudioSessions()

                weakSelf.delegate?.audioRecorderDidStopRecording(weakSelf, withURL: url)
                weakSelf.delegate?.audioRecorderDidFinishRecording(weakSelf, successfully: flag)
            }
        }
    }

    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.recorder?.stop()
                UIApplication.shared.isIdleTimerDisabled = false
                weakSelf.activateOtherInterruptedAudioSessions()

                weakSelf.delegate?.audioRecorderEncodeErrorDidOccur(weakSelf, error: error)
            }
        }
    }

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.player = nil
                weakSelf.removeProximitySensorObserver()
                UIApplication.shared.isIdleTimerDisabled = false
                weakSelf.activateOtherInterruptedAudioSessions()

                weakSelf.delegate?.audioRecorderDidStopPlaying(weakSelf)
                weakSelf.delegate?.audioRecorderDidFinishPlaying(weakSelf, successfully: flag)
            }
        }
    }

    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.player?.stop()
                weakSelf.player = nil
                weakSelf.removeProximitySensorObserver()
                UIApplication.shared.isIdleTimerDisabled = false
                weakSelf.activateOtherInterruptedAudioSessions()

                weakSelf.delegate?.audioRecorderDecodeErrorDidOccur(weakSelf, error: error)
            }
        }
    }
}
