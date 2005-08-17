#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRTextEditor.h"

@class GRDocView;

@interface GRText : NSObject
{
    GRDocView *myView;
    NSString *str;
    NSFont *font;
    NSPoint pos;
    float fsize;
    NSTextAlignment align;
    float parspace;
    NSSize size;
    NSRect bounds;
    float scalex, scaley;
    float rotation;
    float strokeColor[4], fillColor[4];
    float strokeAlpha, fillAlpha;
    float zmFactor;
    BOOL stroked, filled;
    BOOL visible, locked;
    GRTextEditor *editor;
    BOOL isSelect;
    BOOL isvalid;
    NSRect selRect;
}

- (id)initInView:(GRDocView *)aView
         atPoint:(NSPoint)p
                    zoomFactor:(float)zf
                    openEditor:(BOOL)openedit;

- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(float)zf;

- (GRText *)duplicate;

- (NSDictionary *)objectDescription;

- (NSString *)psDescription;

- (NSString *)fontName;

- (void)setString:(NSString *)aString attributes:(NSDictionary *)attrs;

- (void)edit;

- (BOOL)pointInBounds:(NSPoint)p;

- (void)moveAddingCoordsOfPoint:(NSPoint)p;

- (void)setZoomFactor:(float)f;

- (void)setScalex:(float)x scaley:(float)y;

- (void)setRotation:(float)r;

- (void)setStroked:(BOOL)value;

- (BOOL)isStroked;

- (void)setStrokeColor:(float *)c;

- (float *)strokeColor;

- (void)setStrokeAlpha:(float)alpha;

- (float)strokeAlpha;

- (void)setFilled:(BOOL)value;

- (BOOL)isFilled;

- (void)setFillColor:(float *)c;

- (float *)fillColor;

- (void)setFillAlpha:(float)alpha;

- (float)fillAlpha;

- (void)setVisible:(BOOL)value;

- (void)setLocked:(BOOL)value;

- (void)select;

- (void)selectAsGroup;

- (void)unselect;

- (BOOL)isSelect;

- (BOOL)isGroupSelected;

- (void)Draw;

- (void)setIsValid:(BOOL)value;

- (BOOL)isValid;

@end

