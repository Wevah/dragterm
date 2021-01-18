//
//  main.m
//  dragterm
//
//  Created by Nate Weaver on 2019-06-07.
//  Copyright © 2019 Nate Weaver/Derailer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DTDraggingSourceView.h"
#import <getopt.h>

CGEventRef tapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *userInfo) {
	UniChar chars[2];
	UniCharCount count;
	CGEventKeyboardGetUnicodeString(event, 2, &count, chars);

	if (chars[0] == '\e') {
		exit(0);
		return NULL;
	}

	return event;
}

void printVersion(void) {
	NSBundle *bundle = NSBundle.mainBundle;

	printf("dragterm %s (v%s)\n", ((NSString *)[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]).UTF8String, ((NSString *)[bundle objectForInfoDictionaryKey:@"CFBundleVersion"]).UTF8String);
}

void printUsage() {
	printf("Usage: drag <files>\n");
}

int parseArguments(int argc, char * const argv[]) {
	struct option longopts[] = {
		{ "version", no_argument, NULL, 'v' },
		{ "help", no_argument, NULL, 'h' }
	};
	int c;
	while ((c = getopt_long(argc, argv, "vh", longopts, NULL)) != -1) {
		switch (c) {
			case 'v':
				printVersion();
				exit(0);
			case 'h':
				printUsage();
				exit(0);
		}
	}

	return optind;
}

int main(int argc, char * const argv[]) {
	@autoreleasepool {
		if (argc < 2) {
			printUsage();
			return 1;
		}

		int diff = parseArguments(argc, argv);
		argc -= diff;
		argv += diff;

		NSApplicationLoad();

		NSURL *currentDirectoryURL = [NSURL fileURLWithPath:NSFileManager.defaultManager.currentDirectoryPath];

		NSMutableArray<NSURL *> *urls = [NSMutableArray arrayWithCapacity:argc - 1];

		for (int i = 0; i < argc; ++i) {
			NSURL *fileURL = [NSURL fileURLWithPath:@(argv[i]) relativeToURL:currentDirectoryURL].absoluteURL;

			if (![fileURL checkResourceIsReachableAndReturnError:nil]) {
				dprintf(STDERR_FILENO, "Couldn't find file %s\n", fileURL.path.UTF8String);
				return 1;
			}

			[urls addObject:fileURL];
		}

		if (urls.count == 1)
			printf("Dragging %s\n", urls[0].path.UTF8String);
		else
			printf("Dragging %lu files\n", urls.count);

		NSRect frame = (NSRect){ { 0.0, 0.0 }, { 256.0, 256.0 }};

		NSWindow *window = [[NSWindow alloc] initWithContentRect:frame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
		window.opaque = NO;
		window.backgroundColor = NSColor.clearColor;
		window.level = NSStatusWindowLevel;
		window.ignoresMouseEvents = NO;

		DTDraggingSourceView *sourceView = [[DTDraggingSourceView alloc] initWithFrame:frame];
		window.contentView = sourceView;
		sourceView.iconSize = 64.0;
		sourceView.URLs = urls;

		NSPoint mouseLocation = NSEvent.mouseLocation;
		frame.origin = mouseLocation;
		frame.origin.x -= frame.size.width / 2.0;
		frame.origin.y -= frame.size.height / 2.0;
		[window setFrame:frame display:YES];

		[window makeKeyAndOrderFront:nil];

		CFMachPortRef tap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, CGEventMaskBit(kCGEventKeyDown), tapCallback, NULL);

		if (!tap) {
			dprintf(STDERR_FILENO, "Couldn't create event tap for escape key; ensure Terminal has accessibility access\n");
		} else {
			CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
			CFRelease(tap);
			CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
			CFRelease(runLoopSource);
		}

		while (!sourceView.shouldExit) {
			NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:NSDate.distantFuture inMode:NSDefaultRunLoopMode dequeue:YES];

			if (event.type == NSLeftMouseDown)
				CGEventTapEnable(tap, false);

			[NSApp sendEvent:event];
		}
	}

	return 0;
}
