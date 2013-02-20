//
//  articleViewController.m
//  FTCoreText
//
//  Created by Francesco Frison on 18/08/2011.
//  Copyright 2011 Fuerte International. All rights reserved.
//

#import "articleViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface UIImage (Scale)
-(UIImage *)TransformtoSize:(CGSize)Newsize;
@end
@implementation UIImage (Scale)
-(UIImage *)TransformtoSize:(CGSize)Newsize
{
    UIGraphicsBeginImageContext(Newsize);
    [self drawInRect:CGRectMake(0, 0, Newsize.width, Newsize.height)];
    UIImage *TransformedImg=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return TransformedImg;
}
@end

@implementation articleViewController
@synthesize scrollView;
@synthesize coreTextView;


- (NSString *)textForView:(NSString*) fname
{
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fname ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
}


- (NSArray *)coreTextStyle
{
    NSMutableArray *result = [NSMutableArray array];
    
	FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
	defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
	defaultStyle.font = [UIFont systemFontOfSize:16.f];
	defaultStyle.textAlignment = FTCoreTextAlignementJustified;
	[result addObject:defaultStyle];
	
	
	FTCoreTextStyle *titleStyle = [FTCoreTextStyle styleWithName:@"title"]; // using fast method
	titleStyle.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:40.f];
	titleStyle.paragraphInset = UIEdgeInsetsMake(0, 0, 10, 0);
	titleStyle.textAlignment = FTCoreTextAlignementCenter;
	[result addObject:titleStyle];
	
	FTCoreTextStyle *imageStyle = [FTCoreTextStyle new];
	imageStyle.paragraphInset = UIEdgeInsetsMake(0,0,0,0);
	imageStyle.name = FTCoreTextTagImage;

    //这里的值会影响到图片上下行距(by sharetop)
    imageStyle.font = [UIFont systemFontOfSize:4.f];
    
	imageStyle.textAlignment = FTCoreTextAlignementCenter;
	[result addObject:imageStyle];
    
    FTCoreTextStyle *iconStyle=[imageStyle copy];
    iconStyle.name=FTCoreTextTagIcon;
    iconStyle.font=[UIFont systemFontOfSize:16.f];
    iconStyle.textAlignment=FTCoreTextAlignementLeft;
    [result addObject:iconStyle];
    
	FTCoreTextStyle *firstLetterStyle = [FTCoreTextStyle new];
	firstLetterStyle.name = @"firstLetter";
	firstLetterStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:30.f];
	[result addObject:firstLetterStyle];
    
	FTCoreTextStyle *linkStyle = [defaultStyle copy];
	linkStyle.name = FTCoreTextTagLink;
	linkStyle.color = [UIColor orangeColor];
	[result addObject:linkStyle];
    
	FTCoreTextStyle *subtitleStyle = [FTCoreTextStyle styleWithName:@"subtitle"];
	subtitleStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:25.f];
	subtitleStyle.color = [UIColor brownColor];
	subtitleStyle.paragraphInset = UIEdgeInsetsMake(10, 0, 10, 0);
	[result addObject:subtitleStyle];
	
	FTCoreTextStyle *bulletStyle = [defaultStyle copy];
	bulletStyle.name = FTCoreTextTagBullet;
	bulletStyle.bulletFont = [UIFont fontWithName:@"TimesNewRomanPSMT" size:16.f];
	bulletStyle.bulletColor = [UIColor orangeColor];
	bulletStyle.bulletCharacter = @"❧";
	[result addObject:bulletStyle];
    
    FTCoreTextStyle *italicStyle = [defaultStyle copy];
	italicStyle.name = @"italic";
	italicStyle.underlined = YES;
    italicStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:16.f];
	[result addObject:italicStyle];
	
    FTCoreTextStyle *boldStyle = [defaultStyle copy];
	boldStyle.name = @"bold";
    boldStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:16.f];
	[result addObject:boldStyle];
	
    FTCoreTextStyle *coloredStyle = [defaultStyle copy];
    [coloredStyle setName:@"colored"];
    [coloredStyle setColor:[UIColor redColor]];
	[result addObject:coloredStyle];
    
    FTCoreTextStyle *pStyle = [defaultStyle copy];
    [pStyle setName:FTCoreTextTagPage];
    [pStyle setFont:[UIFont systemFontOfSize:16.f]];
    [pStyle setTextAlignment:FTCoreTextAlignementLeft];
    [pStyle setColor:[UIColor blackColor]];
	[result addObject:pStyle];
    
    //可以自己定义特殊的标签，比如<p1>,<p2>或者<red><blue>......
    
//    FTCoreTextStyle *pStyle = [defaultStyle copy];
//    [pStyle setName:@"red"];
//    [pStyle setTextAlignment:FTCoreTextAlignementCenter];
//    [pStyle setColor:[UIColor orangeColor]];
//	[result addObject:pStyle];
    

    
    return  result;
}

- (void)coreTextView:(FTCoreTextView *)acoreTextView receivedTouchOnData:(NSDictionary *)data {
    
    CGRect frame = CGRectFromString([data objectForKey:FTCoreTextDataFrame]);
    
    if (CGRectEqualToRect(CGRectZero, frame)) return;
    
//    frame.origin.x -= 3;
//    frame.origin.y -= 1;
//    frame.size.width += 6;
//    frame.size.height += 6;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view.layer setCornerRadius:3];
    [view setBackgroundColor:[UIColor orangeColor]];
    [view setAlpha:0];
    [acoreTextView.superview addSubview:view];
    [UIView animateWithDuration:0.2 animations:^{
        [view setAlpha:0.4];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [view setAlpha:0];
        }];
    }];
    
    return;
    
    NSURL *url = [data objectForKey:FTCoreTextDataURL];
    if (!url) return;
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - View Controller Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	//add coretextview
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    coreTextView = [[FTCoreTextView alloc] initWithFrame:CGRectMake(20, 20, 280, 0)];
	coreTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // set text
    //[coreTextView setText:[self textForView:@"text"]];
    //[coreTextView setText:[self textForView:@"text2"]];
    [coreTextView setText:@"<title>helloworld</title><_image>giraffe_small</_image>用电脑时间长了，难免会遇到程序卡住，风火轮狂转不停，没有任何相应等情况。<_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon><_icon>ship</_icon>可能是由于程序冲突、缓存不足或者一些bug等情况导致，这个时候我们就需要强制退出这个程序了，\n下面有六种在Mac系统中强制退出程序的方法，大家至少应该记住一两个。<_image>giraffe</_image>"];
    
    //用UIImage绘图
    UIImage * img = [UIImage imageNamed:@"giraffe"];
    [coreTextView addImageResourcesObject:[img TransformtoSize:CGSizeMake(100, 100)] withName:@"giraffe_small"];
    [coreTextView addImageResourcesObject:img withName:@"giraffe"];
    [coreTextView addImageResourcesObject:[[UIImage imageNamed:@"ship"] TransformtoSize:CGSizeMake(20, 20)] withName:@"ship"];
    
    // set styles
    [coreTextView addStyles:[self coreTextStyle]];
    // set delegate
    [coreTextView setDelegate:self];
	
    //背景色淡灰，方便查看尺寸
	[coreTextView fitToSuggestedHeight];
    [coreTextView setBackgroundColor:[UIColor lightGrayColor]];

    [scrollView addSubview:coreTextView];
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.bounds), CGRectGetHeight(coreTextView.frame) + 40)];
    
    [self.view addSubview:scrollView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.bounds), CGRectGetHeight(coreTextView.frame) + 40)];
}


@end
