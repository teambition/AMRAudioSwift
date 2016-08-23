//
//  ExampleViewController.swift
//  AMRAudioSwiftExample
//
//  Created by 洪鑫 on 16/3/2.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import AMRAudioSwift

typealias Voice = (duration: NSTimeInterval?, amrData: NSData, title: String)

enum AudioRecorderState {
    case Normal
    case Recording
}

let dateFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    return dateFormatter
}()

class ExampleViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    private var audioRecorder = AMRAudioRecorder.sharedRecorder
    private var voices = [Voice]()
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
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        audioRecorder.delegate = self
        state = .Normal
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "VoiceCell", bundle: nil), forCellReuseIdentifier: kVoiceCellID)
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
            audioRecorder.stopPlay()
            audioRecorder.delegate = self
            audioRecorder.startRecord()
        case .Recording:
            audioRecorder.stopRecord()
            audioRecorder.delegate = nil
        }
    }

    @IBAction func cancelButtonTapped(sender: UIButton) {
        guard state == .Recording else {
            return
        }
        audioRecorder.cancelRecord()
        audioRecorder.delegate = nil
    }
}

extension ExampleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voices.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kVoiceCellID) as! VoiceCell

        let voice = voices[indexPath.row]
        cell.voice = voice
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        let voice = (duration: AMRAudioRecorder.audioDuration(data), amrData: amrData, title: "Voice \(dateFormatter.stringFromDate(NSDate()))")
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
}
