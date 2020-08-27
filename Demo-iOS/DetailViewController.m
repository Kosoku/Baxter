//
//  DetailViewController.m
//  Demo-iOS
//
//  Created by William Towe on 2/20/19.
//  Copyright © 2020 Kosoku Interactive, LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "DetailViewController.h"
#import "Row.h"

@interface DetailViewController () <UITextFieldDelegate, UITextViewDelegate>
@property (strong,nonatomic) IBOutlet UITextField *titleTextField;
@property (strong,nonatomic) IBOutlet UITextView *summaryTextView;

@property (strong,nonatomic) Row *entity;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Detail";
    
    self.titleTextField.text = self.entity.title;
    self.titleTextField.delegate = self;
    [self.titleTextField addTarget:self action:@selector(_textFieldAction:) forControlEvents:UIControlEventEditingChanged];
    
    self.summaryTextView.text = self.entity.summary;
    self.summaryTextView.textContainerInset = UIEdgeInsetsZero;
    self.summaryTextView.textContainer.lineFragmentPadding = 0.0;
    self.summaryTextView.delegate = self;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.entity.summary = self.summaryTextView.text;
}

- (instancetype)initWithEntity:(Row *)entity {
    if (!(self = [super initWithNibName:nil bundle:nil]))
        return nil;
    
    _entity = entity;
    
    return self;
}

- (IBAction)_textFieldAction:(id)sender {
    self.entity.title = self.titleTextField.text;
}

@end
