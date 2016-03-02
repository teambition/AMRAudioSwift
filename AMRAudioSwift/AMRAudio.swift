//
//  AMRAudio.swift
//  AMRAudioSwift
//
//  Created by Xin Hong on 16/3/2.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public struct AMRAudio {
    public static func decodeAMRDataToWAVEData(data: NSData) -> NSData {
        return DecodeAMRToWAVE(data)
    }

    public static func encodeWAVEDataToAMRData(data: NSData, channels: Int, bitsPerSample: Int) -> NSData {
        return EncodeWAVEToAMR(data, Int32(channels), Int32(bitsPerSample))
    }
}
