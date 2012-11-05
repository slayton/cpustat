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

@synthesize pixelSize;
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
        self.renderSize = s;
        int pixW = [self round:(s.width) To:16];
        int pixH = [self round:(s.height) To:16];
        self.pixelSize = NSMakeSize(pixW, pixH);  
        
        nTotalSamp = (int)( pixelSize.width * pixelSize.height * sampPerPix );
        NSLog(@"Received size of %@", NSStringFromSize(s));
        NSLog(@"Allocating memory for pixel array size:%@ and total:%ld", NSStringFromSize(pixelSize), nTotalSamp * sizeof(unsigned char));
        
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
        renderImage = [[NSImage alloc] initWithSize:pixelSize];
    else{

        NSArray *prevReps = [renderImage representations];
        for (id r in prevReps)
            [renderImage removeRepresentation:r];
    }

    NSLog(@"Creating bitmapImageReprsentation with size:%@", NSStringFromSize(pixelSize));
    NSBitmapImageRep *imgRep =
    [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&pixels
                                            pixelsWide:pixelSize.width
                                            pixelsHigh:pixelSize.height
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
//    
//    for (int i=0; i<pixelSize.height*pixelSize.width; i++){
//        pixels[i+0] = 0;
//        pixels[i+1] = 0;
//        pixels[i+2] = 0;
//        pixels[i+3] = 1;
//    }
    
    int nCol = [per count];
    int nRow = 10;
    double gridWidth =  pixelSize.width / nCol;
    double gridHeight = pixelSize.height / nRow;
    int gridSpace = 15;
    
    NSLog(@"nCol %d colWidth %2.1f", nCol, gridWidth);

    int idx = 0;
    int curCol, curRow;
    r = 0;
    b = 0;
    g = 0;
    a = 255;
    int iRnd;
    double perVal, perRow;
    
    for( int i=0; i<(int)(pixelSize.height); i++){// Rows
        
        curRow =  (int)((double)i / (gridHeight));
        perRow = (double)curRow / (double)nRow;
        iRnd = ((double)i * nRow)/(double)nRow;
        
        for (int j=0; j<(int) pixelSize.width; j++){// Columns
           
            curCol =  (int)((double)j / (gridWidth));

            perVal = [(NSNumber*) [per objectAtIndex:curCol] doubleValue];
            
            perVal = (double)((int)(perVal * nRow))/(double)nRow;

            if ( (pixelSize.height - i) >= (perVal * pixelSize.height ) ||
                (j % (int)gridWidth) < gridSpace  ||  (i % (int)gridHeight) < gridSpace  )
            {

                r= 0; g = 0; b = 0;

            }else
            {

                if ( perRow > .4){
                    r = 0; g = 255; b = 0;
                }
                else if ( perRow > .2) {
                    r = 255; g = 255; b = 0;
                }
                else{
                    r = 255; g = 0; b = 0;
                }
            }
            
            pixels[ idx + 0 ] = r;
            pixels[ idx + 1 ] = g;
            pixels[ idx + 2 ] = b;
            pixels[ idx + 3 ] = a;

            idx += 4;
        }
    }
    
    [self convertPixelsToImage];
    
//    if (DEBUG == 1){
//        NSString *str = [NSString stringWithFormat:@"n:%ld", [per count] ];
//       [self drawStringToImage:str];
//        [self saveImageToFile:renderImage];
//    }
    

    return renderImage;
}

-(NSImage *)generateTestIcon{
    int idx =0;
    for( int i=0; i<(int)(pixelSize.height); i++){// Rows
        for (int j=0; j<(int) pixelSize.width; j++){// Columns
            pixels[ idx + 0 ] = 255 * ((float) j / pixelSize.width); // r
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
                                CGColorCreateGenericRGB(255, 255, 255, 150), (__bridge id)(kCTForegroundColorAttributeName),
                                //[[NSColor whiteColor] CGColor], (__bridge id)(kCTForegroundColorAttributeName),
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
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 5.0); // black background
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, w, h));
    
    // Draw the text
    CGContextSetTextPosition(ctx, 0.0, descent);
    CTLineDraw(textLine, ctx);
    CFRelease(textLine);
    
    // Draw the text to an NSImage
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    NSImage *stringImage = [[NSImage alloc] initWithSize:pixelSize];
    [stringImage addRepresentation:imageRep];
    
    [renderImage lockFocus];
    [stringImage drawInRect:NSMakeRect(0, 0, w, h) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [renderImage unlockFocus];
    
    CGImageRelease(imageRef);
    free(data);
}

- (int) round:(int)num To:(int) multiple
{
    if(multiple == 0)
    {
        return num;
    }
    
    int remainder = num % multiple;
    if (remainder == 0)
        return num;
    
    return num + multiple - remainder;
}

@end
