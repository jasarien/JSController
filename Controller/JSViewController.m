//
//  JSViewController.m
//  Controller
//
//  Created by James Addyman on 28/03/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//

#import "JSViewController.h"
#import "JSDPad.h"

@interface JSViewController () {
	
	NSMutableArray *_pressedButtons;
	
}

- (NSString *)stringForDirection:(JSDPadDirection)direction;

@end

@implementation JSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[self.aButton titleLabel] setText:@"A"];
	[self.aButton setBackgroundImage:[UIImage imageNamed:@"button"]];
	[self.aButton setBackgroundImagePressed:[UIImage imageNamed:@"button-pressed"]];
	
	
	[[self.bButton titleLabel] setText:@"B"];
	[self.bButton setBackgroundImage:[UIImage imageNamed:@"button"]];
	[self.bButton setBackgroundImagePressed:[UIImage imageNamed:@"button-pressed"]];
	
	_pressedButtons = [NSMutableArray new];
	
	[self updateDirectionLabel];
	[self updateButtonLabel];
	[self updateAnalogueLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSString *)stringForDirection:(JSDPadDirection)direction
{
	NSString *string = nil;
	
	switch (direction) {
		case JSDPadDirectionNone:
			string = @"None";
			break;
		case JSDPadDirectionUp:
			string = @"Up";
			break;
		case JSDPadDirectionDown:
			string = @"Down";
			break;
		case JSDPadDirectionLeft:
			string = @"Left";
			break;
		case JSDPadDirectionRight:
			string = @"Right";
			break;
		case JSDPadDirectionUpLeft:
			string = @"Up Left";
			break;
		case JSDPadDirectionUpRight:
			string = @"Up Right";
			break;
		case JSDPadDirectionDownLeft:
			string = @"Down Left";
			break;
		case JSDPadDirectionDownRight:
			string = @"Down Right";
			break;
		default:
			string = @"None";
			break;
	}
	
	return string;
}

- (void)updateDirectionLabel
{
	[self.directionlabel setText:[NSString stringWithFormat:@"Direction: %@", [self stringForDirection:[self.dPad currentDirection]]]];
}

- (void)updateButtonLabel
{
	NSString *buttonString = @"";
	
	for(JSButton *button in _pressedButtons)
	{
		if ([buttonString length])
		{
			buttonString = [buttonString stringByAppendingFormat:@", "];
		}
		
		if ([button isEqual:self.aButton])
		{
			buttonString = [buttonString stringByAppendingFormat:@"A"];
		}
		else if ([button isEqual:self.bButton])
		{
			buttonString = [buttonString stringByAppendingFormat:@"B"];
		}
	}
	
	[self.buttonLabel setText:[NSString stringWithFormat:@"Buttons pressed: %@", buttonString]];
}

- (void)updateAnalogueLabel
{
	[self.analogueLabel setText:[NSString stringWithFormat:@"Analogue: %.1f , %.1f", self.analogueStick.xValue, self.analogueStick.yValue]];
}

#pragma mark - JSDPadDelegate

- (void)dPad:(JSDPad *)dPad didPressDirection:(JSDPadDirection)direction
{
	NSLog(@"Changing direction to: %@", [self stringForDirection:direction]);
	[self updateDirectionLabel];
}

- (void)dPadDidReleaseDirection:(JSDPad *)dPad
{
	NSLog(@"Releasing DPad");
	[self updateDirectionLabel];
}

#pragma mark - JSButtonDelegate

- (void)buttonPressed:(JSButton *)button
{
	if ([_pressedButtons containsObject:button])
	{
		NSLog(@"Button is already being tracked as pressed");
		return;
	}
	
	if ([button isEqual:self.aButton])
	{
		[_pressedButtons addObject:self.aButton];
	}
	else if ([button isEqual:self.bButton])
	{
		[_pressedButtons addObject:self.bButton];
	}
	
	[self updateButtonLabel];
}

- (void)buttonReleased:(JSButton *)button
{
	if ([_pressedButtons containsObject:button] == NO)
	{
		NSLog(@"Button has already been released");
		return;
	}
	
	if ([button isEqual:self.aButton])
	{
		[_pressedButtons removeObject:self.aButton];
	}
	else if ([button isEqual:self.bButton])
	{
		[_pressedButtons removeObject:self.bButton];
	}
	
	[self updateButtonLabel];
	
}

#pragma mark - JSAnalogueStickDelegate

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick
{
	[self updateAnalogueLabel];
}

@end
