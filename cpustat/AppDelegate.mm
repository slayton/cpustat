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


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    timerRunning = false;
    timeOut = 1;
    
    NSLog(@"Application Loaded!");
    
    [self startTimer];
    
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
    NSLog(@"AppDelegate::timerExpired()");
    float cpu = [self getCpuPercentUsasge];
    float mem = [self getMemPercentFree];
//    float net = [self getNetUsage];
    monitor.doPoll();
}

-(float) getCpuPercentUsasge{
    
    double perCpu1, perCpu2;
    perCpu1 = monitor.getPerCPU(0);
    perCpu2 = monitor.getPerCPU(1);
    NSLog(@"CPU:%3.3f %3.3f", perCpu1,perCpu2);
    
}
-(float) getMemPercentFree{
    
    monitor.getPerMemFree();
    return 1;
    
}
-(float) getNetUsage{
    return 1;
}

@end
