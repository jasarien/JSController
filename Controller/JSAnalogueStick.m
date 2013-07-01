//
//  JSAnalogueStick.m
//  Controller
//
//  Created by James Addyman on 29/03/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//

#import "JSAnalogueStick.h"

#define RADIUS ([self bounds].size.width / 2)

@implementation JSAnalogueStick

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self commonInit];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self commonInit];
	}
	
	return self;
}

- (void)commonInit
{
	_backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"analogue_bg"]];
	CGRect backgroundImageFrame = [_backgroundImageView frame];
	backgroundImageFrame.size = [self bounds].size;
	backgroundImageFrame.origin = CGPointZero;
	[_backgroundImageView setFrame:backgroundImageFrame];
	[self addSubview:_backgroundImageView];
	
	_handleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"analogue_handle"]];
	CGRect handleImageFrame = [_handleImageView frame];
	handleImageFrame.size = CGSizeMake([_backgroundImageView bounds].size.width / 1.5,
									   [_backgroundImageView bounds].size.height / 1.5);
	handleImageFrame.origin = CGPointMake(([self bounds].size.width - handleImageFrame.size.width) / 2,
										  ([self bounds].size.height - handleImageFrame.size.height) / 2);
	[_handleImageView setFrame:handleImageFrame];
	[self addSubview:_handleImageView];
	
	_xValue = 0;
	_yValue = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint location = [[touches anyObject] locationInView:self];
	
	CGFloat normalisedX = (location.x / RADIUS) - 1;
	CGFloat normalisedY = ((location.y / RADIUS) - 1) * -1;
	
	if (normalisedX > 1.0)
	{
		location.x = [self bounds].size.width;
		normalisedX = 1.0;
	}
	else if (normalisedX < -1.0)
	{
		location.x = 0.0;
		normalisedX = -1.0;
	}
	
	if (normalisedY > 1.0)
	{
		location.y = 0.0;
		normalisedY = 1.0;
	}
	else if (normalisedY < -1.0)
	{
		location.y = [self bounds].size.height;
		normalisedY = -1.0;
	}
	
	if (self.invertedYAxis)
	{
		normalisedY *= -1;
	}
	
	_xValue = normalisedX;
	_yValue = normalisedY;
	
	CGRect handleImageFrame = [_handleImageView frame];
	handleImageFrame.origin = CGPointMake(location.x - ([_handleImageView bounds].size.width / 2),
										  location.y - ([_handleImageView bounds].size.width / 2));
	[_handleImageView setFrame:handleImageFrame];
	
	if ([self.delegate respondsToSelector:@selector(analogueStickDidChangeValue:)])
	{
		[self.delegate analogueStickDidChangeValue:self];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint location = [[touches anyObject] locationInView:self];
	
	CGFloat normalisedX = (location.x / RADIUS) - 1;
	CGFloat normalisedY = ((location.y / RADIUS) - 1) * -1;
	
	if (normalisedX > 1.0)
	{
		location.x = [self bounds].size.width;
		normalisedX = 1.0;
	}
	else if (normalisedX < -1.0)
	{
		location.x = 0.0;
		normalisedX = -1.0;
	}
	
	if (normalisedY > 1.0)
	{
		location.y = 0.0;
		normalisedY = 1.0;
	}
	else if (normalisedY < -1.0)
	{
		location.y = [self bounds].size.height;
		normalisedY = -1.0;
	}
	
	if (self.invertedYAxis)
	{
		normalisedY *= -1;
	}
	
	_xValue = normalisedX;
	_yValue = normalisedY;
	
	CGRect handleImageFrame = [_handleImageView frame];
	handleImageFrame.origin = CGPointMake(location.x - ([_handleImageView bounds].size.width / 2),
										  location.y - ([_handleImageView bounds].size.width / 2));
	[_handleImageView setFrame:handleImageFrame];
	
	if ([self.delegate respondsToSelector:@selector(analogueStickDidChangeValue:)])
	{
		[self.delegate analogueStickDidChangeValue:self];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	_xValue = 0.0;
	_yValue = 0.0;
	
	CGRect handleImageFrame = [_handleImageView frame];
	handleImageFrame.origin = CGPointMake(([self bounds].size.width - [_handleImageView bounds].size.width) / 2,
										  ([self bounds].size.height - [_handleImageView bounds].size.height) / 2);
	[_handleImageView setFrame:handleImageFrame];
	
	if ([self.delegate respondsToSelector:@selector(analogueStickDidChangeValue:)])
	{
		[self.delegate analogueStickDidChangeValue:self];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	_xValue = 0.0;
	_yValue = 0.0;
	
	CGRect handleImageFrame = [_handleImageView frame];
	handleImageFrame.origin = CGPointMake(([self bounds].size.width - [_handleImageView bounds].size.width) / 2,
										  ([self bounds].size.height - [_handleImageView bounds].size.height) / 2);
	[_handleImageView setFrame:handleImageFrame];
	
	if ([self.delegate respondsToSelector:@selector(analogueStickDidChangeValue:)])
	{
		[self.delegate analogueStickDidChangeValue:self];
	}
}

@end
