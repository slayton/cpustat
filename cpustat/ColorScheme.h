//
//  ColorScheme.h
//  cpustat
//
//  Created by Stuart Layton on 11/12/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorScheme : NSObject
{
    @public
    int lowR;
    int lowG;
    int lowB;
    
    int medR;
    int medG;
    int medB;
    
    int highR;
    int highG;
    int highB;
}
-(id) initCpuScheme;
-(id) initRamScheme;

@end
