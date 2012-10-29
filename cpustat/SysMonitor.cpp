//
//  MyClass.cpp
//  cpustat
//
//  Created by Stuart Layton on 10/25/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#include "SysMonitor.h"
#include <iostream>

SysMonitor::SysMonitor(){
    
//    NSLog(@"SysMonitor Instantiated!");
    std::cout<<"SysMonitor::SysMonitor()"<<std::endl;
    
    int mib[2U] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    
    if(status)
        numCPUs = 1;
    

}

SysMonitor::~SysMonitor(){
 
}

bool SysMonitor::doPoll(){
    
    std::cout<<"SysMonitor::doPoll()"<<std::endl;
    return TRUE;
}

double SysMonitor::getPerMemFree(){
    
    std::cout<<"SysMonitor::getPerMemFree()"<<std::endl;

    int mib[6];
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    
    int pagesize;
    size_t length;
    length = sizeof (pagesize);
    if (sysctl (mib, 2, &pagesize, &length, NULL, 0) < 0)
    {
        fprintf (stderr, "getting page size");
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics (mach_host_self (), HOST_VM_INFO, (host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf (stderr, "Failed to get VM statistics.");
    }
    
    double total = vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count;
    double perFree = (vmstat.free_count + vmstat.inactive_count) / total;
    
    std::cout<<"Mem :"<<perFree*100<<std::endl;

    return 0;
}

double SysMonitor::getTotalMem(){
    
    std::cout<<"SysMonitor::getTotalMem()"<<std::endl;

    return 0;
}

int SysMonitor::getNumCPUs(){
    std::cout<<"SysMonitor::getNumCPUS()"<<std::endl;

    return 0;
}
double SysMonitor::getPerCPU(int i){
    
    double perUse = -1;
    if (i >= numCPUs){
        std::cout<<"Invalid CPU!"<<std::endl;
        return perUse;
        
    }
    

    natural_t numCPUsU = 0U;
    
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    
//    NSMutableString *cpuStr = [NSMutableString stringWithFormat:@"CPU:"];

    if(err == KERN_SUCCESS) {
//        [CPUUsageLock lock];

        float inUse, total;
        if(prevCpuInfo) {
            inUse = (
                     (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                     + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                     + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                     );
            total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
        } else {
            inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
            total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
        }
        
        
        perUse = inUse/total;
//        std::cout << i << ":" << inUse/total << std::endl;
//            [cpuStr appendString:[NSString stringWithFormat:@"[%u %3.3f] ",i,inUse / total] ] ;
            //            NSLog(@"%[u, %3.3f]",i,inUse / total);
        
//        [CPUUsageLock unlock];
        
        if(prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0U;
//        NSLog(cpuStr);
        
    } else {
//        NSLog(@"Error!");
//        [NSApp terminate:nil];
        std::cout<<"ERROR!"<<std::endl;
    }
    
    
    return perUse;
}
