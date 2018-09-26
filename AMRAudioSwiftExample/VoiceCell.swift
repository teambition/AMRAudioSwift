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
let kPlayTimerInterval: TimeInterval = 1.0 / 60

class VoiceCell: UITableViewCell {
    let audioRecorder = AMRAudioRecorder.shared
    static var currentPlayingCell: VoiceCell?
    var progress: Double = 0 {
        didSet {
            if progress > 0 {
                progressLayer.isHidden = false
            } else {
                progressLayer.isHidden = true
            }
            progressLayer.frame.size.width = bounds.width * CGFloat(progress)
        }
    }
    var voice: Voice? {
        didSet {
            configure(with: voice)
        }
    }
    fileprivate(set) var isPlaying = false

    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var playTimer: Timer?
    fileprivate var playedSeconds: Double = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.backgroundColor = .clear
        detailTextLabel?.backgroundColor = .clear
        progressLayer.backgroundColor = UIColor(red: 201 / 255, green: 243 / 255, blue: 252 / 255, alpha: 1).cgColor
        layer.insertSublayer(progressLayer, at: 0)
        progress = 0
        selectionStyle = .none
        accessoryType = .none

        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentViewTapped(_:)))
        addGestureRecognizer(tapGesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        progressLayer.frame = CGRect(origin: .zero, size: CGSize(width: bounds.width * CGFloat(progress), height: bounds.height))
    }

    @objc func contentViewTapped(_ sender: UITapGestureRecognizer) {
        if isPlaying {
            stopPlay()
        } else {
            VoiceCell.currentPlayingCell?.stopPlay()
            startPlay()
        }
    }
}

extension VoiceCell {
    func startPlay() {
        guard !isPlaying else {
            return
        }

        audioRecorder.stopRecord()
        if let voice = voice {
            audioRecorder.delegate = self
            playedSeconds = 0
            progress = 0
            audioRecorder.playAmr(voice.amrData)
            playTimer = Timer.scheduledTimer(timeInterval: kPlayTimerInterval, target: self, selector: #selector(updateProgress(_:)), userInfo: self, repeats: true)
        }
    }

    func stopPlay() {
        audioRecorder.stopPlay()
    }

    @objc func updateProgress(_ timer: Timer) {
        DispatchQueue.main.async {
            self.playedSeconds += timer.timeInterval
            self.detailTextLabel?.text = self.timeString(with: self.playedSeconds)

            let duration = self.voice?.duration ?? 0
            if self.playedSeconds > 0 {
                self.progress = self.playedSeconds / duration
            }
        }
    }

    fileprivate func timeString(with duration: TimeInterval) -> String {
        let minutes = floor(duration / 60)
        let seconds = round(duration - minutes * 60)
        return String(format: "%02.f:%02.f", minutes, seconds)
    }

    fileprivate func configure(with voice: Voice?) {
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

    fileprivate func reset() {
        playTimer?.invalidate()
        playTimer = nil
        playedSeconds = 0
        progress = 0
        isPlaying = false
        audioRecorder.delegate = nil
        configure(with: voice)
    }
}

extension VoiceCell: AMRAudioRecorderDelegate {
    func audioRecorderDidStartPlaying(_ audioRecorder: AMRAudioRecorder) {
        print("*********************start playing \(voice?.title ?? "")*********************")
        isPlaying = true
        VoiceCell.currentPlayingCell = self
    }

    func audioRecorderDidStopPlaying(_ audioRecorder: AMRAudioRecorder) {
        print("*********************stop playing \(voice?.title ?? "")*********************")
        reset()
        if VoiceCell.currentPlayingCell == self {
            VoiceCell.currentPlayingCell = nil
        }
    }

    func audioRecorderDidFinishPlaying(_ audioRecorder: AMRAudioRecorder, successfully flag: Bool) {
        let result = flag ? "successfully" : "unsuccessfully"
        print("*********************finish playing \(voice?.title ?? "") \(result)*********************")
        reset()
        if VoiceCell.currentPlayingCell == self {
            VoiceCell.currentPlayingCell = nil
        }
    }
}
