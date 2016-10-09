//
//  ViewController.m
//  Attributor
//
//  Created by SUN YU on 28/09/2016.
//  Copyright © 2016 SUN YU. All rights reserved.
//

#import "ViewController.h"
#import "TextStatsViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UIButton *outlineButton;

@end

@implementation ViewController


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //make sure the identifyer is indentical
    if ([segue.identifier isEqualToString:@"Analyze Text"]) {
        if([segue.destinationViewController isKindOfClass:[TextStatsViewController class]])
            {
                TextStatsViewController *tsvc= (TextStatsViewController *)segue.destinationViewController;
                
                tsvc.textToAnalyse = self.body.textStorage;
            }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //set the attibuted title of this button to have this attribute outline
    
    //intial a attributed string
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.outlineButton.currentTitle];
    
    //set the attributes
    [title setAttributes:@{ NSStrokeWidthAttributeName :@-3, NSStrokeColorAttributeName : self.outlineButton.tintColor } range:NSMakeRange(0,[title length])];
    
    //apply the attributes
    [self.outlineButton setAttributedTitle:title forState:UIControlStateNormal];
                            
}

-(void)viewWillAppear:(BOOL)animated
{
    //super is necessary to call, it can before and after what you do
    [super viewWillAppear:animated];
    
    //syn up when this view appear again, because although you set up listener up again, the message won't be send again
    [self usePreferredFonts];
    
    
    //set up observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredFontsChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    // this method may remove some obersvers that still needs to retain
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //instead, just removed by name
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

-(void)preferredFontsChanged:(NSNotification *)notification
{
    [self usePreferredFonts];
}

-(void)usePreferredFonts
{
    
    self.body.font =[UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.headline.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

- (IBAction)changeBodySelectionColorToMatchBackgroundOfButton:(UIButton *)sender
{
    //set attributes of the mutable string of our body to let users to change part of text in text view according to their perference.
    [self.body.textStorage addAttribute:NSForegroundColorAttributeName value:sender.backgroundColor range:self.body.selectedRange];
    
}
- (IBAction)outlineBodySelection
{
    //no need argument, because we don't depend on button to do things
    
    //use addatributes a dictionary to add one  more attributes
    [self.body.textStorage addAttributes:@{ NSStrokeWidthAttributeName :@-3, NSStrokeColorAttributeName : [UIColor blackColor]} range:self.body.selectedRange];
}
- (IBAction)unoutlineBodySelection
{
    // do not need to worry about color after since width has been removed
    [self.body.textStorage removeAttribute:NSStrokeWidthAttributeName range:self.body.selectedRange];
}




@end
