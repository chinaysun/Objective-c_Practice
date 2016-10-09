//
//  TextStatsViewController.m
//  Attributor
//
//  Created by SUN YU on 3/10/2016.
//  Copyright © 2016 SUN YU. All rights reserved.
//

#import "TextStatsViewController.h"

@interface TextStatsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *colorfulCharactersLabel;
@property (weak, nonatomic) IBOutlet UILabel *outlinedCharactersLabel;

@end

@implementation TextStatsViewController


/* This is the test method
 
 //when we created a new MVC using this method to test it first before we connect it with other
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.textToAnalyse = [[NSAttributedString alloc] initWithString:@"test" attributes:@{NSForegroundColorAttributeName:[UIColor greenColor],NSStrokeColorAttributeName:@-3}];
    
    
    
}
*/

-(void)setTextToAnalyse:(NSAttributedString *)textToAnalyse
{
    //will be called to prepare for segue
    _textToAnalyse = textToAnalyse;
    
    //self.view.window is the window that your view is in, view is the top level view of your MVC
    // if this is a nil, then you are not in screen right now
    if (self.view.window) {
        
        NSLog(@"Here is a Test 1 =======> go to UpdateUI");
        //if set the text and is on screen, i will update my ui, otherwise i will let vie appear do for me
        [self updateUI];
        
        
    }
}

-(void)updateUI
{
    
    NSLog(@"Here is UpdateUI Method");
    self.colorfulCharactersLabel.text = [NSString stringWithFormat:@"%d colorful characters", [[self charactersWithAttribute:NSForegroundColorAttributeName] length]];
    NSLog(@"The number of is %d",[[self charactersWithAttribute:NSForegroundColorAttributeName] length]);
    
    self.outlinedCharactersLabel.text = [NSString stringWithFormat:@"%d outlined characters",[[self charactersWithAttribute:NSStrokeColorAttributeName] length]];
}

-(void)viewWillAppear:(BOOL)animated
{
    //if the text analaze get set, when i am not on screen, maybe before my outlets are set
    // update UI here could make sure when view appear my ui could be sync
    [super viewWillAppear:animated];
    
    NSLog(@"Here is a Test 2 =======> go to UpdateUI");
    [self updateUI];
}

-(NSAttributedString *)charactersWithAttribute:(NSString *)attributeName
{
    NSMutableAttributedString *characters = [[NSMutableAttributedString alloc] init];
    
    int index = 0;
    
    while (index < [self.textToAnalyse length]) {
        
        NSRange range;
        //it could be a font/color so it is id format
        
        //the effectiveRange will returen the range that this attribute is the same for
        id value = [self.textToAnalyse attribute:attributeName atIndex:index effectiveRange:&range];
        
        if(value)
        {
            //append all character that has the same attributes to the nsmutableattributedString, according to the range
            [characters appendAttributedString:[self.textToAnalyse attributedSubstringFromRange:range]];
            
            // if the range has been set ,then the index goes to skip the range
            index = range.location + range.length;
        }else
        {
            index ++;
        }
    }
    
    
    return characters;
}



@end
