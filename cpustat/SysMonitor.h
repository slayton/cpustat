//
//  MyClass.h
//  cpustat
//
//  Created by Stuart Layton on 10/25/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#ifndef __cpustat__MyClass__
#define __cpustat__MyClass__

#include <iostream>
//#import <Cocoa/Cocoa.h>
//#import <Foundation/Foundation.h>

#import <sys/sysctl.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>
#include <mach/mach_init.h>
#include <mach/vm_map.h>


class SysMonitor{
    
public:
    SysMonitor();
    ~SysMonitor();
    
    bool doPoll();
    double getPerMemFree();
    double getTotalMem();
    
    double getPerCPU(int cpuId);
    int getNumCPUs();
    

private:
   
    processor_info_array_t cpuInfo, prevCpuInfo;
    mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
    unsigned numCPUs;
    
};

#endif /* defined(__cpustat__MyClass__) */
