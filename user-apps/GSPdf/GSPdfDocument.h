 /*
 *  GSPdfDocument.h: Interface and declarations for the GSPdfDocument 
 *  Class of the GNUstep GSPdf application
 *
 *  Copyright (c) 2002 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: February 2002
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#ifndef GSPDFDOCUMENT_H
#define GSPDFDOCUMENT_H

#include <Foundation/Foundation.h>
#include <AppKit/NSView.h>

@class NSWindow;
@class NSScrollView;
@class NSImageView;
@class NSTextField;
@class NSMatrix;
@class NSButton;
@class NSStepper;
@class NSTextField;
@class GSPdfDocWin;
@class PSDocument;
@class PSDocumentPage;
@class GSPdfImView;
@class GSPdf;
@class GSConsole;

@interface GSPdfDocument : NSObject
{
	NSString *myPath;
	NSString *myName;
	PSDocument *psdoc;
	int pageindex;
	float resolution;
	int pagew, pageh;
	NSSize papersize;
	BOOL isPdf;
	GSPdfDocWin *docwin;	
	NSWindow *window;
	NSScrollView *scroll;
	GSPdfImView *imageView;
	NSButton *leftButt, *rightButt;
	NSScrollView *matrixScroll;
	NSMatrix *pagesMatrix;
	NSTextField *zoomField;
	NSStepper *zoomStepper;
	NSButton *zoomButt;
	NSButton *handButt;
	NSString *gsComm;
	NSTask *task;
	BOOL busy;	
	NSFileManager *fm;
	NSNotificationCenter *nc;	
	GSPdf *gspdf;
	GSConsole *console;
}

- (id)initForPath:(NSString *)apath;

-	(NSString *)myPath;

-	(BOOL)isPdf;

- (void)nextPage:(id)sender;

- (void)previousPage:(id)sender;

- (void)goToPage:(id)sender;

- (void)makePage;

- (void)setZoomValue:(id)sender;

- (void)setPaperSize:(id)sender;

- (void)clearTempFiles;

- (void)clearTempFilesOfPage:(PSDocumentPage *)page;

- (void)setBusy:(BOOL)value;

- (void)taskOut:(NSNotification *)notif;

- (void)taskErr:(NSNotification *)notif;

- (void)endOfTask:(NSNotification *)notif;

@end

#endif // GSPDFDOCUMENT_H
