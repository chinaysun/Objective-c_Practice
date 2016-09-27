/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/
/********************************************************************
 FileName: PlayerCell.m
 Date: 13 Oct 2015
 Description: this is class to generate the player cell
 Functions: 1. initial cell method
            2. control the cell move
            3. change the speed based on the size
            4. eject method
            5. split method
            6. ate method
            7. set physical body and some basic features
            8. ball animation
 *******************************************************************/

#import "PlayerCell.h"

@interface PlayerCell()
@property float radius;
@property float numberOfMass;
@property int moveMentSpeed;
@property CGPoint centrePoint;
@end

@implementation PlayerCell

static const uint32_t playerCategory = 0x1 << 1;
static const uint32_t foodCategory = 0x1 << 2;
static const uint32_t megerCategory = 0x1 << 3;
static const uint32_t boundaryCategory = 0x1 <<4;
static const uint32_t obstacleCategory = 0x1 <<5;
static const uint32_t virusCategory = 0x1 <<6;
static const uint32_t animyCategory = 0x1 <<7;

// basic Radius equals to radius of food, the unit of volume
static int BASICRADIUS = 2;
static int initialMass = 30;
static CGFloat GRID = 800;
static NSString *GAME_FONT = @"AmericanTypewriter-Bold";

/*this method is used to born the first cell*/
+(id) PlayerCell:(UIColor *) color PlayerName:(NSString*)playerName
{
    PlayerCell *playerCell = [PlayerCell node];
    
    //set initial mass
    playerCell.numberOfMass = initialMass;

    //set the body
    [playerCell setBody];
    
    //set start type
    playerCell.name = @"playerCell";
    playerCell.lineWidth = 1.0;
    playerCell.fillColor = color;
    playerCell.strokeColor = [SKColor whiteColor];
    playerCell.zPosition = 0.2;
    
    
    /*ADD NAME LABEL*/
    SKLabelNode *nameOfPlayer = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    nameOfPlayer.text = playerName;
    nameOfPlayer.fontSize = playerCell.getRadius*0.8;
    nameOfPlayer.fontColor =[UIColor colorWithRed:236.0 green:206.0 blue:118.0 alpha:1.0];
    nameOfPlayer.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    nameOfPlayer.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
   
    
    playerCell.playerNameLabel = nameOfPlayer;
    [playerCell addChild:nameOfPlayer];
    
    /*ADD SPECIFIC BACKGROUND*/
    if ([playerName isEqualToString:@"WiFi"] || [playerName isEqualToString:@"Orange"]
        || [playerName isEqualToString:@"Email" ]|| [playerName isEqualToString:@"Chrome"]
        || [playerName isEqualToString:@"Tweet"])
    {
        /*add specific background*/
        SKSpriteNode *cellBackground = [SKSpriteNode spriteNodeWithImageNamed:playerName];
        cellBackground.xScale = 2*playerCell.getRadius/cellBackground.size.width;
        cellBackground.yScale = 2*playerCell.getRadius/cellBackground.size.height;
        [playerCell addChild:cellBackground];
        playerCell.specificBackground = cellBackground;
        
        /*change the other attribute feature*/
        playerCell.playerNameLabel.zPosition = 0.3;
        playerCell.playerNameLabel.fontColor = [UIColor blackColor];
        
        playerCell.fillColor = nil;
    }
  

    
    
    /*run ball animation*/
    [playerCell ballAnimation];
    
    return playerCell;
}

/*initial method for split*/
+(id) PlayerCellSplit:(PlayerCell *)previousCell Direction:(CGPoint)direction PlayerName:(NSString*)playerName
{
    
    PlayerCell *playerCell = [PlayerCell node];
    
    /*SET POSITION SAME AS PREVIOUS CELL*/
    playerCell.position = CGPointMake(previousCell.position.x, previousCell.position.y);
    
    playerCell.numberOfMass = previousCell.numberOfMass;
    
    playerCell.cellBornTime = CACurrentMediaTime();
    playerCell.stillAlive = true;
    
    playerCell.direction = previousCell.direction;
    playerCell.lastDirection = previousCell.lastDirection;
    
    
    [playerCell setBody];
    
    //set type
    playerCell.name = @"playerCell";
    playerCell.lineWidth = 1.0;
    playerCell.fillColor = previousCell.fillColor;
    playerCell.strokeColor = [SKColor whiteColor];
    playerCell.zPosition = 0.2;
    
    /*add label*/
    SKLabelNode *nameOfPlayer = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    nameOfPlayer.text = playerName;
    nameOfPlayer.fontSize = playerCell.getRadius*0.8;
    nameOfPlayer.fontColor =[UIColor colorWithRed:236.0 green:206.0 blue:118.0 alpha:1.0];
    nameOfPlayer.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    nameOfPlayer.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    playerCell.playerNameLabel = nameOfPlayer;
    [playerCell addChild:nameOfPlayer];
    
    /*ADD SPECIFIC BACKGROUND*/
    if ([playerName isEqualToString:@"WiFi"] || [playerName isEqualToString:@"Orange"]
        || [playerName isEqualToString:@"Email" ]|| [playerName isEqualToString:@"Chrome"]
        || [playerName isEqualToString:@"Tweet"])
    {
        /*add specific background*/
        SKSpriteNode *cellBackground = [SKSpriteNode spriteNodeWithImageNamed:playerName];
        cellBackground.xScale = 2*playerCell.getRadius/cellBackground.size.width;
        cellBackground.yScale = 2*playerCell.getRadius/cellBackground.size.height;
        [playerCell addChild:cellBackground];
        playerCell.specificBackground = cellBackground;
        
        /*change the other attribute feature*/
        playerCell.playerNameLabel.zPosition = 0.3;
        playerCell.playerNameLabel.fontColor = [UIColor blackColor];
        
        playerCell.fillColor = nil;
    }
    
    
    /*set the destination point for animation*/
    CGPoint destination = CGPointMake(playerCell.position.x + direction.x*100, playerCell.position.y + direction.y*100);
    
    /*vaild the destination*/
    if (destination.x > GRID) {
        destination.x = direction.x*(GRID - playerCell.getRadius);
    }
    
    if (destination.x < 0) {
        destination.x = playerCell.getRadius;
    }
    
    if (destination.y > GRID) {
        destination.y = direction.y*(GRID - playerCell.getRadius);
    }
    
    if (destination.y < 0) {
        destination.y = playerCell.getRadius;
    }
    
    
    
    /*SET ANIMATION FOR SPLIT*/
    SKAction *action = [SKAction moveTo:CGPointMake(destination.x,destination.y)
                               duration:0.2];
    [playerCell runAction:action];
    
    /*run ball animation*/
    [playerCell ballAnimation];
    
    return playerCell;
}


- (float)getRadius
{
    /* at present, just use sum of volume of food as the player volume*/
    float currentVolume = 3.14*BASICRADIUS*BASICRADIUS*self.numberOfMass;
    self.radius = sqrt(currentVolume/3.14);
    
    return self.radius;
}

-(void)ateFunction:(int)number
{
    
    
    self.numberOfMass = self.numberOfMass + number;
    
    [self setBody];
    NSLog(@"%f",self.numberOfMass);
}

-(void)eject
{
    self.numberOfMass = self.numberOfMass - 1;
    [self setBody];
    NSLog(@"Ejecting!!!!!");

}

-(void)split
{
    self.numberOfMass = self.numberOfMass/2;
    [self setBody];
    
    /*refresh the born time*/
    self.cellBornTime = CACurrentMediaTime();
    NSLog(@"Split!!!!!");
}

/*ate virus then spilt as 3 cells*/
-(void)ateVirus
{
    self.numberOfMass = self.numberOfMass/3;
    [self setBody];
    
    /*refresh the born time*/
    self.cellBornTime = CACurrentMediaTime();
    NSLog(@"Virus!!!!!");
}
-(void)setBody
{
    
    // get the current radius
    float radius = [self getRadius];
    
    /*change the size of label*/
    self.playerNameLabel.fontSize = radius*0.8;
    
    /*change the specific background size*/
    if (self.specificBackground) {
        
        /*remove old*/
        [self.specificBackground removeFromParent];
        
        /*add new*/
        SKSpriteNode *cellBackground = [SKSpriteNode spriteNodeWithImageNamed:self.playerNameLabel.text];
        cellBackground.xScale = 2*radius/cellBackground.size.width;
        cellBackground.yScale = 2*radius/cellBackground.size.height;
        [self addChild:cellBackground];
        
        self.specificBackground = cellBackground;
        
    }
    
    /*if radius > 13 then make it can cover virus-zposition-0.3*/
    if (radius > 13) {
        self.zPosition = 0.4;
    }
    else
    {
        self.zPosition = 0.2;
    }
    
    self.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-radius, -radius, radius*2, radius*2)].CGPath;
    
    float acutallyMass = self.numberOfMass - initialMass;
    
    //control the speed of movement
    if ( acutallyMass < 10) {
        
        // the highest speed
        self.moveMentSpeed = 120;
    }else if ( acutallyMass > 60)
    {
        // the lowest speed
        self.moveMentSpeed = 10;
    }else
    {
        // the speed equal to the y = ax + c, a is a negative number
        self.moveMentSpeed = -2.2*acutallyMass + 142;
    }
    


    [self addPhysical];
    
    NSLog(@"getSpeed :%d",self.moveMentSpeed);
    
}

-(void)addPhysical
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.radius ];
    self.physicsBody.friction = 0.0;
    self.physicsBody.linearDamping = 0.0; // ignore the air resistance
    self.physicsBody.restitution = 0.0;; // how many power rest, after collosion
    self.physicsBody.allowsRotation = NO; // force will not effect the speed
    self.physicsBody.affectedByGravity = NO;

    //set collision detection
    self.physicsBody.categoryBitMask = playerCategory;
    self.physicsBody.contactTestBitMask = foodCategory | playerCategory | megerCategory |
                                          boundaryCategory | obstacleCategory | virusCategory | animyCategory;
//    self.physicsBody.collisionBitMask = nodeCategory;
    self.physicsBody.collisionBitMask = playerCategory | boundaryCategory | obstacleCategory;
    
}

-(int)getSpeed
{
    return self.moveMentSpeed;
}

- (void) updatePositionWithTimeInvterval: (CFTimeInterval) interval  {
 
    self.physicsBody.velocity = CGVectorMake(self.direction.x*self.moveMentSpeed, self.direction.y*self.moveMentSpeed);
}

-(float)getNumberofMass
{
    return self.numberOfMass;
}

/*ball animation*/
-(void)ballAnimation
{
    SKAction *wiggleInX = [SKAction scaleXTo:1.03 duration:0.2];
    SKAction *wiggleOutX = [SKAction scaleXTo:1.0 duration:0.2];
    SKAction *wiggleInY = [SKAction scaleYTo:1.03 duration:0.2];
    SKAction *wiggleOutY = [SKAction scaleYTo:1.0 duration:0.2];
    
    SKAction *wiggle = [SKAction sequence:@[wiggleInX,wiggleOutX,wiggleInY,wiggleOutY]];
    
    [self runAction:[SKAction repeatActionForever:wiggle]];
    
}


@end
