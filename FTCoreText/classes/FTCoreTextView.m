//
//  FTCoreTextView.m
//  FTCoreText
//
//  Created by Francesco Freezone <cescofry@gmail.com> on 20/07/2011.
//  Copyright 2011 Fuerte International. All rights reserved.
//

#import "FTCoreTextView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>


NSString * const FTCoreTextTagDefault = @"_default";
NSString * const FTCoreTextTagImage = @"_image";
NSString * const FTCoreTextTagBullet = @"_bullet";
NSString * const FTCoreTextTagPage = @"_page";
NSString * const FTCoreTextTagLink = @"_link";

NSString * const FTCoreTextTagIcon = @"_icon";

NSString * const FTCoreTextDataValue = @"FTCoreTextDataValue";
NSString * const FTCoreTextDataName = @"FTCoreTextDataName";
NSString * const FTCoreTextDataFrame = @"FTCoreTextDataFrame";
NSString * const FTCoreTextDataAttributes = @"FTCoreTextDataAttributes";

typedef enum {
	FTCoreTextTagTypeOpen,
	FTCoreTextTagTypeClose,
	FTCoreTextTagTypeSelfClose
} FTCoreTextTagType;

@interface FTCoreTextNode : NSObject

@property (nonatomic, assign) FTCoreTextNode	*supernode;
@property (nonatomic, strong) NSArray			*subnodes;
@property (nonatomic, copy)	  FTCoreTextStyle	*style;
@property (nonatomic, assign) NSRange			styleRange;
@property (nonatomic, assign) BOOL				isClosed;
@property (nonatomic, assign) NSInteger			startLocation;
@property (nonatomic, assign) BOOL				isLink;
@property (nonatomic, assign) BOOL				isImage;
@property (nonatomic, assign) BOOL				isBullet;
@property (nonatomic, strong) NSString			*imageName;
@property (nonatomic, assign) CGRect            imageBounds;

- (NSString *)descriptionOfTree;
- (NSString *)descriptionToRoot;
- (void)addSubnode:(FTCoreTextNode *)node;
- (void)adjustStylesAndSubstylesRangesByRange:(NSRange)insertedRange;
- (void)insertSubnode:(FTCoreTextNode *)subnode atIndex:(NSUInteger)index;
- (void)insertSubnode:(FTCoreTextNode *)subnode beforeNode:(FTCoreTextNode *)node;
- (FTCoreTextNode *)previousNode;
- (FTCoreTextNode *)nextNode;
- (NSUInteger)nodeIndex;
- (FTCoreTextNode *)subnodeAtIndex:(NSUInteger)index;

@end

@implementation FTCoreTextNode

@synthesize supernode = _supernode;
@synthesize subnodes = _subnodes;
@synthesize style = _style;
@synthesize styleRange = _styleRange;
@synthesize isClosed = _isClosed;
@synthesize isLink = _isLink;
@synthesize isImage = _isImage;
@synthesize startLocation = _startLocation;
@synthesize isBullet = _isBullet;
@synthesize imageName = _imageName;
@synthesize imageBounds = _imageBounds;

- (NSArray *)subnodes
{
	if (_subnodes == nil) {
		_subnodes = [NSMutableArray new];
	}
	return _subnodes;
}

- (void)addSubnode:(FTCoreTextNode *)node
{
	[self insertSubnode:node atIndex:[_subnodes count]];
}

- (void)insertSubnode:(FTCoreTextNode *)subnode atIndex:(NSUInteger)index
{
	subnode.supernode = self;
	
	NSMutableArray *subnodes = (NSMutableArray *)self.subnodes;
	if (index <= [_subnodes count]) {
		[subnodes insertObject:subnode atIndex:index];
	}
	else {
		[subnodes addObject:subnode];
	}
}

- (void)insertSubnode:(FTCoreTextNode *)subnode beforeNode:(FTCoreTextNode *)node
{
	NSInteger existingNodeIndex = [_subnodes indexOfObject:node];
	if (existingNodeIndex == NSNotFound) {
		[self addSubnode:subnode];
	}
	else {
		[self insertSubnode:subnode atIndex:existingNodeIndex];
	}
}

- (NSInteger)numberOfParents
{
	NSInteger returnedValue = 0;
	FTCoreTextNode *node = self.supernode;
	while (node) {
		returnedValue++;
		node = node.supernode;
	}
	return returnedValue;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@\t-\t%@ - \t%@", [super description], _style.name, NSStringFromRange(_styleRange)];
}

- (NSString *)descriptionToRoot
{
	NSMutableString *description = [NSMutableString stringWithString:@"\n\n"];
	
	FTCoreTextNode *node = self;
	do {
		[description insertString:[NSString stringWithFormat:@"%@",[self description]] atIndex:0];
		
		for (int i = 0; i < [self numberOfParents]; i++) {
			[description insertString:@"\t" atIndex:0];
		}
		[description insertString:@"\n" atIndex:0];
		node = node.supernode;
		
	} while (node);
	
	return description;
}

- (NSString *)descriptionOfTree
{
	NSMutableString *description = [NSMutableString string];
	for (int i = 0; i < [self numberOfParents]; i++) {
		[description insertString:@"\t" atIndex:0];
	}
	[description appendFormat:@"%@\n", [self description]];
	for (FTCoreTextNode *node in _subnodes) {
		[description appendString:[node descriptionOfTree]];
	}
	return description;
}

- (NSArray *)_allSubnodes
{
	NSMutableArray *subnodes = [NSMutableArray new];
	for (FTCoreTextNode *node in _subnodes) {
		[subnodes addObject:node];
		if (node.subnodes) [subnodes addObjectsFromArray:[node _allSubnodes]];
	}
	
	return subnodes;
}

//return an array of nodes starting with the current and recursively adding all its child nodes
- (NSArray *)allSubnodes
{
	NSArray *allSubnodes = [[self _allSubnodes] copy];
    
	NSMutableArray *returnedArray = [NSMutableArray arrayWithObject:self];
	[returnedArray addObjectsFromArray:allSubnodes];
    
	return returnedArray;
}

- (void)adjustStylesAndSubstylesRangesByRange:(NSRange)insertedRange
{
	NSRange range = self.styleRange;
	if (range.length + range.location > insertedRange.location) {
		range.location += insertedRange.length;
	}
	self.styleRange = range;
	
	for (FTCoreTextNode *node in _subnodes) {
		[node adjustStylesAndSubstylesRangesByRange:insertedRange];
	}
}

- (NSUInteger)nodeIndex
{
	return [_supernode.subnodes indexOfObject:self];
}

- (FTCoreTextNode *)subnodeAtIndex:(NSUInteger)index
{
	if (index < [_subnodes count]) {
		return [_subnodes objectAtIndex:index];
	}
	return nil;
}

- (FTCoreTextNode *)previousNode
{
	NSUInteger index = [self nodeIndex];
	if (index != NSNotFound) {
		return [_supernode subnodeAtIndex:index - 1];
	}
	return nil;
}

- (FTCoreTextNode *)nextNode
{
	NSUInteger index = [self nodeIndex];
	if (index != NSNotFound) {
		return [_supernode subnodeAtIndex:index + 1];
	}
	return nil;	
}

@end

#pragma mark --
#pragma mark --以下是FTCoreTextView
#pragma mark --
////////////////////////////////////////////////////////////////////
//
// FTCoreTextView
//
////////////////////////////////////////////////////////////////////

@interface FTCoreTextView ()
{
    NSDictionary * _dataDictionary;
    CTFramesetterRef _framesetter;
    FTCoreTextNode * _rootNode;
    CGPoint _longPressPoint;
    UILongPressGestureRecognizer * _longPressGestureRecognizer;
}

CTFontRef CTFontCreateFromUIFont(UIFont *font);
UITextAlignment UITextAlignmentFromCoreTextAlignment(FTCoreTextAlignement alignment);
NSInteger rangeSort(NSString *range1, NSString *range2, void *context);

- (void)updateFramesetterIfNeeded;
- (void)processText;

- (void)drawImages;
- (void)doInit;
- (void)didMakeChanges;
- (NSString *)defaultTagNameForKey:(NSString *)tagKey;

-(void)longPress:(UILongPressGestureRecognizer *)recognizer;

@end

@implementation FTCoreTextView

@synthesize text = _text;
@synthesize processedString = _processedString;
@synthesize path = _path;
@synthesize URLs = _URLs;
@synthesize images = _images;
@synthesize delegate = _delegate;
@synthesize shadowColor = _shadowColor;
@synthesize shadowOffset = _shadowOffset;
@synthesize attributedString = _attributedString;
@synthesize imageResources = _imageResources;
@synthesize enableContextMenu=_enableContextMenu;

#pragma mark - Tools methods

NSInteger rangeSort(NSString *range1, NSString *range2, void *context)
{
    NSRange r1 = NSRangeFromString(range1);
	NSRange r2 = NSRangeFromString(range2);
	
    if (r1.location < r2.location)
        return NSOrderedAscending;
    else if (r1.location > r2.location)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

CTFontRef CTFontCreateFromUIFont(UIFont *font)
{
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, 
                                            font.pointSize, 
                                            NULL);
    return ctFont;
}

UITextAlignment UITextAlignmentFromCoreTextAlignment(FTCoreTextAlignement alignment)
{
	switch (alignment) {
		case FTCoreTextAlignementCenter:
			return UITextAlignmentCenter;
			break;
		case FTCoreTextAlignementRight:
			return UITextAlignmentRight;
			break;			
		default:
			return UITextAlignmentLeft;
			break;
	}
}

#pragma mark - FTCoreTextView business
#pragma mark -

- (void)changeDefaultTag:(NSString *)coreTextTag toTag:(NSString *)newDefaultTag
{
	if ([_defaultsTags objectForKey:coreTextTag] == nil) {
		[NSException raise:NSInvalidArgumentException format:@"%@ is not a default tag of FTCoreTextView. Use the constant FTCoreTextTag constants.", coreTextTag];
	}
	else {
		[_defaultsTags setObject:newDefaultTag forKey:coreTextTag];
	}
}

- (NSString *)defaultTagNameForKey:(NSString *)tagKey
{
	return [_defaultsTags objectForKey:tagKey];
}

- (void)didMakeChanges
{
	_coreTextViewFlags.updatedAttrString = NO;
	_coreTextViewFlags.updatedFramesetter = NO;
}

#pragma mark - UI related

- (NSDictionary *)dataForPoint:(CGPoint)point
{
	NSMutableDictionary *returnedDict = [NSMutableDictionary dictionary];
	
	CGMutablePathRef mainPath = CGPathCreateMutable();
    if (!_path) {
        CGPathAddRect(mainPath, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));  
    }
    else {
        CGPathAddPath(mainPath, NULL, _path);
    }
	
    CTFrameRef ctframe = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), mainPath, NULL);
    CGPathRelease(mainPath);
	
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(ctframe);
    NSInteger lineCount = [lines count];
    CGPoint origins[lineCount];
    
    if (lineCount != 0) {
		
		CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), origins);
		
		for (int i = 0; i < lineCount; i++) {
			CGPoint baselineOrigin = origins[i];
			//the view is inverted, the y origin of the baseline is upside down
			baselineOrigin.y = CGRectGetHeight(self.frame) - baselineOrigin.y;
			
			CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
            CFRange lineRange = CTLineGetStringRange(line);
            
			CGFloat ascent, descent;
			CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
			
			CGRect lineFrame = CGRectMake(baselineOrigin.x, baselineOrigin.y - ascent, lineWidth, ascent + descent);
			
			if (CGRectContainsPoint(lineFrame, point)) {
				//we look if the position of the touch is correct on the line
				
				CFIndex index = CTLineGetStringIndexForPosition(line, point);

				NSArray *urlsKeys = [_URLs allKeys];
				
				for (NSString *key in urlsKeys) {
					NSRange range = NSRangeFromString(key);
					if (index >= range.location && index < range.location + range.length) {
						NSURL *url = [_URLs objectForKey:key];
						if (url) {
                            [returnedDict setObject:url forKey:FTCoreTextDataValue];
                            [returnedDict setObject:FTCoreTextTagLink forKey:FTCoreTextDataName];
                        }
						break;
					}
				}
                
                //frame
                CFArrayRef runs = CTLineGetGlyphRuns(line);
                for(CFIndex j = 0; j < CFArrayGetCount(runs); j++) {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                    NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
                    
                    NSString *name = [attributes objectForKey:FTCoreTextDataName];
                    if (![name isEqualToString:FTCoreTextTagLink]) continue;
                    
                    [returnedDict setObject:attributes forKey:FTCoreTextDataAttributes];
                    
                    CGRect runBounds;
                    runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //8
                    runBounds.size.height = ascent + descent;
                    
                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //9
                    runBounds.origin.x = baselineOrigin.x  + xOffset + 0;
                    runBounds.origin.y = baselineOrigin.y  - ascent;
                    
                    [returnedDict setObject:NSStringFromCGRect(runBounds) forKey:FTCoreTextDataFrame];
                    
                }
            
            
            }
            else {
                //V04 by sharetop
                //如果没有找到URL，有可能是图像
                //NSLog(@"--images count=%d,line count=%ld,line %ld--%ld",_images.count,CTLineGetGlyphCount(line),lineRange.location,lineRange.length);
                for(id runObj in (__bridge NSArray*)CTLineGetGlyphRuns(line)){
                    CTRunRef run = (__bridge CTRunRef)(runObj);
                    CFDictionaryRef runAttributes = CTRunGetAttributes(run);
                    NSString * tagName = (__bridge NSString *)(CFDictionaryGetValue(runAttributes,(__bridge const void *)(FTCoreTextDataName)));
                    if([tagName isEqualToString:FTCoreTextTagImage]){
                        for(FTCoreTextNode * imageNode in _images){
                            if(lineRange.location>imageNode.styleRange.location &&  CGRectContainsPoint(imageNode.imageBounds, point)){
                                
                                [returnedDict setObject:imageNode.imageName forKey:FTCoreTextDataValue];
                                [returnedDict setObject:FTCoreTextTagImage forKey:FTCoreTextDataName];
                                [returnedDict setObject:NSStringFromCGRect(imageNode.imageBounds) forKey:FTCoreTextDataFrame];
                                [returnedDict setObject:(__bridge id)(runAttributes) forKey:FTCoreTextDataAttributes];
                                
                                break;
                            }
                        }
                    }
                    
                }
                
            }
            
			if (returnedDict.count > 0) break;
		}
        
        //V0.4 by sharetop
        if(returnedDict.count==0){
            [returnedDict setObject:FTCoreTextTagDefault forKey:FTCoreTextDataName];
        }
	}
	
	CFRelease(ctframe);
	
	return returnedDict;
}


- (void)updateFramesetterIfNeeded
{
    if (!_coreTextViewFlags.updatedAttrString) {
		if (_framesetter != NULL) CFRelease(_framesetter);
		_framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedString);
		_coreTextViewFlags.updatedAttrString = YES;
    }
}

/*!
 * @abstract get the supposed size of the drawn text
 *
 */

- (CGSize)suggestedSizeConstrainedToSize:(CGSize)size
{
	CGSize suggestedSize;
	{
		[self updateFramesetterIfNeeded];
		if (_framesetter == NULL) {
			return CGSizeZero;
		}
		suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, 0), NULL, size, NULL);
		suggestedSize = CGSizeMake(ceilf(suggestedSize.width), ceilf(suggestedSize.height));
	}
    return suggestedSize;
}

/*!
 * @abstract handy method to fit to the suggested height in one call
 *
 */

- (void)fitToSuggestedHeight
{
	CGSize suggestedSize = [self suggestedSizeConstrainedToSize:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)];
	CGRect viewFrame = self.frame;
	viewFrame.size.height = suggestedSize.height;
	self.frame = viewFrame;
}

#pragma mark - Text processing

/*!
 * @abstract remove the tags from the text and create a tree representation of the text
 *
 */

- (void)processText
{    
    if (!_text || [_text length] == 0) return;
	
	[_URLs removeAllObjects];
    [_images removeAllObjects];
	
	FTCoreTextNode *rootNode = [FTCoreTextNode new];
	rootNode.style = [_styles objectForKey:[self defaultTagNameForKey:FTCoreTextTagDefault]];
	
	FTCoreTextNode *currentSupernode = rootNode;
	
	NSMutableString *processedString = [NSMutableString stringWithString:_text];
	
	BOOL finished = NO;
	NSRange remainingRange = NSMakeRange(0, [processedString length]);
	
	NSString *regEx = @"<(/){0,1}.*?( /){0,1}>";
		
	while (!finished) {
		
		NSRange tagRange;
        {
			tagRange = [processedString rangeOfString:regEx options:NSRegularExpressionSearch range:remainingRange];
		}
		
		if (tagRange.location == NSNotFound) {
			if (currentSupernode != rootNode && !currentSupernode.isClosed) {
				NSLog(@"FTCoreTextView :%@ - Couldn't parse text because tag '%@' at position %d is not closed - aborting rendering", self, currentSupernode.style.name, currentSupernode.startLocation);
				return;
			}
			finished = YES;
            continue;
		}
        
        NSString *fullTag = [processedString substringWithRange:tagRange];
        FTCoreTextTagType tagType;
        
        if ([fullTag rangeOfString:@"</"].location == 0) {
            tagType = FTCoreTextTagTypeClose;
        }
        else if ([fullTag rangeOfString:@"/>"].location == NSNotFound && [fullTag rangeOfString:@" />"].location == NSNotFound) {
            tagType = FTCoreTextTagTypeOpen;
        }
        else {
            tagType = FTCoreTextTagTypeSelfClose;
        }
        
		NSArray *tagsComponents = [fullTag componentsSeparatedByString:@" "];
		NSString *tagName = (tagsComponents.count > 0) ? [tagsComponents objectAtIndex:0] : fullTag;
        tagName = [tagName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"< />"]];
		
        FTCoreTextStyle *style = [_styles objectForKey:tagName];
        
        if (style == nil) {
            style = [_styles objectForKey:[self defaultTagNameForKey:FTCoreTextTagDefault]];
            NSLog(@"FTCoreTextView :%@ - Couldn't find style for tag '%@'", self, tagName);
        }
        
        switch (tagType) {
            case FTCoreTextTagTypeOpen:
            {
                if (currentSupernode.isLink || currentSupernode.isImage) {
                    NSString *predefinedTag = nil;
                    if (currentSupernode.isLink) predefinedTag = [self defaultTagNameForKey:FTCoreTextTagLink];
                    else if (currentSupernode.isImage) predefinedTag = [self defaultTagNameForKey:FTCoreTextTagImage];
                    NSLog(@"FTCoreTextView :%@ - You can't open a new tag inside a '%@' tag - aborting rendering", self, predefinedTag);
                    return;
                }
                
                FTCoreTextNode *newNode = [FTCoreTextNode new];
                newNode.style = style;
                newNode.startLocation = tagRange.location;
                
                if ([tagName isEqualToString:[self defaultTagNameForKey:FTCoreTextTagLink]]) {
                    newNode.isLink = YES;
                }
                else if ([tagName isEqualToString:[self defaultTagNameForKey:FTCoreTextTagBullet]]) {
                    newNode.isBullet = YES;
                    
                    NSString *appendedString = [NSString stringWithFormat:@"%@\t", newNode.style.bulletCharacter];
                    
                    [processedString insertString:appendedString atIndex:tagRange.location + tagRange.length];
                    
                    //bullet styling
                    FTCoreTextStyle *bulletStyle = [FTCoreTextStyle new];
                    bulletStyle.name = @"_FTBulletStyle";
                    bulletStyle.font = newNode.style.bulletFont;
                    bulletStyle.color = newNode.style.bulletColor;
                    bulletStyle.applyParagraphStyling = NO;
                    bulletStyle.paragraphInset = UIEdgeInsetsMake(0, 0, 0, newNode.style.paragraphInset.left);
                    
                    FTCoreTextNode *bulletNode = [FTCoreTextNode new];
                    bulletNode.style = bulletStyle;
                    bulletNode.styleRange = NSMakeRange(tagRange.location, [appendedString length]);
                    
                    [newNode addSubnode:bulletNode];
                }
                else if ([tagName isEqualToString:[self defaultTagNameForKey:FTCoreTextTagImage]] || [tagName isEqualToString:[self defaultTagNameForKey:FTCoreTextTagIcon]]) {
                    newNode.isImage = YES;
                }
                
                [processedString replaceCharactersInRange:tagRange withString:@""];
                
                [currentSupernode addSubnode:newNode];
                
                currentSupernode = newNode;
                
                remainingRange.location = tagRange.location;
                remainingRange.length = [processedString length] - tagRange.location;
            }
                break;
            case FTCoreTextTagTypeClose:
            {
                if ((![currentSupernode.style.name isEqualToString:[self defaultTagNameForKey:FTCoreTextTagDefault]] && ![currentSupernode.style.name isEqualToString:tagName]) ) {
                    NSLog(@"FTCoreTextView :%@ - Closing tag '%@' at range %@ doesn't match open tag '%@' - aborting rendering", self, fullTag, NSStringFromRange(tagRange), currentSupernode.style.name);
                    return;
                }
                
                currentSupernode.isClosed = YES;
                
                if (currentSupernode.isLink) {
                    //replace active string with url text
                    
                    NSRange elementContentRange = NSMakeRange(currentSupernode.startLocation, tagRange.location - currentSupernode.startLocation);
                    NSString *elementContent = [processedString substringWithRange:elementContentRange];
                    NSRange pipeRange = [elementContent rangeOfString:@"|"];
                    NSString *urlString = nil;
                    NSString *urlDescription = nil;
                    if (pipeRange.location != NSNotFound) {
                        urlString = [elementContent substringToIndex:pipeRange.location];
                        urlDescription = [elementContent substringFromIndex:pipeRange.location + 1];
                    }
                    
                    [processedString replaceCharactersInRange:NSMakeRange(elementContentRange.location, elementContentRange.length + tagRange.length) withString:urlDescription];
                    if (![urlString hasPrefix:@"http://"]) {
                        urlString = [NSString stringWithFormat:@"http://%@", urlString];
                    }
                    NSURL *url = [NSURL URLWithString:urlString];
                    NSRange urlDescriptionRange = NSMakeRange(elementContentRange.location, [urlDescription length]);
                    [_URLs setObject:url forKey:NSStringFromRange(urlDescriptionRange)];
                    
                    currentSupernode.styleRange = urlDescriptionRange;
                }
                else if (currentSupernode.isImage) {
                    //replace active string with emptySpace
					
                    NSRange elementContentRange = NSMakeRange(currentSupernode.startLocation, tagRange.location - currentSupernode.startLocation);
                    NSString *elementContent = [processedString substringWithRange:elementContentRange];
                    
                    //V0.2 by sharetop
                    //如果从imageResources中获取不到图像资源，才从bundle中加载
                    UIImage *img = (UIImage*)[_imageResources objectForKey:elementContent];
                    if(!img)
                        img = [UIImage imageNamed:elementContent];
                    
                    if (img) {
                        //V0.1 by sharetop
                        //多让出一行，则解决图片在文字最后面导致无法显示的问题
                        //V0.3 by sharetop
                        //表情图，用-来占位，不换行
                        
                        currentSupernode.style.color=[UIColor clearColor];
                        NSString *lines =@"\n-\n";
                        float leading = img.size.height;
                        
                        if([tagName isEqualToString:FTCoreTextTagIcon]){
                            NSString *ch=@"-";
                            //根据_emoticon对应的字体大小，准备出足够的占位符
                            NSMutableString *str=[[NSMutableString alloc]init];
                            CGFloat spaceWidth = [ch sizeWithFont:style.font].width;
                            int count = (int)ceil((img.size.height/spaceWidth));
                            for (int i=0; i<count; ++i) {
                                [str appendString:ch];
                            }
                            if(str.length>1)
                                [str replaceCharactersInRange:NSMakeRange(str.length-1, 1) withString:@" "];
                            lines=str;
                        }
                        
                        currentSupernode.style.leading = leading;
                        
                        currentSupernode.imageName = elementContent;
                        [processedString replaceCharactersInRange:NSMakeRange(elementContentRange.location, elementContentRange.length + tagRange.length) withString:lines];
                        
                        [_images addObject:currentSupernode];
                        currentSupernode.styleRange = NSMakeRange(elementContentRange.location, [lines length]);
						
                    }
                    else {
                        NSLog(@"FTCoreTextView :%@ - Couldn't find image '%@' in main bundle", self, elementContent);
                        [processedString replaceCharactersInRange:tagRange withString:@""];
                    }
                }
                else {
                    currentSupernode.styleRange = NSMakeRange(currentSupernode.startLocation, tagRange.location - currentSupernode.startLocation);
                    [processedString replaceCharactersInRange:tagRange withString:@""];
                }
                
                if ([currentSupernode.style.appendedCharacter length] > 0) {
                    [processedString insertString:currentSupernode.style.appendedCharacter atIndex:currentSupernode.styleRange.location + currentSupernode.styleRange.length];
                    NSRange newStyleRange = currentSupernode.styleRange;
                    newStyleRange.length += [currentSupernode.style.appendedCharacter length];
                    currentSupernode.styleRange = newStyleRange;							
                }
                
                if (style.paragraphInset.top > 0) {
                    if (![style.name isEqualToString:[self defaultTagNameForKey:FTCoreTextTagBullet]] ||  [[currentSupernode previousNode].style.name isEqualToString:[self defaultTagNameForKey:FTCoreTextTagBullet]]) {
                        
                        //fix: add a new line for each new line and set its height to 'top' value
                        [processedString insertString:@"\n" atIndex:currentSupernode.startLocation];
                        NSRange topSpacingStyleRange = NSMakeRange(currentSupernode.startLocation, [@"\n" length]);
                        FTCoreTextStyle *topSpacingStyle = [[FTCoreTextStyle alloc] init];
                        topSpacingStyle.name = [NSString stringWithFormat:@"_FTTopSpacingStyle_%@", currentSupernode.style.name];
                        topSpacingStyle.minLineHeight = currentSupernode.style.paragraphInset.top;
                        topSpacingStyle.maxLineHeight = currentSupernode.style.paragraphInset.top;
                        FTCoreTextNode *topSpacingNode = [[FTCoreTextNode alloc] init];
                        topSpacingNode.style = topSpacingStyle;
                        
                        topSpacingNode.styleRange = topSpacingStyleRange;
                        
                        [currentSupernode.supernode insertSubnode:topSpacingNode beforeNode:currentSupernode];
                        
                        [currentSupernode adjustStylesAndSubstylesRangesByRange:topSpacingStyleRange];
                    }
                }
                
                remainingRange.location = currentSupernode.styleRange.location + currentSupernode.styleRange.length;
                remainingRange.length = [processedString length] - remainingRange.location;
                
                currentSupernode = currentSupernode.supernode;
            }
                break;
            case FTCoreTextTagTypeSelfClose:
            {
                FTCoreTextNode *newNode = [FTCoreTextNode new];
                newNode.style = style;
                [processedString replaceCharactersInRange:tagRange withString:newNode.style.appendedCharacter];
                newNode.styleRange = NSMakeRange(tagRange.location, [newNode.style.appendedCharacter length]);
                [currentSupernode addSubnode:newNode];
                
                remainingRange.location = tagRange.location;
                remainingRange.length = [processedString length] - tagRange.location;
            }
                break;
        }
	}	
	
	rootNode.styleRange = NSMakeRange(0, [processedString length]);
	
	_rootNode = rootNode;
	_processedString = processedString;
}

/*!
 * @abstract Remove all the tags and return a clean text to be used
 *
 */

+ (NSString *)stripTagsForString:(NSString *)string
{
    FTCoreTextView *instance = [[FTCoreTextView alloc] initWithFrame:CGRectZero];
    [instance setText:string];
    [instance processText];
    NSString *result = [instance.processedString copy];
    return result;
}

#pragma mark Styling

- (void)addStyle:(FTCoreTextStyle *)style
{
    [_styles setValue:style forKey:style.name];
	[self didMakeChanges];
    if ([self superview]) [self setNeedsDisplay];
}

- (void)addStyles:(NSArray *)styles
{
	for (FTCoreTextStyle *style in styles) {
		[_styles setValue:style forKey:style.name];
	}
	[self didMakeChanges];
    if ([self superview]) [self setNeedsDisplay];
}

- (void)removeAllStyles
{
	[_styles removeAllObjects];
	[self didMakeChanges];
    if ([self superview]) [self setNeedsDisplay];
}

- (void)applyStyle:(FTCoreTextStyle *)style inRange:(NSRange)styleRange onString:(NSMutableAttributedString **)attributedString
{
    [*attributedString addAttribute:(id)FTCoreTextDataName
							  value:(id)style.name
							  range:styleRange];
    
	[*attributedString addAttribute:(id)kCTForegroundColorAttributeName
							  value:(id)style.color.CGColor
							  range:styleRange];
	
	if (style.isUnderLined) {
		NSNumber *underline = [NSNumber numberWithInt:kCTUnderlineStyleSingle];
		[*attributedString addAttribute:(id)kCTUnderlineStyleAttributeName
								  value:(id)underline
								  range:styleRange];
	}	
	
	CTFontRef ctFont = CTFontCreateFromUIFont(style.font);
	
	[*attributedString addAttribute:(id)kCTFontAttributeName
							  value:(__bridge id)ctFont
							  range:styleRange];
	CFRelease(ctFont);
	
	CTTextAlignment alignment = style.textAlignment;
	CGFloat maxLineHeight = style.maxLineHeight;
	CGFloat minLineHeight = style.minLineHeight;
	
    
    //V0.2 by sharetop
    //如果是图片，用段前距不用行距
    CGFloat paragraphLeading =([style.name isEqualToString:FTCoreTextTagImage] ||[style.name isEqualToString:FTCoreTextTagIcon])
                                    ?0.f:style.leading;
	CGFloat paragraphSpacingBefore =([style.name isEqualToString:FTCoreTextTagImage])?style.leading:style.paragraphInset.top;
	
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping; //kCTLineBreakByCharWrapping;  //kCTLineBreakByWordWrapping;
    
	CGFloat paragraphSpacingAfter = style.paragraphInset.bottom;
	CGFloat paragraphFirstLineHeadIntent = style.paragraphInset.left;
	CGFloat paragraphHeadIntent = style.paragraphInset.left;
	CGFloat paragraphTailIntent = style.paragraphInset.right;
	
	CFIndex numberOfSettings = 11;
	CGFloat tabSpacing = 28.f;
	
	BOOL applyParagraphStyling = style.applyParagraphStyling;
	
	if ([style.name isEqualToString:[self defaultTagNameForKey:FTCoreTextTagBullet]]) {
		applyParagraphStyling = YES;
	}
	else if ([style.name isEqualToString:@"_FTBulletStyle"]) {
		applyParagraphStyling = YES;
		numberOfSettings++;
		tabSpacing = style.paragraphInset.right;
		paragraphSpacingBefore = 0;
		paragraphSpacingAfter = 0;
		paragraphFirstLineHeadIntent = 0;
		paragraphTailIntent = 0;
	}
	else if ([style.name hasPrefix:@"_FTTopSpacingStyle"]) {
		[*attributedString removeAttribute:(id)kCTParagraphStyleAttributeName range:styleRange];
	}
	
	if (applyParagraphStyling) {
		
		CTTextTabRef tabArray[] = { CTTextTabCreate(0, tabSpacing, NULL) };
		
		CFArrayRef tabStops = CFArrayCreate( kCFAllocatorDefault, (const void**) tabArray, 1, &kCFTypeArrayCallBacks );
		CFRelease(tabArray[0]);
		
		CTParagraphStyleSetting settings[] = {
			{kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
			{kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight},
			{kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight},
			{kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore},
			{kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacingAfter},
			{kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &paragraphFirstLineHeadIntent},
			{kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &paragraphHeadIntent},
			{kCTParagraphStyleSpecifierTailIndent, sizeof(CGFloat), &paragraphTailIntent},
            {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &paragraphLeading},
			{kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &paragraphLeading},
            {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode},
			{kCTParagraphStyleSpecifierTabStops, sizeof(CFArrayRef), &tabStops}//always at the end
		};
		
		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, numberOfSettings);
		[*attributedString addAttribute:(id)kCTParagraphStyleAttributeName
								  value:(__bridge id)paragraphStyle 
								  range:styleRange];
		CFRelease(tabStops);
		CFRelease(paragraphStyle);
	}
}

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andAttributedString:nil];
}

- (id)initWithFrame:(CGRect)frame andAttributedString:(NSAttributedString *)attributedString
{
	self = [super initWithFrame:frame];
	if (self) {
		_attributedString = attributedString;
		[self doInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit
{
	// Initialization code
	_framesetter = NULL;
	_styles = [[NSMutableDictionary alloc] init];
	_URLs = [[NSMutableDictionary alloc] init];
    _images = [[NSMutableArray alloc] init];
    
    _imageResources = [[NSMutableDictionary alloc]init];
    _enableContextMenu = NO;
    
    _longPressPoint=CGPointZero;
    
	self.opaque = NO;
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
	[self setUserInteractionEnabled:YES];
	
	FTCoreTextStyle *defaultStyle = [FTCoreTextStyle styleWithName:FTCoreTextTagDefault];
	[self addStyle:defaultStyle];	
	
	FTCoreTextStyle *linksStyle = [defaultStyle copy];
	linksStyle.color = [UIColor blueColor];
	linksStyle.name = FTCoreTextTagLink;
	[_styles setValue:linksStyle forKey:linksStyle.name];
	
	_defaultsTags = [NSMutableDictionary dictionaryWithObjectsAndKeys:FTCoreTextTagDefault, FTCoreTextTagDefault,
					  FTCoreTextTagLink, FTCoreTextTagLink,
					  FTCoreTextTagImage, FTCoreTextTagImage,
                      FTCoreTextTagIcon, FTCoreTextTagIcon,
					  FTCoreTextTagPage, FTCoreTextTagPage,
					  FTCoreTextTagBullet, FTCoreTextTagBullet,
					  nil];
    
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    _longPressGestureRecognizer.minimumPressDuration = 1.0;
}

- (void)dealloc
{
	if (_framesetter) CFRelease(_framesetter);
	if (_path) CGPathRelease(_path);
    if (_imageResources) [_imageResources removeAllObjects];
}

#pragma mark - Custom Setters

-(void)setEnableContextMenu:(BOOL)enableContextMenu
{
    if(enableContextMenu){
        [self addGestureRecognizer:_longPressGestureRecognizer];
    }
    else {
        [self removeGestureRecognizer:_longPressGestureRecognizer];
    }
    _enableContextMenu=enableContextMenu;
}
-(BOOL)enableContextMenu
{
    return _enableContextMenu;
}
- (void)setText:(NSString *)text
{
    _text = text;
	_coreTextViewFlags.textChangesMade = YES;
	[self didMakeChanges];
    if ([self superview]) [self setNeedsDisplay];
}

- (void)setPath:(CGPathRef)path
{
    _path = CGPathRetain(path);
	[self didMakeChanges];
    if ([self superview]) [self setNeedsDisplay];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
	_shadowColor = shadowColor;
	if ([self superview]) [self setNeedsDisplay];
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
	_shadowOffset = shadowOffset;
	if ([self superview]) [self setNeedsDisplay];
}

- (void)addImageResourcesObject:(UIImage *)object withName:(NSString *)imageName
{
    if(_imageResources){
        [_imageResources setObject:object forKey:imageName];
    }
}

#pragma mark - Custom Getters

- (NSArray *)styles
{
	return [_styles allValues];
}

- (NSAttributedString *)attributedString
{
	if (!_coreTextViewFlags.updatedAttrString) {
		_coreTextViewFlags.updatedAttrString = YES;
		
		if (_processedString == nil || _coreTextViewFlags.textChangesMade) {
			_coreTextViewFlags.textChangesMade = NO;
			[self processText];
		}
		
		if (_processedString) {
			
			NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_processedString];
			
			for (FTCoreTextNode *node in [_rootNode allSubnodes]) {
				[self applyStyle:node.style inRange:node.styleRange onString:&string];
			}
			
			_attributedString = string;
		}
	}
    NSLog(@"%s:_attributedString is %@",__func__,_attributedString);
	return _attributedString;
}

#pragma mark - View lifecycle

/*!
 * @abstract draw the actual coretext on the context
 *
 */

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self.backgroundColor setFill];
	CGContextFillRect(context, rect);
	
    {
		[self updateFramesetterIfNeeded];
		
		CGMutablePathRef mainPath = CGPathCreateMutable();
		
		if (!_path) {
			CGPathAddRect(mainPath, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));  
		}
		else {
			CGPathAddPath(mainPath, NULL, _path);
		}
		
		CTFrameRef drawFrame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), mainPath, NULL);
		
		if (drawFrame == NULL) {
			NSLog(@"FTCoreText unable to render: %@", self.processedString);
		}
		else {
			//draw images
			if ([_images count] > 0) [self drawImages];
			
			if (_shadowColor) {
				CGContextSetShadowWithColor(context, _shadowOffset, 0.f, _shadowColor.CGColor);
			}
			
			CGContextSetTextMatrix(context, CGAffineTransformIdentity);
			CGContextTranslateCTM(context, 0, self.bounds.size.height);
			CGContextScaleCTM(context, 1.0, -1.0);
			// draw text
			CTFrameDraw(drawFrame, context);
		}
		// cleanup
		if (drawFrame) CFRelease(drawFrame);
		CGPathRelease(mainPath);
	}
}

- (void)drawImages
{    
	CGMutablePathRef mainPath = CGPathCreateMutable();
    if (!_path) {
        CGPathAddRect(mainPath, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));  
    }
    else {
        CGPathAddPath(mainPath, NULL, _path);
    }
	
    CTFrameRef ctframe = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), mainPath, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(ctframe);
    NSInteger lineCount = [lines count];
    CGPoint origins[lineCount];
	
	CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), origins);
	
	FTCoreTextNode *imageNode = [_images objectAtIndex:0];
    if(!imageNode) return;
	
	for (int i = 0; i < lineCount; i++) {
		CGPoint baselineOrigin = origins[i];
		//the view is inverted, the y origin of the baseline is upside down
		baselineOrigin.y = CGRectGetHeight(self.frame) - baselineOrigin.y;
		
		CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
		CFRange lineRange = CTLineGetStringRange(line);
		
        //V0.3 by sharetop
        //按图元来绘制
        for( id runObj in (__bridge NSArray*) CTLineGetGlyphRuns(line)){
            CTRunRef run = (__bridge CTRunRef)runObj;
            CFRange runRange = CTRunGetStringRange(run);
            
            CFDictionaryRef runAttributes = CTRunGetAttributes(run);
            NSString * tagName = (__bridge NSString *)(CFDictionaryGetValue(runAttributes,(__bridge const void *)(FTCoreTextDataName)));
            
            if([tagName isEqualToString:FTCoreTextTagImage] && lineRange.location>imageNode.styleRange.location){
                //绘制图像
                CGFloat ascent, descent;
                CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
                
                CGRect lineFrame = CGRectMake(baselineOrigin.x, baselineOrigin.y - ascent, lineWidth, ascent + descent);
                
                CTTextAlignment alignment = imageNode.style.textAlignment;
                
                //V0.2 by sharetop
                //如果从imageResources中获取不到图像资源，才从bundle中加载
                UIImage *img = (UIImage*)[_imageResources objectForKey:imageNode.imageName];
                if(!img)
                    img = [UIImage imageNamed:imageNode.imageName];
                
                if (img) {
                    int x = 0;
                    if (alignment == kCTRightTextAlignment) x = (self.frame.size.width - img.size.width);
                    if (alignment == kCTCenterTextAlignment) x = ((self.frame.size.width - img.size.width) / 2);
                    
                    CGRect frame = CGRectMake(x, (lineFrame.origin.y - img.size.height), img.size.width, img.size.height);
                    
                    // adjusting frame
                    
                    UIEdgeInsets insets = imageNode.style.paragraphInset;
                    if (alignment != kCTCenterTextAlignment) frame.origin.x = (alignment == kCTLeftTextAlignment)? insets.left : (self.frame.size.width - img.size.width - insets.right);
                    frame.origin.y += insets.top;
                    frame.size.width = ((insets.left + insets.right + img.size.width ) > self.frame.size.width)? self.frame.size.width : img.size.width;
                    
                    [img drawInRect:CGRectIntegral(frame)];
                    imageNode.imageBounds=frame;
                }
                
                NSInteger imageNodeIndex = [_images indexOfObject:imageNode];
                if (imageNodeIndex < [_images count] - 1) {
                    imageNode = [_images objectAtIndex:imageNodeIndex + 1];
                }
                else {
                    break;
                }
            }
            else if([tagName isEqualToString:FTCoreTextTagIcon] && runRange.location<=imageNode.styleRange.location && runRange.location+runRange.length>imageNode.styleRange.location){
                //绘制图标
                CGRect imgBounds;
                CGFloat ascent, descent;
                imgBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                imgBounds.size.height = ascent + descent;
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                imgBounds.origin.x = baselineOrigin.x  + xOffset;
                imgBounds.origin.y = baselineOrigin.y;
                imgBounds.origin.y -= (ascent+descent);
                
                UIImage *img = [_imageResources objectForKey:imageNode.imageName];
                if(!img)
                    img = [UIImage imageNamed:imageNode.imageName];
                
                if (img) {
                    imgBounds.size = img.size;
                    
                    NSLog(@"----icon frame is x=%f,y=%f,w=%f,h=%f",imgBounds.origin.x,imgBounds.origin.y,imgBounds.size.width,imgBounds.size.height);
                    [img drawInRect:CGRectIntegral(imgBounds)];
                }
                
                NSInteger imageNodeIndex =[_images indexOfObject:imageNode];
                if (imageNodeIndex < [_images count] - 1) {
                    imageNode = [_images objectAtIndex:imageNodeIndex + 1];
                }
                else {
                    break;
                }
            }
            
        }//for( id runObj in (__bridge NSArray*) CTLineGetGlyphRuns(line))
        
	}//for (int i = 0; i < lineCount; i++)
    
    CGPathRelease(mainPath);
	CFRelease(ctframe);
}

#pragma mark User Interaction
-(BOOL)canBecomeFirstResponder
{
    return YES;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(self.enableContextMenu)
        return (action==@selector(copyText:)||action==@selector(shareText:)
                    ||action==@selector(saveImage:)||action==@selector(shareImage:));
    else return NO;
}
-(void) copyText:(id)sender
{
    if([self.delegate respondsToSelector:@selector(coretextView:receivedContextMenu:onData:)]){
        [self.delegate coretextView:self receivedContextMenu:FTCoreTextActionCopy onData:_dataDictionary];
    }
}
-(void) shareText:(id)sender
{
    if([self.delegate respondsToSelector:@selector(coretextView:receivedContextMenu:onData:)]){
        [self.delegate coretextView:self receivedContextMenu:FTCoreTextActionShare onData:_dataDictionary];
    }
}
-(void) saveImage:(id)sender
{
    if([self.delegate respondsToSelector:@selector(coretextView:receivedContextMenu:onData:)]){
        [self.delegate coretextView:self receivedContextMenu:FTCoreTextActionSave onData:_dataDictionary];
    }
}
-(void) shareImage:(id)sender
{
    if([self.delegate respondsToSelector:@selector(coretextView:receivedContextMenu:onData:)]){
        [self.delegate coretextView:self receivedContextMenu:FTCoreTextActionShare onData:_dataDictionary];
    }
}
-(void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (self.enableContextMenu && recognizer.state == UIGestureRecognizerStateBegan && !CGPointEqualToPoint(_longPressPoint,CGPointZero)) {
        [self becomeFirstResponder];
        
        NSDictionary *data = [self dataForPoint:_longPressPoint];
        if (data) {
            
            _dataDictionary=nil;
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            if([[data objectForKey:FTCoreTextDataName] isEqualToString:FTCoreTextTagDefault]){
                UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy",@"") action:@selector(copyText:)];
                UIMenuItem *shareItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Share",@"") action:@selector(shareText:)];
                
                _dataDictionary = [data copy];
                
                [menu setMenuItems:[NSArray arrayWithObjects:copyItem, shareItem, nil]];
                [menu setTargetRect:self.frame inView:self];
                [menu setMenuVisible:YES animated:YES];                
            }
            else if([[data objectForKey:FTCoreTextDataName] isEqualToString:FTCoreTextTagImage]){
                UIMenuItem *saveItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Save",@"") action:@selector(saveImage:)];
                UIMenuItem *shareItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Share",@"") action:@selector(shareImage:)];
                
                _dataDictionary = [data copy];
                
                [menu setMenuItems:[NSArray arrayWithObjects:saveItem, shareItem, nil]];
                
                CGRect frame = CGRectFromString([data objectForKey:FTCoreTextDataFrame]);
                [menu setTargetRect:frame inView:self];
                [menu setMenuVisible:YES animated:YES];
            }
            
        }
       
    }  
}

#pragma mark touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__func__);
    
    if(self.enableContextMenu)
        _longPressPoint=[(UITouch*)[touches anyObject] locationInView:self];
    
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
    if([UIMenuController sharedMenuController].isMenuVisible)
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    
	if (self.delegate && ([self.delegate respondsToSelector:@selector(touchedData:inCoreTextView:)] || [self.delegate respondsToSelector:@selector(coreTextView:receivedTouchOnData:)])) {
			CGPoint point = [(UITouch *)[touches anyObject] locationInView:self];
			NSDictionary *data = [self dataForPoint:point];
			if (data) {
				if ([self.delegate respondsToSelector:@selector(coreTextView:receivedTouchOnData:)]) {
					[self.delegate coreTextView:self receivedTouchOnData:data];
				}
				
            }
    }
}

@end

@implementation NSString (FTCoreText)
- (NSString *)stringByAppendingTagName:(NSString *)tagName
{
	return [NSString stringWithFormat:@"<%@>%@</%@>", tagName, self, tagName];
}
@end
