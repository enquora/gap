/*

  ArchiveService.h
  Zipper

  Copyright (C) 2012 Free Software Foundation, Inc

  Authors: Dirk Olmes <dirk@xanthippe.ping.de>
           Riccardo Mottola <rm@gnu.org>

  This application is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details

 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "ArchiveService.h"
#import "LhaArchive.h"
#import "SevenZipArchive.h"
#import "TarArchive.h"
#import "ZipArchive.h"
#import "ZooArchive.h"
#import "common.h"

@interface ArchiveService (PrivateAPI)
- (void)createArchiveForFiles:(NSArray *)filenames archiveType: (ArchiveType) archiveType;
@end

@implementation ArchiveService : NSObject
- (void)createZooArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createArchiveForFiles:filenames archiveType:ZOO];
}

- (void)create7zArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createArchiveForFiles:filenames archiveType:SEVENZIP];
}

- (void)createLhaArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createArchiveForFiles:filenames archiveType:LHA];
}

- (void)createZipArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createArchiveForFiles:filenames archiveType:ZIP];
}

- (void)createTarArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createArchiveForFiles:filenames archiveType:TAR];
}

- (void)createZippedTarArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createArchiveForFiles:filenames archiveType:TARGZ];
}
- (void)createBZippedTarArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createArchiveForFiles:filenames archiveType:TARBZ2];
}

- (void)createXzTarArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createArchiveForFiles:filenames archiveType:TARXZ];
}
@end

@implementation ArchiveService (PrivateAPI)
- (void)createArchiveForFiles:(NSArray *)filenames archiveType: (ArchiveType) archiveType;
{
	int rc;
	
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setTitle:@"Archive destination"];
	rc = [panel runModalForDirectory:NSHomeDirectory() file:nil];
	if (rc == NSOKButton)
	  {
	    NSString *archiveFile = [panel filename];
	    // create the archive
	    switch (archiveType)
	      {
		case TAR:
		case TARGZ:
		case TARBZ2:
		case TARXZ:
	    	  [TarArchive createArchive:archiveFile withFiles:filenames archiveType:archiveType];
		  break;
		case LHA:
	     	  [LhaArchive createArchive:archiveFile withFiles:filenames archiveType:archiveType];
		  break;
		case ZIP:
	          [ZipArchive createArchive:archiveFile withFiles:filenames archiveType:archiveType];
		  break;
		case SEVENZIP:
	          [SevenZipArchive createArchive:archiveFile withFiles:filenames archiveType:archiveType];
		  break;
		case ZOO:
	          [ZooArchive createArchive:archiveFile withFiles:filenames archiveType:archiveType];
		  break;
		default:
		  NSRunAlertPanel(@"Error", @"Archive type not supported for archive creation",
						@"OK", nil, nil, nil);
	      }
	  }
}
@end
