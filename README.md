#AMRAudioSwift
AMRAudioSwift is an useful tool to encode or decode audio between AMR and WAVE. It's written in Swift, and it supports [Bitcode](https://developer.apple.com/library/prerelease/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AppThinning/AppThinning.html#//apple_ref/doc/uid/TP40012582-CH35-SW3).

In addition, AMRAudioSwift contains an audio recorder/player, which can record voice and play AMR data.

At the bottom level,  ```libopencore-amr``` is applied for audio decoding.

##How To Get Started
###Carthage
Specify "AMRAudioSwift" in your Cartfile:
```ogdl 
github "teambition/AMRAudioSwift"
```

###Usage
#####  Configuration
```swift
let audioRecorder = AMRAudioRecorder()
audioRecorder.volume = ...
audioRecorder.proximityMonitoringEnabled = ...

// assign delegate
audioRecorder.delegate = self
```

##### Recording and Playing
```swift
audioRecorder.startRecord()
audioRecorder.cancelRecord()
audioRecorder.stopRecord()
audioRecorder.play(amrData)
audioRecorder.stopPlay()
```

#####  Implement delegate
```swift
func audioRecorderDidStartRecording(audioRecorder: AMRAudioRecorder) {
    // do something
}

func audioRecorderDidCancelRecording(audioRecorder: AMRAudioRecorder) {
    // do something
}

func audioRecorderDidStopRecording(audioRecorder: AMRAudioRecorder, url: NSURL?) {
    // do something
}

func audioRecorderEncodeErrorDidOccur(audioRecorder: AMRAudioRecorder, error: NSError?) {
    // do something
}

func audioRecorderDidFinishRecording(audioRecorder: AMRAudioRecorder, successfully flag: Bool) {
    // do something
}

func audioRecorderDidStartPlaying(audioRecorder: AMRAudioRecorder) {
    // do something
}

func audioRecorderDidStopPlaying(audioRecorder: AMRAudioRecorder) {
    // do something
}

func audioRecorderDecodeErrorDidOccur(audioRecorder: AMRAudioRecorder, error: NSError?) {
    // do something
}

func audioRecorderDidFinishPlaying(audioRecorder: AMRAudioRecorder, successfully flag: Bool) {
    // do something
}
```

## Minimum Requirement
iOS 8.0

## Release Notes
* [Release Notes](https://github.com/teambition/AMRAudioSwift/releases)

## License
AMRAudioSwift is released under the MIT license. See [LICENSE](https://github.com/teambition/AMRAudioSwift/blob/master/LICENSE.md) for details.

## More Info
Have a question? Please [open an issue](https://github.com/teambition/AMRAudioSwift/issues/new)!
