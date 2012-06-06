require 'micblow'

-- Manually start mic blow detection
micblow.startTimerAndRecorder()

micblow:addEventListener("MicrophoneBlow", 
function() 
    print(os.date(), "Detected Microphone Blow") 
    -- You can stop this timer at any time
    micblow.stopTimerAndRecorder()
end, scene)
