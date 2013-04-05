//
//  JSViewController.h
//  Controller
//
//  Created by James Addyman on 28/03/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSDPad.h"
#import "JSButton.h"

@interface JSViewController : UIViewController <JSDPadDelegate, JSButtonDelegate>

@property (weak, nonatomic) IBOutlet UILabel *directionlabel;
@property (weak, nonatomic) IBOutlet UILabel *buttonLabel;
@property (weak, nonatomic) IBOutlet JSDPad *dPad;
@property (weak, nonatomic) IBOutlet JSButton *bButton;
@property (weak, nonatomic) IBOutlet JSButton *aButton;

@end
