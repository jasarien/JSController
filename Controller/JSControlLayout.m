//
//  JSControlLayout.m
//  Controller
//
//  Created by James Addyman on 04/04/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//

#import "JSControlLayout.h"

@interface JSControlLayout () {

	JSDPad *_dPad;
	NSMutableArray *_buttons;
	
}

@end

@implementation JSControlLayout

- (id)initWithLayout:(NSString *)layoutFile delegate:(id <JSDPadDelegate, JSButtonDelegate>)delegate
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		if (![layoutFile length] || !delegate)
		{
			@throw [NSException exceptionWithName:@"JSControlPadInternalInconsistencyException"
										   reason:@"A Layout file path AND a delegate must be provided"
										 userInfo:nil];
			return nil;
		}
		
		self.delegate = delegate;
		
		if ([layoutFile length])
		{
			NSDictionary *layout = [[NSDictionary alloc] initWithContentsOfFile:layoutFile];
			if (layout)
			{
				self.title = [layout objectForKey:@"title"];
				
				// set up the dpad
				NSDictionary *dPadDict = [layout objectForKey:@"dpad"];
				CGRect dPadFrame = CGRectFromString([dPadDict objectForKey:@"frame"]);
				_dPad = [[JSDPad alloc] initWithFrame:dPadFrame];
				[_dPad setDelegate:self.delegate];
				[self addSubview:_dPad];
				
				// set up buttons
				_buttons = [NSMutableArray array];
				NSArray *buttonArray = [layout objectForKey:@"buttons"];
				for (NSDictionary *buttonDict in buttonArray)
				{
					CGRect buttonFrame = CGRectFromString([buttonDict objectForKey:@"frame"]);
					JSButton *button = [[JSButton alloc] initWithFrame:buttonFrame];
					[[button titleLabel] setText:[buttonDict objectForKey:@"title"]];
					[button setDelegate:self.delegate];
					[self addSubview:button];
					[_buttons addObject:button];
				}
			}
		}
	}
	
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGRect frame = [_dPad frame];
	
	if (CGRectContainsPoint(frame, point))
	{
		[_dPad touchesBegan:touches withEvent:event];
	}
	else
	{
		for (JSButton *button in _buttons)
		{
			frame = [button frame];
			
			if (CGRectContainsPoint(frame, point))
			{
				[_dPad touchesBegan:touches withEvent:event];
			}
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGRect frame = [_dPad frame];
	
	if (CGRectContainsPoint(frame, point))
	{
		[_dPad touchesMoved:touches withEvent:event];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

@end
