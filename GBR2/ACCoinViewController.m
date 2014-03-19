//
//  ACCoinViewController.m
//  GBR
//
//  Created by Andrew J Cavanagh on 9/6/12.
//  Copyright (c) 2012 Andrew J Cavanagh. All rights reserved.
//

#import "ACCoinViewController.h"
#import "AwesomeCoin.h"
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>

@interface ACCoinViewController ()
{
    GLKMatrix4 modelViewProjectionMatrix;
    GLKMatrix3 normalMatrix;
    float rotation;
    GLuint vertexArray;
    GLuint vertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
- (void)setupGL;
- (void)tearDownGL;
@end

@implementation ACCoinViewController

#pragma mark - Lifecycle

- (id)initWithView:(GLKView *)view
{
    self = [super init];
    if (self) {
        self.view = view;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.view.layer;
    eaglLayer.opaque = NO;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.preferredFramesPerSecond = 20;
    
    [self setupGL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

#pragma mark - OpenGL Configuration

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.lightingType = GLKLightingTypePerPixel;
    
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.position = GLKVector4Make(-5.f, -5.f, 10.f, 1.0f);
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 0.82f, 1.0f);
    self.effect.light0.specularColor = GLKVector4Make(1.0f, 1.0f, 0.82f, 1.0f);

    self.effect.material.diffuseColor = GLKVector4Make(0.54f, 0.53f, 0.47f, 1.0f);
    self.effect.material.ambientColor = GLKVector4Make(1.0f, 0.84f, 0.0f, 1.0f);
    self.effect.material.specularColor = GLKVector4Make(0.54f, 0.50f, 0.29f, 1.0f);
    self.effect.material.shininess = 20.0f;
    self.effect.material.emissiveColor = GLKVector4Make(0.54f, 0.39f, 0.031f, 1.0f);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    glEnable(GL_DEPTH_TEST);

    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(MeshVertexData), MeshVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(vertexData), 0);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE,  6 * sizeof(GLfloat), (char *)12);
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &vertexBuffer);
    glDeleteVertexArraysOES(1, &vertexArray);
    
    self.effect = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, -0.66f, -2.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 0.0f, 1.0f, 0.0f);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    rotation += self.timeSinceLastUpdate * 1.25f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(vertexArray);
    
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, sizeof(MeshVertexData) / sizeof(vertexData));
}

@end
