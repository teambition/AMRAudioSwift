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
    internal static let recordSettings: [String: AnyObject] = [AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatLinearPCM),
                                                               AVSampleRateKey: NSNumber(float: 8000.0),
                                                               AVNumberOfChannelsKey: NSNumber(int: 1),
                                                               AVLinearPCMBitDepthKey: NSNumber(int: 16),
                                                               AVLinearPCMIsNonInterleaved: false,
                                                               AVLinearPCMIsFloatKey: false,
                                                               AVLinearPCMIsBigEndianKey: false,]

    internal static func recordLocationURL() -> NSURL {
        let recordLocationURL = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingFormat("%.0f.%@", NSDate.timeIntervalSinceReferenceDate() * 1000, "caf"))
        return recordLocationURL
    }
}
