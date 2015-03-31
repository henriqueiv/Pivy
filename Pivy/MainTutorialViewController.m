//
//  MainTutorialViewController.m
//  Pivy
//
//  Created by Ami Garcia on 3/26/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

#import "MainTutorialViewController.h"
#import "DataManager.h"
#import "Background.h"
#import "MBProgressHUD.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

@interface MainTutorialViewController () <UIScrollViewDelegate>{
    int page;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIImageView *imgPageView01;
@property (weak, nonatomic) IBOutlet UIImageView *imgPageView02;
@property (weak, nonatomic) IBOutlet UIImageView *imgPageView03;
@property (weak, nonatomic) IBOutlet UIImageView *imgPageView04;
@property (weak, nonatomic) IBOutlet UIImageView *imgPageView05;

@end

@implementation MainTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        [self presentViewController:vc animated:YES completion:nil];
    }
    page = 0;
}

-(void)viewDidLayoutSubviews{
    UIViewController *vc1 = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"firstTutorial"];
    UIViewController *vc2 = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"secondTutorial"];
    UIViewController *vc3 = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"thirdTutorial"];
    UIViewController *vc4 = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"fourthTutorial"];
    UIViewController *vc5 = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"fifthTutorial"];
    
    [self.scrollView addSubview:vc1.view];
    
    vc2.view.frame = CGRectMake(vc1.view.frame.size.width, 0, vc2.view.frame.size.width, vc2.view.frame.size.height);
    [self.scrollView addSubview:vc2.view];
    
    vc3.view.frame = CGRectMake(vc1.view.frame.size.width*2, 0, vc3.view.frame.size.width, vc3.view.frame.size.height);
    [self.scrollView addSubview:vc3.view];
    
    vc4.view.frame = CGRectMake(vc1.view.frame.size.width*3, 0, vc4.view.frame.size.width, vc4.view.frame.size.height);
    [self.scrollView addSubview:vc4.view];
    
    vc5.view.frame = CGRectMake(vc1.view.frame.size.width*4, 0, vc5.view.frame.size.width, vc5.view.frame.size.height);
    [self.scrollView addSubview:vc5.view];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * 5, self.scrollView.frame.size.height)];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //[scrollView layoutIfNeeded];
    CGFloat pageWidth = scrollView.bounds.size.width;
    page = floor((scrollView.contentOffset.x - pageWidth / 4) / pageWidth) + 1;
    _pageControl.currentPage = page;
    
    switch (page) {
        case 0:{
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            self.imgPageView01.hidden=NO;
            self.imgPageView02.hidden=YES;
            self.imgPageView03.hidden=YES;
            self.imgPageView04.hidden=YES;
            self.imgPageView05.hidden=YES;
            break;
        }
            
        case 1:{
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            self.imgPageView01.hidden=YES;
            self.imgPageView02.hidden=NO;
            self.imgPageView03.hidden=YES;
            self.imgPageView04.hidden=YES;
            self.imgPageView05.hidden=YES;
            break;
        }
            
        case 2:{
            self.imgPageView01.hidden=YES;
            self.imgPageView02.hidden=YES;
            self.imgPageView03.hidden=NO;
            self.imgPageView04.hidden=YES;
            self.imgPageView05.hidden=YES;
            break;
        }
            
        case 3:{
            self.imgPageView01.hidden=YES;
            self.imgPageView02.hidden=YES;
            self.imgPageView03.hidden=YES;
            self.imgPageView04.hidden=NO;
            self.imgPageView05.hidden=YES;
            break;
        }
        case 4:{
            self.imgPageView01.hidden=YES;
            self.imgPageView02.hidden=YES;
            self.imgPageView03.hidden=YES;
            self.imgPageView04.hidden=YES;
            self.imgPageView05.hidden=NO;
            break;
        }
            
        default:
            break;
    }
}

- (IBAction)downloadData:(id)sender {
    NSLog(@"hue");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(kBgQueue, ^{
        [DataManager updateLocalDatastore:[Pivy parseClassName] inBackground:YES];
        [DataManager updateLocalDatastore:[Background parseClassName] inBackground:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            // This is the first launch ever
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [sb instantiateInitialViewController];
            [self presentViewController:vc animated:YES completion:nil];
        });
    });
}

@end
