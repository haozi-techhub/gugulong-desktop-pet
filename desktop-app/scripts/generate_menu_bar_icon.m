#import <Cocoa/Cocoa.h>

static CGFloat S(CGFloat value, CGFloat scale) { return value * scale; }

static BOOL GenerateIcon(NSInteger pixels, NSString *output) {
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
        initWithBitmapDataPlanes:NULL pixelsWide:pixels pixelsHigh:pixels
        bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO
        colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
    if (!rep) return NO;

    [rep setSize:NSMakeSize(pixels, pixels)];
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
    [NSGraphicsContext setCurrentContext:context];
    CGFloat s = (CGFloat)pixels / 20.0;

    [[NSColor clearColor] setFill];
    NSRectFill(NSMakeRect(0, 0, pixels, pixels));
    [[NSColor blackColor] setFill];

    NSBezierPath *head = [NSBezierPath bezierPath];
    [head moveToPoint:NSMakePoint(S(3.2,s), S(5.3,s))];
    [head curveToPoint:NSMakePoint(S(5.2,s), S(16.2,s)) controlPoint1:NSMakePoint(S(2.7,s), S(9.8,s)) controlPoint2:NSMakePoint(S(3.4,s), S(14.4,s))];
    [head lineToPoint:NSMakePoint(S(6.2,s), S(18.5,s))];
    [head curveToPoint:NSMakePoint(S(9.1,s), S(16.7,s)) controlPoint1:NSMakePoint(S(7.2,s), S(19.6,s)) controlPoint2:NSMakePoint(S(8.4,s), S(18.3,s))];
    [head lineToPoint:NSMakePoint(S(11.2,s), S(18.3,s))];
    [head curveToPoint:NSMakePoint(S(13.8,s), S(16.0,s)) controlPoint1:NSMakePoint(S(12.2,s), S(19.2,s)) controlPoint2:NSMakePoint(S(13.4,s), S(17.8,s))];
    [head curveToPoint:NSMakePoint(S(16.8,s), S(5.3,s)) controlPoint1:NSMakePoint(S(16.0,s), S(14.0,s)) controlPoint2:NSMakePoint(S(17.4,s), S(9.5,s))];
    [head curveToPoint:NSMakePoint(S(10.0,s), S(2.2,s)) controlPoint1:NSMakePoint(S(15.9,s), S(2.6,s)) controlPoint2:NSMakePoint(S(13.2,s), S(2.2,s))];
    [head curveToPoint:NSMakePoint(S(3.2,s), S(5.3,s)) controlPoint1:NSMakePoint(S(6.8,s), S(2.2,s)) controlPoint2:NSMakePoint(S(4.1,s), S(2.6,s))];
    [head closePath]; [head fill];

    [context setCompositingOperation:NSCompositingOperationClear];
    [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(S(5.2,s), S(9.1,s), S(3.6,s), S(3.5,s))] fill];
    [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(S(11.2,s), S(9.1,s), S(3.6,s), S(3.5,s))] fill];

    NSBezierPath *leftBrow = [NSBezierPath bezierPath];
    [leftBrow setLineWidth:S(1.15,s)]; [leftBrow setLineCapStyle:NSLineCapStyleRound];
    [leftBrow moveToPoint:NSMakePoint(S(5.1,s), S(13.8,s))]; [leftBrow lineToPoint:NSMakePoint(S(9.1,s), S(11.9,s))]; [leftBrow stroke];
    NSBezierPath *rightBrow = [NSBezierPath bezierPath];
    [rightBrow setLineWidth:S(1.15,s)]; [rightBrow setLineCapStyle:NSLineCapStyleRound];
    [rightBrow moveToPoint:NSMakePoint(S(14.9,s), S(13.8,s))]; [rightBrow lineToPoint:NSMakePoint(S(10.9,s), S(11.9,s))]; [rightBrow stroke];

    [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(S(7.0,s), S(7.2,s), S(1.0,s), S(0.9,s))] fill];
    [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(S(12.0,s), S(7.2,s), S(1.0,s), S(0.9,s))] fill];
    const CGFloat teeth[] = {7.1, 9.3, 11.5};
    for (NSInteger i = 0; i < 3; i++) {
        [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(S(teeth[i],s), S(3.1,s), S(1.4,s), S(1.8,s)) xRadius:S(0.35,s) yRadius:S(0.35,s)] fill];
    }

    [NSGraphicsContext restoreGraphicsState];
    NSData *data = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    return [data writeToFile:output atomically:YES];
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 2) return 2;
        NSString *root = [NSString stringWithUTF8String:argv[1]];
        BOOL one = GenerateIcon(20, [root stringByAppendingPathComponent:@"MenuBarIconTemplate.png"]);
        BOOL two = GenerateIcon(40, [root stringByAppendingPathComponent:@"MenuBarIconTemplate@2x.png"]);
        return (one && two) ? 0 : 1;
    }
}
