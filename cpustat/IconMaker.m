//
//  IconMaker.m
//  cpustat
//
//  Created by Stuart Layton on 10/30/12.
//  Copyright (c) 2012 Stuart Layton. All rights reserved.
//

#import "IconMaker.h"
#import "Cocoa/Cocoa.h"

@interface IconMaker (hidden)

-(void)writePixelsToIcon;
-(void)addDrawingMask;
-(BOOL) shouldDrawIndex:(int)i;

@end


@implementation IconMaker

@synthesize size;
@synthesize sampPerPix;
@synthesize sampPerRow;
@synthesize nTotalSamp;
@synthesize pixels;
@synthesize iconMask;
@synthesize theIcon;

-(id) initWithSize:(NSSize) s{
    
    self = [super init];
    
    if (self){

        sampPerPix = 4;
        self.size = s;
        sampPerRow = sampPerPix * size.width;
        
        nTotalSamp = (int)size.width * (int)size.height * sampPerPix;

        pixels = malloc( nTotalSamp * sizeof(unsigned char));
    
        renderArea = NSMakeRect(0, 0, size.width, size.height);
        
    }
    return self;


}
-(BOOL) shouldDrawIndex:(int) i{
   
    
    return ( i / sampPerRow > renderArea.origin.y    &&
             i / sampPerRow < renderArea.size.height &&
             i % sampPerRow > renderArea.origin.x * sampPerPix   &&
             i % sampPerRow < renderArea.size.width * sampPerPix);
}
-(void) writePixelsToIcon{
    
    if (theIcon == NULL)
        theIcon = [[NSImage alloc] initWithSize:size];
    else{

        // Remove previous representations from theIcon
        NSArray *prevReps = [theIcon representations];
        for (id r in prevReps)
            [theIcon removeRepresentation:r];
    }

    // Generate a new NSBitmapImageRep 
    NSBitmapImageRep *imgRep =
    [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&pixels
                                            pixelsWide:size.width
                                            pixelsHigh:size.height
                                         bitsPerSample:8
                                       samplesPerPixel:sampPerPix
                                              hasAlpha:true
                                              isPlanar:false
                                        colorSpaceName:NSDeviceRGBColorSpace
                                          bitmapFormat:0
                                           bytesPerRow:0
                                          bitsPerPixel:0];
    
    // update the Representatin for theIcon
    [theIcon addRepresentation:imgRep];
    
}

-(NSImage *)generateIconFromActivity:(NSArray *)per{

    double p1 = [(NSNumber *)[per objectAtIndex:0] doubleValue] * 255.00;
    double p2 = [(NSNumber *)[per objectAtIndex:1] doubleValue] * 255.00;
    
    p1 = (p1 > 255) ? 255 : p1;
    p2 = (p2 > 255) ? 255 : p2;
    
    p1 = (p1 < 0) ? 0 : p1;
    p2 = (p2 < 0) ? 0 : p2;

    for( int i=0; i<nTotalSamp; i+=4)
    {
        // Check to see if the current drawing index is within the bounds of the image
        if (![self shouldDrawIndex:i])
            continue;
        
        pixels[ i + 0] = (int) p1;//(drawCount * 32) % 256;//(drawCount * 255 * i) / (1024 * 1024 * 4 * 10);
        pixels[ i + 1 ] = (int) p2;//255 - ((255 * i) / (1024 * 1024 * 4));//(255 * (1024 - i))/1024;
        pixels[ i + 2 ] = 0;
        pixels[ i + 3 ] = 255;//(255 * i) / (1024 * 1024 * 4);
    }
    
    [self writePixelsToIcon];
    [self addDrawingMask];
    
    return theIcon;
}

-(NSImage *) generateTestIcon{
    
    for( int i=0; i<nTotalSamp; i+=4)
    {
        // Check to see if the current drawing index is within the bounds of the image
//        if (![IconMaker shouldDrawIndex:i])
//            continue;
        if (![self shouldDrawIndex:i])
            continue;
   
        pixels[ i + 0] =  ( 255 * i) / nTotalSamp;
        pixels[ i + 1 ] = ( 255 * (nTotalSamp - i) ) / nTotalSamp;
        pixels[ i + 2 ] = 0; // / nTotalSamp;
        pixels[ i + 3 ] = (255);// * i) / (1024 * 1024 * 4);
        
    }
    [self writePixelsToIcon];
    [self addDrawingMask];
    
    return theIcon;
}

-(void) setRenderBounds:(NSRect)bounds{
    
    NSLog(@"Set Render bounds");
    NSLog(@"Constraining drawing to:%3.1f %3.1f, %3.1f %3.1f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);

    renderArea = bounds;
    
}
// Overlay iconMask on top of theIcon
-(void)addDrawingMask{
    
    NSLog(@"Applying drawing mask");
    [theIcon lockFocus];

    [iconMask drawAtPoint:NSMakePoint(0, 0) fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositeDestinationOver fraction:1];
    
    [theIcon unlockFocus];

//    theIcon = iconMask;
    
}



@end
