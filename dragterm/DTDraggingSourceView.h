//
//  DTDraggingSourceView.h
//  drag
//
//  Created by Nate Weaver on 2019-06-07.
//  Copyright © 2019 Nate Weaver/Derailer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTDraggingSourceView : NSView <NSDraggingSource>

@property (nonatomic, copy) NSArray<NSURL *> *URLs;

@property (nonatomic) CGFloat iconSize;

@end

NS_ASSUME_NONNULL_END
