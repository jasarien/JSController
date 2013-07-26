//
//  JSDPad.m
//  Controller
//
//  Created by James Addyman on 28/03/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//

#import "JSDPad.h"
#import <QuartzCore/QuartzCore.h>

#define MAIN_FILL_COLOR ([UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0])
#define ARROW_FILL_COLOR ([UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0])
#define STROKE_COLOR ([UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0])

@interface JSDPad () {
	
	JSDPadDirection _currentDirection;
	
}

@end

@implementation JSDPad

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self commonInit];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder]))
	{
		[self commonInit];
	}
	
	return self;
}

- (void)commonInit
{
	[self setBackgroundColor:[UIColor clearColor]];
	[self setContentMode:UIViewContentModeRedraw];
	
	// set these externally for resizing to work while editing.
	self.maxSize = CGSizeMake(300, 300);
	self.minSize = CGSizeMake(100, 100);
	
	_currentDirection = JSDPadDirectionNone;
}

- (void)dealloc
{
	self.delegate = nil;
}

- (JSDPadDirection)currentDirection
{
	return _currentDirection;
}

- (JSDPadDirection)directionForPoint:(CGPoint)point
{
	CGFloat x = point.x;
	CGFloat y = point.y;
	
	if (((x < 0) || (x > [self bounds].size.width)) ||
		((y < 0) || (y > [self bounds].size.height)))
	{
		return JSDPadDirectionNone;
	}
	
	NSUInteger column = x / ([self bounds].size.width / 3);
	NSUInteger row = y / ([self bounds].size.height / 3);

	JSDPadDirection direction = (row * 3) + column + 1;
	
	return direction;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_editing)
	{
		return;
	}
	
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	JSDPadDirection direction = [self directionForPoint:point];
	
	if (direction != _currentDirection)
	{
		_currentDirection = direction;
		[self setNeedsDisplay];
		
		if ([self.delegate respondsToSelector:@selector(dPad:didPressDirection:)])
		{
			[self.delegate dPad:self didPressDirection:_currentDirection];
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_editing)
	{
		return;
	}
	
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	JSDPadDirection direction = [self directionForPoint:point];
	
	if (direction != _currentDirection)
	{
		_currentDirection = direction;
		[self setNeedsDisplay];
		
		if ([self.delegate respondsToSelector:@selector(dPad:didPressDirection:)])
		{
			[self.delegate dPad:self didPressDirection:_currentDirection];
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_editing)
	{
		return;
	}
	
	_currentDirection = JSDPadDirectionNone;
	[self setNeedsDisplay];
	
	if ([self.delegate respondsToSelector:@selector(dPadDidReleaseDirection:)])
	{
		[self.delegate dPadDidReleaseDirection:self];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_editing)
	{
		return;
	}
	
	_currentDirection = JSDPadDirectionNone;
	[self setNeedsDisplay];
	
	if ([self.delegate respondsToSelector:@selector(dPadDidReleaseDirection:)])
	{
		[self.delegate dPadDidReleaseDirection:self];
	}
}

// scalability stuff

- (void)setEditing:(BOOL)editing
{
	_editing = editing;
	
	if (_editing)
	{
		UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
																						action:@selector(panRecognized:)];
		[panRecognizer setMaximumNumberOfTouches:2];
		[panRecognizer setDelegate:self];
		[self addGestureRecognizer:panRecognizer];
		
		UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
																							  action:@selector(pinchRecognized:)];
		[pinchRecognizer setDelegate:self];
		[self addGestureRecognizer:pinchRecognizer];
	}
	else
	{
		for (UIGestureRecognizer *recognizer in [self gestureRecognizers])
		{
			[self removeGestureRecognizer:recognizer];
		}
	}
}

- (void)adjustAnchorPointForRecognizer:(UIGestureRecognizer *)recognizer
{
	if ([recognizer state] == UIGestureRecognizerStateBegan)
	{
		UIView *view = [recognizer view];
		UIView *superview = [view superview];
		
        CGPoint locationInView = [recognizer locationInView:view];
        CGPoint locationInSuperview = [recognizer locationInView:superview];
		
		view.layer.anchorPoint = CGPointMake(locationInView.x / self.bounds.size.width, locationInView.y / self.bounds.size.height);
		view.center = locationInSuperview;
    }
}

- (void)panRecognized:(UIPanGestureRecognizer *)recognizer
{
	[self adjustAnchorPointForRecognizer:recognizer];
	
	if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
	{
		UIView *view = [recognizer view];
		UIView *superview = [view superview];
		
		CGPoint translation = [recognizer translationInView:superview];
		CGFloat newX = roundf([view center].x + translation.x);
		CGFloat newY = roundf([view center].y + translation.y);
		[view setCenter:CGPointMake(newX, newY)];
		[recognizer setTranslation:CGPointZero inView:superview];
	}
}

- (void)pinchRecognized:(UIPinchGestureRecognizer *)recognizer
{
	[self adjustAnchorPointForRecognizer:recognizer];
	
	if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
	{
		UIView *view = [recognizer view];
		CGRect frame = [view frame];
		
		CGFloat newWidth = roundf(frame.size.width * [recognizer scale]);
		CGFloat newHeight = roundf(frame.size.height * [recognizer scale]);
		
		if ((newWidth >= self.minSize.width && newWidth <= self.maxSize.width) ||
			(newHeight >= self.minSize.height && newHeight <= self.minSize.height))
		{
			frame.size.width = newWidth;
			frame.size.height = newHeight;
			[view setFrame:frame];
		}
		
		[view setCenter:[recognizer locationInView:[view superview]]];
		[recognizer setScale:1];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(ctx);
	
	//vertical bar
	CGContextMoveToPoint(ctx, roundf(rect.size.width/3), 0);
	CGContextAddLineToPoint(ctx, roundf(rect.size.width/3)*2, 0);
	CGContextAddLineToPoint(ctx, roundf(rect.size.width/3)*2, rect.size.height);
	CGContextAddLineToPoint(ctx, roundf(rect.size.width/3), rect.size.height);
	CGContextAddLineToPoint(ctx, roundf(rect.size.width/3), 0);
	CGContextClosePath(ctx);
	
	//horizontal bar
	CGContextMoveToPoint(ctx, 0, roundf(rect.size.height/3));
	CGContextAddLineToPoint(ctx, rect.size.width, roundf(rect.size.height/3));
	CGContextAddLineToPoint(ctx, rect.size.width, roundf(rect.size.height/3)*2);
	CGContextAddLineToPoint(ctx, 0, roundf(rect.size.height/3)*2);
	CGContextAddLineToPoint(ctx, 0, roundf(rect.size.width/3));
	CGContextClosePath(ctx);
	
	//fill vert and horiz bars
	CGContextSetFillColorWithColor(ctx, [MAIN_FILL_COLOR CGColor]);
	CGContextDrawPath(ctx, kCGPathFill);
	
	CGContextRestoreGState(ctx);
	CGContextSaveGState(ctx);
	
	//stroke
	CGFloat lineWidth = roundf((rect.size.width / 100) * 1); // 2% of width
	CGFloat halfLineWidth = roundf(lineWidth/2);
	
	CGFloat widthThird = roundf(rect.size.width / 3);
	CGFloat widthTwoThirds = widthThird * 2;
	CGFloat widthMinusHalfLineWidth = rect.size.width - halfLineWidth;
	
	CGFloat heightThird = roundf(rect.size.height / 3);
	CGFloat heightTwoThirds = heightThird * 2;
	CGFloat heightMinusHalfLineWidth = rect.size.height - halfLineWidth;
	
	CGContextMoveToPoint(ctx, widthThird, halfLineWidth);
	CGContextAddLineToPoint(ctx, widthTwoThirds, halfLineWidth);
	CGContextAddLineToPoint(ctx, widthTwoThirds, heightThird);
	CGContextAddLineToPoint(ctx, widthMinusHalfLineWidth, heightThird);
	CGContextAddLineToPoint(ctx, widthMinusHalfLineWidth, heightTwoThirds);
	CGContextAddLineToPoint(ctx, widthTwoThirds, heightTwoThirds);
	CGContextAddLineToPoint(ctx, widthTwoThirds, heightMinusHalfLineWidth);
	CGContextAddLineToPoint(ctx, widthThird, heightMinusHalfLineWidth);
	CGContextAddLineToPoint(ctx, widthThird, heightTwoThirds);
	CGContextAddLineToPoint(ctx, halfLineWidth, heightTwoThirds);
	CGContextAddLineToPoint(ctx, halfLineWidth, heightThird);
	CGContextAddLineToPoint(ctx, widthThird, heightThird);
	CGContextAddLineToPoint(ctx, widthThird, halfLineWidth);
	CGContextClosePath(ctx);
	
	CGContextSetStrokeColorWithColor(ctx, [STROKE_COLOR CGColor]);
	CGContextSetLineWidth(ctx, lineWidth);
	CGContextSetLineJoin(ctx, kCGLineJoinRound);
	CGContextSetLineCap(ctx, kCGLineCapRound);
	CGContextDrawPath(ctx, kCGPathStroke);
	
	CGContextRestoreGState(ctx);
	CGContextSaveGState(ctx);
	
	//measurements for arrows
	CGFloat halfWidth = roundf(rect.size.width / 2);
	CGFloat halfHeight = roundf(rect.size.height / 2);
	CGFloat arrowInset = roundf((rect.size.width / 100) * 7); // 7% of width/height
	CGSize arrowSize = CGSizeMake(roundf((rect.size.width / 100) * 20), roundf((rect.size.width / 100) * 15)); //20% of width and 13% of height
	CGFloat halfArrowWidth = roundf(arrowSize.width / 2);
	
	//up
	CGContextMoveToPoint(ctx, halfWidth, arrowInset);
	CGContextAddLineToPoint(ctx, halfWidth + halfArrowWidth, arrowInset + arrowSize.height);
	CGContextAddLineToPoint(ctx, halfWidth - halfArrowWidth, arrowInset + arrowSize.height);
	CGContextAddLineToPoint(ctx, halfWidth, arrowInset);
	CGContextClosePath(ctx);
	
	if ([self currentDirection] == JSDPadDirectionUp ||
		[self currentDirection] == JSDPadDirectionUpLeft ||
		[self currentDirection] == JSDPadDirectionUpRight)
	{
		CGContextSetShadowWithColor(ctx, CGSizeZero, (rect.size.width / 100) * 4, [[UIColor whiteColor] CGColor]);
		CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
		CGContextSetStrokeColorWithColor(ctx, [STROKE_COLOR CGColor]);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextDrawPath(ctx, kCGPathEOFillStroke);
		
		CGContextRestoreGState(ctx);
		CGContextSaveGState(ctx);
	}
	else
	{
		CGContextSetFillColorWithColor(ctx, [ARROW_FILL_COLOR CGColor]);
		CGContextSetStrokeColorWithColor(ctx, [STROKE_COLOR CGColor]);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextDrawPath(ctx, kCGPathEOFillStroke);
		
		CGContextRestoreGState(ctx);
		CGContextSaveGState(ctx);
	}
	
	//right
	CGContextMoveToPoint(ctx, rect.size.width - arrowInset, halfHeight);
	CGContextAddLineToPoint(ctx, rect.size.width - arrowInset - arrowSize.height, halfHeight + halfArrowWidth);
	CGContextAddLineToPoint(ctx, rect.size.width - arrowInset - arrowSize.height, halfHeight - halfArrowWidth);
	CGContextAddLineToPoint(ctx, rect.size.width - arrowInset, halfHeight);
	CGContextClosePath(ctx);
	
	if ([self currentDirection] == JSDPadDirectionUpRight ||
		[self currentDirection] == JSDPadDirectionDownRight ||
		[self currentDirection] == JSDPadDirectionRight)
	{
		CGContextSetShadowWithColor(ctx, CGSizeZero, (rect.size.width / 100) * 4, [[UIColor whiteColor] CGColor]);
		CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
		CGContextSetStrokeColorWithColor(ctx, [STROKE_COLOR CGColor]);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextDrawPath(ctx, kCGPathEOFillStroke);
		
		CGContextRestoreGState(ctx);
		CGContextSaveGState(ctx);
	}
	else
	{
		CGContextSetFillColorWithColor(ctx, [ARROW_FILL_COLOR CGColor]);
		CGContextSetStrokeColorWithColor(ctx, [STROKE_COLOR CGColor]);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextDrawPath(ctx, kCGPathEOFillStroke);
		
		CGContextRestoreGState(ctx);
		CGContextSaveGState(ctx);
	}
	
	//down
	CGContextMoveToPoint(ctx, halfWidth, rect.size.height - arrowInset);
	CGContextAddLineToPoint(ctx, halfWidth - halfArrowWidth, rect.size.height - arrowInset - arrowSize.height);
	CGContextAddLineToPoint(ctx, halfWidth + halfArrowWidth, rect.size.height - arrowInset - arrowSize.height);
	CGContextAddLineToPoint(ctx, halfWidth, rect.size.height - arrowInset);
	CGContextClosePath(ctx);
	
	if ([self currentDirection] == JSDPadDirectionDown ||
		[self currentDirection] == JSDPadDirectionDownLeft ||
		[self currentDirection] == JSDPadDirectionDownRight)
	{
		CGContextSetShadowWithColor(ctx, CGSizeZero, (rect.size.width / 100) * 4, [[UIColor whiteColor] CGColor]);
		CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
		CGContextSetStrokeColorWithColor(ctx, [STROKE_COLOR CGColor]);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextDrawPath(ctx, kCGPathEOFillStroke);
		
		CGContextRestoreGState(ctx);
		CGContextSaveGState(ctx);
	}
	else
	{
		CGContextSetFillColorWithColor(ctx, [ARROW_FILL_COLOR CGColor]);
		CGContextSetStrokeColorWithColor(ctx, [STROKE_COLOR CGColor]);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextDrawPath(ctx, kCGPathEOFillStroke);
		
		CGContextRestoreGState(ctx);
		CGContextSaveGState(ctx);
	}
	
	//left
	CGContextMoveToPoint(ctx, arrowInset, halfHeight);
	CGContextAddLineToPoint(ctx, arrowInset + arrowSize.height, halfHeight - halfArrowWidth);
	CGContextAddLineToPoint(ctx, arrowInset + arrowSize.height, halfHeight + halfArrowWidth);
	CGContextAddLineToPoint(ctx, arrowInset, halfHeight);
	CGContextClosePath(ctx);
	
	if ([self currentDirection] == JSDPadDirectionLeft ||
		[self currentDirection] == JSDPadDirectionUpLeft ||
		[self currentDirection] == JSDPadDirectionDownLeft)
	{
		CGContextSetShadowWithColor(ctx, CGSizeZero, (rect.size.width / 100) * 4, [[UIColor whiteColor] CGColor]);
		CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
		CGContextSetStrokeColorWithColor(ctx, [STROKE_COLOR CGColor]);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextDrawPath(ctx, kCGPathEOFillStroke);
		
		CGContextRestoreGState(ctx);
		CGContextSaveGState(ctx);
	}
	else
	{
		CGContextSetFillColorWithColor(ctx, [ARROW_FILL_COLOR CGColor]);
		CGContextSetStrokeColorWithColor(ctx, [STROKE_COLOR CGColor]);
		CGContextSetLineWidth(ctx, lineWidth);
		CGContextDrawPath(ctx, kCGPathEOFillStroke);
		
		CGContextRestoreGState(ctx);
		CGContextSaveGState(ctx);
	}
	
	//middle circle
	CGContextAddEllipseInRect(ctx, CGRectMake(halfWidth - halfArrowWidth, halfHeight - halfArrowWidth, arrowSize.width, arrowSize.width));
	
	CGContextSetFillColorWithColor(ctx, [ARROW_FILL_COLOR CGColor]);
	CGContextSetStrokeColorWithColor(ctx, [STROKE_COLOR CGColor]);
	CGContextSetLineWidth(ctx, lineWidth);
	CGContextDrawPath(ctx, kCGPathEOFillStroke);
	
	CGContextRestoreGState(ctx);
}

@end
