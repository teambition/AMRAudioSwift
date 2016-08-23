//
//  VoiceCell.swift
//  AMRAudioSwiftExample
//
//  Created by 洪鑫 on 16/8/23.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import AMRAudioSwift

let kVoiceCellID = "VoiceCell"
let kPlayTimerInterval: NSTimeInterval = 1.0 / 60

class VoiceCell: UITableViewCell {
    let audioRecorder = AMRAudioRecorder.sharedRecorder
    static var currentPlayingCell: VoiceCell?
    var progress: Double = 0 {
        didSet {
            if progress > 0 {
                progressLayer.hidden = false
            } else {
                progressLayer.hidden = true
            }
            progressLayer.frame.size.width = bounds.width * CGFloat(progress)
        }
    }
    var voice: Voice? {
        didSet {
            configure(voice)
        }
    }
    private(set) var playing = false

    private var progressLayer = CAShapeLayer()
    private var playTimer: NSTimer?
    private var playedSeconds: Double = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.backgroundColor = UIColor.clearColor()
        detailTextLabel?.backgroundColor = UIColor.clearColor()
        progressLayer.backgroundColor = UIColor(red: 201 / 255, green: 243 / 255, blue: 252 / 255, alpha: 1).CGColor
        layer.insertSublayer(progressLayer, atIndex: 0)
        progress = 0
        selectionStyle = .None
        accessoryType = .None

        userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentViewTapped(_:)))
        addGestureRecognizer(tapGesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        progressLayer.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: bounds.width * CGFloat(progress), height: bounds.height))
    }

    func contentViewTapped(sender: UITapGestureRecognizer) {
        if playing {
            stopPlay()
        } else {
            VoiceCell.currentPlayingCell?.stopPlay()
            startPlay()
        }
    }
}

extension VoiceCell {
    func startPlay() {
        guard !playing else {
            return
        }

        audioRecorder.stopRecord()
        if let voice = voice {
            audioRecorder.delegate = self
            playedSeconds = 0
            progress = 0
            audioRecorder.playAmr(voice.amrData)
            playTimer = NSTimer.scheduledTimerWithTimeInterval(kPlayTimerInterval, target: self, selector: #selector(updateProgress(_:)), userInfo: self, repeats: true)
        }
    }

    func stopPlay() {
        audioRecorder.stopPlay()
    }

    func updateProgress(timer: NSTimer) {
        dispatch_async(dispatch_get_main_queue()) {
            self.playedSeconds += timer.timeInterval
            self.detailTextLabel?.text = self.timeStringWithDuration(self.playedSeconds)

            let duration = self.voice?.duration ?? 0
            if self.playedSeconds > 0 {
                self.progress = self.playedSeconds / duration
            }
        }
    }

    private func timeStringWithDuration(duration: NSTimeInterval) -> String {
        let minutes = floor(duration / 60)
        let seconds = round(duration - minutes * 60)
        return String(format: "%02.f:%02.f", minutes, seconds)
    }

    private func configure(voice: Voice?) {
        if let voice = voice {
            if let duration = voice.duration {
                textLabel?.text = "\(voice.title) (\(duration)s)"
            } else {
                textLabel?.text = "\(voice.title)"
            }
            detailTextLabel?.text = "Tap To Play"
        } else {
            textLabel?.text = "No Voice Data"
            detailTextLabel?.text = nil
        }
    }

    private func reset() {
        playTimer?.invalidate()
        playTimer = nil
        playedSeconds = 0
        progress = 0
        playing = false
        audioRecorder.delegate = nil
        configure(voice)
    }
}

extension VoiceCell: AMRAudioRecorderDelegate {
    func audioRecorderDidStartPlaying(audioRecorder: AMRAudioRecorder) {
        print("*********************start playing \(voice?.title ?? "")*********************")
        playing = true
        VoiceCell.currentPlayingCell = self
    }

    func audioRecorderDidStopPlaying(audioRecorder: AMRAudioRecorder) {
        print("*********************stop playing \(voice?.title ?? "")*********************")
        reset()
        if VoiceCell.currentPlayingCell == self {
            VoiceCell.currentPlayingCell = nil
        }
    }

    func audioRecorderDidFinishPlaying(audioRecorder: AMRAudioRecorder, successfully flag: Bool) {
        let result = flag ? "successfully" : "unsuccessfully"
        print("*********************finish playing \(voice?.title ?? "") \(result)*********************")
        reset()
        if VoiceCell.currentPlayingCell == self {
            VoiceCell.currentPlayingCell = nil
        }
    }
}
