//
//  SecondViewController.m
//  LanguageClassificator
//
//  Created by Filipe Beck on 2/10/16.
//  Copyright © 2016 Beck. All rights reserved.
//

#import "TrainViewController.h"

#import "AppDelegate.h"
#import "floatfann.h"

@interface TrainViewController ()

@end

@implementation TrainViewController
{
	IBOutlet UIScrollView* trainLogView;
	
	UILabel* trainLogLabel;
}

TrainViewController* THIS = nil;

int FANN_API callbackTrain(struct fann *ann, struct fann_train_data *train,
													 unsigned int max_epochs, unsigned int epochs_between_reports,
													 float desired_error, unsigned int epochs)
{
	[THIS addItemToLog:[NSString stringWithFormat:@"Epochs: %8d\nMSE: %.5f\nDesired-MSE: %.5f\n", epochs, fann_get_MSE(ann), desired_error] separator:@"\n"];
	
	return 0;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	THIS = self;
	
	trainLogLabel = [UILabel new];
	trainLogLabel.numberOfLines =0;
	trainLogLabel.textAlignment = NSTextAlignmentLeft;
	trainLogLabel.text = @"";
	
	[trainLogView addSubview:trainLogLabel];
}

- (void)addItemToLog:(NSString*)item separator:(NSString*)sep
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSString* separator = [trainLogLabel.text isEqualToString:@""] ? @"": sep;
		trainLogLabel.text = [NSString stringWithFormat:@"%@%@%@", trainLogLabel.text, separator, item];
		[trainLogLabel sizeToFit];
		trainLogView.contentSize = trainLogLabel.frame.size;
		
		if (trainLogLabel.frame.size.height > trainLogView.frame.size.height)
			trainLogView.contentOffset = CGPointMake(0.0, trainLogView.contentSize.height - trainLogView.frame.size.height);
	});
}

- (void)formatText:(NSString*)text output:(float[26])outputData
{
	int totalCharCont = 0;
	
	for (int i = 0; i < 26; i++)
		outputData[i] = 0.0;
	
	const char* ch = text.lowercaseString.UTF8String;
	
	while (*ch)
	{
		if (*ch >= 'a' && *ch <= 'z')
		{
			outputData[*ch - 'a'] += 1.0;
			totalCharCont++;
		}
		
		ch++;
	}
	
	for (int i = 0; i < 26; i++)
		outputData[i] /= (float)totalCharCont;
}

- (void)logFormattedData:(float[26])data
{
	for (int i = 0; i < 26; i++)
		[self addItemToLog:[NSString stringWithFormat:@"%c: %f", ((unsigned char)i) + 'A', data[i]] separator:(i < 26) ? @"\n" : @""];
}

- (void)trainCurrentAddedData
{
	trainLogLabel.text = @"";
	
	[self addItemToLog:@"Formatando os dados recebidos:" separator:@"\n\n"];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSMutableArray<NSString*>* enData = AppDelegate.shared.enData;
		NSMutableArray<NSString*>* ptData = AppDelegate.shared.ptData;
		
		int inCount = 26 * (enData.count + ptData.count);
		int outCount = 2 * (enData.count + ptData.count);
		
		float formattedData[inCount];
		float results[outCount];
		
		for (int i = 0, count = enData.count; i < count; i++)
		{
			[self addItemToLog:[NSString stringWithFormat:@"\n(Inglês) Item %d\n", i + 1] separator:@"\n"];
			float* data = &(formattedData[i * 26]);
			
			[self formatText:enData[i] output:data];
			results[i * 2] = 1.0;
			results[i * 2 + 1] = -1.0;
			
			[self logFormattedData:data];
		}
		
		[self addItemToLog:[NSString stringWithFormat:@""] separator:@"\n"];
		
		for (int i = 0, count = ptData.count; i < count; i++)
		{
			[self addItemToLog:[NSString stringWithFormat:@"(Português) Item %d\n", i + 1] separator:@"\n"];
			
			float* data = &(formattedData[i * 26 + (enData.count * 26)]);
			
			[self formatText:ptData[i] output:data];
			results[i * 2 + enData.count * 2] = -1.0;
			results[i * 2 + 1 + enData.count * 2] = 1.0;
			
			[self logFormattedData:data];
		}
		
		/*for (int i = 0; i < inCount; i++)
			NSLog(@"%f", formattedData[i]);*/
		NSLog(@"%@", @"\nout\n");
		for (int i = 0; i < outCount; i++)
			NSLog(@"%f", results[i]);
		
		[self addItemToLog:@"\n" separator:@""];
		
		struct fann* ann = AppDelegate.shared.ann;
		
		fann_set_callback(ann, callbackTrain);
			
		struct fann_train_data* trainData = fann_create_train_array(enData.count + ptData.count, 26, formattedData, 2, results);
		
		fann_set_activation_function_output(ann, FANN_SIGMOID_SYMMETRIC);
		//fann_cascadetrain_on_data(ann, trainData, 100, 10, 0.0);
		fann_train_on_data(ann, trainData, 50000, 1000, 0.0);
		
		[self addItemToLog:@"\nTreino finalizado" separator:@"\n"];
	});
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
