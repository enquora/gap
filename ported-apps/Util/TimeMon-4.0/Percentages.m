// Copyright 1991, 1994, 1997 Scott Hess.  Permission to use, copy,
// modify, and distribute this software and its documentation for
// any purpose and without fee is hereby granted, provided that
// this copyright notice appear in all copies.
// 
// Scott Hess makes no representations about the suitability of
// this software for any purpose.  It is provided "as is" without
// express or implied warranty.
//
#import "Percentages.h"
#import "TimeMonWraps.h"
#import "loadave.h"
#import "TimeMonColors.h"
#import <syslog.h>
#import <math.h>

// Determines how much movement is needed for a display/redisplay.
#define MINSHOWN	0.01
// Minimum values for the defaults.
#define MINPERIOD	0.1
#define MINFACTOR	4
#define MINLAGFACTOR	1

@implementation Percentages

- (id)init
{
    self = [super init];
    if(self) {
	stipple = [NSImage imageNamed:@"NSApplicationIcon"];
	defaults = [NSUserDefaults standardUserDefaults];
	[NSApp setDelegate:self];
    }
    return self;
}

-(void) drawImageRep
{
  int i;
  static float radii[3]={ 23.0, 17.0, 11.0};

  PSsetlinewidth(1.0);
  PSsetalpha(1.0);

  for(i = 0; i < 3; i++) {
    // Store away the values we redraw.
    bcopy(pcents[i], lpcents[ i], sizeof( lpcents[ i]));

    drawArc2(radii[ i],
	 90 - (pcents[i][0]) * 360,
	 90 - (pcents[i][0] + pcents[i][1]) * 360,
	 90 - (pcents[i][0] + pcents[i][1] + pcents[i][2]) * 360);
  }
    
  PSsetgray(NSBlack);
  PSmoveto(47.5, 24.0);
  PSarc(24.0, 24.0, 23.5, 0.0, 360.0);
  PSmoveto(41.5, 24.0);
  PSarc(24.0, 24.0, 17.5, 0.0, 360.0);
  PSmoveto(35.5, 24.0);
  PSarc(24.0, 24.0, 11.5, 0.0, 360.0);
  PSmoveto(24.0, 24.0);
  PSlineto(24.0, 48.0);
  PSstroke();
}

- (void)update
{
    NSImageRep *r;

    // Clear to the background color if all rings are to be
    // redrawn.
    stipple = [[NSImage alloc] initWithSize: NSMakeSize(48,48)];
    r = [[NSCustomImageRep alloc]
      initWithDrawSelector: @selector(drawImageRep)
      delegate: self];
    [r setSize: NSMakeSize(48,48)];
    [stipple addRepresentation: r];
    [NSApp setApplicationIconImage:stipple];
    DESTROY(stipple);
}

- (void)step
{
  int i, j, oIndex;
  float total;
  
  // Read the new CPU times.
  la_read( oldTimes[ laIndex]);
  
  // The general idea for calculating the ring values is to
  // first find the earliest valid index into the oldTimes
  // table for that ring.  Once in a "steady state", this is
  // determined by the lagFactor and/or layerFactor values.
  // Prior to steady state, things are restricted by how many
  // steps have been performed.	 Note that the index must
  // also be wrapped around to remain within the table.
  // 
  // The values are all then easily calculated by subtracting
  // the info at the old index from the info at the current
  // index.
  
  // Calculate values for the innermost "lag" ring.
  oIndex=(laIndex-MIN( lagFactor, steps)+laSize)%laSize;
  for( total=0, i=0; i<CPUSTATES; i++) {
    total+=oldTimes[ laIndex][ i]-oldTimes[ oIndex][ i];
  }
  if( total) {
    pcents[ 2][ 0]=(oldTimes[ laIndex][	 CP_SYS]-oldTimes[ oIndex][  CP_SYS])/total;
    pcents[ 2][ 1]=(oldTimes[ laIndex][ CP_USER]-oldTimes[ oIndex][ CP_USER])/total;
    pcents[ 2][ 2]=(oldTimes[ laIndex][ CP_NICE]-oldTimes[ oIndex][ CP_NICE])/total;
  }
  
  // Calculate the middle ring.
  oIndex=(laIndex-MIN( lagFactor+layerFactor, steps)+laSize)%laSize;
  for( total=0, i=0; i<CPUSTATES; i++) {
    total+=oldTimes[ laIndex][ i]-oldTimes[ oIndex][ i];
  }
  if( total) {
    pcents[ 1][ 0]=(oldTimes[ laIndex][	 CP_SYS]-oldTimes[ oIndex][  CP_SYS])/total;
    pcents[ 1][ 1]=(oldTimes[ laIndex][ CP_USER]-oldTimes[ oIndex][ CP_USER])/total;
    pcents[ 1][ 2]=(oldTimes[ laIndex][ CP_NICE]-oldTimes[ oIndex][ CP_NICE])/total;
  }
  
  // Calculate the outer ring.
  oIndex=(laIndex-MIN( lagFactor+layerFactor*layerFactor, steps)+laSize)%laSize;
  for( total=0, i=0; i<CPUSTATES; i++) {
    total+=oldTimes[ laIndex][ i]-oldTimes[ oIndex][ i];
  }
  if( total) {
    pcents[ 0][ 0]=(oldTimes[ laIndex][	 CP_SYS]-oldTimes[ oIndex][  CP_SYS])/total;
    pcents[ 0][ 1]=(oldTimes[ laIndex][ CP_USER]-oldTimes[ oIndex][ CP_USER])/total;
    pcents[ 0][ 2]=(oldTimes[ laIndex][ CP_NICE]-oldTimes[ oIndex][ CP_NICE])/total;
  }
  
  // Move the index forward for the next cycle.
  laIndex = (laIndex + 1) % laSize;
  steps++;
  
  // Look through the rings and see if any values changed by
  // one percent or more, and if so mark that and inner rings
  // for update.
  for( i=0; i < 3; i++) {
    for( j=0; j < 3; j++) {
      if( rint( pcents[ i][ j] * 100) != rint( lpcents[ i][ j] * 100)) {
	for( ; i < 3; i++) {
	  updateFlags[ i]=YES;
	}
	break;
      }
    }
  }
  
  // If there's a need for updating of any rings, call update.
  if( updateFlags[ 2]) {
    [self update];
  }
}

// This was for debugging, no longer needed.  I used it to hook
// up a menu item to manually call step.
- (void)cycle:(id)sender
{
     [self step];
}

// Set up to have a low priority from the get-go.
- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
#ifndef GNUSTEP
    struct task_basic_info tbi;
    unsigned ic = TASK_BASIC_INFO_COUNT;
    
    if( task_info( task_self(), TASK_BASIC_INFO, (task_info_t)&tbi, &ic) != KERN_SUCCESS) {
	return;
    }
    task_priority( task_self(), tbi.base_priority - 4, TRUE);
#endif
}

// Resize the oldTimes array and rearrange the values within
// so that as many as possible are retained, but no bad values
// are introduced.
- (void)__reallocOldTimes
{
    CPUTime *newTimes;
    // Get the new size for the array.
    unsigned newSize = layerFactor * layerFactor + lagFactor + 1;
    
    // Allocate info for the array.
    newTimes = NSZoneMalloc( [self zone], sizeof(CPUTime) * newSize);
    bzero( newTimes, sizeof(CPUTime) * newSize);
    
    // If there was a previous array, copy over values.  First,
    // an index is found for the first valid time.	Then enough
    // times to fill the rings are copied, if available.
    if( oldTimes) {
	unsigned ii, jj, elts;

	elts = MIN( lagFactor + layerFactor * layerFactor + 1, steps);
	ii = (laIndex + laSize - elts) % laSize;
	jj = MIN( laSize - ii, elts);

	if( jj) {
	    bcopy( oldTimes + ii, newTimes + 0, jj * sizeof( oldTimes[ 0]));
	}
	if( jj < elts) {
	    bcopy( oldTimes + 0, newTimes + jj, (elts - jj) * sizeof( oldTimes[ 0]));
	}

	    // Free the old times.
	NSZoneFree( [self zone], oldTimes);
    }

    // Reset everything so that we only access valid data.
    oldTimes	= newTimes;
    laIndex	= MIN( steps, laSize);
    laIndex	= MIN( laIndex, newSize)%newSize;
    steps	= MIN( steps, laSize);
    steps	= MIN( steps, newSize);
    laSize	= newSize;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    float f;
    int ret;
    CPUTime cp_time;

    NSDictionary *defs = [NSDictionary dictionaryWithObjectsAndKeys:
	@"0.5",			@"UpdatePeriod",
	@"4",			@"LagFactor",
	@"16",			@"LayerFactor",
	@"YES",			@"HideOnAutolaunch",
	@"NO",			@"NXAutoLaunch",
	// For color systems.
	@"1.000 1.000 1.000",	@"IdleColor",	// White
	@"0.333 0.667 0.867",	@"NiceColor",	// A light blue-green
	@"0.200 0.467 0.800",	@"UserColor",	// A darker blue-green
	@"0.000 0.000 1.000",	@"SystemColor",	// Blue
	// For monochrome systems.
	@"1.000",		@"IdleGray",	// White
	@"0.667",		@"NiceGray",	// Light gray
	@"0.333",		@"UserGray",	// Dark gray
	@"0.000",		@"SystemGray",	// Black
	nil];

    [defaults registerDefaults:defs];
    [defaults synchronize];
	
	// Shoot out error codes if there was an error.
    if( (ret = la_init( cp_time)) ) {
	const id syslogs[] = {
	    NULL,				// LA_NOERR
	    @"Cannot nlist /mach.",		// LA_NLIST
	    @"Must be installed setgid kmem.",	// LA_PERM
	    @"Cannot open /dev/kmem.",		// LA_KMEM
	    @"Unable to seek in /dev/kmem",	// LA_SEEK
	    @"Unable to read from /dev/kmem",	// LA_READ
	    @"table() call failed.",		// LA_TABLE
	};
	NSLog(@"TimeMon: %@", syslogs[ret]);
	NSLog(@"TimeMon: Exiting!");
	NSRunAlertPanel(@"TimeMon", syslogs[ret], @"OK", nil, nil, nil);
	[NSApp terminate:[notification object]];
    }

    // Move ourselves over to the appIcon window.
    [NSApp setApplicationIconImage:stipple];
    
    // Get us registered for periodic exec.
    f = [defaults floatForKey:@"UpdatePeriod"];
    f = MAX( f, MINPERIOD);
    [periodText setFloatValue:f];
    
    {
      SEL stepSel = @selector(step);
      NSMethodSignature *sig = [self methodSignatureForSelector:stepSel];
      
      selfStep = [[NSInvocation invocationWithMethodSignature:sig] retain];
      [selfStep setSelector:stepSel];
      [selfStep setTarget:self];
      [selfStep retainArguments];
      te = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)f invocation:selfStep repeats:YES];
    }
    
    // Get the lag factor.
    lagFactor = [defaults integerForKey:@"LagFactor"];
    lagFactor = MAX( lagFactor, MINLAGFACTOR);
    [lagText setIntValue:lagFactor];
    
    // Get the layer factor.
    layerFactor = [defaults integerForKey:@"LayerFactor"];
    layerFactor = MAX( layerFactor, MINFACTOR);
    [factorText setIntValue:layerFactor];
    
    [self __reallocOldTimes];
    bcopy(cp_time, oldTimes[ 0], sizeof(CPUTime));
    laIndex = 1;
    steps = 1;
    
    [colorFields readColors];
    if([defaults boolForKey:@"HideOnAutolaunch"]
       && [defaults boolForKey:@"NXAutoLaunch"]) {
      [NSApp hide:self];
    }
}

- (BOOL)applicationShouldTerminate:(id)sender
{ 
  // If te is installed, remove it.
  if( te) {
    [te invalidate];
    te = nil;
  }
  [stipple release];
  la_finish();
  return YES;
}

- (void)display
{
  updateFlags[ 0] = updateFlags[ 1] = updateFlags[ 2] = YES;
  [self update];
}

- (void)togglePause:(id)sender
{
  if( te) {
    NSImage *pausedStipple = [NSApp applicationIconImage];
    NSImage *pausedImage = [NSImage imageNamed:@"TimeMonP"];
    [pauseMenuCell setTitle:@"Continue"];
    [te invalidate];
    te = nil;
    /*
    [pausedStipple lockFocus];
    [pausedImage compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
    [pausedStipple unlockFocus];
    */
    [NSApp setApplicationIconImage:pausedStipple];
  } else {
    float f;
    [pauseMenuCell setTitle:@"Pause"];
    f = [defaults floatForKey:@"UpdatePeriod"];
    f = MAX( f, MINPERIOD);
    [periodText setFloatValue:f];
    te = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)f invocation:selfStep repeats:YES];
    [self display];
  }
}

- (void)setPeriod:(id)sender
{
  [defaults setObject:[periodText stringValue] forKey:@"UpdatePeriod"];
  [defaults synchronize];
  if( te) {
    float f;
    [te invalidate];
    f = [defaults floatForKey:@"UpdatePeriod"];
    f = MAX( f, MINPERIOD);
    [periodText setFloatValue:f];
    te = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)f invocation:selfStep repeats:YES];
  }
}

- (void)setLag:(id)sender
{
  [defaults setObject:[lagText stringValue] forKey:@"LagFactor"];
  [defaults synchronize];
  lagFactor = [defaults integerForKey:@"LagFactor"];
  lagFactor = MAX( lagFactor, MINLAGFACTOR);
  [lagText setIntValue:lagFactor];
  [self __reallocOldTimes];
}

- (void)setFactor:(id)sender
{
  [defaults setObject:[factorText stringValue] forKey:@"LayerFactor"];
  [defaults synchronize];
  layerFactor = [defaults integerForKey:@"LayerFactor"];
  layerFactor = MAX( layerFactor, MINFACTOR);
  [factorText setIntValue:layerFactor];
  [self __reallocOldTimes];
}

- (BOOL)textShouldEndEditing:(NSText *)sender
{
  id delegate = [sender delegate];
  
  if( delegate == factorText) {
    [self setFactor:factorText];
  } else if( delegate == periodText) {
    [self setPeriod:periodText];
  } else if( delegate == lagText) {
    [self setLag:lagText];
  }
  return YES;
}
@end
