//
//  SystemMonitor.h
//  cpustat
//
//  Created by Stuart Layton on 10/31/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//
#import <Foundation/Foundation.h>

#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>

@interface SystemMonitor : NSObject{
    
    processor_info_array_t cpuInfo, prevCpuInfo;
    mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
    unsigned numCPUs;
    NSLock *CPUUsageLock;
    
    double mbRam;
//    double *perCpu;
    NSMutableArray *perCpu;
    BOOL realTime;
    int nSampleHistory;
    
}
@property (nonatomic) processor_info_array_t cpuInfo;
@property (nonatomic) processor_info_array_t prevCpuInfo;
@property (nonatomic) unsigned numCPUs;
@property (nonatomic) NSLock * CPUUsageLock;

@property (nonatomic) NSMutableArray * perCpu;


-(void) pollCpuUsage;
-(double) getPerCpu:(int)i;
-(NSArray*) getPerCpu;
-(double) gerPerRam;



@end
