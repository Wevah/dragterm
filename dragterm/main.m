//
//  main.m
//  dragterm
//
//  Created by Nate Weaver on 2019-06-07.
//  Copyright © 2019 Nate Weaver/Derailer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DTDraggingSourceView.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		if (argc < 2)
			return 1;

		NSApplicationLoad();

		NSURL *currentDirectoryURL = [NSURL fileURLWithPath:NSFileManager.defaultManager.currentDirectoryPath];

		NSMutableArray<NSURL *> *urls = [NSMutableArray arrayWithCapacity:argc - 1];

		for (int i = 1; i < argc; ++i) {
			NSURL *fileURL = [NSURL fileURLWithPath:@(argv[i]) relativeToURL:currentDirectoryURL].absoluteURL;

			if (![fileURL checkResourceIsReachableAndReturnError:nil]) {
				dprintf(STDERR_FILENO, "Couldn't find file %s\n", fileURL.path.UTF8String);
				return 1;
			}

			[urls addObject:fileURL];
		}

		printf("%s\n", urls.description.UTF8String);

		if (urls.count == 1)
			printf("Dragging %s\n", urls[0].path.UTF8String);
		else
			printf("Dragging %lu files\n", urls.count);

		NSRect frame = (NSRect){ { 0.0, 0.0 }, { 64.0, 64.0 }};

		NSWindow *window = [[NSWindow alloc] initWithContentRect:frame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
		window.opaque = NO;
		window.backgroundColor = NSColor.clearColor;
		window.level = NSStatusWindowLevel;

		DTDraggingSourceView *sourceView = [[DTDraggingSourceView alloc] initWithFrame:frame];
		window.contentView = sourceView;
		sourceView.URLs = urls;

		NSPoint mouseLocation = NSEvent.mouseLocation;
		frame.origin = mouseLocation;
		frame.origin.x -= frame.size.width / 2.0;
		frame.origin.y -= frame.size.height / 2.0;
		[window setFrame:frame display:YES];

		[NSApp activateIgnoringOtherApps:YES];
		[window makeKeyAndOrderFront:nil];

		while (!sourceView.shouldExit) {
			NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:NSDate.distantFuture inMode:NSDefaultRunLoopMode dequeue:YES];
			[NSApp sendEvent:event];
		}
	}

	return 0;
}
