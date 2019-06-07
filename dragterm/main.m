//
//  main.m
//  dragterm
//
//  Created by Nate Weaver on 2019-06-07.
//  Copyright © 2019 Nate Weaver/Derailer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static BOOL exitRunLoop = NO;

@interface DTDraggingSourceView : NSView <NSDraggingSource>

@property (nonatomic, copy)	NSURL	*fileURL;
@property (nonatomic, copy)	NSImage	*icon;

@end

@implementation DTDraggingSourceView

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
	exitRunLoop = YES;
}

- (NSDragOperation)draggingSession:(nonnull NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
	return NSDragOperationEvery;
}

- (void)setFileURL:(NSURL *)fileURL {
	if (fileURL != _fileURL) {
		_fileURL = fileURL;
		NSImage *icon;
		[self.fileURL getResourceValue:&icon forKey:NSURLEffectiveIconKey error:nil];
		self.icon = icon;
	}
}

- (void)drawRect:(NSRect)dirtyRect {
	[self.icon drawInRect:self.bounds];
}

- (void)mouseDragged:(NSEvent *)event {
	self.hidden = YES;
	NSURL *fileURL = self.fileURL;
	NSDraggingItem *item = [[NSDraggingItem alloc] initWithPasteboardWriter:fileURL];

	item.draggingFrame = self.bounds;
	item.imageComponentsProvider = ^NSArray<NSDraggingImageComponent *> *{
		NSString *name;
		[fileURL getResourceValue:&name forKey:NSURLLocalizedNameKey error:nil];

		NSDraggingImageComponent *iconComponent = [NSDraggingImageComponent draggingImageComponentWithKey:NSDraggingImageComponentIconKey];
		iconComponent.contents = self.icon;
		iconComponent.frame = self.bounds;
		NSDraggingImageComponent *nameComponent = [NSDraggingImageComponent draggingImageComponentWithKey:NSDraggingImageComponentLabelKey];
		nameComponent.contents = name;
		return @[iconComponent, nameComponent];
	};

	[self beginDraggingSessionWithItems:@[item] event:event source:self];
}

@end

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		if (argc < 2)
			return 1;

		NSString *file = @(argv[1]);

		NSApplicationLoad();

		NSURL *currentDirectoryURL = [NSURL fileURLWithPath:NSFileManager.defaultManager.currentDirectoryPath];
		NSURL *fileURL = [NSURL fileURLWithPath:file relativeToURL:currentDirectoryURL].absoluteURL;

		if (![fileURL checkResourceIsReachableAndReturnError:nil]) {
			fprintf(stderr, "Couldn't find file %s\n", fileURL.path.UTF8String);
			return 1;
		}

		printf("Dragging %s\n", fileURL.path.UTF8String);

		NSRect frame = (NSRect){ { 0.0, 0.0 }, { 64.0, 64.0 }};

		NSWindow *window = [[NSWindow alloc] initWithContentRect:frame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
		window.opaque = NO;
		window.backgroundColor = NSColor.clearColor;
		window.level = NSModalPanelWindowLevel;

		DTDraggingSourceView *sourceView = [[DTDraggingSourceView alloc] initWithFrame:frame];
		window.contentView = sourceView;
		sourceView.fileURL = fileURL;

		NSPoint mouseLocation = NSEvent.mouseLocation;
		frame.origin = mouseLocation;
		frame.origin.x -= frame.size.width / 2.0;
		frame.origin.y -= frame.size.width / 2.0;
		[window setFrame:frame display:YES];

		[NSApp activateIgnoringOtherApps:YES];
		[window makeKeyAndOrderFront:nil];
		
		while (!exitRunLoop) {
			NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:NSDate.distantFuture inMode:NSDefaultRunLoopMode dequeue:YES];
			[NSApp sendEvent:event];
		}
	}

	return 0;
}
