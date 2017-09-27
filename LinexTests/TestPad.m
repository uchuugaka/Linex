//
//  Pad.m
//  Linex
//
//  Created by Kaunteya Suryawanshi on 26/09/17.
//  Copyright © 2017 Kaunteya Suryawanshi. All rights reserved.
//

#import <Foundation/Foundation.h>

// https://regex101.com/r/w07BiC/2

@property int age;
//Name of person
@property NSString *name;
@property       (nonatomic, assign) BOOL useAnimation;
@property           (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, strong) UIView *indicator;
@property (nonatomic,     strong) NSDate * showStarted;

@property (nonatomic, strong, class) NSArray* paddingConstraints;
@property (nonatomic, strong) NSArray *bezelConstraints;
@property (nonatomic, strong) UIView *      topSpacer;
@property (nonatomic, strong) UIView    *bottomSpacer;
@property (nonatomic, weak) NSTimer *graceTimer;
@property (nonatomic, weak) NSTimer* minShowTimer;
@property (nonatomic, weak) NSTimer *hideDelayTimer;
@property (nonatomic, weak) CADisplayLink *progressObjectDisplayLink; //Bottom Space of
