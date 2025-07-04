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

static NSString *ASCIIfy(NSString *str) {
	str = [str stringByReplacingOccurrencesOfString:@"©" withString:@"Copyright"];
	str = [str stringByReplacingOccurrencesOfString:@"–" withString:@"-"]; // en dash to hyphen
	return str;
}

static void printVersion(void) {
	NSBundle *bundle = NSBundle.mainBundle;

	printf("dragterm %s (v%s)\n", ((NSString *)[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]).UTF8String, ((NSString *)[bundle objectForInfoDictionaryKey:@"CFBundleVersion"]).UTF8String);

	printf("%s\n", ASCIIfy([bundle objectForInfoDictionaryKey:@"NSHumanReadableCopyright"]).UTF8String);
}

static void printUsage(void) {
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

		if (argc < 1) {
			return 1;
		}

		NSApplicationLoad();

		NSMutableArray<NSURL *> *urls = [NSMutableArray arrayWithCapacity:argc - 1];

		for (int i = 0; i < argc; ++i) {
			NSURL *fileURL = [NSURL fileURLWithPath:@(argv[i])].absoluteURL;

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

		[window orderFront:nil];

		while (1) {
			NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:NSDate.distantFuture inMode:NSEventTrackingRunLoopMode dequeue:YES];
			[NSApp sendEvent:event];
		}
	}

	return 0;
}
