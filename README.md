# A gideros mobile plugin for iphone player

Based on Caroline's work at http://www.giderosmobile.com/forum/discussion/comment/4048

# Usage

    require 'micblow'

    micblow:addEventListener("MicrophoneBlow", function(timer) 
        print(Global.blowScene, os.date(), "Mic Blow detected")
    end)

    # Start micblow detection
    micblow.startTimerAndRecorder()

    # Stop micblow detection
    micblow.stopTimerAndRecorder()
