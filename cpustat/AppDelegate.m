//
//  AppDelegate.m
//  cpustat
//
//  Created by Stuart Layton on 10/24/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate
@synthesize monitor;
@synthesize timerRunning;
@synthesize timeOut;
@synthesize iconMaker;

//@synthesize iconImage;
//@synthesize iconAllocated;
#define ICON_W 1024
#define ICON_H 1024

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"applicationDidFinishLaunching!");

    // Initialize the instance vars
    timerRunning = false;
    timeOut = .5;

    // Instantiate the icon maker, set the mask, and drawing area
    
    iconMaker = [[IconMaker alloc] initWithSize:NSMakeSize(ICON_W, ICON_H)];
    iconMaker.iconMask = [NSImage imageNamed:@"frame.png"];
    
    [iconMaker setRenderBounds: NSMakeRect(32, 68, ICON_W - 32, ICON_H - 68) ];
    
    monitor = [[SystemMonitor alloc] init];
    // Start the timer!

    [self startTimer];
    [self timerExpired]; // run once to update immediately!
    
}

-(void) startTimer{
    NSLog(@"AppDelegate::startTimer()");
    [NSTimer scheduledTimerWithTimeInterval: timeOut
                                     target: self
                                   selector:@selector(timerExpired)
                                   userInfo: nil
                                    repeats: YES];
}

-(void) timerExpired{

    [monitor pollCpuUsage];
    
    [self updateDockIcon];
}

-(float) getCpuPercentUsasge{ return -1; }
-(float) getMemPercentFree{ return -1; }
-(float) getNetUsage{ return -1; }

-(void) updateDockIcon{
    //NSLog(@"Updating dock icon!");
    
//    NSString *str = [NSString stringWithFormat:@"CPU "];
//    for (int i=0; i< [monitor numCPUs]; i++ ){
//        str = [str stringByAppendingFormat:@"%d:%3.3f ", i, [monitor getPerCpu:i]];
//    }
//    NSLog(str);
    
    NSImage *iconImage = [iconMaker generateTestIcon];
    [NSApp setApplicationIconImage:iconImage];
}

@end
