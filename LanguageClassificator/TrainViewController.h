//
//  SecondViewController.h
//  LanguageClassificator
//
//  Created by Filipe Beck on 2/10/16.
//  Copyright © 2016 Beck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainViewController : UIViewController

- (void)trainCurrentAddedData;

- (void)formatText:(NSString*)text output:(float[26])outputData;

@end

