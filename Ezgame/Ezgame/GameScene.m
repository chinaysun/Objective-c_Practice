//
//  GameScene.m
//  Ezgame
//
//  Created by SUN YU on 10/08/2015.
//  Copyright (c) 2015 SUN YU. All rights reserved.
//

#import "GameScene.h"
#import "MLHero.h"
#import "MLWorldGenerator.h"
#import "MLPointsLabel.h"
#import "GameData.h"


// set some boolean to judge the game
@interface GameScene()
@property BOOL isStarted;
@property BOOL isGameOver;
@end

@implementation GameScene
{
    //global var is easily to used in different function
    MLHero *hero;
    //set the var to control the world, then can centre the hero on camera
    SKNode *world;
    MLWorldGenerator *generator;
}

static NSString *GAME_FONT = @"AmericanTypewriter-Bold";

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    //what is the anchor point means, in this game?
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    //change the world become real world
    self.physicsWorld.contactDelegate = self;
    [self createContent];
    
}

-(void)createContent
{
    
    
    self.backgroundColor = [SKColor colorWithRed:0.54 green:0.7853 blue:1.0 alpha:1.0];
    
    world =[SKNode node];
    [self addChild:world];
    
    generator = [MLWorldGenerator generatorWithWorld:world];
    [self addChild:generator];
    [generator populate];
    
    [self loadScoreLabels];
    
   
    
    SKLabelNode *tapToBeginLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    tapToBeginLabel.name = @"tapToBeginLabel";
    tapToBeginLabel.text = @"tap to begin";
    tapToBeginLabel.position =CGPointMake(0, 20);
    tapToBeginLabel.fontSize = 12;
    [self addChild:tapToBeginLabel];
    [self animationWithPulse:tapToBeginLabel];
    
    [self loadClouds];

    
    // new version using generator method to create the world
    //    SKSpriteNode *ground = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(self.frame.size.width, 50
    //                                                                                            )];
    ////    ground.position = CGPointMake(0, -self.frame.size.height/2 + ground.frame.size.height/2);
    //// above code does not work, how to call the whole frame in a node?
    //    ground.position = CGPointMake(0, -100);
    //
    //// physicsbody just likes according to it attach node, the calculate the posistion of scene then updates the scene
    //    ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ground.size];
    //    ground.physicsBody.dynamic = NO;
    //    [world addChild:ground];
    
    hero = [MLHero hero];
    [world addChild:hero]; // in here, self points the whole screen
    
    
}

-(void)loadScoreLabels
{
    MLPointsLabel *pointsLabel = [MLPointsLabel pointsLableWithFontNamed:GAME_FONT];
    pointsLabel.name = @"pointsLabel";
    pointsLabel.position = CGPointMake(-150, 70);
    pointsLabel.fontSize = 18;
    [self addChild:pointsLabel];
    
    GameData *data = [GameData data];
    [data load];
    //default value is 0, no matter it has store or not
    
    
    MLPointsLabel *highscoreLabel = [MLPointsLabel pointsLableWithFontNamed:GAME_FONT];
    highscoreLabel.position = CGPointMake(150, 70);
    highscoreLabel.fontSize = 18;
    highscoreLabel.name = @"highscoreLabel";
    [highscoreLabel setPoints:data.highscore];
    [self addChild:highscoreLabel];
    
    SKLabelNode *bestLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    bestLabel.text = @"best";
    bestLabel.fontColor = [UIColor redColor];
    bestLabel.fontSize = 10;
    bestLabel.position = CGPointMake(-30, 0);
    [highscoreLabel addChild:bestLabel];
}

//add some shape node
-(void)loadClouds
{
    SKShapeNode *cloud1 = [SKShapeNode node];
    cloud1.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-100, -180, 40, 20)].CGPath;
    cloud1.fillColor = [UIColor whiteColor];
    cloud1.strokeColor = [UIColor blackColor];
    [world addChild:cloud1];
    
    SKShapeNode *cloud2 = [SKShapeNode node];
    cloud2.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-50, -150, 40, 20)].CGPath;
    cloud2.fillColor = [UIColor whiteColor];
    cloud2.strokeColor = [UIColor blackColor];
    [world addChild:cloud2];
}
-(void)start
{
    self.isStarted = YES;
    [[self childNodeWithName:@"tapToBeginLabel"] removeFromParent];
    [hero start];
}

-(void)clear
{
   // GameScene *scene = [[GameScene alloc] initWithSize:self.frame.size];
    //[self.view presentScene:scene];
    
   [self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
       [node removeFromParent];
   }];
    
    self.isStarted = NO;
    self.isGameOver = NO;
    
   [self createContent];
    
}

-(void)gameOver
{
    self.isGameOver =YES;
    
    [hero stop];
    
    [self runAction:[SKAction playSoundFileNamed:@"onGameOver.mp3" waitForCompletion:NO]];
    //set the label to show game over
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    gameOverLabel.text = @"GAME OVER";
    gameOverLabel.fontSize = 22;
    gameOverLabel.position = CGPointMake(0, 40);
  
    [self addChild:gameOverLabel];
    
    SKLabelNode *tapToResetLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    tapToResetLabel.name = @"tapToResetLabel";
    tapToResetLabel.text = @"tap to reset";
    tapToResetLabel.position =CGPointMake(0, 20);
    tapToResetLabel.fontSize = 12;
    [self addChild:tapToResetLabel];
    [self animationWithPulse:tapToResetLabel];
    
    [self updateHighscore];
    
}

-(void)updateHighscore
{
    MLPointsLabel *pointsLabel = (MLPointsLabel *)[self childNodeWithName:@"pointsLabel"];
    MLPointsLabel *highscoreLabel = (MLPointsLabel *)[self childNodeWithName:@"highscoreLabel"];

        
    if (pointsLabel.number > highscoreLabel.number) {
        
        [highscoreLabel setPoints:pointsLabel.number];
        
        GameData *data = [GameData data];
        data.highscore = pointsLabel.number;
        [data save];
    }
}


// make the camera focus on hero
//this is labrary method to do the physic body change, automatically update
-(void)didSimulatePhysics
{
    [self centerOrNode:hero];
    [self handlePoints];
    [self handleGeneration];
    [self handleCleanup];

    
}

-(void)handlePoints
{
    [world enumerateChildNodesWithName:@"obstacle" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x < hero.position.x) {
            //access the childNode and put it to a new instance
            MLPointsLabel *pointsLabel = (MLPointsLabel *)[self childNodeWithName:@"pointsLabel"];
            [pointsLabel increment];
        }
    }];
}


-(void)handleGeneration
{
    //keep generating the ground based on the name, look at this, the judgement has to be put into the ]
    //and also, must to focus on which node should be added, this case it is world not self
    [world enumerateChildNodesWithName:@"obstacle" usingBlock:^(SKNode *node, BOOL *stop){
        // this node insteads of what?
        if (node.position.x < hero.position.x)
        {
            node.name = @"obstacle_cancelled";
            [generator generate];
        }
    }];
}


-(void) handleCleanup
{
   [world enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
       if (node.position.x < hero.position.x -self.frame.size.width/2 - node.frame.size.width/2) {
           [node removeFromParent];
       }
   }];
    
    [world enumerateChildNodesWithName:@"obstacle_cancelled" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x < hero.position.x -self.frame.size.width/2 - node.frame.size.width/2) {
            [node removeFromParent];
        }
    }];
}


//this method accepte a node point
-(void)centerOrNode:(SKNode *)node
{
    //USING THE HERO POSITION
    CGPoint positionInScene = [self convertPoint:node.position fromNode:node.parent];
    // CALCULATHE THE DIFFERENT THEN, MOVE TEH WORLD
    world.position =CGPointMake(world.position.x - positionInScene.x, world.position.y - positionInScene.y);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    // every time touched, then black move 10
    //[hero walkRight];
    
    if (!self.isStarted) [self start];
    else if (self.isGameOver)
        [self clear];
    else
        [hero jump];
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

// IF NO SET THE BIT, THIS METHOD WILL NOT BE INVOKED
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"111");
    
    if ([contact.bodyA.node.name  isEqualToString:@"ground"] || [contact.bodyB.node.name  isEqualToString:@"ground"]) {
        [hero land];
    }else {
          [self gameOver];
    }
  
}

// **ANIMATION SECTION **//
- (void)animationWithPulse:(SKNode *)node
{
    //使Label有闪现效果
    SKAction *disapper = [SKAction fadeAlphaTo:0.0 duration:0.8];
    SKAction *appear = [SKAction fadeAlphaTo:1.0 duration:0.8];
    // sequence effect
    SKAction *pulse = [SKAction sequence:@[disapper,appear]];
    [node runAction:[SKAction repeatActionForever:pulse]];
}



@end
