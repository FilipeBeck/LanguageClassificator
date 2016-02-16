//
//  ExecutionViewController.m
//  LanguageClassificator
//
//  Created by Filipe Beck on 2/15/16.
//  Copyright © 2016 Beck. All rights reserved.
//

#import "ExecutionViewController.h"

#import "AppDelegate.h"
#import "TrainViewController.h"

@interface ExecutionViewController ()

@end

@implementation ExecutionViewController
{
	IBOutlet UITextField* urlField;
	
	IBOutlet UILabel* enOutLabel;
	
	IBOutlet UILabel* ptOutLabel;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	self.view.userInteractionEnabled = NO;
	self.view.alpha = 0.75;
	
	UIActivityIndicatorView* loadingView = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:loadingView];
	[loadingView startAnimating];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError* error = nil;
		
		NSString* documentText = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlField.text] encoding:NSUTF8StringEncoding error:&error];
		
		if (error)
		{
			NSLog(@"%@", error);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				UILabel* alertLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
				alertLabel.text = error.description;
				alertLabel.numberOfLines = 0;
				alertLabel.textAlignment = NSTextAlignmentCenter;
				alertLabel.backgroundColor = UIColor.lightGrayColor;
				
				[self.view addSubview:alertLabel];
				
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
			
			struct fann* ann = AppDelegate.shared.ann;
			TrainViewController* trainController = AppDelegate.tabController.viewControllers[1];
			float formattedData[26];
			fann_type *calcOut;
			
			[trainController formatText:documentText output:formattedData];
			
			fann_set_activation_function_output(ann, FANN_THRESHOLD);
			
			calcOut = fann_run(ann, formattedData);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				enOutLabel.text = [NSString stringWithFormat:@"%f", (float)calcOut[0]];
				ptOutLabel.text = [NSString stringWithFormat:@"%f", (float)calcOut[1]];
				
				self.view.userInteractionEnabled = YES;
				self.view.alpha = 1.0;
				
				[loadingView stopAnimating];
				[loadingView removeFromSuperview];
			});
		}
	});
	
	return YES;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
