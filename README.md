# A gideros mobile plugin for microphone blowing detection


## Usage

### iOS

    require 'micblow'

    micblow:addEventListener("MicrophoneBlow", function(timer) 
        print(Global.blowScene, os.date(), "Mic Blow detected")
    end)

    # Start micblow detection
    micblow.startTimerAndRecorder()

    # Stop micblow detection
    micblow.stopTimerAndRecorder()
    
### Android

	# Get average background volume
    self.sampleTimer = CBlowDetectTimer:new()
    self.sampleTimer:startSampleBackgroundVolume()
    # … wait a little
    self.sampleTimer:stopSampleBackgroundVolume()
    
    # Register event for blowing detection
    self.blowDetectTimer:addEventListener(Global.event.micblowDetected, self.onMicblowDetected, self)




## Thanks

iOS version is based on Caroline's work at http://www.giderosmobile.com/forum/discussion/comment/4048

Android AudioMeter: http://www.michaelpardo.com/2012/03/recording-audio-streams/
