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

@property (nonatomic)		BOOL			shouldExit;

@end

NSRect DTCenterRect(NSRect baseRect, CGFloat rectDim) {
	NSRect rect = NSZeroRect;
	rect.size = (NSSize){ rectDim, rectDim };
	rect.origin = (NSPoint){ (baseRect.size.width - rectDim) / 2.0, (baseRect.size.height - rectDim) / 2.0};
	return rect;
}

@implementation DTDraggingSourceView

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
	_shouldExit = YES;
}

- (NSDragOperation)draggingSession:(nonnull NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
	return NSDragOperationEvery;
}

- (void)setURLs:(NSArray<NSURL *> *)urls {
	_URLs = [urls copy];
	NSImage *icon;

	if (urls.count == 1) {
		NSURL *firstUrl = urls.firstObject;
		[firstUrl getResourceValue:&icon forKey:NSURLEffectiveIconKey error:nil];
	} else
		icon = [NSImage imageNamed:NSImageNameMultipleDocuments];

	self.icon = icon;

}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];
	self.trackingArea = trackingArea;
}

- (void)drawRect:(NSRect)dirtyRect {
	[self.icon drawInRect:DTCenterRect(self.bounds, self.iconSize)];
}

- (void)mouseExited:(NSEvent *)event {
	[NSApp terminate:nil];
}

- (void)mouseDown:(NSEvent *)event {
	[self removeTrackingArea:self.trackingArea];
	[self.window orderOut:nil];

	NSMutableArray<NSDraggingItem *> *items = [NSMutableArray arrayWithCapacity:self.URLs.count];

	for (NSURL *url in self.URLs) {
		NSDraggingItem *item = [[NSDraggingItem alloc] initWithPasteboardWriter:url];
		NSImage *icon;
		CGFloat iconSize = self.iconSize;
		[url getResourceValue:&icon forKey:NSURLEffectiveIconKey error:nil];

		item.draggingFrame = DTCenterRect(self.bounds, iconSize);

		item.imageComponentsProvider = ^NSArray<NSDraggingImageComponent *> *{
			NSDraggingImageComponent *iconComponent = [NSDraggingImageComponent draggingImageComponentWithKey:NSDraggingImageComponentIconKey];
			iconComponent.contents = [NSImage imageWithSize:(NSSize){ iconSize, iconSize } flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
				[icon drawInRect:dstRect];
				return YES;
			}];
			iconComponent.frame = (NSRect){ { 0.0, 0.0 }, { iconSize, iconSize } };
			return @[iconComponent];
		};

		[items addObject:item];
	}

	[self beginDraggingSessionWithItems:items event:event source:self];
}

@end
