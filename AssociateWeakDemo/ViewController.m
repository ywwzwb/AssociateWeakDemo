//
//  ViewController.m
//  AssociateWeakDemo
//
//  Created by 曾文斌 on 2017/7/31.
//  Copyright © 2017年 yww. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
@interface MyObject : NSObject
@end

@implementation MyObject
@end

@interface MyObject (Category)
@property(nonatomic, weak) NSObject* weakvalue;

@end



@implementation MyObject (Category)
void *weakValueKey = NULL;
-(void)setWeakvalue:(NSObject *)weakvalue {
    __weak typeof(weakvalue) weakObj = weakvalue;
    typeof(weakvalue) (^block)() = ^(){
        return weakObj;
    };
    objc_setAssociatedObject(self, weakValueKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(NSObject *)weakvalue {
    id (^block)() = objc_getAssociatedObject(self, weakValueKey);
    return block();
}
@end

@interface ViewController ()
@property(nonatomic, strong) MyObject *myObj;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myObj = [MyObject new];
    self.myObj.weakvalue = [NSObject new];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"weak value is: %@", self.myObj.weakvalue);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
