# AssociateWeakDemo
 要在 category 中定义属性, 唯一的办法就是使用关联对象. 但是关联对象的存储方式只有 assign, retain, copy 三种, 并没有 weak. 想要使用 weak 属性就要自己想办法了.

我们自定义类如下
```
@interface MyObject : NSObject
@end

@implementation MyObject
@end
```
测试代码如下, 在一个 viewcontroller 的 viewDidLoad 中, 我们定义一个 MyObject 对象, 并未其中的 weakObj 赋值.
```
- (void)viewDidLoad {
    [super viewDidLoad
![](http://upload-images.jianshu.io/upload_images/943998-014e43df98242088.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
];
    self.myObj = [MyObject new];
    self.myObj.weakvalue = [NSObject new];
}
```
在viewDidDisappear 中去获取值
```
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"weak value is: %@", self.myObj.weakvalue);
}
```

### 直接使用 assign
代码如下
```
void *weakValueKey = NULL;
-(void)setWeakvalue:(NSObject *)weakvalue {
    objc_setAssociatedObject(self, weakValueKey, weakvalue, OBJC_ASSOCIATION_ASSIGN);
}
-(NSObject *)weakvalue {
    return objc_getAssociatedObject(self, weakValueKey);
}
```
不用怀疑, 不会自动值为 nil , 如果在对象释放之后访问, 将会直接崩溃.
![崩溃了](http://upload-images.jianshu.io/upload_images/943998-46ad4f6d3dcd8383.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 解决方案
最简单的解决方案就是使用 block 包起来. 先来看代码
```
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
```
运行结果
![image.png](http://upload-images.jianshu.io/upload_images/943998-1b04f81c9c3d7d7d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 原理解析:
首先我们在 setter 方法里面使用了一个weak 的局部变量 weakObj 来存储值. 并在 block 中将其捕获并返回.
由于 weakObj 是弱引用, 所以不会修改对象的引用计数. 当对象释放时, 由于 weakObj的 weak属性, 它也会在释放后指向nil. 所以挡在 getter 中返回的时候, 自然也是返回 nil.
