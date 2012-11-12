//
//  AppDelegate.m
//  cpustat
//
//  Created by Stuart Layton on 10/24/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#import "AppDelegate.h"
#import "TaskInfo.h"

@implementation AppDelegate
@synthesize monitor;
@synthesize timeOut;
@synthesize iconCpu;
@synthesize iconRam;
@synthesize taskList;

//@synthesize iconImage;
//@synthesize iconAllocated;

#define ICON_W 1024
#define ICON_H 1024

static const int MAX_N_TASK = 5;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    plotType = PLOT_ALL_CORES;
    reportCpu = YES;
    reportRam = YES;
    
    renderRect = NSMakeRect(94, 125, ICON_W-(91+94), ICON_H - (131+125));
//    renderRect = NSMakeRect(94, 125, 848, ICON_H - (131+125));
//    renderRect = NSMakeRect(200, 200, 200, 200);

    iconCpu = [[IconMaker alloc] initWithSize:renderRect.size];
    
    iconFrame = [NSImage imageNamed:@"frame_900.png"];
    
    monitor = [[SystemMonitor alloc] init];

    timeOut = 2;
    [self timerExpired];
    [self startTimer];

    //[self populateDockMenu];
    
    
    
}

-(void) populateDockMenu{
    
    if (appDockMenu == NULL){
        appDockMenu = [[NSMenu alloc] initWithTitle:@"DockMenu"];
        [appDockMenu setAutoenablesItems:NO];
	}
    [appDockMenu removeAllItems];
    
    
    NSMenu *taskListMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"Top!!Tasks"];
    NSMenuItem *taskListItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle: @"Top Tasks"
                                                                                    action:NULL
                                                                             keyEquivalent:@""];

    int nTask = ([taskList count] > MAX_N_TASK ? MAX_N_TASK : [taskList count]);
    TaskInfo *t;
    NSString *s;
    
//  -----------------------------------
//   Create list of top tasks as menu items
//  -----------------------------------
//    for (int i=0; i<nTask; i++){
//        t = [taskList objectAtIndex:i];
//        s = [NSString stringWithFormat:@"%2.2f %2.2f %@",t.cpu, t.ram, t.name];
//        NSMenuItem *item =[[ NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:s
//                                                                               action:@selector(killProcess:)
//                                                                            keyEquivalent:@""];
//        [item setTarget: self];
//        [taskListMenu addItem:item];
//    
//        
//    }
    
    NSMenuItem *item =
    [[ NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Coming Soon!"
                                                          action:@selector(killProcess:)
                                                   keyEquivalent:@""];
    [item setEnabled:NO];
    [item setTarget: self];
    [taskListMenu addItem:item];
    
    [appDockMenu addItem:taskListItem];
    [appDockMenu setSubmenu:taskListMenu forItem:taskListItem];
    
    //-----------------
    // RAM AND CPU ITEMS
    //-----------------
    [appDockMenu addItem:[NSMenuItem separatorItem]];
    
    if (showCpuItem == NULL){
        showCpuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Show CPU Usage" action:@selector(toggleCpuPlotting:) keyEquivalent:@""];
        [showCpuItem setState:reportCpu];
        [showCpuItem setImage:[NSImage imageNamed:@"menu_cpu_high.png"]];

    }
    if (showRamItem == NULL){
        showRamItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Show RAM Usage" action:@selector(toggleRamPlotting:) keyEquivalent:@""];
        [showRamItem setState:reportRam];
    }
    
    [appDockMenu addItem:showCpuItem];
    [appDockMenu addItem:showRamItem];    
    
}
// -------------------------------------------------------------------------------
//	validateMenuItem:theMenuItem
// -------------------------------------------------------------------------------
- (BOOL)validateMenuItem:(NSMenuItem*)theMenuItem
{
    BOOL enable = [self respondsToSelector:[theMenuItem action]];

	return enable;
}

// -------------------------------------------------------------------------------
//	applicationDockMenu:sender
// -------------------------------------------------------------------------------
// This NSApplication delegate method is called when the user clicks and holds on
// the application icon in the dock.
//

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
	return appDockMenu;
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

//    taskList = [monitor getRunningTasks];
    [self updateDockIcon];
    [self populateDockMenu];
}

-(void) updateDockIcon{
    
    NSImage *iconImage = [iconCpu generateIconFromActivity:[monitor perCpu] halfSize:(reportCpu && reportRam)];
   
    [iconFrame lockFocus];
    [iconImage drawInRect:renderRect fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1];
    [iconFrame unlockFocus];

    [NSApp setApplicationIconImage:iconFrame];   
}


-(void) toggleCpuPlotting:(id)sender{
    if (sender != showCpuItem)
        return;
    
    reportCpu = [sender state];
    switch( reportCpu ){

        case 0: // already OFF, set to ON
            reportCpu = YES;
            NSLog(@"Enabling CPU Plotting");
            break;
        case 1: // already ON set to OFF
            reportCpu = NO;
            NSLog(@"Disabling CPU Plotting");
            break;
    }
    [sender setState:reportCpu];
}
-(void) toggleRamPlotting:(id)sender{
    if (sender != showRamItem)
        return;
    reportRam = [sender state];
    switch( reportRam ){
            
        case 0: // already OFF, set to ON
            reportRam = YES;
            NSLog(@"Enabling RAM Plotting");
            break;
        case 1: // already ON set to OFF
            reportRam = NO;
            NSLog(@"Disabling RAM Plotting");
            break;
    }
    [sender setState:reportRam];
}
-(void) killProcess:(id)sender{
    NSLog(@"Killing the process");
}

@end
