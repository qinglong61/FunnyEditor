//
//  FunnyEditor.m
//  FunnyEditor
//
//  Created by duanqinglun on 16/6/16.
//  Copyright © 2016年 duan.yu. All rights reserved.
//

#import "FunnyEditor.h"

static FunnyEditor *sharedPlugin;

@implementation FunnyEditor

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidFinishLaunching:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
        } else {
            [self initializeAndLog];
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [self initializeAndLog];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
}

#pragma mark - Implementation

- (BOOL)initialize
{
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Funny Edit" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
        return YES;
    } else {
        return NO;
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    id tmpView = [self textView];
    while (tmpView) {
        [tmpView setBackgroundColor:[NSColor clearColor]];
        if ([NSStringFromClass([tmpView class]) isEqualToString:@"DVTSourceTextScrollView"]) {
            [tmpView setDrawsBackground:NO];
        }
        if ([NSStringFromClass([tmpView class]) isEqualToString:@"DVTBorderedView"]) {
            break;
        }
        tmpView = [tmpView superview];
    }
    
    NSWindow *window = [[NSWindow alloc] initWithContentRect:[tmpView frame] styleMask:NSTitledWindowMask | NSBorderlessWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:NO];
    [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [window setTitle:[[NSProcessInfo processInfo] processName]];
    [window makeKeyAndOrderFront:self];
    [window makeMainWindow];
    window.opaque = NO;
    window.backgroundColor = [NSColor clearColor];
    [window.contentView addSubview:tmpView];
}

- (NSTextView *)textView
{
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    id editorArea = [currentWindowController performSelector:@selector(editorArea)];
    id editorContext = [editorArea performSelector:@selector(lastActiveEditorContext)];
    id editor = [editorContext performSelector:@selector(editor)];
    return [editor textView];
}

@end
