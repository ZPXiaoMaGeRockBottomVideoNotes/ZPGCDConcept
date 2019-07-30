//
//  ViewController.m
//  多线程的基本概念
//
//  Created by 赵鹏 on 2019/7/25.
//  Copyright © 2019 赵鹏. All rights reserved.
//

/**
 iOS中常见的多线程方案：
 1、pthread：
 （1）一套通用的多线程API；
 （2）适用于Unix\Linux\Windows等系统；
 （3）跨平台\可移植；
 （4）使用难度大；
 （5）线程生命周期需要开发者进行管理。
 2、NSThread：
 （1）使用更加面向对象；
 （2）简单易用，可直接操作线程对象；
 （3）线程生命周期需要开发者进行管理。
 3、GCD：
 （1）旨在替代NSThread等线程技术；
 （2）充分利用设备的多核；
 （3）线程生命周期自动管理。
 4、NSOperation：
 （1）基于GCD（底层是GCD）；
 （2）比GCD多了一些更简单实用的功能；
 （3）使用更加面向对象；
 （4）线程生命周期自动管理。
 
 GCD中包含两个函数：同步函数(dispatch_sync)和异步函数(dispatch_async)；
 GCD中包含两个队列：串行队列和并发队列。
 
 GCD的队列：
 GCD的队列可以分为两大类型：
 1、并发队列（Concurrent Dispatch Queue）：
 （1）可以让多个任务并发（同时）执行（自动开启多个线程同时执行任务）；
 （2）并发功能只有在异步（dispatch_async）函数下才有效。
 2、串行队列（Serial Dispatch Queue）：让任务一个接着一个地执行（一个任务执行完毕后，再执行下一个任务）。
 
 容易混淆的术语：有4个术语比较容易混淆：同步、异步、并发、串行。
 1、同步和异步主要影响：能不能开启新的线程。
 （1）同步：在当前线程中执行任务，不具备开启新线程的能力；
 （2）异步：在新的线程中执行任务，具备开启新线程的能力，但不一定会开启新线程（例如：主队列+异步函数，结果是在主线程中串行地执行任务）。
 2、并发和串行主要影响：任务的执行方式；
 （1）并发：多个任务并发（同时）执行；
 （2）串行：一个任务执行完毕后，再执行下一个任务。
 
 并发队列+异步函数：根据代码，系统会先创建一个并发队列，然后把多个任务不分顺序地放到这个并发队列中，由于在代码中调用了异步函数，所以系统会创建多个新的子线程，然后会把那些任务从并发队列中不分先后、几乎同时地放到那些新创建的子线程中（一个子线程放一个任务）执行；
 串行队列+异步函数：根据代码，系统会先创建一个串行队列，然后把多个任务按照先后顺序放到这个串行队列中，因为是串行队列，所以不具备开启新线程的能力，所以系统会把串行队列中的任务按照FIFO（先进先出，后进后出）的原则把它们一个一个地放到当前的线程中执行。
 */

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self test];
    
//    [self test1];
    
//    [self test2];
    
//    [self test3];
    
//    [self test4];
    
//    [self test5];
    
//    [self test6];
    
    [self test7];
}

#pragma mark ————— 异步函数 —————
- (void)test
{
    //获取全局的并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    //用异步的方式执行任务：在一个新开启的子线程中执行任务
    dispatch_async(queue, ^{
        NSLog(@"执行任务 - %@", [NSThread currentThread]);
    });
}

#pragma mark ————— 同步函数 —————
- (void)test1
{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    //用同步的方式执行任务：在当前的线程（主线程）中执行任务
    dispatch_sync(queue, ^{
        NSLog(@"执行任务 - %@", [NSThread currentThread]);
    });
}

#pragma mark ————— 并发队列 —————
/**
 可以让多个任务并发（同时）执行（自动开启多个子线程同时执行任务）；
 并发功能只有在异步（dispatch_async）函数下才有效。
 */
- (void)test2
{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    //在新开启的子线程中执行任务
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++)
        {
            NSLog(@"执行任务1 - %@", [NSThread currentThread]);
        }
    });
    
    //在新开启的子线程中执行任务
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++)
        {
            NSLog(@"执行任务2 - %@", [NSThread currentThread]);
        }
    });
}

#pragma mark ————— 串行队列 —————
//让任务一个接一个地执行（一个任务执行完毕后，再执行下一个任务）。
- (void)test3
{
    //创建一个串行队列
    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_SERIAL);
    
    //因为是异步函数，所以具备开启新线程的能力，又因为是串行队列，所以只能在新开辟的子线程中串行地执行任务。
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++)
        {
            NSLog(@"执行任务1 - %@", [NSThread currentThread]);
        }
    });
    
    //在之前新开辟的子线程中等任务1全都执行完毕以后再执行任务2。
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++)
        {
            NSLog(@"执行任务2 - %@", [NSThread currentThread]);
        }
    });
}

#pragma mark ————— 线程卡死 —————
/**
 在本方法内获取的是主队列，然后又使用的是同步函数(dispatch_sync)执行任务，意味着在当前线程（主线程）中执行任务2。现在的情况是在主线程中已经有一个正在执行的任务(test4)了，又来了一个新的任务（任务2）准备在主线程中串行地执行，由于GCD的原理，在主线程上执行的任务必须一个挨一个地执行，所以想要执行任务2，就必须等当前正在执行的test4执行完了以后才行，但是由于同步函数的原理，必须要立即执行任务2，所以就造成了矛盾，以至于会出现"EXC_BAD_INSTRUCTION"(线程卡死)的问题。
 */
- (void)test4
{
    NSLog(@"执行任务1");
    
    //获取主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    //同步函数执行任务
    dispatch_sync(queue, ^{
        NSLog(@"执行任务2");
    });
    
    NSLog(@"执行任务3");
}

#pragma mark ————— 线程不卡死 —————
/**
 在本方法内获取的是主队列，然后又使用的是异步函数(dispatch_async)执行任务，意味着在当前线程（主线程）中执行任务2。现在的情况是在主线程中已经有一个正在执行的任务(test4)了，又来了一个新的任务（任务2）准备在主线程中串行地执行，由于GCD的原理，在主线程上执行的任务必须一个挨一个地执行，所以想要执行任务2，就必须等当前正在执行的test4执行完了以后才行，与同步函数不同的是，异步函数不要求立即执行任务2，可以等待主线程中当前正在执行的任务执行完了以后再执行任务2，所以打印的结果是“执行任务1 执行任务3 执行任务2”。
 */
- (void)test5
{
    NSLog(@"执行任务1");
    
    //获取主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    //异步函数执行任务
    dispatch_async(queue, ^{
        NSLog(@"执行任务2");
    });
    
    NSLog(@"执行任务3");
}

#pragma mark ————— 另一种线程卡死 —————
/**
 在本方法内获取的是一个串行队列，然后又使用异步函数(dispatch_async)来执行block 0，在block 0里面又使用了一个同步函数(dispatch_sync)来执行block 1。现在的情况是主线程中先执行任务1和任务5，执行完毕后，然后系统会开辟一条子线程来执行任务2，之后还会在这条子线程中串行地执行任务3，但是由于同步函数的特点，必须要在子线程中立即执行任务3，但是子线程中当前还要继续执行任务4了，任务4还没有执行完了就没有办法执行任务3，所以就会造成"EXC_BAD_INSTRUCTION"(线程卡死)的问题。
 */
- (void)test6
{
    NSLog(@"执行任务1");
    
    //获取串行队列
    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_SERIAL);
    
    //异步函数执行任务
    dispatch_async(queue, ^{  //block 0
        NSLog(@"执行任务2");
        
        //同步函数执行任务
        dispatch_sync(queue, ^{  //block 1
            NSLog(@"执行任务3");
        });
        
        NSLog(@"执行任务4");
    });
    
    NSLog(@"执行任务5");
}

#pragma mark ————— 另一种线程不卡死 —————
/**
 在本方法内创建一个串行队列queue和一个并发队列queue1，然后又使用异步函数(dispatch_async)来执行block 0，在block 0里面又使用了一个同步函数(dispatch_sync)来执行block 1。现在的情况是主线程中先执行任务1和任务5，由于使用了异步函数，所以系统会开辟一条子线程，在子线程执行任务2之前这个任务2会被放到串行队列queue中，后面又使用了同步函数来执行任务3，同样，在执行任务3之前这个任务3会被放到并发队列queue1中，由于同步函数的特性，要求立即执行任务3，所以任务3会被系统从queue1中放到主线程中优先执行，然后等任务3执行完了以后再把任务4从queue中放到主线程中继续执行，所以最后的打印结果是"执行任务1 执行任务5 执行任务2 执行任务3 执行任务4"。
 */
- (void)test7
{
    NSLog(@"执行任务1");
    
    //创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_SERIAL);
    
    //创建并发队列
    dispatch_queue_t queue1 = dispatch_queue_create("myqueue1", DISPATCH_QUEUE_CONCURRENT);
    
    //异步函数执行任务
    dispatch_async(queue, ^{  //block 0
        NSLog(@"执行任务2");
        
        //在并发队列中同步函数执行任务
        dispatch_sync(queue1, ^{  //block 1
            NSLog(@"执行任务3");
        });
        
        NSLog(@"执行任务4");
    });
    
    NSLog(@"执行任务5");
}

@end
