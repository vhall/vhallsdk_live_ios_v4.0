//
//  VHDocListModel.h
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class VHRoomDocumentModel;
@interface VHDocListModel : NSObject

@property (nonatomic, copy) NSString *document_id;     ///<paas文档ID
@property (nonatomic, copy) NSString *file_name;     ///<文件名
@property (nonatomic, assign) NSInteger size;     ///<文件大小 字节数
@property (nonatomic, copy) NSString *created_at;     ///<创建时间
@property (nonatomic, copy) NSString *updated_at;     ///<修改时间
@property (nonatomic, copy) NSString *ext;       ///<文档类型扩展名
@property (nonatomic,assign, getter=isSelected) BOOL selected;  ///<是否选中

+ (NSArray <VHDocListModel *> *)modelArrWithInteractDocModelArr:(NSArray<VHRoomDocumentModel *> *)array;


@end

NS_ASSUME_NONNULL_END
