//
//  AMRAudio.swift
//  AMRAudioSwift
//
//  Created by Xin Hong on 16/3/2.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public struct AMRAudio {
    public static func decodeAMRDataToWAVEData(amrData data: Data) -> Data {
        return DecodeAMRToWAVE(data)
    }

    public static func encodeWAVEDataToAMRData(waveData data: Data, channels: Int, bitsPerSample: Int) -> Data {
        return EncodeWAVEToAMR(data, Int32(channels), Int32(bitsPerSample))
    }
}
