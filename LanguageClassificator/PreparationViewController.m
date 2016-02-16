//
//  FirstViewController.m
//  LanguageClassificator
//
//  Created by Filipe Beck on 2/10/16.
//  Copyright © 2016 Beck. All rights reserved.
//

#import "PreparationViewController.h"
#import "AppDelegate.h"

#import "TrainViewController.h"

@interface PreparationViewController ()
{
	IBOutlet UITextField* urlField;
	
	IBOutlet UIPickerView* languagePicker;
	
	IBOutlet UIButton* addToTrainButton;
	
	IBOutlet UIScrollView* addToTrainLogView;
	
	UILabel* addToTrainLogLabel;
	
	IBOutlet UIButton* trainButton;
	
	NSMutableArray<NSString*>* textArray[2];
}
@end

@implementation PreparationViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	addToTrainLogLabel = [UILabel new];
	addToTrainLogLabel.numberOfLines = 0;
	addToTrainLogLabel.textAlignment = NSTextAlignmentLeft;
	addToTrainLogLabel.lineBreakMode = NSLineBreakByCharWrapping;
	addToTrainLogLabel.text = @"";
	
	[addToTrainLogView addSubview:addToTrainLogLabel];
	
	AppDelegate.shared.enData = textArray[0] = [NSMutableArray new];
	AppDelegate.shared.ptData = textArray[1] = [NSMutableArray new];
}

- (void)addItemToLog:(NSString*)item
{
	NSString* separator = [addToTrainLogLabel.text isEqualToString:@""] ? @"": @"\n";
	addToTrainLogLabel.text = [NSString stringWithFormat:@"%@%@%@", addToTrainLogLabel.text, separator, item];
	[addToTrainLogLabel sizeToFit];
	addToTrainLogView.contentSize = addToTrainLogLabel.frame.size;
	
	if (addToTrainLogLabel.frame.size.height > addToTrainLogView.frame.size.height)
		addToTrainLogView.contentOffset = CGPointMake(0.0, addToTrainLogView.contentSize.height - addToTrainLogView.frame.size.height);
}

- (void)addCurrentURLToTrain
{
	NSLog(@"%d", (int)[languagePicker selectedRowInComponent:0]);
	
	self.view.userInteractionEnabled = NO;
	self.view.alpha = 0.75;
	
	UIActivityIndicatorView* loadingView = [[UIActivityIndicatorView alloc] initWithFrame:addToTrainLogView.bounds];
	[addToTrainLogView addSubview:loadingView];
	[loadingView startAnimating];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError* error = nil;
		
		NSString* documentText = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlField.text] encoding:NSUTF8StringEncoding error:&error];
		
		if (error)
		{
			NSLog(@"%@", error);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				UILabel* alertLabel = [[UILabel alloc] initWithFrame:addToTrainLogView.bounds];
				alertLabel.text = error.description;
				alertLabel.numberOfLines = 0;
				alertLabel.textAlignment = NSTextAlignmentCenter;
				alertLabel.backgroundColor = UIColor.lightGrayColor;
				
				[addToTrainLogView addSubview:alertLabel];
				
				[UIView animateWithDuration:0.5 delay:3.0 options:UIViewAnimationOptionCurveLinear animations:^{
					alertLabel.alpha = 0.0;
				} completion:^(BOOL finished) {
					[alertLabel removeFromSuperview];
					
					self.view.userInteractionEnabled = YES;
					self.view.alpha = 1.0;
				}];
				 
				[loadingView stopAnimating];
				[loadingView removeFromSuperview];
			});
		}
		else
		{
			NSLog(@"%@", documentText);
			
			[textArray[[languagePicker selectedRowInComponent:0]] addObject:documentText];
			
			NSString* langType = ([languagePicker selectedRowInComponent:0] == 0) ? @"(Inglês)" : @"(Português)";
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[self addItemToLog:[NSString stringWithFormat:@"%@ %@", urlField.text, langType]];
				
				self.view.userInteractionEnabled = YES;
				self.view.alpha = 1.0;
				
				[loadingView stopAnimating];
				[loadingView removeFromSuperview];
			});
		}
	});
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}

- (IBAction)addToTrainButtonPressed:(UIButton*)button
{
	[urlField resignFirstResponder];
	
	[self addCurrentURLToTrain];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 2;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return pickerView.frame.size.width;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return @[@"Inglês", @"Português"][row];
}

- (IBAction)trainButtonPressed:(UIButton*)sender
{
	[AppDelegate.tabController setSelectedIndex:1];
	
	TrainViewController* trainController = AppDelegate.tabController.viewControllers[1];
	
	[trainController trainCurrentAddedData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[urlField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
