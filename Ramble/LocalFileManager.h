//
//  LocalFileManager.h
//  StraboGIS
//
//  Created by Thomas Beatty on 1/12/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LocalFileManagerDelegate
@optional
-(void)saveTemporaryFilesFailedWithError:(NSError *)error;

@end

@interface LocalFileManager : NSObject {
    id delegate;
    NSFileManager * fileManager;
}

@property(strong)id delegate;

-(id)init;
-(void)saveTemporaryFiles;

@end
