//The code for this is taken from 
//http://mobileorchard.com/tutorial-detecting-when-a-user-blows-into-the-mic/
//and Gideros Studio's atilim's code for a global Event Dispatcher here:
//http://www.giderosmobile.com/forum/discussion/690/global-geventdispatcherproxy#Item_2
//

#include "gideros.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface MicBlowTimer : NSObject
{
	NSTimer* timer;
	lua_State* L;
    AVAudioRecorder *recorder;
    double lowPassResults;
}

@property (nonatomic, retain) AVAudioRecorder *recorder;

@end

@implementation MicBlowTimer

@synthesize recorder;

- (id)initWithLuaState:(lua_State *)theL andRecorder:(AVAudioRecorder *)theRecorder
{
    self = [super init];
    if (self)
	{	
        L = theL;
        self.recorder = theRecorder;
	}
    return self;
}

-(void)stopTimerAndRecorder
{
    [timer invalidate];
    timer = nil;
    [recorder stop];
}

-(void)startTimerAndRecorder
{
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    [recorder record];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                             target:self
                                           selector:@selector(onTick:)
                                           userInfo:nil
                                            repeats:YES];	
}

-(void)onTick:(NSTimer *)timer
{
    if (recorder) {
    [recorder updateMeters];
    
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    
    if (lowPassResults < 0.80)
        return;
    
    //dispatch microphone blow 
	lua_getglobal(L, "micblow");
	if (!lua_isnil(L, -1))
	{
		lua_getfield(L, -1, "dispatchEvent");	// get the dispatchEvent function of micblow
		lua_pushvalue(L, -2);	// duplicate micblow, this will be the 1st parameter of dispatchEvent
		
		// create an Event object (this will be the 2nd parameter of dispatchEvent)
		lua_getglobal(L, "Event");		// get the global Event table
		lua_getfield(L, -1, "new");		// get its new function
		lua_remove(L, -2);				// remove the global Event table
		lua_pushstring(L, "MicrophoneBlow");
		lua_call(L, 1, 1);				// call as Event.new("complete")
		
		lua_call(L, 2, 0);	// call dispatchEvent with micblow and event
 	}
	lua_pop(L, 1);	// pop nil or onesec
    }
}

- (void)invalidate
{
	[timer invalidate];
}

@end


static int destruct(lua_State* L)
{
	void* ptr = *(void**)lua_touserdata(L, 1);
	GReferenced* object = static_cast<GReferenced*>(ptr);
	GEventDispatcherProxy* proxy = static_cast<GEventDispatcherProxy*>(object->proxy());
	
	proxy->unref();
	
	return 0;
}

static MicBlowTimer *timer = nil;

static int stopTimerAndRecorder(lua_State* L)
{
    [timer stopTimerAndRecorder];
}

static int startTimerAndRecorder(lua_State* L)
{
    [timer startTimerAndRecorder];
}

static int loader(lua_State* L)
{
	const luaL_Reg functionlist[] = {
        {"stopTimerAndRecorder", stopTimerAndRecorder},
        {"startTimerAndRecorder", startTimerAndRecorder},
		{NULL, NULL},
	};
	
	g_createClass(L, "MicBlow", "EventDispatcher", NULL, destruct, functionlist);
    
	GEventDispatcherProxy* proxy = new GEventDispatcherProxy;
	g_pushInstance(L, "MicBlow", proxy->object());
    
	lua_pushvalue(L, -1);
	lua_setglobal(L, "micblow");
	
	return 1;
}

static void g_initializePlugin(lua_State *L)
{
	lua_getglobal(L, "package");
	lua_getfield(L, -1, "preload");
	
	lua_pushcfunction(L, loader);
	lua_setfield(L, -2, "micblow");
	
	lua_pop(L, 2);
    
    
    //initialise the AVAudioRecorder
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    //additional line to make it work
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    
    //code from http://mobileorchard.com/tutorial-detecting-when-a-user-blows-into-the-mic/
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
  	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
  	NSError *error;
    
  	AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
  	if (recorder) {
//  		[recorder prepareToRecord];
//  		recorder.meteringEnabled = YES;
//  		[recorder record];
  	} else
  		NSLog(@"%@",[error description]);
    
    //end initialise the AVAudioRecorder
    
	timer = [[MicBlowTimer alloc] initWithLuaState:L andRecorder:recorder];
    [recorder release];
    
}

static void g_deinitializePlugin(lua_State *L)
{
	[timer invalidate];
	[timer release];
	timer = nil;
}

REGISTER_PLUGIN("CBMicBlow", "1.0")
