//
//  ViewController.m
//  XBAcFun
//
//  Created by Fanglei on 16/5/11.
//  Copyright © 2016年 Fanglei. All rights reserved.
//

#import "ViewController.h"
#import "XBAcFunCommon.h"
#import "TableViewCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *blackMaskButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBaseBottomLayout;

@property (strong, nonatomic) XBAcFunManager * acfunManager;
@property (strong, nonatomic) NSMutableArray * dataSource;
@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textField.layer.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.45].CGColor;
    self.textField.layer.borderWidth = 1.0f;
    self.textField.layer.cornerRadius = 5.0f;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHid:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.acfunManager showAcFunWithComments:self.dataSource inViewController:self];
        /**
         * since in my working situation I need to wait until all acfuns have been downloaded already, then start the diplaying .U can change it depend on your situation
         */
        self.acfunManager.hasLoadAllAcfun = YES;
        [self.acfunManager startAcFun];
    });
}

#pragma mark - delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[TableViewCell description] forIndexPath:indexPath];
    [cell bindDictionary:self.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75.0;
}

#pragma mark - private

- (IBAction)showTextField:(UIBarButtonItem *)sender {
    [self.textField becomeFirstResponder];
}

- (IBAction)showPrivateAcFunAction {
    [self.view endEditing:YES];
    if (self.textField.text.length > 0) {
        [self.acfunManager showPrivateAcFunComment:[self.textField.text copy] userAvatar:[UIImage imageNamed:@"AppleIcon"]];
        self.textField.text = @"";
    }
}

- (IBAction)touchBlackMask {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notify{
    CGRect targetRect = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    [UIView animateWithDuration:[[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        self.blackMaskButton.alpha = 1.0;
        self.textFieldBaseBottomLayout.constant = CGRectGetHeight(targetRect);
        _acfunManager.currentBaseOriginY = - (CGRectGetHeight(targetRect) + 50);
        [self.view layoutSubviews];
    }];
}

- (void)keyboardWillHid:(NSNotification *)notify{
    [UIView animateWithDuration:[[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        self.blackMaskButton.alpha = 0.0;
        self.textFieldBaseBottomLayout.constant = - 50.0;
        _acfunManager.currentBaseOriginY = 0;
        [self.view layoutSubviews];
    }];
}

#pragma mark - setter / getter

- (NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray arrayWithCapacity:300];
        NSInteger count = arc4random_uniform(100) + 300;
        NSString * imageName = @"";
        NSString * title = @"";
        NSInteger likeCount = 0;
        for (NSInteger index = 0; index < count; index++) {
            switch (index%4) {
                case 0:
                    imageName = @"ALiPayIcon";
                    break;
                case 1:
                    imageName = @"MasterCardPayIcon";
                    break;
                case 2:
                    imageName = @"UnionPayIcon";
                    break;
                case 3:
                    imageName = @"WeixinPayIcon";
                    break;
                default:
                    break;
            }
            title = imageName;
            /**
             *  the acfunsubview's bg color depend on the likecount
             */
            NSInteger random = arc4random_uniform(200) % 4;
            switch (random) {
                case 0:
                    likeCount = 0;
                    break;
                case 1:
                    likeCount = 10;
                    break;
                case 2:
                    likeCount = 11;
                    break;
                case 3:
                    likeCount = 101;
                    break;
                default:
                    break;
            }
            
            /**
             *  since I need display the acfun so I use the acfunIem's property names as the keys
             */
            [_dataSource addObject:@{kTitle:title,kImage:imageName,kLikeCount:[@(likeCount) stringValue]}];
        }
    }
    return _dataSource;
}

- (XBAcFunManager *)acfunManager{
    if (_acfunManager == nil) {
        _acfunManager = [[XBAcFunManager alloc]init];
        _acfunManager.belowView = self.blackMaskButton;
        _acfunManager.acfunCustomParamMaker.privateAppearStrategy(XBAcFunPrivateAppearStrategy_Flutter_Mix).numberOfLine(7);
    }
    return _acfunManager;
}

@end
