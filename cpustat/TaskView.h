//
//  TaskView.h
//  cpustat
//
//  Created by Stuart Layton on 11/8/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TaskView : NSView
{
    NSTextField *name;
    NSTextField *cpu;
    NSTextField *ram;
    NSButton *close;
}

@property (nonatomic) NSTextField * name;
@property (nonatomic) NSTextField * cpu;
@property (nonatomic) NSTextField * ram;
@property (nonatomic) NSButton * close;

@end
