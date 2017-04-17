//
//  DLFileModel.h
//  DLBase
//
//  Created by lucaslu on 16/1/18.
//  Copyright © 2016年 lucaslu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLModel.h"
#import "DLFactory.h"

typedef enum {
    EFile_Text = 1,
    EFile_Image,
    EFile_Voice,
    EFile_Video,
    EFile_Word,
    EFile_Excel,
    EFile_Ppt,
    EFile_Pdf,
    EFile_Zip,
    EFile_Other
}TDLFileType;

@interface DLFileModel : NSObject 

AS_FACTORY(DLFileModel);

AS_MODEL_STRONG(NSString, myFileUrl);
AS_MODEL_STRONG(NSString, myFilePath);
AS_MODEL_STRONG(NSString, myFileName);
AS_MODEL_STRONG(NSString, myFileSize);

AS_MODEL_STRONG(NSString, myFileSuffix);

AS_MODEL(TDLFileType, myFileType);

AS_BOOL(isSelete);

AS_MODEL_STRONG(NSString, myUid);
AS_MODEL_STRONG(NSString, myTimer);

//0未下载 1 正在下载 2已下载
AS_INT(currDownStatus);

-(void)setFile:(NSString*)url
      withPath:(NSString*)path
      withSize:(NSString*)size
      withName:(NSString*)name;

@end
