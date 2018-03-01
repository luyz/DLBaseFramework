//
//  DLPersonAddressBookHelper.m
//  Catalyzer
//
//  Created by luyz on 2017/3/26.
//  Copyright © 2017年 luyz. All rights reserved.
//

#import "DLPersonAddressBookHelper.h"
#import <Contacts/Contacts.h>
#import "NSDictionary+DLExtension.h"
#import "NSString+DLExtension.h"
#import "SBJson.h"

@implementation DLPersonAddressBookHelper

DEF_SINGLETON(DLPersonAddressBookHelper);

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

-(void)initData
{
    [self addNotifityAddressBook];
}

-(void)addNotifityAddressBook
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookDidChange:) name:CNContactStoreDidChangeNotification object:nil];
}

-(void)addressBookDidChange:(NSNotification*)notification{
    // 比如上传
    NSLog(@"contacts :%@",notification);
    
    [self getAllData];
}

-(void)checkStatusAndGetData:(void (^)(BOOL status))block
{
    // 1.获取授权状态
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    // 2.判断授权状态,如果不是已经授权,则直接返回
    if (status != CNAuthorizationStatusAuthorized){
        // ios 9
        CNContactStore *contactStore = [[CNContactStore alloc] init]; // 创建通讯录
        // 请求授权
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(granted?@"授权成功!":@"授权失败!");
            if (block!=nil) {
                block(granted);
            }
        }];
    }
    if (block!=nil) {
        block(YES);
    }
}

-(void)getAllData
{
    [self checkStatusAndGetData:^(BOOL status) {
        if (status) {
            
            // 3.创建通信录对象
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            
            // 4.创建获取通信录的请求对象
            // 4.1.拿到所有打算获取的属性对应的key
            NSArray *keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
            
            // 4.2.创建CNContactFetchRequest对象
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
            
            //5.创建联系人数组
            NSMutableArray *contactArray = [[NSMutableArray alloc]init];
            
            // 5.1.遍历所有的联系人
            [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                // 1.创建联系人信息字典
                NSMutableDictionary* tempDic = [[NSMutableDictionary alloc]init];
                
                // 2.获取联系人的姓名
                NSString *lastname = contact.familyName;
                NSString *firstname = contact.givenName;
                NSLog(@"%@ %@", lastname, firstname);
                
                NSString *name = [NSString stringWithFormat:@"%@%@",lastname,firstname];
                [tempDic sObject:name forKey:@"name"];
                
                // 3.获取联系人的电话号码
                NSArray *phoneNums = contact.phoneNumbers;
                for (CNLabeledValue *labeledValue in phoneNums) {
                    // 2.1.获取电话号码的KEY
                    NSString *phoneLabel = labeledValue.label;
                    
                    // 2.2.获取电话号码
                    CNPhoneNumber *phoneNumer = labeledValue.value;
                    NSString *phoneValue = phoneNumer.stringValue;
                    NSLog(@"%@ %@", phoneLabel, phoneValue);
                    
                    //3.1.存取纯数字号码
                    NSString *normalphoneNumber = [self chinesePhoneNumber:phoneValue];
                    
                    //3.2.判断是否为手机号
                    if(normalphoneNumber.length >= 11){
                        NSString *phoneNumber = [normalphoneNumber substringFromIndex:normalphoneNumber.length - 11];
                        
                        //3.3.手机号存入字典
                        if ([phoneNumber isTelephone])
                        {
                            [tempDic sObject:phoneNumber forKey:@"phone"];
                        }
                    }
                }
                
                //如果姓名有其对应的手机号添加字典到联系人数组
                if(tempDic.count >= 2)
                {
                    [contactArray addObject:tempDic];
                }
                
            }];
            
            if (self.block!=nil) {
                self.block(0,[contactArray JSONRepresentation]);
            }
        }
    }];
    
}

//对系统电话号进行处理
-(NSString *)chinesePhoneNumber:(NSString *)phoneNumber
{
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+  "];
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet: doNotWant]componentsJoinedByString: @""];
    return phoneNumber;
}

@end
