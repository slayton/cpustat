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

-(void)convertPixelsToImage;
-(BOOL) shouldDrawIndex:(int)i;

@end


@implementation IconMaker

@synthesize size;
@synthesize sampPerPix;
@synthesize sampPerRow;
@synthesize nTotalSamp;
@synthesize pixels;
@synthesize theIcon;
@synthesize renderImage;

-(id) initWithSize:(NSSize) s{
    
    self = [super init];
    
    if (self){

        sampPerPix = 4;
        self.size = s;
        nTotalSamp = (int)( size.width * size.height * sampPerPix );
       
        NSLog(@"Allocating memory for pixel array size:%@ and total:%ld", NSStringFromSize(size), nTotalSamp * sizeof(unsigned char));
        
        pixels = malloc( nTotalSamp * sizeof(unsigned char));
        
    }
    return self;

}
-(BOOL) shouldDrawIndex:(int) i{
    return YES;//( i / sampPerRow > renderArea.origin.y    &&
//             i / sampPerRow < renderArea.size.height &&
//             i % sampPerRow > renderArea.origin.x * sampPerPix   &&
//             i % sampPerRow < renderArea.size.width * sampPerPix);
}
-(void) convertPixelsToImage{
    
    if (renderImage == NULL)
        renderImage = [[NSImage alloc] initWithSize:size];
    else{

        NSArray *prevReps = [renderImage representations];
        for (id r in prevReps)
            [renderImage removeRepresentation:r];
    }

    NSLog(@"Creating bitmapImageReprsentation with size:%@", NSStringFromSize(size));
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
    
    [renderImage addRepresentation:imgRep];
}

-(NSImage *)generateIconFromActivity:(NSArray *)per{

    int r,g,b,a;
    
    for (int i=0; i<nTotalSamp; i++)
        pixels[i] = 0;
    
    int nCol = [per count];
    double colWidth =  size.width / nCol;
    NSLog(@"nCol %d colWidth %2.1f", nCol, colWidth);
    int curCol;
    int idx = 0;
    
    r = 0;
    b = 0;
    g = 0;
    a = 255;
    for( int i=0; i<(int)(size.height); i++){// Rows
        for (int j=0; j<(int) size.width; j++){// Columns
           
            r = 255 * ((float) j / size.width);
            
            pixels[ idx + 0 ] = r;
            pixels[ idx + 1 ] = g;
            pixels[ idx + 2 ] = b;
            pixels[ idx + 3 ] = a;
            
            idx += 4;
        }
    }
    
    [self convertPixelsToImage];
    
    if (DEBUG == 1){
        NSString *str = [NSString stringWithFormat:@"n:%ld", [per count] ];
      //  [self drawStringToImage:str];
    }
    
    [self saveImageToFile:renderImage];
    return renderImage;
}

-(NSImage *)generateTestIcon{
    int idx =0;
    for( int i=0; i<(int)(size.height); i++){// Rows
        for (int j=0; j<(int) size.width; j++){// Columns
            pixels[ idx + 0 ] = 255 * ((float) j / size.width); // r
            pixels[ idx + 1 ] = 0; //  g
            pixels[ idx + 2 ] = 0; //  b
            pixels[ idx + 3 ] = 255;// a
            
            idx += 4;
        }
    }
    
    [self convertPixelsToImage];

    [self saveImageToFile:renderImage];
    return renderImage;
}

-(void) saveImageToFile:(NSImage*) img{
    
    NSString * filename = @"/Users/stuartlayton/Desktop/test.jpg";
    
    NSData * imgData = [img TIFFRepresentation];
    NSBitmapImageRep * imgRep = [NSBitmapImageRep imageRepWithData:imgData];
    
    NSDictionary * imgProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    
    imgData = [imgRep representationUsingType:NSJPEGFileType properties:imgProps];
    
    [imgData writeToFile:filename atomically:NO];
    
}

-(void) drawStringToImage:(NSString*) string{
    
    CGFloat fontSize = 150.0f;
    
    // Create an attributed string with string and font information
    CTFontRef font = CTFontCreateWithName(CFSTR("Courier Bold"), fontSize, nil);
    
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

    unsigned char * data = malloc(w*h*4);
    
    // Create the context and fill it with white background
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    CGContextRef ctx = CGBitmapContextCreate(data, w, h, 8, w*4, space, bitmapInfo);
    CGColorSpaceRelease(space);
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0); // black background
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, w, h));
    
    // Draw the text
    CGContextSetTextPosition(ctx, 0.0, descent);
    CTLineDraw(textLine, ctx);
    CFRelease(textLine);
    
    // Draw the text to an NSImage
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    NSImage *stringImage = [[NSImage alloc] initWithSize:size];
    [stringImage addRepresentation:imageRep];
    
    [renderImage lockFocus];
    [stringImage drawInRect:NSMakeRect(0, 0, w, h) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [renderImage unlockFocus];
    
    CGImageRelease(imageRef);
    free(data);
}


@end
