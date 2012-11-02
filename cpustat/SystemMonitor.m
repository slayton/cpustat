//
//  SystemMonitor.m
//  cpustat
//
//  Created by Stuart Layton on 10/31/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#import "SystemMonitor.h"

@implementation SystemMonitor
@synthesize perCpu;
@synthesize numCPUs;
@synthesize cpuInfo;
@synthesize prevCpuInfo;
@synthesize CPUUsageLock;

-(id)init{
    
    self = [super init];
    
    if (self){
    
        int mib[2U] = { CTL_HW, HW_NCPU };
        size_t sizeOfNumCPUs = sizeof(numCPUs);
        int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
        
        if(status)
            numCPUs = 1;
        
        CPUUsageLock = [[NSLock alloc] init];
        
        // Setup the percentCpu array, alloc, then initialize to 0
        perCpu = [ [NSMutableArray alloc] initWithCapacity:numCPUs];
        
        for (int i=0; i<perCpu.count; i++)
            [perCpu insertObject:[NSNumber numberWithDouble:-1.0] atIndex:i];
        
    }
    return self;
}

-(void) pollCpuUsage{
    
    [perCpu removeAllObjects];
    natural_t numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    
    if(err == KERN_SUCCESS) {
        [CPUUsageLock lock];
        
        for(unsigned i = 0U; i < numCPUs; ++i) {
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
            
//            NSLog(@"Core: %u Usage: %f",i,inUse / total);
            
            [perCpu insertObject:[NSNumber numberWithDouble:inUse/total] atIndex:i];
            
        }
        [CPUUsageLock unlock];
        
        if(prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0U;
    }
    else {
        NSLog(@"Error!");
        [NSApp terminate:nil];
    }
}
-(double) getPerCpu:(int)i{

    
    if (i >= numCPUs) {
        fprintf(stderr, "Invalid CPU requested, ignoring!");
        return -1;
    }
    
    NSNumber *num = [perCpu objectAtIndex:i];
    return [num doubleValue];
    
}
-(NSArray *) getPerCpu{
    return perCpu;
}

-(double) gerPerRam{
    return 0;
}
@end
