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
@synthesize timeOut;
@synthesize iconMaker;

//@synthesize iconImage;
//@synthesize iconAllocated;

#define ICON_W 1024
#define ICON_H 1024

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    plotType = PLOT_ALL_CORES;

//    renderRect = NSMakeRect(94, 125, ICON_W-(91+94), ICON_H - (131+125));
    renderRect = NSMakeRect(200, 200, 200, 200);

    iconMaker = [[IconMaker alloc] initWithSize:renderRect.size];
    
    iconFrame = [NSImage imageNamed:@"frame_900.png"];
    
    monitor = [[SystemMonitor alloc] init];

    timeOut = 1.25;
    [self startTimer];
    
}


-(void) startTimer{
    NSLog(@"AppDelegate::startTimer()");
    timerRunning = YES;
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
    
    NSString *str = [NSString stringWithFormat:@" "];
    for (int i=0; i< [monitor numCPUs]; i++ )
        str = [str stringByAppendingFormat:@"%0.2f ", [monitor getPerCpu:i]];
    
    NSLog(@"%@",str);

//    NSImage *iconImage = [iconMaker generateIconFromActivity:[monitor perCpu]];
    NSImage *iconImage = [iconMaker generateTestIcon];
   
    [iconFrame lockFocus];
    [iconImage drawInRect:renderRect fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1];
//    [iconImage drawAtPoint:NSMakePoint(94, 125) fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1];
    [iconFrame unlockFocus];

    
    
    [NSApp setApplicationIconImage:iconFrame];
    
    if(DEBUG){
      NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
        [tile setBadgeLabel:str];
    }
}



-(IBAction) menuSetPlotType:(id)sender{
   
    switch ([sender tag]){
        case PLOT_ALL_CORES:
            plotType = PLOT_ALL_CORES;
            break;
        case PLOT_HISTORY:
            plotType = PLOT_HISTORY;
            break;
    }
    
}
@end
