/*
 Project: FTP

 Copyright (C) 2005-2013 Riccardo Mottola

 Author: Riccardo Mottola

 Created: 2005-04-12

 Table class for file listing

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


#import <AppKit/AppKit.h>
#import "fileElement.h"

#define TAG_FILENAME @"filename"

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#define NSInteger int
#define NSUInteger unsigned
#endif


enum sortOrderDef
{
  ascending, descending, undefined
};

@interface FileTable : NSObject
{
  NSArray        *fileStructs;
  NSMutableArray *sortedArray;
  NSString       *sortByIdent;
  enum sortOrderDef   sortOrder;
}

- (void)initData:(NSArray *)fnames;
- (void)clear;
- (FileElement *)elementAtIndex:(NSUInteger)index;
- (void)sortByIdent:(NSString *)idStr;

@end
