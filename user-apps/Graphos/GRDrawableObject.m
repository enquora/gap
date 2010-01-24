/*
 Project: Graphos
 GRDrawableObject.h

 Copyright (C) 2008-2010 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2008-02-25

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

#import "GRDrawableObject.h"
#import "GRObjectEditor.h"


@implementation GRDrawableObject

- (void)dealloc
{
    [editor dealloc];
    [super dealloc];
}

- (NSDictionary *)objectDescription
{
    [self subclassResponsibility: _cmd];
    return nil;
}

- (GRDrawableObject *)duplicate
{
    [self subclassResponsibility: _cmd];
    return  nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    GRDrawableObject *objCopy = NSCopyObject(self, 0, zone);
    
    objCopy->docView = [self view];
    objCopy->editor = [[self editor] retain];
    
    return objCopy;
}


- (GRDocView *)view
{
    return docView;
}

- (GRObjectEditor *)editor
{
    return editor;
}

- (BOOL)visible
{
    return visible;
}

- (void)setVisible:(BOOL)value
{
    visible = value;
    if(!visible)
        [editor unselect];
}

- (BOOL)locked
{
    return locked;
}

- (void)setLocked:(BOOL)value
{
    locked = value;
}

- (void)setZoomFactor:(float)f
{
    zmFactor = f;
}

- (void)draw
{
}


@end
