//
//  FFViewController.m
//  Dynamics
//
//  Created by 王小飞您 on 14-2-20.
//  Copyright (c) 2014年 王小飞. All rights reserved.
//

#import "FFViewController.h"

@interface FFViewController ()<UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet UIView *bView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attBehavior;

@end

@implementation FFViewController

/**
 UIDynamicItem：用来描述一个力学物体的状态，其实就是实现了UIDynamicItem委托的对象，或者抽象为有面积有旋转的质点；
 
 *UIDynamicBehavior：动力行为的描述，用来指定UIDynamicItem应该如何运动，即定义适用的物理规则。一般我们使用这个类的子类对象来对一组UIDynamicItem应该遵守的行为规则进行描述；
 
 *UIDynamicAnimator；动画的播放者，动力行为（UIDynamicBehavior）的容器，添加到容器内的行为将发挥作用；
 
 ReferenceView：等同于力学参考系，如果你的初中物理不是语文老师教的话，我想你知道这是啥..只有当想要添加力学的UIView是ReferenceView的子view时，动力UI才发生作用。
 */


/** UIDynamicBehavior:
 除了重力和碰撞，iOS SDK还预先帮我们实现了一些其他的有用的物理行为，它们包括
 
 UIAttachmentBehavior 描述一个view和一个锚相连接的情况，也可以描述view和view之间的连接。attachment描述的是两个点之间的连接情况，可以通过设置来模拟无形变或者弹性形变的情况（再次希望你还记得这些概念，简单说就是木棒连接和弹簧连接两个物体）。当然，在多个物体间设定多个；UIAttachmentBehavior，就可以模拟多物体连接了..有了这些，似乎可以做个老鹰捉小鸡的游戏了- -…
 
 UISnapBehavior 将UIView通过动画吸附到某个点上。初始化的时候设定一下UISnapBehavior的initWithItem:snapToPoint:就行，因为API非常简单，视觉效果也很棒，估计它是今后非游戏app里会被最常用的效果之一了；
 
 UIPushBehavior 可以为一个UIView施加一个力的作用，这个力可以是持续的，也可以只是一个冲量。当然我们可以指定力的大小，方向和作用点等等信息。
 
 UIDynamicItemBehavior 其实是一个辅助的行为，用来在item层级设定一些参数，比如item的摩擦，阻力，角阻力，弹性密度和可允许的旋转等等
 
 UIDynamicItemBehavior有一组系统定义的默认值，
 allowsRotation YES
 density 1.0
 elasticity 0.0
 friction 0.0
 resistance 0.0
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
//    [self.view addGestureRecognizer:tap1];
    

    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIGravityBehavior *graBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.bView]];
    [animator addBehavior:graBehavior];
    
    UICollisionBehavior *collBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.bView]];
    collBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [animator addBehavior:collBehavior];
    
    self.animator = animator;
    
}

- (IBAction)handleAttachmentPanGesture:(UIPanGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        //
        UIOffset offset = UIOffsetMake(-25.0, -25.0);
        // 连接点
        CGPoint attachmentPoint = CGPointMake(self.bView.center.x , self.bView.center.y);
        self.attBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.bView offsetFromCenter:offset attachedToAnchor:attachmentPoint];
        
        [self.animator addBehavior:self.attBehavior];
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"s");
        [self.attBehavior setAnchorPoint:[sender locationInView:self.view]];
        
    } else if (sender.state == UIGestureRecognizerStateEnded){

        [self.animator removeBehavior:self.attBehavior];
    }
}


- (void)tapGesture
{
    if (self.view.subviews.count != 0) {
        for (UIView *view in self.view.subviews) {
            [view removeFromSuperview];
        }
    }
    
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(100, 50, 100, 100)];
    // 初始状态下加个角度
    aView.transform = CGAffineTransformRotate(aView.transform, 45);
    aView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:aView];
    
    // 1. 动画的播放者，动画的容器，绑定self.view
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // 2.1 重力行为,item为动画的执行者
    UIGravityBehavior *graBehavior = [[UIGravityBehavior alloc] initWithItems:@[aView]];
    // 往容器中添加动画
    [animator addBehavior:graBehavior];
    
    // 2.2 Collision碰撞行为
    UICollisionBehavior *collBehavior = [[UICollisionBehavior alloc] initWithItems:@[aView]];
    // 以参照物以碰撞边界（reference：参照物）
    collBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collBehavior.collisionDelegate = self;
    [animator addBehavior:collBehavior];
    
    // 3. 控制器持有，以免被ARC
    self.animator = animator;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
