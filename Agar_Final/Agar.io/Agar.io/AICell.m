/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/
/********************************************************************
 FileName: AICell.m
 Date: 13 Oct 2015
 Description: this is class to generate the ai player
 Functions: 1. ai generator method
            2. online game animy generator method
            3. set body to draw the circle
            4. some basic methods for ai
 *******************************************************************/


#import "AICell.h"

@implementation AICell

static const uint32_t boundaryCategory = 0x1 <<4;
static const uint32_t obstacleCategory = 0x1 <<5;
static const uint32_t animyCategory = 0x1 <<7;

// basic Radius equals to radius of food, the unit of volume
static int BASICRADIUS = 2;
static CGFloat GRID = 800;
static NSString *GAME_FONT = @"AmericanTypewriter-Bold";

/*initial on single game*/
+(id)AICell:(float)playerSize PlayerSpeed:(int)playerSpeed
{
    AICell *newCell = [AICell node];
    
    
    /*fixed size and speed*/
    newCell.numberOfMass = playerSize * 1.1;
    newCell.aiSpeed =  playerSpeed * 1.01;
    
    /*initial the radius*/
    [newCell getRadius];
    
    /*set body*/
    [newCell setBody];
    
    /*set start type*/
    newCell.name =@"animy";
    newCell.lineWidth = 1.0;
    newCell.fillColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    newCell.strokeColor = [SKColor whiteColor];
    newCell.zPosition = 0.2;
    
    /*add label for AI name*/
    SKLabelNode *nameOfCell = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    nameOfCell.text = @"AI";
    nameOfCell.fontSize = newCell.getRadius*0.8;
    nameOfCell.fontColor =[UIColor colorWithRed:236.0 green:206.0 blue:118.0 alpha:1.0];
    nameOfCell.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    nameOfCell.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    newCell.nameOfAi = nameOfCell;
    [newCell addChild:nameOfCell];
    
    /*run ball animation*/
    [newCell ballAnimation];
    
    /*get random position*/
    newCell.position = [newCell getRandomPosition:newCell.radius Height:newCell.radius];

    return newCell;
}

/*initial method used in online game*/
+(id)AIcellwithPosition:(CGPoint)location AIname:(NSString *)aiName AIcolor:(UIColor *)aiColor AIMass:(float)aiMass
{
    AICell *newCell = [AICell node];
    
    /*initial the number of mass*/
    newCell.numberOfMass = aiMass;
    
    /*initial the radius*/
    [newCell getRadius];
    
    /*set body*/
    [newCell setBody];
    
    /*set start type*/
    newCell.name =@"animy";
    newCell.lineWidth = 1.0;
    newCell.strokeColor = [SKColor whiteColor];
    newCell.zPosition = 0.2;
    
    newCell.fillColor = aiColor;
    
    
    
    /*add label for AI name*/
    SKLabelNode *nameOfCell = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    nameOfCell.text = aiName;
    nameOfCell.fontSize = newCell.getRadius*0.8;
    nameOfCell.fontColor =[UIColor colorWithRed:236.0 green:206.0 blue:118.0 alpha:1.0];
    nameOfCell.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    nameOfCell.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    newCell.nameOfAi = nameOfCell;
    [newCell addChild:nameOfCell];
    
    /*ADD SPECIFIC BACKGROUND*/
    if ([aiName isEqualToString:@"WiFi"] || [aiName isEqualToString:@"Orange"]
        || [aiName isEqualToString:@"Email" ]|| [aiName isEqualToString:@"Chrome"]
        || [aiName isEqualToString:@"Tweet"])
    {
        /*add specific background*/
        SKSpriteNode *cellBackground = [SKSpriteNode spriteNodeWithImageNamed:aiName];
        cellBackground.xScale = 2*newCell.getRadius/cellBackground.size.width;
        cellBackground.yScale = 2*newCell.getRadius/cellBackground.size.height;
        [newCell addChild:cellBackground];
        newCell.specificBackground = cellBackground;
        
        /*change the other attribute feature*/
        newCell.nameOfAi.zPosition = 0.3;
        newCell.nameOfAi.fontColor = [UIColor blackColor];
        
        newCell.fillColor = nil;
    }

    
    /*run ball animation*/
    [newCell ballAnimation];
    
    /*get random position*/
    newCell.position = location;
    
    return newCell;
    
}

- (float)getRadius
{
    /* at present, just use sum of volume of food as the player volume*/
    float currentVolume = 3.14*BASICRADIUS*BASICRADIUS*self.numberOfMass;
    self.radius = sqrt(currentVolume/3.14);
    
    return self.radius;
}

-(void)setBody
{
    

    self.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-self.radius, -self.radius, self.radius*2, self.radius*2)].CGPath;
    
    /*add physical body*/
    [self addPhysical];
    
    
}


/*add physical body*/
-(void)addPhysical
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.radius ];
    self.physicsBody.friction = 0.0;
    self.physicsBody.linearDamping = 0.0; // ignore the air resistance
    self.physicsBody.restitution = 0.0;; // how many power rest, after collosion
    self.physicsBody.allowsRotation = NO; // force will not effect the speed
    self.physicsBody.affectedByGravity = NO;
    
    //set collision detection
    self.physicsBody.categoryBitMask = animyCategory;
    self.physicsBody.collisionBitMask =  boundaryCategory | obstacleCategory;
    
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

/*RANDOM POSITION METHOD*/
-(CGPoint)getRandomPosition:(float)width Height:(float)height
{
    BOOL vaildPostion = false;
    CGPoint randomPosition;
    
    while (!vaildPostion) {
        
        float x = arc4random_uniform(GRID);
        float y = arc4random_uniform(GRID);
        
        randomPosition.x = x;
        randomPosition.y = y;
        
        if (x > width/2 && x < (GRID - width/2) && y > height/2 && y < (GRID - height/2)) {
            vaildPostion = true;
        }
    }
    
    return randomPosition;
}

/*ate function*/
-(void)ateFunction:(int)number
{
    
    self.numberOfMass = self.numberOfMass + number;
    [self setBody];
}

- (void) moveMethod  {
    
    self.physicsBody.velocity = CGVectorMake(self.direction.x*self.aiSpeed, self.direction.y*self.aiSpeed);
}

/*towards a point*/
-(void)calculateTheDirection:(CGPoint)location
{
    float distance = sqrtf((location.x - self.position.x)*(location.x - self.position.x)+
                           (location.y - self.position.y)*(location.y - self.position.y));
    
    self.direction = CGPointMake((location.x-self.position.x)/distance, (location.y-self.position.y)/distance);
    
    self.physicsBody.velocity = CGVectorMake(self.direction.x*self.aiSpeed, self.direction.y*self.aiSpeed);
    
}

@end
