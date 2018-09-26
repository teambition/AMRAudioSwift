//
//  ExampleViewController.swift
//  AMRAudioSwiftExample
//
//  Created by 洪鑫 on 16/3/2.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import AMRAudioSwift

typealias Voice = (duration: TimeInterval?, amrData: Data, title: String)

enum AudioRecorderState {
    case normal
    case recording
}

let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    return dateFormatter
}()

class ExampleViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    fileprivate var audioRecorder = AMRAudioRecorder.shared
    fileprivate var voices = [Voice]()
    fileprivate var state: AudioRecorderState = .normal {
        didSet {
            switch state {
            case .normal:
                primaryButton.setTitle("Record", for: .normal)
                stopAnimation()
                cancelButton.isHidden = true
            case .recording:
                primaryButton.setTitle("Recording...", for: .normal)
                startAnimation()
                cancelButton.isHidden = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        audioRecorder.delegate = self
        state = .normal
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "VoiceCell", bundle: nil), forCellReuseIdentifier: kVoiceCellID)
    }

    fileprivate func startAnimation() {
        let animation: CABasicAnimation = {
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
            animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(.pi / 2, 0, 0, 1))
            animation.duration = 1.5
            animation.isCumulative = true
            animation.repeatCount = .greatestFiniteMagnitude
            return animation
        }()
        primaryButton.layer.add(animation, forKey: "rotation")
    }

    fileprivate func stopAnimation() {
        primaryButton.layer.removeAllAnimations()
    }

    @IBAction func primaryButtonTapped(_ sender: UIButton) {
        switch state {
        case .normal:
            audioRecorder.delegate = self
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    self.audioRecorder.stopPlay()
                    self.audioRecorder.startRecord()
                }
            }
        case .recording:
            audioRecorder.stopRecord()
            audioRecorder.delegate = nil
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        guard state == .recording else {
            return
        }
        audioRecorder.cancelRecord()
        audioRecorder.delegate = nil
    }
}

extension ExampleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voices.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kVoiceCellID) as! VoiceCell

        let voice = voices[indexPath.row]
        cell.voice = voice
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ExampleViewController: AMRAudioRecorderDelegate {
    func audioRecorderDidStartRecording(_ audioRecorder: AMRAudioRecorder) {
        print("*********************start recording*********************")
        state = .recording
    }

    func audioRecorderDidCancelRecording(_ audioRecorder: AMRAudioRecorder) {
        print("*********************cancel recording*********************")
        state = .normal
    }

    func audioRecorderDidStopRecording(_ audioRecorder: AMRAudioRecorder, withURL url: URL?) {
        print("*********************stop recording*********************")
        state = .normal
        guard let url = url, let data = try? Data(contentsOf: url) else {
            return
        }
        let amrData = AMRAudio.encodeWAVEDataToAMRData(waveData: data, channels: 1, bitsPerSample: 16)
        let voice = (duration: AMRAudioRecorder.audioDuration(from: data), amrData: amrData, title: "Voice \(dateFormatter.string(from: Date()))")
        let indexPath = IndexPath(row: voices.count, section: 0)
        tableView.beginUpdates()
        voices.append(voice)
        tableView.insertRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }

    func audioRecorderDidFinishRecording(_ audioRecorder: AMRAudioRecorder, successfully flag: Bool) {
        let result = flag ? "successfully" : "unsuccessfully"
        print("*********************finish recording \(result)*********************")
    }
}
