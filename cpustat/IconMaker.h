//
//  IconMaker.h
//  cpustat
//
//  Created by Stuart Layton on 10/30/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconMaker : NSObject{

    NSSize pixelSize;
    NSSize renderSize;
    
    int sampPerPix;
    int sampPerRow;
    int nTotalSamp;
    
    unsigned char * pixels;
    
    NSImage *renderImage;
            
}
@property (nonatomic) NSSize pixelSize;
@property (nonatomic) NSSize renderSize;

@property (nonatomic) int sampPerPix;
@property (nonatomic) int sampPerRow;
@property (nonatomic) int nTotalSamp;


@property (nonatomic) unsigned char * pixels;
@property (nonatomic) NSImage * theIcon;
@property (nonatomic) NSImage * renderImage;

-(id) initWithSize:(NSSize)s;

-(void) setRenderBounds:(NSRect) bounds;
-(NSImage *)generateTestIcon;
-(NSImage *)generateIconFromActivity:(NSArray *)per;
-(void) drawStringToImage:(NSString*) str;
//-(void)bytesToImage;
//-(NSImage *)addMask:(NSImage*)img1 withImage:(NSImage*)img2;

//-(NSImage *)generateCpuHistoryIcon:(int) n:(int*)cpuLoad:(unsigned char*) bytes;
//-(NSImage *)generateCpuAndRamIcon:(int) n:(int *)cpuLoad:(int)ramLoad:(unsigned char*) byte
@end


