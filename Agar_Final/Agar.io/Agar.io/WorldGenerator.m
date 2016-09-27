/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/
/********************************************************************
 FileName: WorldGenerator.m
 Date: 13 Oct 2015
 Description: this is class to generate the player and control its cells
 Functions: 1. random create/fixed create the food/virus/obstales based
            on game type
            2. create the boundry
            3. create the eject food
            4. online game will use fixed position
            5. single game will use random position
 *******************************************************************/

#import "WorldGenerator.h"
#import "AICell.h"
@interface WorldGenerator()
@property SKSpriteNode *world;
@property CGFloat GRID;
@end

@implementation WorldGenerator


@synthesize foodPositionNSArray;
@synthesize obstaclePositionNSArray;
@synthesize virusPositionNSArray;


static const uint32_t foodCategory = 0x1 << 2;
static const uint32_t boundaryCategory = 0x1 <<4;
static const uint32_t obstacleCategory = 0x1 <<5;
static const uint32_t virusCategory = 0x1 <<6;
// used to set collision mask, if the node in same categroy, the collison will not happen

static float foodRadius = 2;

+(id)generatorWithWorld:(SKSpriteNode *)world getSize:(CGFloat)grid
{
    WorldGenerator *generator = [WorldGenerator node];
    generator.world = world;
    generator.GRID = grid;
    return  generator;
}

/*create the boundary*/
-(void)generateBoundary
{
    /* used this for instead of the previous method for better detect the contact*/
    SKSpriteNode *edgeBottom = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(self.GRID, 1)];
    edgeBottom.position = CGPointMake(self.GRID/2, 0);
    edgeBottom.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:edgeBottom.size];
    edgeBottom.physicsBody.dynamic = NO;
    edgeBottom.physicsBody.friction = 0.0;
    edgeBottom.physicsBody.restitution = 0.0;
    edgeBottom.physicsBody.categoryBitMask = boundaryCategory;
    edgeBottom.name = @"edgeBottom";
    [self.world addChild:edgeBottom];
    
    SKSpriteNode *edgeTop = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(self.GRID, 1)];
    edgeTop.position = CGPointMake(self.GRID/2, self.GRID);
    edgeTop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:edgeTop.size];
    edgeTop.physicsBody.dynamic = NO;
    edgeTop.physicsBody.friction = 0.0;
    edgeTop.physicsBody.restitution = 0.0;
    edgeTop.physicsBody.categoryBitMask = boundaryCategory;
    edgeTop.name = @"edgeTop";
    [self.world addChild:edgeTop];
    
    SKSpriteNode *edgeLeft = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(1, self.GRID)];
    edgeLeft.position = CGPointMake(0, self.GRID/2);
    edgeLeft.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:edgeLeft.size];
    edgeLeft.physicsBody.dynamic = NO;
    edgeLeft.physicsBody.friction = 0.0;
    edgeLeft.physicsBody.restitution = 0.0;
    edgeLeft.physicsBody.categoryBitMask = boundaryCategory;
    edgeLeft.name = @"edgeLeft";
    [self.world addChild:edgeLeft];
    
    SKSpriteNode *edgeRight = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(1, self.GRID)];
    edgeRight.position = CGPointMake(self.GRID, self.GRID/2);
    edgeRight.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:edgeRight.size];
    edgeRight.physicsBody.dynamic = NO;
    edgeRight.physicsBody.friction = 0.0;
    edgeRight.physicsBody.restitution = 0.0;
    edgeRight.physicsBody.categoryBitMask = boundaryCategory;
    edgeRight.name = @"edgeRight";
    [self.world addChild:edgeRight];
    
    
    
//    SKShapeNode *edge = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, self.GRID, self.GRID)];
//    edge.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.GRID, self.GRID)];
//    edge.physicsBody.dynamic = NO;
//    edge.physicsBody.friction = 0;
//    edge.physicsBody.restitution = 0;
//    edge.physicsBody.categoryBitMask = boundaryCategory;
//    edge.name = @"boundary";
//    [self.world addChild:edge];
}


//import the food position from the JSON file
//this method return a NSArray which contains 100 arrays
-(void)importPosition{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"position" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    //    NSLog(@"dictionary:%@", jsonDict);
    
    
    foodPositionNSArray = [jsonDict objectForKey:@"foodPosition"];
    obstaclePositionNSArray = [jsonDict objectForKey:@"obstaclePosition"];
    virusPositionNSArray = [jsonDict objectForKey:@"virusPosition"];
    
    //    NSLog(@"array1:%@", foodPositionNSArray);
    
    
}

/*create food*/
-(void)generateFood:(int)number
{
    for (int i= 0; i<number; i++) {
      
        SKShapeNode *food = [SKShapeNode shapeNodeWithCircleOfRadius:foodRadius];
        
        if ([foodPositionNSArray count] > 1) {
            food.position = [self getFixPosition:i positionArray:foodPositionNSArray];
        }else
        {
            food.position = [self getRandomPosition:foodRadius Height:foodRadius];
        }

//        NSLog(@"food%d: [%f, %f]", i, food.position.x, food.position.y);
        food.zPosition = 0.2;
        food.name = @"food";
        food.strokeColor = [SKColor whiteColor];
        food.fillColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
        
        
        food.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:foodRadius];
        food.physicsBody.dynamic = NO;
        food.physicsBody.categoryBitMask = foodCategory;
        food.physicsBody.collisionBitMask = foodCategory;
        
        [self.world addChild:food];
    }
}



/*add eject*/
-(void)addEject:(UIColor *)color Position:(CGPoint)position Direction:(CGPoint)direction Radius:(float)playerRadius
{
    
    SKShapeNode *ejectMass = [SKShapeNode shapeNodeWithCircleOfRadius:foodRadius];
    
    // the distance between player and mass is 2 times of player radius,MUST OUT SIDE OF CELL
    ejectMass.position = CGPointMake(position.x + direction.x*2*playerRadius, position.y + direction.y*2*playerRadius);
    
    /*SET RUN ACTION destination*/
    CGPoint destination = CGPointMake(ejectMass.position.x + direction.x*100, ejectMass.position.y + direction.y*100);
    
    /*judge the destination out side the boudary or not*/
    if (destination.x > self.GRID) {
        destination.x = direction.x*(self.GRID - foodRadius);
    }
    
    if (destination.x < 0) {
        destination.x = foodRadius;
    }
    
    if (destination.y > self.GRID) {
        destination.y = direction.y*(self.GRID - foodRadius);
    }
    
    if (destination.y < 0) {
        destination.y = foodRadius;
    }
    
    /*start animation*/
    SKAction *action = [SKAction moveTo:CGPointMake(destination.x,destination.y)
                                 duration:0.5];
    
    [ejectMass runAction:action];
    
    
    ejectMass.zPosition = 0.2;
    ejectMass.name = @"food";
    ejectMass.strokeColor = [SKColor whiteColor];
    ejectMass.fillColor = color;
    
    ejectMass.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:foodRadius];
    ejectMass.physicsBody.dynamic = NO;
    ejectMass.physicsBody.categoryBitMask = foodCategory;
    ejectMass.physicsBody.collisionBitMask = foodCategory;
    
    [self.world addChild:ejectMass];
}


/*this method used to create the linear obstacles in the world*/
-(void) generateStaticObstacles:(int)number
{
    for (int i= 0; i<number; i++)
    {
        float obstacleWidth;
        float obstacleHeigth;
        
        /*random decide it is vertical(0) or horizontal(1)*/
        if (arc4random_uniform(2) == 0) {
            obstacleHeigth = 2;
            obstacleWidth = 80;
        }
        else
        {
            obstacleHeigth = 80;
            obstacleWidth = 2;
        }
        
        SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1] size:CGSizeMake(obstacleWidth, obstacleHeigth)];
        
        if ([obstaclePositionNSArray count] > 1) {
            obstacle.position = [self getFixPosition:i positionArray:obstaclePositionNSArray];
        }else{
            obstacle.position = [self getRandomPosition:obstacleWidth Height:obstacleHeigth];
        }

//        NSLog(@"obstacles%d: [%f, %f]", i, obstacle.position.x, obstacle.position.y);

        
        obstacle.zPosition = 0.2;
        obstacle.name = @"obstacle";
        
        obstacle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:obstacle.size];
        obstacle.physicsBody.dynamic = NO;
        obstacle.physicsBody.categoryBitMask = obstacleCategory;

        
        [self.world addChild:obstacle];
    }
    
    
}

/*generate the virus*/
-(void) generateVirus:(int)number
{
    for (int i = 0 ; i < number; i++) {
        
        SKSpriteNode *virus = [SKSpriteNode spriteNodeWithImageNamed:@"virus.png"];
        virus.xScale = 0.5;
        virus.yScale = 0.5;
//        virus.physicsBody = [SKPhysicsBody bodyWithTexture:virus.texture size:virus.texture.size];
        
        /*used below method is easier to detect contact, and from the visual when the cicle raduis bigger
          then 13, the cell could cover this picture
         */
        virus.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:13];
        virus.physicsBody.dynamic = NO;
        virus.physicsBody.categoryBitMask = virusCategory;
        virus.name = @"virus";

        
        if ([virusPositionNSArray count] > 1) {
             /*get fixed position*/
             virus.position = [self getFixPosition:i positionArray:virusPositionNSArray];
        }else{
            /*get random position*/
            virus.position = [self getRandomPosition:virus.texture.size.width/2 Height:virus.texture.size.height/2];
        }

        
        virus.zPosition = 0.3;
        
        [self.world addChild:virus];
        
    }
}

/*used in singleGame and practice model*/
-(CGPoint)getRandomPosition:(float)width Height:(float)height
{
    BOOL vaildPostion = false;
    CGPoint randomPosition;
    
    while (!vaildPostion) {
        
        float x = arc4random_uniform(self.GRID);
        float y = arc4random_uniform(self.GRID);
        
        randomPosition.x = x;
        randomPosition.y = y;
        
        if (x > width/2 && x < (self.GRID - width/2) && y > height/2 && y < (self.GRID - height/2)) {
            vaildPostion = true;
        }
    }
    
    return randomPosition;
}

/*load the fix position from json*/
-(CGPoint)getFixPosition:(int)arrayIndex positionArray:(NSArray*)arrayName{
    
    
    CGPoint fixPosition;
//    vonvert get x y coordinate from NSArray
    double x = [[[arrayName objectAtIndex:arrayIndex] objectAtIndex:0] doubleValue];
    double y = [[[arrayName objectAtIndex:arrayIndex] objectAtIndex:1] doubleValue];
    fixPosition.x = x;
    fixPosition.y = y;
    return fixPosition;

    
}


@end
