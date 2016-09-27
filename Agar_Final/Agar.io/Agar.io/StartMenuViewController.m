//
//  StartMenuViewController.m
//  Agar.io
//
//  Created by SUN YU on 3/10/2015.
//  Copyright (c) 2015 SUN YU. All rights reserved.
//

#import "StartMenuViewController.h"
#import "GameViewController.h"

@interface StartMenuViewController ()

@end

@implementation StartMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"singleGame"]) {
        GameViewController *controller = (GameViewController *)segue.destinationViewController;
        
        controller.customerName = self.textField.text;
        controller.gameType = @"singleGame";
      
    }
    
    if ([segue.identifier isEqualToString:@"onlineGame"]) {
        GameViewController *controller = (GameViewController *)segue.destinationViewController;
        
        controller.customerName = self.textField.text;
        controller.gameType = @"onlineGame";
        
    }
    
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
