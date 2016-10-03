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

//when we created a new MVC using this method to test it first before we connect it with other
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.textToAnalyse = [[NSAttributedString alloc] initWithString:@"test" attributes:@{NSForegroundColorAttributeName:[UIColor greenColor],NSStrokeColorAttributeName:@-3}];
}

-(void)setTextToAnalyse:(NSAttributedString *)textToAnalyse
{
    _textToAnalyse = textToAnalyse;
    if (self.view.window) {
        [self updateUI];
    }
}

-(void)updateUI
{
    self.colorfulCharactersLabel.text = [NSString stringWithFormat:@"%d colorful characters", [[self charactersWithAttribute:NSForegroundColorAttributeName] length]];
    
    self.outlinedCharactersLabel.text = [NSString stringWithFormat:@"%d outlined characters",[[self charactersWithAttribute:NSStrokeColorAttributeName] length]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

-(NSAttributedString *)charactersWithAttribute:(NSString *)attributeName
{
    NSMutableAttributedString *characters = [[NSMutableAttributedString alloc] init];
    
    int index = 0;
    while (index < [self.textToAnalyse length]) {
        
        NSRange range;
        //it could be a font/color so it is id format
        id value = [self.textToAnalyse attribute:attributeName atIndex:index effectiveRange:&range];
        
        if(value)
        {
            [characters appendAttributedString:[self.textToAnalyse attributedSubstringFromRange:range]];
        }else
        {
            index ++;
        }
    }
    
    return characters;
}



@end
