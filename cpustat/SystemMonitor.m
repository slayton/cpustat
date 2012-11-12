//
//  SystemMonitor.m
//  cpustat
//
//  Created by Stuart Layton on 10/31/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#import "SystemMonitor.h"
#import "TaskInfo.h";

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
        
        realTime = NO;
        nSampleHistory = 10;
        [self makePerCpuArray];
        
    }
    return self;
}

-(void) pollCpuUsage{
    
    NSMutableArray *pollArray = [[NSMutableArray alloc] initWithCapacity:numCPUs];

    //[perCpu removeAllObjects];
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
            
            [pollArray insertObject:[NSNumber numberWithDouble:inUse/total] atIndex:i];
            
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
        
        
        if (realTime){
            [perCpu removeAllObjects];
            
            for (int i=0; i<pollArray.count; i++)
                [perCpu insertObject:[pollArray objectAtIndex:i] atIndex:i];
        }
        else{
            double meanUsage = 0;
            for (int i=0; i<pollArray.count; i++)
                meanUsage += [(NSNumber *)[pollArray objectAtIndex:i] doubleValue];
            meanUsage /= [pollArray count];
            [perCpu removeObjectAtIndex:0];
            [perCpu addObject:[NSNumber numberWithDouble:meanUsage]];
        }
    }
    else {
        NSLog(@"Error!");
        [NSApp terminate:nil];
    }
    
    NSString *str = @"";
    for (int i=0; i<[perCpu count]; i++) 
        str = [str stringByAppendingFormat:@"%0.2f ", [(NSNumber *) [perCpu objectAtIndex:i] doubleValue]];
    
//    NSLog([@"Poll cpu usage:" stringByAppendingString:str]);
}
-(void) makePerCpuArray{
    int nSample;
    if (realTime)
        nSample = numCPUs;
    else
        nSample = nSampleHistory;
    
    perCpu = [ [NSMutableArray alloc] initWithCapacity:nSample];

    for (int i=0; i<nSample; i++)
        [perCpu insertObject:[NSNumber numberWithDouble:0] atIndex:i];
    
    NSLog(@"New perCpu array initialized with %d samples", nSample);
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

-(NSArray *) getRunningTasks{
    
    NSMutableArray *taskList = [[NSMutableArray alloc] initWithCapacity:150];
    char ps_cmd[256];
    sprintf(ps_cmd, "ps AcrO %%cpu,%%mem");
    //    printf("Executing command:%s\n", ps_cmd);
    
    const int NCHARS = 1024;
    FILE *fp = popen(ps_cmd, "r");
    if (fp){
        
        char result[NCHARS];
        fgets(result, NCHARS, fp); // Read and ignore the first line
        NSScanner *sc;
        
        while( fgets(result, NCHARS, fp) ){
            fgets(result, NCHARS, fp);
            
            sc = [NSScanner scannerWithString:[NSString stringWithUTF8String:result]];
            
            int pid;
            double cpu;
            double ram;
            NSString * name = NULL;
            
            
            [sc scanInt:&pid];
            [sc scanDouble:&cpu];
            [sc scanDouble:&ram];
            
            [sc scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
            [sc scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
            [sc scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
            [sc scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]  intoString:&name];
            
            [taskList addObject:[ [TaskInfo alloc] initWithName:name percentCpu:cpu percentRam:ram andPID:pid] ];
            
            result[0] = 0;
        }
    }
//    NSLog(@"Returning task list with %d items", [taskList count]);
    return taskList;
}
@end
