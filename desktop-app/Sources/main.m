#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, PetState) {
    PetStateIdle,
    PetStateWave,
    PetStateCry,
    PetStateAngry,
    PetStateWaiting,
    PetStateRunning,
    PetStateReview
};

static NSString *PetStateName(PetState state) {
    switch (state) {
        case PetStateWave: return @"wave";
        case PetStateCry: return @"cry";
        case PetStateAngry: return @"angry";
        case PetStateWaiting: return @"waiting";
        case PetStateRunning: return @"running";
        case PetStateReview: return @"review";
        default: return @"idle";
    }
}

static NSInteger PetStateRow(PetState state) {
    switch (state) {
        case PetStateWave: return 3;
        case PetStateAngry: return 4;
        case PetStateCry: return 5;
        case PetStateWaiting: return 6;
        case PetStateRunning: return 7;
        case PetStateReview: return 8;
        default: return 0;
    }
}

static NSInteger PetStateFrames(PetState state) {
    switch (state) {
        case PetStateWave: return 4;
        case PetStateAngry: return 5;
        case PetStateCry: return 8;
        default: return 6;
    }
}

static NSTimeInterval PetStateFrameInterval(PetState state) {
    switch (state) {
        case PetStateIdle: return 0.25;
        case PetStateWave: return 0.24;
        case PetStateCry: return 0.24;
        case PetStateAngry: return 0.22;
        case PetStateWaiting: return 0.26;
        case PetStateRunning: return 0.18;
        case PetStateReview: return 0.24;
    }
}

static NSInteger PetIdlePrimaryPoseHoldTicks(void) { return 7; }
static NSTimeInterval PetManualPreviewDuration(void) { return 12.0; }

@interface HoverView : NSImageView
@property(nonatomic, strong) NSMenu *controlMenu;
@property(nonatomic, copy) void (^hoverChanged)(BOOL hovering);
@property(nonatomic, copy) void (^windowMoved)(void);
@property(nonatomic) NSPoint dragStartScreen;
@property(nonatomic) NSPoint dragStartOrigin;
@end

@implementation HoverView
- (BOOL)acceptsFirstMouse:(NSEvent *)event { return YES; }
- (void)updateTrackingAreas {
    for (NSTrackingArea *area in self.trackingAreas) [self removeTrackingArea:area];
    NSRect body = NSInsetRect(self.bounds, MAX(10, self.bounds.size.width * 0.08), MAX(6, self.bounds.size.height * 0.03));
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:body options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:area];
    [super updateTrackingAreas];
}
- (void)mouseEntered:(NSEvent *)event { if (self.hoverChanged) self.hoverChanged(YES); }
- (void)mouseExited:(NSEvent *)event { if (self.hoverChanged) self.hoverChanged(NO); }
- (void)mouseDown:(NSEvent *)event {
    self.dragStartScreen = [NSEvent mouseLocation];
    self.dragStartOrigin = self.window.frame.origin;
}
- (void)mouseDragged:(NSEvent *)event {
    NSPoint current = [NSEvent mouseLocation];
    NSPoint origin = NSMakePoint(self.dragStartOrigin.x + current.x - self.dragStartScreen.x,
                                 self.dragStartOrigin.y + current.y - self.dragStartScreen.y);
    [self.window setFrameOrigin:origin];
    if (self.windowMoved) self.windowMoved();
}
- (NSMenu *)menuForEvent:(NSEvent *)event { return self.controlMenu; }
- (void)rightMouseDown:(NSEvent *)event {
    if (self.controlMenu) [NSMenu popUpContextMenu:self.controlMenu withEvent:event forView:self];
}
@end

@interface SpeechBubbleView : NSView
@property(nonatomic, copy) NSString *text;
@end

@implementation SpeechBubbleView
- (BOOL)isOpaque { return NO; }

- (NSFont *)roundedFontAtSize:(CGFloat)size {
    NSFont *base = [NSFont systemFontOfSize:size weight:NSFontWeightHeavy];
    NSFontDescriptor *rounded = [base.fontDescriptor fontDescriptorWithDesign:NSFontDescriptorSystemDesignRounded];
    return rounded ? [NSFont fontWithDescriptor:rounded size:size] : base;
}

- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    CGFloat scale = self.bounds.size.width / 150.0;
    [NSGraphicsContext saveGraphicsState];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform scaleXBy:scale yBy:scale];
    [transform concat];

    NSColor *ink = [NSColor colorWithCalibratedRed:0.08 green:0.31 blue:0.16 alpha:1.0];
    NSColor *creamTop = [NSColor colorWithCalibratedRed:1.0 green:0.99 blue:0.91 alpha:0.98];
    NSColor *creamBottom = [NSColor colorWithCalibratedRed:0.90 green:1.0 blue:0.82 alpha:0.98];

    NSShadow *cardShadow = [NSShadow new];
    cardShadow.shadowColor = [NSColor colorWithCalibratedRed:0.05 green:0.22 blue:0.10 alpha:0.24];
    cardShadow.shadowBlurRadius = 4;
    cardShadow.shadowOffset = NSMakeSize(0, -1);
    [cardShadow set];

    NSBezierPath *tail = [NSBezierPath bezierPath];
    [tail moveToPoint:NSMakePoint(111, 13)];
    [tail lineToPoint:NSMakePoint(143, 3)];
    [tail lineToPoint:NSMakePoint(130, 20)];
    [tail closePath];
    [creamBottom setFill]; [tail fill];
    [ink setStroke]; tail.lineWidth = 2.0; [tail stroke];

    NSBezierPath *body = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(4, 10, 137, 36) xRadius:18 yRadius:18];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:creamBottom endingColor:creamTop];
    [gradient drawInBezierPath:body angle:90];
    [ink setStroke]; body.lineWidth = 2.2; [body stroke];

    [NSGraphicsContext restoreGraphicsState];
    [NSGraphicsContext saveGraphicsState];
    transform = [NSAffineTransform transform];
    [transform scaleXBy:scale yBy:scale];
    [transform concat];

    NSBezierPath *highlight = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(7, 13, 131, 30) xRadius:15 yRadius:15];
    [[NSColor colorWithWhite:1 alpha:0.58] setStroke]; highlight.lineWidth = 0.8; [highlight stroke];

    NSBezierPath *sparkle = [NSBezierPath bezierPath];
    [sparkle moveToPoint:NSMakePoint(18, 37)];
    [sparkle lineToPoint:NSMakePoint(20, 31)];
    [sparkle lineToPoint:NSMakePoint(26, 29)];
    [sparkle lineToPoint:NSMakePoint(20, 27)];
    [sparkle lineToPoint:NSMakePoint(18, 21)];
    [sparkle lineToPoint:NSMakePoint(16, 27)];
    [sparkle lineToPoint:NSMakePoint(10, 29)];
    [sparkle lineToPoint:NSMakePoint(16, 31)];
    [sparkle closePath];
    [[NSColor colorWithCalibratedRed:1.0 green:0.72 blue:0.18 alpha:1.0] setFill]; [sparkle fill];
    [[NSColor colorWithWhite:1 alpha:0.9] setStroke]; sparkle.lineWidth = 0.9; [sparkle stroke];

    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.alignment = NSTextAlignmentCenter;
    NSShadow *textShadow = [NSShadow new];
    textShadow.shadowColor = [NSColor colorWithCalibratedRed:0.10 green:0.30 blue:0.15 alpha:0.18];
    textShadow.shadowBlurRadius = 1.5;
    textShadow.shadowOffset = NSMakeSize(0, -1);
    NSDictionary *attributes = @{
        NSFontAttributeName: [self roundedFontAtSize:17],
        NSForegroundColorAttributeName: ink,
        NSStrokeColorAttributeName: [NSColor colorWithWhite:1 alpha:0.95],
        NSStrokeWidthAttributeName: @(-1.6),
        NSKernAttributeName: @(0.3),
        NSParagraphStyleAttributeName: paragraph,
        NSShadowAttributeName: textShadow
    };
    [(self.text ?: @"咕咕嘎嘎") drawInRect:NSMakeRect(28, 18, 106, 22) withAttributes:attributes];
    [NSGraphicsContext restoreGraphicsState];
}
@end

typedef void (^CodexUpdateHandler)(PetState state, NSString *sourcePath);

@interface CodexSessionWatcher : NSObject
@property(nonatomic, copy) CodexUpdateHandler handler;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic) PetState lastState;
@property(nonatomic, copy) NSString *lastSource;
- (void)start;
- (void)stop;
- (void)refresh;
+ (NSDictionary *)parseSessionData:(NSData *)data modifiedAt:(NSDate *)modifiedAt;
@end

@implementation CodexSessionWatcher
+ (NSDictionary *)parseSessionData:(NSData *)data modifiedAt:(NSDate *)modifiedAt {
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!text) return @{@"state": @(PetStateIdle)};
    NSArray<NSString *> *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    PetState state = PetStateIdle;
    NSString *stateTimestamp = @"";
    BOOL taskActive = NO;
    for (NSString *line in lines) {
        if (line.length < 2) continue;
        NSData *lineData = [line dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:lineData options:0 error:nil];
        if (![json isKindOfClass:[NSDictionary class]]) continue;
        NSString *timestamp = [json[@"timestamp"] isKindOfClass:[NSString class]] ? json[@"timestamp"] : @"";
        NSDictionary *payload = [json[@"payload"] isKindOfClass:[NSDictionary class]] ? json[@"payload"] : @{};
        NSString *outerType = [json[@"type"] isKindOfClass:[NSString class]] ? json[@"type"] : @"";
        NSString *type = [payload[@"type"] isKindOfClass:[NSString class]] ? payload[@"type"] : @"";
        if ([outerType isEqualToString:@"event_msg"] && [timestamp compare:stateTimestamp] != NSOrderedAscending) {
            if ([type isEqualToString:@"task_started"]) { state = PetStateRunning; taskActive = YES; stateTimestamp = timestamp; }
            else if ([type isEqualToString:@"task_complete"]) { state = PetStateReview; taskActive = NO; stateTimestamp = timestamp; }
            else if ([type containsString:@"failed"] || [type containsString:@"error"]) { state = PetStateCry; taskActive = NO; stateTimestamp = timestamp; }
        }
        NSString *toolName = [payload[@"name"] isKindOfClass:[NSString class]] ? payload[@"name"] : @"";
        BOOL isWaitingEvent = [type isEqualToString:@"approval_request"] || [type isEqualToString:@"mcp_elicitation"] ||
            ([outerType isEqualToString:@"response_item"] && [type isEqualToString:@"custom_tool_call"] &&
             ([toolName isEqualToString:@"request_permissions"] || [toolName isEqualToString:@"request_user_input"]));
        if ([timestamp compare:stateTimestamp] != NSOrderedAscending && isWaitingEvent) {
            state = PetStateWaiting; taskActive = YES; stateTimestamp = timestamp;
        }
    }
    if (modifiedAt && [[NSDate date] timeIntervalSinceDate:modifiedAt] > 86400) {
        state = PetStateIdle;
    } else if (!taskActive && state == PetStateRunning) {
        state = PetStateIdle;
    }
    return @{@"state": @(state)};
}

- (NSURL *)latestMainSessionURL {
    NSString *root = [NSHomeDirectory() stringByAppendingPathComponent:@".codex/sessions"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:root]
        includingPropertiesForKeys:@[NSURLContentModificationDateKey, NSURLIsRegularFileKey]
                           options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    NSURL *best = nil;
    NSDate *bestDate = [NSDate distantPast];
    for (NSURL *url in enumerator) {
        if (![[url.pathExtension lowercaseString] isEqualToString:@"jsonl"]) continue;
        NSNumber *regular = nil; [url getResourceValue:&regular forKey:NSURLIsRegularFileKey error:nil];
        if (![regular boolValue]) continue;
        NSDate *modified = nil; [url getResourceValue:&modified forKey:NSURLContentModificationDateKey error:nil];
        if (!modified || [modified compare:bestDate] != NSOrderedDescending) continue;
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:url.path];
        NSData *prefix = [handle readDataOfLength:16384]; [handle closeFile];
        NSString *prefixText = [[NSString alloc] initWithData:prefix encoding:NSUTF8StringEncoding];
        NSString *firstLine = [[prefixText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] firstObject];
        NSDictionary *meta = firstLine ? [NSJSONSerialization JSONObjectWithData:[firstLine dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil] : nil;
        NSDictionary *payload = [meta[@"payload"] isKindOfClass:[NSDictionary class]] ? meta[@"payload"] : @{};
        NSString *threadSource = [payload[@"thread_source"] isKindOfClass:[NSString class]] ? payload[@"thread_source"] : @"";
        NSDictionary *source = [payload[@"source"] isKindOfClass:[NSDictionary class]] ? payload[@"source"] : @{};
        if ([threadSource isEqualToString:@"subagent"] || source[@"subagent"]) continue;
        best = url; bestDate = modified;
    }
    return best;
}

- (NSData *)tailDataForURL:(NSURL *)url {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:url.path];
    if (!handle) return nil;
    unsigned long long size = [handle seekToEndOfFile];
    unsigned long long offset = size > 1048576 ? size - 1048576 : 0;
    [handle seekToFileOffset:offset];
    NSData *data = [handle readDataToEndOfFile]; [handle closeFile];
    if (offset == 0) return data;
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange newline = [text rangeOfString:@"\n"];
    if (newline.location == NSNotFound) return data;
    return [[text substringFromIndex:newline.location + 1] dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)refresh {
    NSURL *url = [self latestMainSessionURL];
    if (!url) { if (self.handler) self.handler(PetStateIdle, nil); return; }
    NSDate *modified = nil; [url getResourceValue:&modified forKey:NSURLContentModificationDateKey error:nil];
    NSDictionary *parsed = [CodexSessionWatcher parseSessionData:[self tailDataForURL:url] modifiedAt:modified];
    PetState state = [parsed[@"state"] integerValue];
    if (self.handler) self.handler(state, url.path);
    self.lastState = state; self.lastSource = url.path;
}
- (void)start { [self refresh]; self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(refresh) userInfo:nil repeats:YES]; }
- (void)stop { [self.timer invalidate]; self.timer = nil; }
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property(nonatomic, strong) NSWindow *petWindow;
@property(nonatomic, strong) NSPanel *bubbleWindow;
@property(nonatomic, strong) SpeechBubbleView *bubbleView;
@property(nonatomic, strong) HoverView *petView;
@property(nonatomic, strong) NSImage *atlas;
@property(nonatomic, strong) NSTimer *animationTimer;
@property(nonatomic, strong) NSTimer *bubbleTimer;
@property(nonatomic) NSInteger frame;
@property(nonatomic) NSInteger idlePrimaryPoseHoldTick;
@property(nonatomic) PetState currentState;
@property(nonatomic) PetState beforeHoverState;
@property(nonatomic) BOOL petHovering;
@property(nonatomic) CGFloat scale;
@property(nonatomic, strong) NSStatusItem *statusItem;
@property(nonatomic, strong) NSWindow *visibleMenuBarWindow;
@property(nonatomic, strong) NSWindow *settingsWindow;
@property(nonatomic, strong) CodexSessionWatcher *watcher;
@property(nonatomic) PetState lastCodexState;
@property(nonatomic, strong) NSDate *manualOverrideUntil;
@property(nonatomic) BOOL manualOverridePendingResume;
@property(nonatomic) NSUInteger bubbleOpportunityCount;
@property(nonatomic, strong) NSDate *lastBubbleShownAt;
@end

static NSImage *GugulongStatusBrandImage(NSImage *icon) {
    if (!icon) return nil;
    NSSize canvasSize = NSMakeSize(68, 20);
    NSImage *brand = [[NSImage alloc] initWithSize:canvasSize];
    [brand lockFocus];
    [[NSColor clearColor] setFill];
    NSRectFill(NSMakeRect(0, 0, canvasSize.width, canvasSize.height));

    // Draw one indivisible template image. This avoids a macOS status-button
    // layout edge case where the text survives but the separate icon vanishes.
    [icon drawInRect:NSMakeRect(1, 1, 18, 18)
            fromRect:NSZeroRect
           operation:NSCompositingOperationSourceOver
            fraction:1.0
      respectFlipped:YES
               hints:nil];
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:11 weight:NSFontWeightSemibold],
        NSForegroundColorAttributeName: NSColor.blackColor
    };
    [@"咕咕龙" drawAtPoint:NSMakePoint(23, 3) withAttributes:attributes];
    [brand unlockFocus];
    brand.template = YES;
    return brand;
}

@interface GugulongVisibleMenuView : NSView
@property(nonatomic, strong) NSMenu *controlMenu;
@end

@implementation GugulongVisibleMenuView
- (BOOL)isFlipped { return YES; }
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [@"🦖 咕咕龙" drawAtPoint:NSMakePoint(2, 3) withAttributes:@{
        NSFontAttributeName: [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold],
        NSForegroundColorAttributeName: NSColor.whiteColor
    }];
}
- (void)mouseDown:(NSEvent *)event {
    if (self.controlMenu) [self.controlMenu popUpMenuPositioningItem:nil atLocation:NSMakePoint(0, NSMaxY(self.bounds)) inView:self];
}
- (void)rightMouseDown:(NSEvent *)event { [self mouseDown:event]; }
@end


@implementation AppDelegate

- (void)createVisibleMenuBarWindowWithMenu:(NSMenu *)menu {
    NSScreen *screen = NSScreen.mainScreen ?: NSScreen.screens.firstObject;
    if (!screen) return;
    NSRect frame = screen.frame;
    NSRect windowFrame = NSMakeRect(NSMaxX(frame) - 330, NSMaxY(frame) - 24, 76, 24);
    self.visibleMenuBarWindow = [[NSWindow alloc] initWithContentRect:windowFrame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    self.visibleMenuBarWindow.opaque = NO;
    self.visibleMenuBarWindow.backgroundColor = NSColor.clearColor;
    self.visibleMenuBarWindow.hasShadow = NO;
    self.visibleMenuBarWindow.level = NSStatusWindowLevel + 2;
    self.visibleMenuBarWindow.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorStationary | NSWindowCollectionBehaviorFullScreenAuxiliary;
    self.visibleMenuBarWindow.releasedWhenClosed = NO;
    GugulongVisibleMenuView *view = [[GugulongVisibleMenuView alloc] initWithFrame:NSMakeRect(0, 0, 76, 24)];
    view.controlMenu = menu;
    view.toolTip = @"咕咕龙 Codex 搭子";
    self.visibleMenuBarWindow.contentView = view;
    [self.visibleMenuBarWindow orderFrontRegardless];
}

- (NSUserDefaults *)defaults { return [NSUserDefaults standardUserDefaults]; }

- (NSMenuItem *)item:(NSString *)title action:(SEL)action {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
    item.target = self;
    return item;
}

- (NSMenu *)buildControlMenu:(BOOL)includePanels {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"咕咕龙"];
    [menu addItem:[self item:@"默认" action:@selector(showIdle:)]];
    [menu addItem:[self item:@"挥爪" action:@selector(showWave:)]];
    [menu addItem:[self item:@"大哭" action:@selector(showCry:)]];
    [menu addItem:[self item:@"暴怒跺脚" action:@selector(showAngry:)]];
    [menu addItem:[self item:@"等待" action:@selector(showWaiting:)]];
    [menu addItem:[self item:@"执行中" action:@selector(showRunning:)]];
    [menu addItem:[self item:@"点赞" action:@selector(showReview:)]];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[self item:@"50%" action:@selector(scale50:)]];
    [menu addItem:[self item:@"75%" action:@selector(scale75:)]];
    [menu addItem:[self item:@"100%" action:@selector(scale100:)]];
    [menu addItem:[self item:@"150%" action:@selector(scale150:)]];
    [menu addItem:[self item:@"200%" action:@selector(scale200:)]];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[self item:@"显示/隐藏宠物" action:@selector(togglePet:)]];
    [menu addItem:[self item:@"设置" action:@selector(showSettingsWindow:)]];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[self item:@"退出咕咕龙" action:@selector(quitApp:)]];
    return menu;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [[self defaults] registerDefaults:@{@"scale": @1.0, @"alwaysOnTop": @YES, @"hoverCry": @YES, @"bubbleEnabled": @YES, @"codexSync": @YES, @"petVisible": @YES, @"lastState": @"idle", @"welcomeBubbleShown": @NO}];
    self.lastCodexState = -1;
    self.scale = [[self defaults] doubleForKey:@"scale"];
    if (self.scale < 0.50 || self.scale > 2.0) self.scale = 1.0;
    CGFloat width = 192 * self.scale, height = 208 * self.scale;
    NSScreen *screen = NSScreen.mainScreen;
    NSRect visible = screen.visibleFrame;
    CGFloat x = [[self defaults] objectForKey:@"petX"] ? [[self defaults] doubleForKey:@"petX"] : NSMaxX(visible) - width - 40;
    CGFloat y = [[self defaults] objectForKey:@"petY"] ? [[self defaults] doubleForKey:@"petY"] : NSMinY(visible) + 60;
    self.petWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(x, y, width, height) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    self.petWindow.opaque = NO; self.petWindow.backgroundColor = NSColor.clearColor; self.petWindow.hasShadow = NO; self.petWindow.delegate = self;
    self.petWindow.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary;
    [self applyWindowLevel];
    self.petView = [[HoverView alloc] initWithFrame:self.petWindow.contentView.bounds];
    self.petView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.petView.imageScaling = NSImageScaleAxesIndependently;
    self.petView.controlMenu = [self buildControlMenu:NO];
    self.petWindow.contentView = self.petView;
    NSString *atlasPath = [[NSBundle mainBundle] pathForResource:@"spritesheet" ofType:@"webp"];
    self.atlas = [[NSImage alloc] initWithContentsOfFile:atlasPath];
    __weak AppDelegate *weakSelf = self;
    self.petView.hoverChanged = ^(BOOL hovering) { [weakSelf handleHover:hovering]; };
    self.petView.windowMoved = ^{ [weakSelf petDidMove]; };
    [self createBubbleWindow];
    [self applyWindowLevel];
    // Keep the item square so it remains visible when the menu bar is crowded.
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    // A new explicit identity clears the stale off-screen placement left by
    // earlier builds that changed the status-item width repeatedly.
    self.statusItem.autosaveName = @"tech.haozi.gugulong.status.v2";
    self.statusItem.behavior = 0;
    self.statusItem.visible = YES;
    // Load the 1x template resource and let AppKit select its @2x representation.
    // Loading the @2x file as the logical source makes macOS scale it twice on
    // some menu-bar configurations, which can make the mark look faint or absent.
    // Text is the only status-item rendering path that remains visible on this
    // Mac's dual-display menu bar. Use a dinosaur glyph as the reliable logo.
    self.statusItem.button.image = nil;
    self.statusItem.button.imagePosition = NSNoImage;
    self.statusItem.button.title = @"🦖";
    self.statusItem.button.font = [NSFont systemFontOfSize:15];
    self.statusItem.button.accessibilityLabel = @"咕咕龙";
    NSMenu *statusMenu = [self buildControlMenu:YES];
    self.statusItem.menu = statusMenu;
    dispatch_async(dispatch_get_main_queue(), ^{ [self createVisibleMenuBarWindowWithMenu:statusMenu]; });
    self.statusItem.button.toolTip = @"咕咕龙 Codex 搭子";
    [self applyState:PetStateIdle manual:NO];
    if ([[self defaults] boolForKey:@"petVisible"]) [self.petWindow orderFrontRegardless];
    if (![[self defaults] boolForKey:@"welcomeBubbleShown"]) {
        [self speak:@"咕咕嘎嘎"];
        [[self defaults] setBool:YES forKey:@"welcomeBubbleShown"];
    }
    self.watcher = [CodexSessionWatcher new];
    self.watcher.handler = ^(PetState state, NSString *sourcePath) {
        (void)sourcePath;
        [weakSelf handleCodexState:state];
    };
    [self.watcher start];
}

- (void)createBubbleWindow {
    self.bubbleWindow = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 150, 50) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    self.bubbleWindow.opaque = NO; self.bubbleWindow.backgroundColor = NSColor.clearColor; self.bubbleWindow.hasShadow = NO;
    self.bubbleWindow.ignoresMouseEvents = YES; self.bubbleWindow.hidesOnDeactivate = NO; self.bubbleWindow.collectionBehavior = self.petWindow.collectionBehavior;
    self.bubbleWindow.alphaValue = 0;
    self.bubbleView = [[SpeechBubbleView alloc] initWithFrame:self.bubbleWindow.contentView.bounds];
    self.bubbleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.bubbleView.text = @"咕咕嘎嘎";
    self.bubbleView.accessibilityLabel = @"咕咕龙气泡：咕咕嘎嘎";
    self.bubbleWindow.contentView = self.bubbleView;
    [self.petWindow addChildWindow:self.bubbleWindow ordered:NSWindowAbove];
    [self updateBubblePosition];
}

- (void)applyWindowLevel {
    self.petWindow.level = [[self defaults] boolForKey:@"alwaysOnTop"] ? NSFloatingWindowLevel : NSNormalWindowLevel;
    self.bubbleWindow.level = self.petWindow.level + 1;
}

- (void)updateBubblePosition {
    if (!self.bubbleWindow || !self.petWindow) return;
    CGFloat bubbleScale = MIN(1.25, MAX(0.68, self.scale));
    NSRect pet = self.petWindow.frame;
    NSRect bubble = NSMakeRect(0, 0, 150 * bubbleScale, 50 * bubbleScale);
    bubble.origin = NSMakePoint(NSMinX(pet) - bubble.size.width + 58 * self.scale,
                                NSMaxY(pet) - 18 * self.scale);
    NSRect visible = self.petWindow.screen.visibleFrame;
    bubble.origin.x = MIN(MAX(bubble.origin.x, NSMinX(visible) + 4), NSMaxX(visible) - bubble.size.width - 4);
    bubble.origin.y = MIN(MAX(bubble.origin.y, NSMinY(visible) + 4), NSMaxY(visible) - bubble.size.height - 4);
    [self.bubbleWindow setFrame:bubble display:YES];
}

- (void)speak:(NSString *)text {
    if (![[self defaults] boolForKey:@"bubbleEnabled"] || ![[self defaults] boolForKey:@"petVisible"]) return;
    self.bubbleView.text = text ?: @"咕咕嘎嘎";
    [self.bubbleView setNeedsDisplay:YES];
    [self updateBubblePosition];
    BOOL wasHidden = self.bubbleWindow.alphaValue < 0.05;
    if (wasHidden) self.bubbleWindow.alphaValue = 0;
    [self.bubbleWindow orderFrontRegardless];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = wasHidden ? 0.12 : 0.06;
        context.allowsImplicitAnimation = YES;
        self.bubbleWindow.animator.alphaValue = 1;
    } completionHandler:nil];
    self.lastBubbleShownAt = [NSDate date];
    [self.bubbleTimer invalidate]; self.bubbleTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(hideBubble:) userInfo:nil repeats:NO];
}
- (void)speakOccasionally {
    self.bubbleOpportunityCount += 1;
    if (self.bubbleOpportunityCount % 6 != 0) return;
    if (self.lastBubbleShownAt && [[NSDate date] timeIntervalSinceDate:self.lastBubbleShownAt] < 10.0) return;
    [self speak:@"咕咕嘎嘎"];
}
- (void)hideBubble:(NSTimer *)timer {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.12;
        context.allowsImplicitAnimation = YES;
        self.bubbleWindow.animator.alphaValue = 0;
    } completionHandler:nil];
}

- (void)applyState:(PetState)state manual:(BOOL)manual {
    self.currentState = state; self.frame = 0; self.idlePrimaryPoseHoldTick = 0;
    [[self defaults] setObject:PetStateName(state) forKey:@"lastState"];
    [self.animationTimer invalidate];
    self.animationTimer = [NSTimer timerWithTimeInterval:PetStateFrameInterval(state) target:self selector:@selector(nextFrame:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
    [self nextFrame:nil];
}

- (void)nextFrame:(NSTimer *)timer {
    CGImageRef source = [self.atlas CGImageForProposedRect:NULL context:nil hints:nil];
    if (!source) return;
    size_t cellW = CGImageGetWidth(source) / 8, cellH = CGImageGetHeight(source) / 11;
    NSInteger frameCount = PetStateFrames(self.currentState), row = PetStateRow(self.currentState);
    NSInteger displayFrame = self.frame;
    CGRect rect = CGRectMake(displayFrame * cellW, row * cellH, cellW, cellH);
    CGImageRef crop = CGImageCreateWithImageInRect(source, rect);
    if (crop) {
        NSSize frameSize = NSMakeSize(cellW, cellH);
        NSImage *frameImage = [[NSImage alloc] initWithCGImage:crop size:frameSize];
        self.petView.image = frameImage;
        CGImageRelease(crop);
    }
    if (self.currentState == PetStateIdle && self.frame == 0 && self.idlePrimaryPoseHoldTick < PetIdlePrimaryPoseHoldTicks()) {
        self.idlePrimaryPoseHoldTick += 1;
        return;
    }
    self.idlePrimaryPoseHoldTick = 0;
    self.frame += 1;
    if (self.frame >= frameCount) self.frame = 0;
}

- (void)handleHover:(BOOL)hovering {
    self.petHovering = hovering;
    if (![[self defaults] boolForKey:@"hoverCry"]) return;
    if (hovering) { self.beforeHoverState = self.currentState; [self applyState:PetStateCry manual:NO]; [self speakOccasionally]; }
    else [self applyState:self.beforeHoverState manual:NO];
}

- (void)handleCodexState:(PetState)state {
    if (![[self defaults] boolForKey:@"codexSync"]) return;
    BOOL firstSync = self.lastCodexState < 0;
    BOOL manualPreviewActive = self.manualOverrideUntil && [self.manualOverrideUntil timeIntervalSinceNow] > 0;
    if (manualPreviewActive) {
        self.lastCodexState = state;
        return;
    }
    BOOL resumeAfterManual = self.manualOverridePendingResume;
    if (resumeAfterManual) {
        self.manualOverridePendingResume = NO;
        self.manualOverrideUntil = nil;
    }
    BOOL changed = firstSync || state != self.lastCodexState || resumeAfterManual;
    self.lastCodexState = state;
    if (changed && state != self.currentState) {
        [self applyState:state manual:NO];
        if (!firstSync) [self speakOccasionally];
    }
}

- (void)petDidMove {
    [[self defaults] setDouble:self.petWindow.frame.origin.x forKey:@"petX"];
    [[self defaults] setDouble:self.petWindow.frame.origin.y forKey:@"petY"];
    [self updateBubblePosition];
}

- (void)windowDidMove:(NSNotification *)notification {
    if (notification.object == self.petWindow) [self petDidMove];
}

- (void)setPetScale:(CGFloat)newScale {
    self.scale = newScale;
    [[self defaults] setDouble:newScale forKey:@"scale"];
    NSRect old = self.petWindow.frame;
    NSRect visible = self.petWindow.screen.visibleFrame;
    CGFloat width = 192 * newScale, height = 208 * newScale;
    NSPoint origin = NSMakePoint(NSMidX(old) - width / 2, NSMaxY(old) - height);
    origin.x = MIN(MAX(origin.x, NSMinX(visible)), NSMaxX(visible) - width);
    origin.y = MIN(MAX(origin.y, NSMinY(visible)), NSMaxY(visible) - height);
    [self.petWindow setFrame:NSMakeRect(origin.x, origin.y, width, height) display:YES animate:YES];
    [self.petView updateTrackingAreas]; [self petDidMove];
}

- (void)manualState:(PetState)state {
    self.manualOverrideUntil = [NSDate dateWithTimeIntervalSinceNow:PetManualPreviewDuration()];
    self.manualOverridePendingResume = YES;
    if (self.petHovering) self.beforeHoverState = state;
    [self applyState:state manual:YES];
    [self speakOccasionally];
}
- (void)showIdle:(id)sender { [self manualState:PetStateIdle]; }
- (void)showWave:(id)sender { [self manualState:PetStateWave]; }
- (void)showCry:(id)sender { [self manualState:PetStateCry]; }
- (void)showAngry:(id)sender { [self manualState:PetStateAngry]; }
- (void)showWaiting:(id)sender { [self manualState:PetStateWaiting]; }
- (void)showRunning:(id)sender { [self manualState:PetStateRunning]; }
- (void)showReview:(id)sender { [self manualState:PetStateReview]; }
- (void)scale50:(id)sender { [self setPetScale:0.50]; }
- (void)scale75:(id)sender { [self setPetScale:0.75]; }
- (void)scale100:(id)sender { [self setPetScale:1.0]; }
- (void)scale150:(id)sender { [self setPetScale:1.5]; }
- (void)scale200:(id)sender { [self setPetScale:2.0]; }
- (void)togglePet:(id)sender {
    BOOL visible = self.petWindow.isVisible;
    if (visible) { [self.petWindow orderOut:nil]; self.bubbleWindow.alphaValue = 0; }
    else { [self.petWindow orderFrontRegardless]; [self speak:@"咕咕嘎嘎"]; }
    [[self defaults] setBool:!visible forKey:@"petVisible"];
}

- (NSButton *)checkbox:(NSString *)title key:(NSString *)key y:(CGFloat)y {
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(24, y, 280, 24)];
    button.buttonType = NSButtonTypeSwitch; button.title = title; button.state = [[self defaults] boolForKey:key] ? NSControlStateValueOn : NSControlStateValueOff;
    button.identifier = key; button.target = self; button.action = @selector(settingChanged:); return button;
}
- (void)showSettingsWindow:(id)sender {
    if (!self.settingsWindow) {
        self.settingsWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 330, 250) styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable backing:NSBackingStoreBuffered defer:NO];
        self.settingsWindow.title = @"咕咕龙设置";
        NSView *content = self.settingsWindow.contentView;
        [content addSubview:[self checkbox:@"始终置顶" key:@"alwaysOnTop" y:190]];
        [content addSubview:[self checkbox:@"鼠标悬停时大哭" key:@"hoverCry" y:154]];
        [content addSubview:[self checkbox:@"显示“咕咕嘎嘎”气泡" key:@"bubbleEnabled" y:118]];
        [content addSubview:[self checkbox:@"跟随 Codex 任务状态" key:@"codexSync" y:82]];
        NSTextField *hint = [NSTextField labelWithString:@"尺寸可从右键菜单或菜单栏调整，位置会自动保存。"];
        hint.frame = NSMakeRect(24, 34, 290, 28); hint.textColor = NSColor.secondaryLabelColor; [content addSubview:hint];
    }
    [self.settingsWindow center]; [self.settingsWindow makeKeyAndOrderFront:nil]; [NSApp activateIgnoringOtherApps:YES];
}
- (void)settingChanged:(NSButton *)sender {
    [[self defaults] setBool:sender.state == NSControlStateValueOn forKey:sender.identifier];
    if ([sender.identifier isEqualToString:@"alwaysOnTop"]) [self applyWindowLevel];
    if ([sender.identifier isEqualToString:@"bubbleEnabled"] && sender.state == NSControlStateValueOff) self.bubbleWindow.alphaValue = 0;
    if ([sender.identifier isEqualToString:@"codexSync"] && sender.state == NSControlStateValueOn) [self.watcher refresh];
}

- (void)quitApp:(id)sender {
    [self.watcher stop]; [self.animationTimer invalidate]; [self.bubbleTimer invalidate];
    [[self defaults] synchronize]; [NSApp terminate:nil];
}
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender { return NSTerminateNow; }
@end

static int RunSelfTest(NSString *fixturePath) {
    NSData *data = [NSData dataWithContentsOfFile:fixturePath];
    if (!data) { fprintf(stderr, "fixture missing\n"); return 2; }
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fixturePath error:nil];
    NSDate *modifiedAt = [attributes[NSFileModificationDate] isKindOfClass:[NSDate class]] ? attributes[NSFileModificationDate] : [NSDate date];
    NSDictionary *result = [CodexSessionWatcher parseSessionData:data modifiedAt:modifiedAt];
    NSDictionary *output = @{@"state": PetStateName([result[@"state"] integerValue])};
    NSData *json = [NSJSONSerialization dataWithJSONObject:output options:NSJSONWritingPrettyPrinted error:nil];
    fwrite(json.bytes, 1, json.length, stdout); fputc('\n', stdout);
    return 0;
}

static int RunAnimationTimingSelfTest(void) {
    NSDictionary *output = @{
        @"idleFrameInterval": @(PetStateFrameInterval(PetStateIdle)),
        @"idlePrimaryPoseSeconds": @((PetIdlePrimaryPoseHoldTicks() + 1) * PetStateFrameInterval(PetStateIdle)),
        @"waveFrameInterval": @(PetStateFrameInterval(PetStateWave)),
        @"cryFrameInterval": @(PetStateFrameInterval(PetStateCry)),
        @"angryFrameInterval": @(PetStateFrameInterval(PetStateAngry)),
        @"waitingFrameInterval": @(PetStateFrameInterval(PetStateWaiting)),
        @"runningFrameInterval": @(PetStateFrameInterval(PetStateRunning)),
        @"reviewFrameInterval": @(PetStateFrameInterval(PetStateReview)),
        @"manualPreviewSeconds": @(PetManualPreviewDuration())
    };
    NSData *json = [NSJSONSerialization dataWithJSONObject:output options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys error:nil];
    fwrite(json.bytes, 1, json.length, stdout); fputc('\n', stdout);
    return 0;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc == 3 && strcmp(argv[1], "--self-test") == 0) return RunSelfTest([NSString stringWithUTF8String:argv[2]]);
        if (argc == 2 && strcmp(argv[1], "--timing-self-test") == 0) return RunAnimationTimingSelfTest();
        NSApplication *app = NSApplication.sharedApplication;
        AppDelegate *delegate = [AppDelegate new]; app.delegate = delegate; [app run];
    }
    return 0;
}
