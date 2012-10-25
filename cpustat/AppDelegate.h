//
//  AppDelegate.h
//  cpustat
//
//  Created by Stuart Layton on 10/24/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    
    float timeOut;
    bool timerRunning;

    processor_info_array_t cpuInfo, prevCpuInfo;
    mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
    unsigned numCPUs;
    NSTimer *updateTimer;
    NSLock *CPUUsageLock;
}
@property (assign) IBOutlet NSWindow *window;

@property (nonatomic) float timeOut;
@property (nonatomic) bool timerRunning;

-(void) startTimer;
-(void) timerExpired;
-(float) getCpuPercentUsasge;
-(float) getMemPercentFree;
-(float) getNetUsage;





@end
