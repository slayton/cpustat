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
        renderArea = NSMakeRect(0, 0, size.width, size.height);
        sampPerRow = sampPerPix * size.width;
        nTotalSamp = (int)size.width * (int)size.height * sampPerPix;

        pixels = malloc( nTotalSamp * sizeof(unsigned char));
        
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

    double p1 = [(NSNumber *)[per objectAtIndex:0] doubleValue];// * 255.00;
    double p2 = [(NSNumber *)[per objectAtIndex:1] doubleValue];// * 255.00;
    
    int r,g,b,a;
    a = 255;
    for( int i=0; i<nTotalSamp; i+=4)
    {
        if ( ![self shouldDrawIndex:i] )
            continue;
        if ( (i%sampPerRow) > (sampPerRow/2 - 64) && (i%sampPerRow) < (sampPerRow/2 + 64) )
            continue;
        
        r = 0; g = 0; b = 0;
        
        // Split into two columns
        if (i % sampPerRow < sampPerRow/2){
            if ( (nTotalSamp - i) < (p1 * nTotalSamp ) )
                r = 255;//p1;
        }
        else{
            if ( (nTotalSamp - i) < (p2 * nTotalSamp) )
                g = 255;//(p2;
        }
        pixels[ i + 0 ] = r;
        pixels[ i + 1 ] = g;
        pixels[ i + 2 ] = b;
        pixels[ i + 3 ] = a;
    }
    
    [self writePixelsToIcon];

    
    [theIcon lockFocus];
    [iconMask drawAtPoint:NSMakePoint(0, 0) fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositeDestinationOver fraction:1];
    [theIcon unlockFocus];
    
    
    if (DEBUG == 1){
//        NSString *str = [NSString stringWithFormat:@"N:%ld %2.2f %2.2f", [per count], p1, p2];
        NSString *str = [NSString stringWithFormat:@"n:%ld", [per count] ];
        [self drawStringToImage:str];
    }
    return theIcon;
}

-(NSImage *) generateTestIcon{
    
    for( int i=0; i<nTotalSamp; i+=4)
    {
        if (![self shouldDrawIndex:i])
            continue;
   
        pixels[ i + 0] =  ( 255 * i) / nTotalSamp;
        pixels[ i + 1 ] = ( 255 * (nTotalSamp - i) ) / nTotalSamp;
        pixels[ i + 2 ] = 0; // / nTotalSamp;
        pixels[ i + 3 ] = (255);// * i) / (1024 * 1024 * 4);
        
    }
    [self writePixelsToIcon];
  
    return theIcon;
}

-(void) setRenderBounds:(NSRect)bounds{
    
    NSLog(@"Set Render bounds");
    NSLog(@"Constraining drawing to:%3.1f %3.1f, %3.1f %3.1f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);

    renderArea = bounds;
}

-(void) drawStringToImage:(NSString*) string{
    
    CGFloat fontSize = 200.0f;
    
    // Create an attributed string with string and font information
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica Bold"), fontSize, nil);
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)(font), kCTFontAttributeName,
                                [[NSColor whiteColor] CGColor], (__bridge id)(kCTForegroundColorAttributeName),
                                nil];
   
    
    NSAttributedString* as = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    CFRelease(font);

    // Figure out how big an image we need
    CTLineRef textLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)as);
    CGFloat ascent, descent, leading;
    double fWidth = CTLineGetTypographicBounds(textLine, &ascent, &descent, &leading);
    
    // On iOS 4.0 and Mac OS X v10.6 you can pass null for data
    size_t w = (size_t)ceilf(fWidth);
    size_t h = (size_t)ceilf(ascent + descent);

    void* data = malloc(w*h*4);
    
    // Create the context and fill it with white background
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    CGContextRef ctx = CGBitmapContextCreate(data, w, h, 8, w*4, space, bitmapInfo);
    CGColorSpaceRelease(space);
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.0); // black background
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, w, h));
    
    // Draw the text

    CGFloat x = 0.0;
    CGFloat y = descent;
    CGContextSetTextPosition(ctx, x, y);
    CTLineDraw(textLine, ctx);
    CFRelease(textLine);
    
    // Draw the text to an NSImage
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    NSImage *stringImage = [[NSImage alloc] initWithSize:size];
    [stringImage addRepresentation:imageRep];
    
    // Overlay the new image on the Icon
    [theIcon lockFocus];
    [stringImage drawInRect:NSMakeRect(renderArea.origin.x, renderArea.origin.y, w, h) fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1];
    [theIcon unlockFocus];
    
    CGImageRelease(imageRef);
    free(data);

}


@end
