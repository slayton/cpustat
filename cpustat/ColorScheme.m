//
//  ColorScheme.m
//  cpustat
//
//  Created by Stuart Layton on 11/12/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#import "ColorScheme.h"

@implementation ColorScheme

-(id) initCpuScheme{
    
    
    self = [super init];
    if(self){
        
        lowR = 0;
        lowG = 255;
        lowB = 0;
        
        medR = 255;
        medG = 255;
        medB = 0;
        
        highR = 255;
        highG = 0;
        highB = 0;
    }
    return self;
}
-(id) initRamScheme{
    
    
    self = [super init];
    if(self){
        lowR = 0;
        lowG = 0;
        lowB = 255;
        
        medR = 0;
        medG = 0;
        medB = 255;
        
        highR = 0;
        highG = 0;
        highB = 255;
        
    }
    return self;
}

@end
