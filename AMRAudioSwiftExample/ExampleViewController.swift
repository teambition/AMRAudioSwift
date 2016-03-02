//
//  ExampleViewController.swift
//  AMRAudioSwiftExample
//
//  Created by 洪鑫 on 16/3/2.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import AMRAudioSwift

enum AudioRecorderState {
    case Normal
    case Recording
    case Playing
}

class ExampleViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    private var audioRecorder = AMRAudioRecorder()
    private var voices = [(duration: NSTimeInterval?, data: NSData)]()
    private var state: AudioRecorderState = .Normal {
        didSet {
            switch state {
            case .Normal:
                primaryButton.setTitle("Record", forState: .Normal)
                stopAnimation()
                cancelButton.hidden = true
            case .Recording:
                primaryButton.setTitle("Recording...", forState: .Normal)
                startAnimation()
                cancelButton.hidden = false
            case.Playing:
                primaryButton.setTitle("Playing...", forState: .Normal)
                startAnimation()
                cancelButton.hidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        audioRecorder.delegate = self
        state = .Normal
    }

    private func startAnimation() {
        let animation: CABasicAnimation = {
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
            animation.toValue = NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 0, 1))
            animation.duration = 1.5
            animation.cumulative = true
            animation.repeatCount = FLT_MAX
            return animation
        }()
        primaryButton.layer.addAnimation(animation, forKey: "rotation")
    }

    private func stopAnimation() {
        primaryButton.layer.removeAllAnimations()
    }

    @IBAction func primaryButtonTapped(sender: UIButton) {
        switch state {
        case .Normal:
            audioRecorder.startRecord()
        case .Recording:
            audioRecorder.stopRecord()
        case .Playing:
            audioRecorder.stopPlay()
        }
    }

    @IBAction func cancelButtonTapped(sender: UIButton) {
        guard state == .Recording else {
            return
        }
        audioRecorder.cancelRecord()
    }
}

extension ExampleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voices.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "Cell")
        }
        let voice = voices[indexPath.row]
        if let duration = voice.duration {
            cell!.textLabel?.text = "Voice \(indexPath.row + 1)  Duration: \(duration)"
        } else {
            cell!.textLabel?.text = "Voice \(indexPath.row + 1)"
        }
        cell!.detailTextLabel?.text = "Click To Play"
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let voice = voices[indexPath.row]
        audioRecorder.play(voice.data)
    }
}

extension ExampleViewController: AMRAudioRecorderDelegate {
    func audioRecorderDidStartRecording(audioRecorder: AMRAudioRecorder) {
        print("*********************start recording*********************")
        state = .Recording
    }

    func audioRecorderDidCancelRecording(audioRecorder: AMRAudioRecorder) {
        print("*********************cancel recording*********************")
        state = .Normal
    }

    func audioRecorderDidStopRecording(audioRecorder: AMRAudioRecorder, url: NSURL?) {
        print("*********************stop recording*********************")
        state = .Normal
        guard let url = url, data = NSData(contentsOfURL: url) else {
            return
        }
        let amrData = AMRAudio.encodeWAVEDataToAMRData(data, channels: 1, bitsPerSample: 16)
        let voice = (duration: AMRAudioRecorder.audioDuration(data), data: amrData)
        let indexPath = NSIndexPath(forRow: voices.count, inSection: 0)
        tableView.beginUpdates()
        voices.append(voice)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableView.endUpdates()
    }

    func audioRecorderDidFinishRecording(audioRecorder: AMRAudioRecorder, successfully flag: Bool) {
        let result = flag ? "successfully" : "unsuccessfully"
        print("*********************finish recording \(result)*********************")
    }

    func audioRecorderDidStartPlaying(audioRecorder: AMRAudioRecorder) {
        print("*********************start playing*********************")
        state = .Playing
    }

    func audioRecorderDidStopPlaying(audioRecorder: AMRAudioRecorder) {
        print("*********************stop playing*********************")
        state = .Normal
    }

    func audioRecorderDidFinishPlaying(audioRecorder: AMRAudioRecorder, successfully flag: Bool) {
        let result = flag ? "successfully" : "unsuccessfully"
        print("*********************finish playing \(result)*********************")
    }
}
