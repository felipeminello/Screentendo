//
//  GameScene.m
//  TestGame
//
//  Created by Aaron Randall on 05/04/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import "GameScene.h"
#import "ImageStructureAnalyser.h"
#import "AppDelegate.h"

@interface GameScene() <SKPhysicsContactDelegate>
@end

typedef NS_ENUM(NSInteger, Direction) {
    Left  = 123,
    Right = 124,
    Up    = 126,
    Down  = 125
};

@implementation GameScene {
    SKSpriteNode *_sprite;
    NSMutableArray *_blocks;
    BOOL _isJumping;
    BOOL _isFacingLeft;
    
    BOOL _leftPressed;
    BOOL _rightPressed;
    BOOL _upPressed;
    BOOL _downPressed;
    
    int _frameCount;
    int _animationTicker;
}

- (void) didChangeSize:(CGSize)oldSize {
    [self clearSpritesFromScene];
    [self makeAppWindowTransparent];
}

- (void)windowDidResize {
    NSLog(@"Window resized");
}

- (void) keyDown:(NSEvent *)event {
    switch([event keyCode]) {
        case Up:
            _upPressed = YES;
            break;
        case Down:
            _downPressed = YES;
            break;
        case Right:
            _rightPressed = YES;
            break;
        case Left:
            _leftPressed = YES;
            break;
        default:
            break;
    }
}

- (void) keyUp:(NSEvent *)event {
    switch([event keyCode]) {
        case Up:
            _upPressed = NO;
            break;
        case Down:
            _downPressed = NO;
            break;
        case Right:
            _rightPressed = NO;
            break;
        case Left:
            _leftPressed = NO;
            break;
        default:
            break;
    }
}

- (void) clearSpritesFromScene {
    [self removeAllChildren];
    [_blocks removeAllObjects];
}

- (void) makeAppWindowTransparent {
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] makeWindowTransparent];
}

- (void) makeAppWindowOpaque {
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] makeWindowOpaque];
}

- (void) mouseDown:(NSEvent *)theEvent {
    int blockSize = 10;
    bool hardcodeBlocks = NO;
    
    [self clearSpritesFromScene];

    NSArray *imageArray = nil;
    if (!hardcodeBlocks) {
        imageArray = [ImageStructureAnalyser topLevelWindowToBinaryArrayWithBlockSize:blockSize];
    }
    
    self.physicsWorld.gravity = CGVectorMake(0, -3);
    self.physicsWorld.contactDelegate = self;
    
    CGPoint location = [theEvent locationInNode:self];
    _sprite = [SKSpriteNode spriteNodeWithImageNamed:@"player-standing-right"];
    _sprite.size = CGSizeMake(blockSize, blockSize * 2);
    _sprite.position = CGPointMake(location.x, location.y + 230);
    _sprite.scale = 1;
    _sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(_sprite.size.width, _sprite.size.height)];
    _sprite.physicsBody.allowsRotation = NO;
    _sprite.physicsBody.angularVelocity = 0.0f;
    _sprite.physicsBody.angularDamping = 0.0f;
    _sprite.physicsBody.dynamic = YES;
    _sprite.physicsBody.contactTestBitMask = 0;
    
    [self addChild:_sprite];
    
    if (!hardcodeBlocks) {
        int blocksWide = (int)imageArray.count;
        int blocksHigh = (int)[(NSArray*)[imageArray objectAtIndex:0] count];
        
        // Draw the blocks to the screen as images
        for (int x = 0; x < blocksWide; x++) {
            for (int y = 0; y < blocksHigh; y++) {
                NSNumber *currentColor = imageArray[x][y];
                
                if ([currentColor isEqualToNumber:[NSNumber numberWithInt:1]]) {
                    SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
                    block.size = CGSizeMake(blockSize, blockSize);
                    block.position = CGPointMake(x*blockSize,(blocksHigh * blockSize) - y*blockSize);
                    block.scale = 1;
                    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(block.size.width, block.size.height)];
                    //block.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-2,-2) toPoint:CGPointMake(2,2)];
                    //block.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:block.size.height/2];
                    //block.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:@"block"] size:block.size];
                    block.physicsBody.dynamic = NO;
                    block.physicsBody.allowsRotation = NO;
                    block.physicsBody.usesPreciseCollisionDetection = YES;
                    block.physicsBody.affectedByGravity = NO;
                    block.physicsBody.contactTestBitMask = 1;
                    
                    [_blocks addObject:block];
                    [self addChild:block];
                }
            }
        }
    }
    
    [self makeAppWindowOpaque];
    
    if (hardcodeBlocks) {
        // Hardcoded blocks
        int numBlocks = 20;
        for (int i = 0; i < numBlocks; i++) {
            SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
            block.size = CGSizeMake(blockSize, blockSize);
            block.position = CGPointMake(location.x + ((i*blockSize)-((numBlocks/2)*blockSize)),location.y);
            block.scale = 1;
            
            //block.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:CGPathCreateWithRoundedRect(CGRectMake(block.position.x, block.position.y - 50, block.size.width, block.size.height), 1, 0, nil)];
            
//            block.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:CGPathCreateWithRect([block calculateAccumulatedFrame], nil)];
            
            //block.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0,0) toPoint:CGPointMake(0,0)];
            //block.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:CGPathCreateWithRoundedRect(CGRectMake(0, 0, 5, 5), 2, 2, nil)];
            
//            block.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(block.position.x, block.position.y) toPoint:CGPointMake(block.position.x + block.size.width, block.position.y)];
            
            
            block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
            block.physicsBody.dynamic = NO;
            block.physicsBody.allowsRotation = NO;
            block.physicsBody.usesPreciseCollisionDetection = YES;
            block.physicsBody.affectedByGravity = NO;
            block.physicsBody.contactTestBitMask = 1;
            
            [_blocks addObject:block];
            [self addChild:block];
        }
    }
}

- (void) renderPlayerPosition {
    int xDelta = 0;
    int yDelta = 0;
    
    int deltaChange = 1.7;
    
    if (_upPressed) {
        if (!_isJumping) {
            _isJumping = YES;
            [_sprite.physicsBody applyImpulse:CGVectorMake(0.0f, 1.5f) atPoint:_sprite.position];
            if (_isFacingLeft) {
                [self changeSpriteTexture:@"player-jumping-left"];
            } else {
                [self changeSpriteTexture:@"player-jumping-right"];
            }
        }
    } else if (_downPressed) {
        yDelta = -deltaChange;
    }
    
    if (_rightPressed) {
        _isFacingLeft = NO;
        if (!_isJumping) {
            [self changeSpriteTexture:[NSString stringWithFormat:@"player-running-%i-right",_animationTicker]];
        }
        xDelta = +deltaChange;
    } else if (_leftPressed) {
        _isFacingLeft = YES;
        if (!_isJumping) {
            [self changeSpriteTexture:[NSString stringWithFormat:@"player-running-%i-left",_animationTicker]];
        }
        xDelta = -deltaChange;
    }
    
    if (!_upPressed && !_downPressed && !_rightPressed && !_leftPressed) {
        if (_isFacingLeft) {
            [self changeSpriteTexture:@"player-standing-left"];
        } else {
            [self changeSpriteTexture:@"player-standing-right"];
        }
    }
    
    CGPoint desiredPosition = CGPointMake(_sprite.position.x + xDelta, _sprite.position.y + yDelta);
    _sprite.position = desiredPosition;
    
    //_sprite.physicsBody.velocity = CGVectorMake(_sprite.physicsBody.velocity.dx + xDelta,_sprite.physicsBody.velocity.dy + yDelta);
}

- (void)changeSpriteTexture:(NSString*)textureName {
    if (![_sprite.texture.description isEqualToString:textureName]) {
        [_sprite setTexture:[SKTexture textureWithImageNamed:textureName]];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    _isJumping = NO;
    
    if (contact.bodyA.node.physicsBody.contactTestBitMask == 0) {
        // BodyA is player
        if ((contact.bodyA.node.position.y < contact.contactPoint.y) && (contact.bodyB.node.position.y > contact.contactPoint.y)) {
            [contact.bodyB.node removeFromParent];
        }
    } else {
        // BodyB is player
        if ((contact.bodyB.node.position.y < contact.contactPoint.y) && (contact.bodyA.node.position.y > contact.contactPoint.y)) {
            [contact.bodyA.node removeFromParent];
        }
    }
}

- (void) update:(CFTimeInterval)currentTime {
    _frameCount++;
    
    if (_frameCount == INT_MAX) {
        _frameCount = 0;
    }
    
    if ((_frameCount % 4) == 0) {
        _animationTicker++;
        if (_animationTicker > 3) {
            _animationTicker = 1;
        }
        NSLog(@"%i", _animationTicker);
    }
    
    [self renderPlayerPosition];
}

@end
