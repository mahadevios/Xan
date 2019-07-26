//
//  ViewHospitalsTableViewController.h
//  Xan
//
//  Created by Martina Makasare on 7/26/19.
//  Copyright © 2019 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewHospitalsTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *hospitalsTableView;


@end

NS_ASSUME_NONNULL_END
