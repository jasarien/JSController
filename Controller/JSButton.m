//
//  JSButton.m
//  Controller
//
//  Created by James Addyman on 29/03/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//

#import "JSButton.h"

@interface JSButton () {
	
	UIImageView *_backgroundImageView;
	
}

@property (nonatomic, assign) BOOL pressed;

@end

@implementation JSButton

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
	_backgroundImageView = [[UIImageView alloc] initWithImage:self.backgroundImage];
	[_backgroundImageView setFrame:[self bounds]];
	[self addSubview:_backgroundImageView];
	
	_titleLabel = [[UILabel alloc] init];
	[_titleLabel setBackgroundColor:[UIColor clearColor]];
	[_titleLabel setTextColor:[UIColor darkGrayColor]];
	[_titleLabel setShadowColor:[UIColor whiteColor]];
	[_titleLabel setShadowOffset:CGSizeMake(0, 1)];
	[_titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
	[_titleLabel setFrame:[self bounds]];
	[_titleLabel setTextAlignment:NSTextAlignmentCenter];
	[self addSubview: _titleLabel];
	
	[self addObserver:self
		   forKeyPath:@"pressed"
			  options:NSKeyValueObservingOptionNew
			  context:NULL];
	
	[self addObserver:self
		   forKeyPath:@"backgroundImage"
			  options:NSKeyValueObservingOptionNew
			  context:NULL];
	
	[self addObserver:self
		   forKeyPath:@"backgroundImagePressed"
			  options:NSKeyValueObservingOptionNew
			  context:NULL];
	
	self.pressed = NO;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"pressed"];
	self.delegate = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"pressed"] ||
		[keyPath isEqualToString:@"backgroundImage"] ||
		[keyPath isEqualToString:@"backgroundImagePressed"])
	{
		if (self.pressed)
		{
			[_backgroundImageView setImage:self.backgroundImagePressed];
		}
		else
		{
			[_backgroundImageView setImage:self.backgroundImage];
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.pressed = YES;
	if ([self.delegate respondsToSelector:@selector(buttonPressed:)])
	{
		[self.delegate buttonPressed:self];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGFloat width = [self frame].size.width;
	CGFloat height = [self frame].size.height;
	
	if (!self.pressed)
	{
		self.pressed = YES;
		if ([self.delegate respondsToSelector:@selector(buttonPressed:)])
		{
			[self.delegate buttonPressed:self];
		}
	}
	
	if (((point.x < 0) || (point.x > width)) || ((point.y < 0) || (point.y > height)))
	{
		if (self.pressed)
		{
			self.pressed = NO;
			if ([self.delegate respondsToSelector:@selector(buttonReleased:)])
			{
				[self.delegate buttonReleased:self];
			}
		}
	}
	else
	{
		self.pressed = YES;
		if ([self.delegate respondsToSelector:@selector(buttonPressed:)])
		{
			[self.delegate buttonPressed:self];
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.pressed = NO;
	if ([self.delegate respondsToSelector:@selector(buttonReleased:)])
	{
		[self.delegate buttonReleased:self];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.pressed = NO;
	if ([self.delegate respondsToSelector:@selector(buttonReleased:)])
	{
		[self.delegate buttonReleased:self];
	}
}

@end
