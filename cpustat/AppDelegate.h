//
//  AppDelegate.h
//  cpustat
//
//  Created by Stuart Layton on 10/24/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#import "SystemMonitor.h"
#include "IconMaker.h"

static const int PLOT_ALL_CORES = 1;
static const int PLOT_HISTORY = 2;
static const int PLOT_RAM = 10;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    
    float timeOut;
    BOOL timerRunning;
    BOOL reportCpu;
    BOOL reportRam;
    
    NSTimer *updateTimer;
    NSLock *CPUUsageLock;
    
    NSImage *iconFrame;
    NSRect renderRect;
    
    SystemMonitor *monitor;
    IconMaker *iconCpu;
    IconMaker *iconRam;

    NSMenu *appDockMenu;
    NSMenuItem *showCpuItem;
    NSMenuItem *showRamItem;
    
    NSArray *taskList;
    
    int plotType;
    
}
@property (nonatomic) NSArray *taskList;
@property (assign) IBOutlet NSWindow *window;

@property (nonatomic) float timeOut;

@property  (nonatomic) SystemMonitor * monitor;
@property (nonatomic) IconMaker * iconCpu;
@property (nonatomic) IconMaker * iconRam;


-(void) startTimer;
-(void) timerExpired;
-(float) getCpuPercentUsasge;
-(float) getMemPercentFree;
-(float) getNetUsage;

-(void) updateDockIcon;

-(NSMenu *) applicationDockMenu;





@end
