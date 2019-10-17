//
//  HospitalListViewController.m
//  Xan
//
//  Created by Martina Makasare on 7/26/19.
//  Copyright © 2019 Xanadutec. All rights reserved.
//

#import "HospitalListViewController.h"

@interface HospitalListViewController ()

@end

@implementation HospitalListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.hospitalTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UIView * hospitalView = [cell viewWithTag:100];
        hospitalView.layer.borderWidth = 1;
    hospitalView.layer.borderColor = [[UIColor colorWithRed:239.0/255.0 green:235.0/255.0 blue:239.0/255.0 alpha:1] CGColor];
        hospitalView.layer.cornerRadius = 5;
        hospitalView.clipsToBounds = true;
    //  Configure the cell...
    return cell;
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
