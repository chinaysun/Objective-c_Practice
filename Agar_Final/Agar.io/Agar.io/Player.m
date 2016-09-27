/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/
/********************************************************************
 FileName: Player.m
 Date: 13 Oct 2015
 Description: this is class to generate the player and control its cells
 Functions: 1. update the cell position
            2. set the camera position
            3. generate an objective array to control cells
            4. get min Cell and max Cell
 *******************************************************************/

#import "Player.h"
#import "PlayerCell.h"
#import "WorldGenerator.h"


@implementation Player

//static const uint32_t megerCategory = 0x1 << 3;

/*change to control the behaviour*/
/*below value has to equal to the initialMass in the playerCell Class*/
static int startMass = 30;


+(id)Player:(UIColor *)color WorldSize:(CGFloat)GRID PlayerName:(NSString *)playerName
{
    Player *player = [Player node];
    
    //INITIAL FIRST CELL
    PlayerCell *playerCell = [PlayerCell PlayerCell:color PlayerName:playerName];
    playerCell.cellBornTime = CACurrentMediaTime();
    playerCell.stillAlive = TRUE;
    
    [player addChild:playerCell];
    
    //have to initial first, otherwise there will be null
    player.playerCellArray = [NSMutableArray array];
    [player.playerCellArray addObject:playerCell];
    
    player.bornTime = CACurrentMediaTime();
    
    player.numberOfAIattacted = 0;
    
    player.name = @"player";
    
    player.playerName = playerName;
    
    return player;
}


- (void) updatePositionWithTimeInvterval: (CFTimeInterval) interval  {
    
    for (PlayerCell *oneOfCell in self.playerCellArray) {
        
        [oneOfCell updatePositionWithTimeInvterval:interval];
    }
    
    [self getTotalNumberOfMass];
    
}

-(void)ejectMass:(WorldGenerator *)generator
{
//    for (int i = 0; i < [self.playerCellArray count]; i++) {
    
    /* replaced by the faster method*/
    for (PlayerCell *oneOfCells in self.playerCellArray)
    {
        
        if (oneOfCells.getNumberofMass > 1.5*startMass) {
            [oneOfCells eject];
            [generator addEject:oneOfCells.fillColor Position:oneOfCells.position Direction:oneOfCells.lastDirection Radius:[oneOfCells getRadius]];
            
        }
    }
}

-(void)splitCell
{
    
    /* very important here, can not use for(Objective *c in Array) method to update,
       due to this is a faster method, visit the array via multi-threads, thus if change
       array simulately, then an expection will be thrown
     */
    
    //count outside, if not will make more split
    int numberOfObject = (int)[self.playerCellArray count];
    for (int i=0; i < numberOfObject ;i++) {
        
        PlayerCell *oneOfCell = self.playerCellArray[i];
        
        /*cell has to be alived and bigger than limitation*/
        if ([oneOfCell getNumberofMass] > 2*startMass && oneOfCell.stillAlive )
        {
            
            [oneOfCell split];
            
            PlayerCell *newPlayerCell = [PlayerCell PlayerCellSplit:oneOfCell
                                                          Direction:oneOfCell.lastDirection
                                                         PlayerName:self.playerName];
            
            
            [self addChild:newPlayerCell];
            [self.playerCellArray addObject:newPlayerCell];
        }
    }

}

-(void)cleanArray
{
    for (PlayerCell *oneOfCells in self.playerCellArray)
    {
        /*remove one dead from array once*/
        if (!oneOfCells.stillAlive) {
            [self.playerCellArray removeObject:oneOfCells];
            break;
        }
    }
}

-(void)getTotalNumberOfMass
{
    self.totalNumberOfMass = 0;
    
    for (int i=0;i<[self.playerCellArray count];i++)
    {
        PlayerCell *oneOfCells = self.playerCellArray[i];
        
        if (oneOfCells.stillAlive) {
            self.totalNumberOfMass = self.totalNumberOfMass + oneOfCells.getNumberofMass;
        }
    }
    
    self.totalNumberOfMass = self.totalNumberOfMass - startMass;
    
}

/*set the start centre Point*/
-(void)setCentreP:(CGPoint)centre
{
    self.centre = centre;
    /*set the cell 0 position*/
    ((PlayerCell *)self.playerCellArray[0]).position = centre;
}

-(CGPoint)getCentre
{
    return ((PlayerCell *)self.playerCellArray[0]).position;
}

-(void)ateVirus:(PlayerCell *)cell
{
    /* the original cell will be splited as three smaller cells*/
    [cell ateVirus];
    
    PlayerCell *newCell1 = [PlayerCell PlayerCellSplit:cell
                                             Direction:cell.lastDirection
                                            PlayerName:self.playerName];
    [self addChild:newCell1];
    [self.playerCellArray addObject:newCell1];
    
    /*the second cell will at different direction*/
    PlayerCell *newCell2 = [PlayerCell PlayerCellSplit:cell
                                             Direction:CGPointMake(cell.lastDirection.x, -cell.lastDirection.y)
                                            PlayerName:self.playerName];
    [self addChild:newCell2];
    [self.playerCellArray addObject:newCell2];
    
}

-(int)theMinCell
{
    PlayerCell *miniCell = (PlayerCell *) self.playerCellArray[0];
    int indexOfCell = 0;
    
    for (int i = 0; i<[self.playerCellArray count]; i++) {
        
        if (((PlayerCell *) self.playerCellArray[i]).getRadius < miniCell.getRadius) {
            indexOfCell = i;
        }
    }
    
    return indexOfCell;
}

-(int)theMaxCell
{
    PlayerCell *maxCell = (PlayerCell *) self.playerCellArray[0];
    int indexOfCell = 0;
    
    for (int i = 0; i<[self.playerCellArray count]; i++) {
        
        if (((PlayerCell *) self.playerCellArray[i]).getRadius > maxCell.getRadius) {
            indexOfCell = i;
        }
    }
    
    return indexOfCell;
}

/*below is alternative method for megering cells of player*/
//-(void)checkMegerable
//{
//    /*check the cells in the arrary can be megered or not*/
//    for (int i = 0; i < [self.playerCellArray count]; i++) {
//        
//        PlayerCell *firstCell = [self.playerCellArray objectAtIndex:i];
//        
//        /*check alvie or not first*/
//        if (firstCell.stillAlive)
//        {
//            CFTimeInterval currentTime = CACurrentMediaTime();
//            
//            /*if alive more than 15s then can be megerage*/
//            if ((currentTime - firstCell.cellBornTime)>15)
//            {
//                /*check other cell*/
//                for (int j = i+1; j < [self.playerCellArray count]; j++)
//                {
//                    
//                    PlayerCell *secondCell = [self.playerCellArray objectAtIndex:j];
//                    
//                    /*alive then can be megered*/
//                    if (secondCell.stillAlive)
//                    {
//                        /*check the alive time*/
//                        if ((currentTime - secondCell.cellBornTime)>15)
//                        {
//                            /*if both achieve requirements, change the mask*/
//                            firstCell.physicsBody.categoryBitMask = megerCategory;
//                            secondCell.physicsBody.categoryBitMask = megerCategory;
//                            
//                            /*calculate the distance*/
//                            CGPoint positionOne = [firstCell.scene convertPoint:firstCell.position fromNode:firstCell.parent];
//                            CGPoint positionTwo = [secondCell.scene convertPoint:secondCell.position fromNode:secondCell.parent];
//                            
//                            float distance = sqrtf((positionOne.x - positionTwo.x)*(positionOne.x - positionTwo.x)+
//                                                   (positionOne.y - positionTwo.y)*(positionOne.y - positionTwo.y));
//                            
//                            /*judge wether two cell contacted*/
//                            if (distance <= (firstCell.getRadius + secondCell.getRadius))
//                            {
//                                
//                                if (firstCell.getRadius >= secondCell.getRadius) {
//                                    
//                                    /*if the centre point of smaller cell located in bigger one*/
//                                    if (distance <= secondCell.getRadius) {
//                                        
//                                        /*bigger Cell ate smaller cell*/
//                                        [firstCell ateFunction:secondCell.getNumberofMass];
//                                        secondCell.stillAlive = false;
//                                        [secondCell removeFromParent];
//                                        
//                                    }
//                                }
//                                else
//                                {
//                                    if (distance <= firstCell.getRadius) {
//                                        
//                                        /*bigger Cell ate smaller cell*/
//                                        [secondCell ateFunction:firstCell.getNumberofMass];
//                                        firstCell.stillAlive = false;
//                                        [firstCell removeFromParent];
//                                        
//                                    }
//                                }
//                            }
//                            
//                            
//                        }
//                    }
//                    
//                   
//                }
//            }
//       
//        }
//        
//  
//    }
//}
@end
