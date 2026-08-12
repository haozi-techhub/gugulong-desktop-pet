#import <Cocoa/Cocoa.h>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 3) {
            fprintf(stderr, "usage: render-file-icon <input-path> <output.png>\n");
            return 2;
        }
        NSString *inputPath = [NSString stringWithUTF8String:argv[1]];
        NSString *outputPath = [NSString stringWithUTF8String:argv[2]];
        [NSApplication sharedApplication];
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:inputPath];
        if (!icon) return 3;
        icon.size = NSMakeSize(512, 512);
        NSData *tiff = icon.TIFFRepresentation;
        NSBitmapImageRep *bitmap = tiff ? [NSBitmapImageRep imageRepWithData:tiff] : nil;
        if (!bitmap) return 4;
        NSData *png = [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        return [png writeToFile:outputPath atomically:YES] ? 0 : 5;
    }
}
