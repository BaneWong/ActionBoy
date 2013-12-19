//
//  GLView.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "GLView.h"
#import "ConstantsAndMacros.h"


@interface GLView ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;
- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
@end

#pragma mark -

@implementation GLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;
@synthesize delegate;

+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
		self.multipleTouchEnabled = YES;
		
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], 
										kEAGLDrawablePropertyRetainedBacking, 
										kEAGLColorFormatRGBA8, 
										kEAGLDrawablePropertyColorFormat, 
										nil];
    
        
#if kAttemptToUseOpenGLES2
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (context == NULL)
        {
#endif
            context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
            
            if (!context || ![EAGLContext setCurrentContext:context]) {
                [self release];
                return nil;
            }
#if kAttemptToUseOpenGLES2
        }
#endif
        
        animationInterval = 1.0 / kRenderingFrequency;
    }
    return self;
}

- (void)drawView
{
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    [delegate drawView:self];
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)layoutSubviews 
{
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

- (BOOL)createFramebuffer 
{
    
    // Check if we can actually support high resolution screens, and set things up accordingly
    SEL scaleSelector = NSSelectorFromString(@"scale");
    SEL setContentScaleSelector = NSSelectorFromString(@"setContentScaleFactor:");
    SEL getContentScaleSelector = NSSelectorFromString(@"contentScaleFactor");
    if ([self respondsToSelector: getContentScaleSelector] && [self respondsToSelector: setContentScaleSelector])
    {
        // Get the screen scale
        float screenScale = 1.0f;
        NSMethodSignature *scaleSignature = [UIScreen instanceMethodSignatureForSelector: scaleSelector];
        NSInvocation *scaleInvocation = [NSInvocation invocationWithMethodSignature: scaleSignature];
        [scaleInvocation setTarget: [UIScreen mainScreen]];
        [scaleInvocation setSelector: scaleSelector];
        [scaleInvocation invoke];
		
        NSInteger returnLength = [[scaleInvocation methodSignature] methodReturnLength];
        if (returnLength == sizeof(float))
            [scaleInvocation getReturnValue: &screenScale];
		
        // Set the content scale factor
        typedef void (*CC_CONTENT_SCALE)(id, SEL, float);
        CC_CONTENT_SCALE method = (CC_CONTENT_SCALE) [self methodForSelector: setContentScaleSelector];
        method(self, setContentScaleSelector, screenScale);
        
        if( !IS_WIDESCREEN ){
            
            // Retina 3.5
            CGRect r = CGRectMake(0, -(960/2), 640, 960);
            self.layer.bounds = r;
            self.layer.frame = r;
            
        } else if(IS_WIDESCREEN) {
            
            // Retina 4
            CGRect r = CGRectMake(0, -(1136/2), 640, 1136);
            self.layer.bounds = r;
            self.layer.frame = r;
            
        }
    }
    
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
	
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    //CGFloat screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;
    //GLsizei width  = (GLsizei)self.layer.bounds.size.width;
    //GLsizei height = (GLsizei)self.layer.bounds.size.height;
    
    
    // Widescreen low res
    //self.layer.bounds = CGRectMake(0, 0, 320, 568);
    //self.layer.frame = CGRectMake(0, 0, 320, 568);
    
    
    if( IS_WIDESCREEN ){
        //self.layer.bounds = CGRectMake(0, 0, 320, 568);
        //self.layer.frame = CGRectMake(0, 0, 320, 568);
        //self.layer.bounds = CGRectMake(0, 0, 640, 1136);
        //self.layer.frame = CGRectMake(0, 0, 640, 1136);
        
        //self.layer.bounds = CGRectMake(0, -568, 640, 1136);
        //self.layer.frame = CGRectMake(0, -568, 640, 1136);
        //self.layer.frame.origin = CGPointMake(-100, -100);
    }

    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    //glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, screenWidth, screenHeight);
    
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
	NSLog(@" GLView %d  %d ", backingWidth, backingHeight);
	
    if (USE_DEPTH_BUFFER) 
    {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) 
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    [delegate setupView:self];
    
    return YES;
}

- (void)destroyFramebuffer 
{
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) 
    {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}
- (void)startAnimation 
{
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}
- (void)stopAnimation 
{
    self.animationTimer = nil;
    
    [delegate shutdownWarning];
}
- (void)setAnimationTimer:(NSTimer *)newTimer 
{
    [animationTimer invalidate];
    animationTimer = newTimer;
}
- (void)setAnimationInterval:(NSTimeInterval)interval 
{
    animationInterval = interval;
    if (animationTimer) 
    {
        [self stopAnimation];
        [self startAnimation];
    }
}
- (void)dealloc 
{
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) 
        [EAGLContext setCurrentContext:nil];
    
    [context release];  
    [super dealloc];
}


-(NSNumber*) getBackingWidth {
	NSLog(@"getBackingWidth: %d  %f ", backingWidth , backingWidth);
	return [NSNumber numberWithInt: backingWidth ];
}
-(NSNumber*) getBackingHeight {
	return [NSNumber numberWithInt: backingHeight ];
}


@end
