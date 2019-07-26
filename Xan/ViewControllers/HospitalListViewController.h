//
//  HospitalListViewController.h
//  Xan
//
//  Created by Martina Makasare on 7/26/19.
//  Copyright © 2019 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HospitalListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *hospitalTableView;


@end

NS_ASSUME_NONNULL_END
