#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/ThanosDanceBundle.bundle"

#import <AVFoundation/AVFoundation.h>

//SBHomeScreenViewController
//_SBRemoteAlertHostViewController
//_UIRemoteView

@interface _SBRemoteAlertHostViewController : UIViewController
	- (void)playerItemDidReachEnd:(NSNotification *)notification;
@end

@interface SBHomeScreenViewController : UIViewController
	- (void)playerItemDidReachEnd:(NSNotification *)notification;
@end

@interface _UIRemoteView : UIView
	- (id)_viewControllerForAncestor;
@end


%hook _UIRemoteView

 - (void)didMoveToSuperview {
 	UIViewController *ancestor = [self _viewControllerForAncestor];

 	if (ancestor != NULL && [ancestor class] == [NSClassFromString(@"_SBRemoteAlertHostViewController") class]) {
 		self.alpha = 0.5;
 	}
 }

%end


%hook _SBRemoteAlertHostViewController

-(void)viewDidAppear:(bool)something {

    %orig;

	NSBundle *bundle = [[[NSBundle alloc] initWithPath:kBundlePath] autorelease];
	NSString *videoPath = [bundle pathForResource:@"thanos" ofType:@"mp4"];

    if (videoPath != NULL) {
    	NSURL *url = [NSURL fileURLWithPath:videoPath];
    
	    AVPlayer *player = [AVPlayer playerWithURL:url];
	    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
	    
	    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	    player.volume = 0;
	    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
	    
	    playerLayer.frame = self.view.layer.bounds;
	    [self.view.layer insertSublayer:playerLayer atIndex:0];

	    NSError *sessionError = nil;
	    AVAudioSession *session = [AVAudioSession sharedInstance];
	    [session setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
	    [session setActive:true error:&sessionError];
	    
	    [player play];

	    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];

        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:true block:^(NSTimer * _Nonnull timer) {
	        if (player.timeControlStatus != AVPlayerTimeControlStatusPlaying) {
	            [player play];
	        }
	    }];
    }
}

%new
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:NULL];
}

%end





// %hook SBHomeScreenViewController

// -(void)viewDidAppear:(bool)something {

//     %orig;

// 	NSBundle *bundle = [[[NSBundle alloc] initWithPath:kBundlePath] autorelease];
// 	NSString *videoPath = [bundle pathForResource:@"thanos" ofType:@"mp4"];

//     if (videoPath != NULL) {
//     	NSURL *url = [NSURL fileURLWithPath:videoPath];
    
// 	    AVPlayer *player = [AVPlayer playerWithURL:url];
// 	    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
	    
// 	    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
// 	    player.volume = 0;
// 	    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
	    
// 	    playerLayer.frame = self.view.layer.bounds;
// 	    [self.view.layer insertSublayer:playerLayer atIndex:0];

// 	    NSError *sessionError = nil;
// 	    AVAudioSession *session = [AVAudioSession sharedInstance];
// 	    [session setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
// 	    [session setActive:true error:&sessionError];
	    
// 	    [player play];

// 	    [[NSNotificationCenter defaultCenter] addObserver:self
//                                              selector:@selector(playerItemDidReachEnd:)
//                                                  name:AVPlayerItemDidPlayToEndTimeNotification
//                                                object:[player currentItem]];

//         [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:true block:^(NSTimer * _Nonnull timer) {
// 	        if (player.timeControlStatus != AVPlayerTimeControlStatusPlaying) {
// 	            [player play];
// 	        }
// 	    }];
//     }
// }

// %new
// - (void)playerItemDidReachEnd:(NSNotification *)notification {
//     AVPlayerItem *p = [notification object];
//     [p seekToTime:kCMTimeZero completionHandler:NULL];
// }

// %end