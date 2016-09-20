//
//  Constants.swift
//  AMRAudioSwift
//
//  Created by Xin Hong on 16/8/19.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import AVFoundation

internal struct AudioRecorder {
    internal static let recordSettings: [String: Any] = [AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
                                                         AVSampleRateKey: NSNumber(value: 8000.0),
                                                         AVNumberOfChannelsKey: NSNumber(value: 1),
                                                         AVLinearPCMBitDepthKey: NSNumber(value: 16),
                                                         AVLinearPCMIsNonInterleaved: false,
                                                         AVLinearPCMIsFloatKey: false,
                                                         AVLinearPCMIsBigEndianKey: false]

    internal static func recordLocationURL() -> URL {
        let recordLocationPath = NSTemporaryDirectory().appendingFormat("%.0f.%@", Date.timeIntervalSinceReferenceDate * 1000, "caf")
        return URL(fileURLWithPath: recordLocationPath)
    }
}
