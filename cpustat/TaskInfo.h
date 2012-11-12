//
//  TaskInfo.h
//  CocoaSandbox
//
//  Created by Stuart Layton on 11/8/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#ifndef CocoaSandbox_TaskInfo_h
#define CocoaSandbox_TaskInfo_h

@interface TaskInfo : NSObject{
    
    NSString * name;
    double cpu;
    double ram;
    int pid;
}
@property (nonatomic) NSString * name;
@property (nonatomic) double cpu;
@property (nonatomic) double ram;
@property (nonatomic) int pid;


-(id) initWithName:(NSString*)name percentCpu:(double)c percentRam:(double) r andPID:(int)pid;
@end


#endif
