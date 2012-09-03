--[[
-- Detect mic blowing using customized http server plugin
-- ANDROID ONLY
-- ]]

CBlowDetectTimer = Core.class(EventDispatcher)

function CBlowDetectTimer:init()
    self.timer = Timer.new(400)
    self.volumeBuffer = {}
    self.timer:addEventListener(Event.TIMER, function(e)
        local loader = UrlLoader.new("http://localhost:8080")

        function onComplete(event)
            local volume = tonumber(event.data)
            print(Global.GameBlow.averageBackgroundVolume, event.data)

            if (volume > Global.GameBlow.averageBackgroundVolume * 2) then
                print("blow detected")
                self:dispatchEvent(Event.new(Global.event.micblowDetected))
            else
                table.insert(self.volumeBuffer, volume)
            end
        end

        function onError()
            print("mic blow detection timer connection error")
        end

        loader:addEventListener(Event.COMPLETE, onComplete)
        loader:addEventListener(Event.ERROR, onError)
    end)

    self.sampleBackgroundNoiseTimer = Timer.new(200)
    self.backgroundNoiseVolumeBuffer = {}
    self.sampleBackgroundNoiseTimer:addEventListener(Event.TIMER, function(e)
        local loader = UrlLoader.new("http://localhost:8080")

        function onComplete(event)
            local volume = tonumber(event.data)
            print(volume)

            if volume ~= 0 then
                table.insert(self.backgroundNoiseVolumeBuffer, volume)
            end
        end

        function onError()
            print("mic blow backgroundNoiseVolume timer connection error")
        end

        loader:addEventListener(Event.COMPLETE, onComplete)
        loader:addEventListener(Event.ERROR, onError)
    end)
    
end

function CBlowDetectTimer:start()
    print("CBlowDetectTimer start")
    self.timer:start()
end

function CBlowDetectTimer:stop()
    print("CBlowDetectTimer stop")
    self.timer:stop()
end

function CBlowDetectTimer:startSampleBackgroundVolume()
    self.sampleBackgroundNoiseTimer:start()
end

function CBlowDetectTimer:stopSampleBackgroundVolume()
    self.sampleBackgroundNoiseTimer:stop()
    local sum = 0
    for i,v in ipairs(self.backgroundNoiseVolumeBuffer) do
        sum = sum + v
    end

    Global.GameBlow.averageBackgroundVolume = sum / #self.backgroundNoiseVolumeBuffer
    print("averageBackgroundVolume", Global.GameBlow.averageBackgroundVolume)
end

