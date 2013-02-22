//
//  FTCoreTextStyle.m
//  FTCoreText
//
//  Created by Francesco Freezone <cescofry@gmail.com> on 20/07/2011.
//  Copyright 2011 Fuerte International. All rights reserved.
//

#import "FTCoreTextStyle.h"

@implementation FTCoreTextStyle

@synthesize name = _name;
@synthesize appendedCharacter = _appendedCharacter;
@synthesize font = _font;
@synthesize color = _color;
@synthesize underlined = _underlined;
@synthesize textAlignment = _textAlignment;
@synthesize paragraphInset = _paragraphInset;
@synthesize applyParagraphStyling = _applyParagraphStyling;
@synthesize leading = _leading;
@synthesize maxLineHeight = _maxLineHeight;
@synthesize minLineHeight = _minLineHeight;

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (id)init
{
	self = [super init];
	if (self) {
		self.name = @"_default";
		self.appendedCharacter = @"";
		self.font = [UIFont systemFontOfSize:12];
		self.color = [UIColor blackColor];
		self.underlined = NO;
		self.textAlignment = FTCoreTextAlignementLeft;
		self.maxLineHeight = 0;
		self.minLineHeight = 0;
		self.paragraphInset = UIEdgeInsetsZero;
		self.applyParagraphStyling = YES;
		self.leading = 0;
	}
	return self;
}

+ (id)styleWithName:(NSString *)name {
    FTCoreTextStyle *style = [[FTCoreTextStyle alloc] init];
    [style setName:name];
    return style;
}

- (void)setSpaceBetweenParagraphs:(CGFloat)spaceBetweenParagraphs
{
	UIEdgeInsets edgeInset = _paragraphInset;
	edgeInset.bottom = spaceBetweenParagraphs;
	self.paragraphInset = edgeInset;
}

- (CGFloat)spaceBetweenParagraphs
{
	return _paragraphInset.bottom;
}

- (id)copyWithZone:(NSZone *)zone
{
	FTCoreTextStyle *style = [[FTCoreTextStyle alloc] init];
	style.name = [self.name copy];
    style.appendedCharacter = [self.appendedCharacter copy];
	style.font = [UIFont fontWithName:self.font.fontName size:self.font.pointSize];
	style.color = self.color;
	style.underlined = self.isUnderLined;
    style.textAlignment = self.textAlignment;
	style.maxLineHeight = self.maxLineHeight;
	style.minLineHeight = self.minLineHeight;
	style.paragraphInset = self.paragraphInset;
	style.applyParagraphStyling = self.applyParagraphStyling;
	style.leading = self.leading;
	return style;
}

- (void)setParagraphInset:(UIEdgeInsets)paragraphInset
{
	_paragraphInset = paragraphInset;
}

#pragma GCC diagnostic warning "-Wdeprecated-declarations"

@end
