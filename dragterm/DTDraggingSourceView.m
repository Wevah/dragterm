//
//  DTDraggingSourceView.m
//  drag
//
//  Created by Nate Weaver on 2019-06-07.
//  Copyright © 2019 Nate Weaver/Derailer. All rights reserved.
//

#import "DTDraggingSourceView.h"

@interface DTDraggingSourceView ()

@property (nonatomic)		NSTrackingArea	*trackingArea;
@property (nonatomic, copy)	NSImage			*icon;

@end

@implementation DTDraggingSourceView

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
	_shouldExit = YES;
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

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];
	self.trackingArea = trackingArea;
}

- (void)drawRect:(NSRect)dirtyRect {
	[self.icon drawInRect:self.bounds];
}

- (void)mouseExited:(NSEvent *)event {
	[NSApp terminate:nil];
}

- (void)mouseDown:(NSEvent *)event {
	[self removeTrackingArea:self.trackingArea];
	self.hidden = YES;
	NSURL *fileURL = self.fileURL;
	NSDraggingItem *item = [[NSDraggingItem alloc] initWithPasteboardWriter:fileURL];

	item.draggingFrame = self.bounds;
	item.imageComponentsProvider = ^NSArray<NSDraggingImageComponent *> *{
		NSDraggingImageComponent *iconComponent = [NSDraggingImageComponent draggingImageComponentWithKey:NSDraggingImageComponentIconKey];
		iconComponent.contents = [NSImage imageWithSize:self.bounds.size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			[self.icon drawInRect:dstRect];
			return YES;
		}];
		iconComponent.frame = self.bounds;
		return @[iconComponent];
	};

	[self beginDraggingSessionWithItems:@[item] event:event source:self];
}

@end