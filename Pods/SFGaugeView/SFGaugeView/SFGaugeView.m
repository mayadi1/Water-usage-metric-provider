//
//  SFGaugeView.m
//  SFGaugeView
//
//  Created by Thomas Winkler on 15/11/13.
//  Copyright (c) 2013 Thomas Winkler. All rights reserved.
//

#import "SFGaugeView.h"

@interface SFGaugeView()

@property(nonatomic) CGFloat needleRadius;
@property(nonatomic) CGFloat bgRadius;
@property(nonatomic) CGFloat currentRadian;
@property(nonatomic) NSInteger oldLevel;
@property(nonatomic, readonly) NSUInteger scale;
@end

@implementation SFGaugeView

@synthesize minlevel = _minlevel;

static const CGFloat CUTOFF = 0.5;

#pragma mark init stuff

- (id) init
{
    self = [super init];
    [self setup];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    
    self.currentRadian = 0;
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
}

- (void) awakeFromNib
{
    [self setup];
}

#pragma mark drawing

- (void)drawRect:(CGRect)rect
{
    [self drawBg];
    [self drawNeedle];
    [self drawLabels];
    [self drawImageLabels];
}

- (void) drawImageLabels
{
    if (self.minImage && self.maxImage) {
        
        UIImage *badImg;
        UIImage *goodImg;
        
        if (self.autoAdjustImageColors) {
            badImg = [self imageNamed:self.minImage withColor:self.needleColor drawAsOverlay:NO];
            goodImg = [self imageNamed:self.maxImage withColor:self.needleColor drawAsOverlay:NO];
        } else {
            badImg = [UIImage imageNamed:self.minImage];
            goodImg = [UIImage imageNamed: self.maxImage];
        }
        
        CGFloat scaleFactor = (self.bounds.size.width / badImg.size.width)/6 ;
        
        [badImg drawInRect:CGRectMake([self centerX] - self.bgRadius, [self centerY] - badImg.size.height * scaleFactor, badImg.size.width * scaleFactor, badImg.size.height * scaleFactor)];
        [goodImg drawInRect:CGRectMake([self centerX] + self.bgRadius - (goodImg.size.width * scaleFactor), [self centerY] - goodImg.size.height * scaleFactor, goodImg.size.width * scaleFactor, goodImg.size.height * scaleFactor)];
    }
}

- (void) drawLabels
{
    CGFloat fontSize = self.bounds.size.width/18;
    UIFont* font = [UIFont fontWithName:@"Arial" size:fontSize];
    UIColor* textColor = [self needleColor];
    
    
    NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
    
    if (!self.hideLevel) {
        fontSize = [self needleRadius] + 5;
        font = [UIFont fontWithName:@"Arial" size:fontSize];
        textColor = [self bgColor];
        
        stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
        NSAttributedString* levelStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", (unsigned long)[self currentLevel]] attributes:stringAttrs];
        
        CGPoint levelStrPoint = CGPointMake([self center].x - levelStr.size.width/2, [self center].y - levelStr.size.height/2);
        [levelStr drawAtPoint:levelStrPoint];
    }
}

- (void) drawBg
{
    CGFloat starttime = M_PI + CUTOFF;
    CGFloat endtime = 2 * M_PI - CUTOFF;
    
    CGFloat bgEndAngle = (3 * M_PI_2) + self.currentRadian;
    
    if (bgEndAngle > starttime) {
        UIBezierPath *bgPath = [UIBezierPath bezierPath];
        [bgPath moveToPoint:[self center]];
        [bgPath addArcWithCenter:[self center] radius:self.bgRadius startAngle:starttime endAngle: (3 * M_PI_2) + self.currentRadian clockwise:YES];
        [bgPath addLineToPoint:[self center]];
        [[self bgColor] set];
        [bgPath fill];
    }
    
    UIBezierPath *bgPath2 = [UIBezierPath bezierPath];
    [bgPath2 moveToPoint:[self center]];
    [bgPath2 addArcWithCenter:[self center] radius:self.bgRadius startAngle:(3 * M_PI_2) + self.currentRadian endAngle:endtime clockwise:YES];
    [[self lighterColorForColor:[self bgColor]] set];
    [bgPath2 fill];
    
    UIBezierPath *bgPathInner = [UIBezierPath bezierPath];
    [bgPathInner moveToPoint:[self center]];
    
    CGFloat innerRadius = self.bgRadius - (self.bgRadius * 0.3);
    [bgPathInner addArcWithCenter:[self center] radius:innerRadius startAngle:starttime endAngle:endtime clockwise:YES];
    [bgPathInner addLineToPoint:[self center]];
    
    self.backgroundColor ? [self.backgroundColor set] : [[UIColor whiteColor] set];
    [bgPathInner stroke];
    [bgPathInner fill];
}

- (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color drawAsOverlay:(BOOL)overlay{
    // load the image
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContextWithOptions(img.size, NO, [[UIScreen mainScreen] scale]);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to overlay, and the original image
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    if(overlay) CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (overlay) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

- (void) drawNeedle
{
    CGFloat distance = [self bgRadius] + ([self bgRadius] * 0.1);
    CGFloat starttime = 0;
    CGFloat endtime = M_PI;
    CGFloat topSpace = (distance * 0.1)/6;
    
    CGPoint center = [self center];
    
    CGPoint topPoint = CGPointMake([self center].x, [self center].y - distance);
    CGPoint topPoint1 = CGPointMake([self center].x - topSpace, [self center].y - distance + (distance * 0.1));
    CGPoint topPoint2 = CGPointMake([self center].x + topSpace, [self center].y - distance + (distance * 0.1));
    
    CGPoint finishPoint = CGPointMake([self center].x + self.needleRadius, [self center].y);
    
    UIBezierPath *needlePath = [UIBezierPath bezierPath]; //empty path
    [needlePath moveToPoint:center];
    CGPoint next;
    next.x = center.x + self.needleRadius * cos(starttime);
    next.y = center.y + self.needleRadius * sin(starttime);
    [needlePath addLineToPoint:next]; //go one end of arc
    [needlePath addArcWithCenter:center radius:self.needleRadius startAngle:starttime endAngle:endtime clockwise:YES]; //add the arc
    
    [needlePath addLineToPoint:topPoint1];
    
    [needlePath addQuadCurveToPoint:topPoint2 controlPoint:topPoint];
    
    [needlePath addLineToPoint:finishPoint];
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(-1 * (self.bounds.origin.x + [self center].x), -1 * (self.bounds.origin.y + [self center].y));
    [needlePath applyTransform:translate];
    
    CGAffineTransform rotate = CGAffineTransformMakeRotation(self.currentRadian);
    [needlePath applyTransform:rotate];
    
    translate = CGAffineTransformMakeTranslation((self.bounds.origin.x + [self center].x), (self.bounds.origin.y + [self center].y));
    [needlePath applyTransform:translate];
    
    [[self needleColor] set];
    [needlePath fill];
}

- (UIColor *)lighterColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.1, 1.0)
                               green:MIN(g + 0.1, 1.0)
                                blue:MIN(b + 0.1, 1.0)
                               alpha:a];
    return nil;
}

#pragma mark pan gesture recognizer

- (void) handlePan: (UIPanGestureRecognizer *) gesture
{
    CGPoint currentPosition = [gesture locationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        //                NSLog (@"[%f,%f]",currentPosition.x, currentPosition.y);
        self.currentRadian = [self calculateRadian:currentPosition];
        [self setNeedsDisplay];
        [self currentLevel];
    }
}

#pragma mark calculation stuff

- (CGFloat)calculateRadian: (CGPoint) pos
{
    CGPoint tmpPoint = CGPointMake(pos.x, [self center].y);
    
    // return zero if needle in center
    if (pos.x == [self center].x) {
        return 0;
    }
    
    if (pos.y > [self center].y) {
        return self.currentRadian;
    }
        
    // calculate distance between pos and center
    CGFloat p12 = [self calculateDistanceFrom:pos to:[self center]];
    
    // calculate distance between pos and tmpPoint
    CGFloat p23 = [self calculateDistanceFrom:pos to: tmpPoint];
    
    // cacluate distance between tmpPont and center
    CGFloat p13 = [self calculateDistanceFrom:tmpPoint to: [self center]];
    
    CGFloat result = M_PI_2 - acos(((p12 * p12) + (p13 * p13) - (p23 * p23))/(2 * p12 * p13));
    
    if (pos.x <= [self center].x) {
        result = -result;
    }
    
    if (result > (M_PI_2 - CUTOFF)) {
        return M_PI_2 - CUTOFF;
    }
    
    if (result < (-M_PI_2 + CUTOFF)) {
        return -M_PI_2 + CUTOFF;
    }
    
//    NSLog(@"Calculated Angle: %f", result);
    
    return result;
}

- (CGFloat)calculateDistanceFrom: (CGPoint) p1 to: (CGPoint) p2
{
    CGFloat dx = p2.x - p1.x;
    CGFloat dy = p2.y - p1.y;
    CGFloat distance = sqrt(dx*dx + dy*dy);
    return distance;
}

# pragma mark current level
- (double) currentLevel
{
    NSInteger level = -1;
    
    CGFloat levelSection = (M_PI - (CUTOFF * 2)) / self.scale;
    CGFloat currentSection = -M_PI_2 + CUTOFF;
    
    for (int i=1; i<=self.scale;i++) {
//        NSLog(@"[%fl, %fl] = %fl", currentSection, (currentSection + levelSection), self.currentRadian);
        if (self.currentRadian >= currentSection && self.currentRadian < (currentSection + levelSection)) {
            level = i;
            break;
        }
        currentSection += levelSection;
    }
    
    if (self.currentRadian >= (M_PI_2 - CUTOFF)) {
        level = self.scale + 1;
    }
    
    level = level + self.minlevel - 1;
    
    //    NSLog(@"Current Level is %lu", (unsigned long)level);
    if (self.oldLevel != level && self.delegate && [self.delegate respondsToSelector:@selector(sfGaugeView:didChangeLevel:)]) {
        [self.delegate sfGaugeView:self didChangeLevel:level];
    }
    
    self.oldLevel = level;
    return level;
}

- (void) setCurrentLevel:(double)currentLevel
{
    if (currentLevel >= self.minlevel && currentLevel <= self.maxlevel) {
        
        self.oldLevel = currentLevel;
        
        CGFloat range = M_PI - (CUTOFF * 2);
        if (currentLevel != self.scale/2) {
            self.currentRadian = (currentLevel * range)/self.scale - (range/2);
        } else {
            self.currentRadian = 0.f;
        }
        
        //        NSLog(@"Current Radian is %f", self.currentRadian);
        [self setNeedsDisplay];
    }
}

#pragma mark custom getter/setter

- (CGPoint)center
{
    return CGPointMake([self centerX], [self centerY]);
}

- (CGFloat)centerY
{
    return self.bounds.size.height - (self.bounds.size.height * 0.2);
}

- (CGFloat)centerX
{
    return self.bounds.size.width/2;
}   

- (UIColor *) needleColor
{
    if (!_needleColor) {
        _needleColor = [UIColor colorWithRed:76/255.0 green:177/255.0 blue:88/255.0 alpha:1];
    }
    
    return _needleColor;
}

- (UIColor *) bgColor
{
    if (!_bgColor) {
        _bgColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1];
    }
    
    return _bgColor;
}

- (CGFloat) needleRadius
{
    if (!_needleRadius) {
        _needleRadius = self.bounds.size.height * 0.08;
    }
    
    return _needleRadius;
}

- (NSUInteger) maxlevel
{
    if (!_maxlevel) {
        _maxlevel = 10;
    }
    
    return _maxlevel;
}

- (void)setMinlevel:(NSUInteger)minlevel
{
    _minlevel = minlevel;
}

- (CGFloat) bgRadius
{
    if (!_bgRadius) {
        _bgRadius = [self centerX] - ([self centerX] * 0.1);
    }
    
    return _bgRadius;
}

- (NSUInteger)scale {
    return self.maxlevel - self.minlevel;
}

@end
