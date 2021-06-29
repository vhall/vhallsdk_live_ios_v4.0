//
//  VHDocListModel.m
//  UIModel
//
//  Created by leiheng on 2021/4/14.
//  Copyright © 2021 www.vhall.com. All rights reserved.
//

#import "VHDocListModel.h"
#import <VHInteractive/VHRoom.h>

@implementation VHDocListModel

+ (NSArray <VHDocListModel *> *)modelArrWithInteractDocModelArr:(NSArray<VHRoomDocumentModel *> *)array {
    NSMutableArray <VHDocListModel *> *tempArr = [NSMutableArray array];
    for(int i = 0 ; i < array.count ; i++) {
        VHRoomDocumentModel *docModel = array[i];
        VHDocListModel *model = [[VHDocListModel alloc] init];
        model.file_name = docModel.file_name;
        model.size = docModel.size;
        model.created_at = docModel.created_at;
        model.updated_at = docModel.updated_at;
        model.document_id = docModel.document_id;
        model.ext = docModel.ext;
        [tempArr addObject:model];
    }
    return [tempArr copy];
}
@end
