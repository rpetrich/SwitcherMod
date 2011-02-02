#import <SpringBoard/SpringBoard.h>
#import <CaptainHook/CaptainHook.h>

@class SBAppSwitcherModel, SBNowPlayingBar, SBAppSwitcherBarView;

@interface SBAppSwitcherController : NSObject {
	SBAppSwitcherModel *_model;
	SBNowPlayingBar *_nowPlaying;
	SBAppSwitcherBarView *_bottomBar;
	SBApplicationIcon *_pushedIcon;
	BOOL _editing;
}
@property(nonatomic, readonly) SBAppSwitcherModel *model;
+ (id)sharedInstance;
- (void)viewWillAppear;
- (void)viewDidDisappear;
- (void)_quitButtonHit:(id)sender;
- (BOOL)_inEditMode;
- (void)_beginEditing;
- (void)_stopEditing;
- (void)_removeApplicationFromRecents:(SBApplication *)application;
@end

@interface SBAppSwitcherBarView : UIView {
}
- (NSArray *)appIcons;
- (void)setEditing:(BOOL)editing;
- (CGRect)_frameForIndex:(NSUInteger)iconIndex withSize:(CGSize)size; // 4.0/4.1
- (CGRect)_iconFrameForIndex:(NSUInteger)iconIndex withSize:(CGSize)size; // 4.2
@end

@interface SBAppIconQuitButton : UIButton {
	SBApplicationIcon* _appIcon;
}
@property(retain, nonatomic) SBApplicationIcon *appIcon;
@end

@interface SBAppSwitcherModel : NSObject {
	NSMutableArray* _recentDisplayIdentifiers;
}
+ (id)sharedInstance;
- (void)_saveRecents;
- (id)_recentsFromPrefs;
- (void)addToFront:(SBApplication *)application;
- (void)remove:(SBApplication *)application;
- (SBApplication *)appAtIndex:(NSUInteger)index;
- (NSUInteger)count;
- (void)appsRemoved:(NSArray *)removedApplications added:(NSArray *)addedApplications;
@end

@interface SBIcon (OS40)
- (void)setCloseBox:(UIView *)view;
- (void)setShadowsHidden:(BOOL)hidden;
- (UIImageView *)iconImageView;
@end

@interface SBIcon (OS41)
- (void)setShowsCloseBox:(BOOL)shows;
- (void)closeBoxTapped;
@end

@interface SBProcess : NSObject {
}
- (BOOL)isRunning;
@end

@interface SBApplication (OS40)
@property (nonatomic, readonly) SBProcess *process;
@end

@interface SBUIController (OS40)
- (void)_toggleSwitcher;
@end


CHDeclareClass(SBAppSwitcherController);
CHDeclareClass(SBAppIconQuitButton);
CHDeclareClass(SBApplicationIcon);
CHDeclareClass(SBAppSwitcherBarView);
CHDeclareClass(SBUIController);

static BOOL SMShowActiveApp = NO;
static BOOL SMFastIconGrabbing = NO;
static BOOL SMDragUpToQuit = NO;
static BOOL SMWiggleModeOff = YES;
static BOOL SMIconLabelsOff = NO;
static float SMExitedIconAlpha = 50.0f;
static NSInteger SMCloseButtonStyle = 0;
static NSInteger SMExitedAppStyle = 2;

enum {
	SMCloseButtonStyleBlackClose = 0,
	SMCloseButtonStyleRedMinus = 1,
	SMCloseButtonStyleNone = 2
};

enum {
	SMExitedAppStyleTransparent = 0,
	SMExitedAppStyleHidden = 1,
	SMExitedAppStyleOpaque = 2
};

static void LoadSettings()
{
	CHAutoreleasePoolForScope();
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.collab.switchermod.plist"];
	SMFastIconGrabbing = [[dict objectForKey:@"SMFastIconGrabbing"] boolValue];
	SMShowActiveApp = [[dict objectForKey:@"SMShowActiveApp"] boolValue];
	SMExitedIconAlpha = [[dict objectForKey:@"SMExitedIconAlpha"] floatValue];
	if(!SMExitedIconAlpha) SMExitedIconAlpha = 50.0f;
	SMDragUpToQuit = [[dict objectForKey:@"SMDragUpToQuit"] boolValue];
	SMCloseButtonStyle = [[dict objectForKey:@"SMCloseButtonStyle"] integerValue];
	SMExitedAppStyle = [[dict objectForKey:@"SMExitedAppStyle"] integerValue];
	if(SMExitedAppStyle == 0) SMExitedAppStyle = SMExitedAppStyleOpaque;
	if([dict objectForKey:@"SMWiggleModeOff"] != nil) SMWiggleModeOff = [[dict objectForKey:@"SMWiggleModeOff"] boolValue];
	if([dict objectForKey:@"SMIconLabelsOff"] != nil) SMIconLabelsOff = [[dict objectForKey:@"SMIconLabelsOff"] boolValue];
	
	[dict release];
}

static SBIcon *grabbedIcon;
static NSUInteger grabbedIconIndex;
static SBApplication *activeApplication;

static void ReleaseGrabbedIcon()
{
	if (grabbedIcon) {
		//[grabbedIcon setAllowJitter:YES];
		//[grabbedIcon setIsJittering:YES];
		[grabbedIcon setIsGrabbed:NO];
		[grabbedIcon release];
		grabbedIcon = nil;
	}
}

CHOptimizedMethod(0, self, void, SBAppSwitcherController, _beginEditing)
{
	// Reimplement the standard _beginEditing, but don't add the close buttons
	/*SBAppSwitcherBarView *_bottomBar = CHIvar(self, _bottomBar, SBAppSwitcherBarView *);
	for (SBIcon *icon in [_bottomBar appIcons])
		[icon setIsJittering:YES];
	CHIvar(self, _editing, BOOL) = YES;
	[_bottomBar setEditing:NO];*/
	if (!SMWiggleModeOff)
		CHSuper(0, SBAppSwitcherController, _beginEditing);

	[self viewWillAppear];	
		
}

CHOptimizedMethod(0, self, void, SBAppSwitcherController, _stopEditing)
{
	/*ReleaseGrabbedIcon();
	// Reimplement the standard _stopEditing, but don't remove the close buttons
	SBAppSwitcherBarView *_bottomBar = CHIvar(self, _bottomBar, SBAppSwitcherBarView *);
	for (SBIcon *icon in [_bottomBar appIcons])
		[icon setIsJittering:NO];
	CHIvar(self, _editing, BOOL) = NO;
	[_bottomBar setEditing:NO];*/
	if (!SMWiggleModeOff)
		CHSuper(0, SBAppSwitcherController, _stopEditing);
	
	[self viewWillAppear];	
}


CHOptimizedMethod(1, self, NSUInteger, SBAppSwitcherController, closeBoxTypeForIcon, SBApplicationIcon *, icon)
{
	switch (SMCloseButtonStyle) {
		case SMCloseButtonStyleNone:
			return 2;
			break;
		case SMCloseButtonStyleBlackClose:
			return 0;
			break;
		case SMCloseButtonStyleRedMinus:
			return 1;
			break;
		default:
			return 1;
			break;
	}
	
}


CHOptimizedMethod(0, self, void, SBAppSwitcherController, viewWillAppear)
{
	CHSuper(0, SBAppSwitcherController, viewWillAppear);
	UIImage *image;
	switch (SMCloseButtonStyle) {
		case SMCloseButtonStyleBlackClose:
			image = [UIImage imageNamed:@"closebox"];
			break;
		case SMCloseButtonStyleRedMinus:
			image = [UIImage imageNamed:@"SwitcherQuitBox"];
			break;
		default:
			image = nil;
			break;
	}
	
	for (SBApplicationIcon *icon in [CHIvar(self, _bottomBar, SBAppSwitcherBarView *) appIcons]) {
		if (CHIsClass(icon, SBApplicationIcon)) {
			SBApplication *application = [icon application];
			BOOL isRunning = [[application process] isRunning];
			[icon iconImageView].alpha = isRunning ?  1.0f : (SMExitedIconAlpha / 100);
			[icon setShadowsHidden:!isRunning];
		
			SBIconLabel *label = CHIvar(icon, _label, SBIconLabel *);
			[label setAlpha:(SMIconLabelsOff) ? 0.0f : 1.0f];
//			[icon setDrawsLabel:(SMIconLabelsOff) ? NO : YES];
					
			if ((image == nil) || (application == activeApplication))
			{
				if([icon respondsToSelector:@selector(setShowsCloseBox:)])
					[icon setShowsCloseBox:NO];
				else
					[icon setCloseBox:nil];
			}
			else
			{
				SBAppIconQuitButton *button = [CHClass(SBAppIconQuitButton) buttonWithType:UIButtonTypeCustom];
				[button setAppIcon:(SBApplicationIcon *)icon];
				[button setImage:image forState:0];
				[button addTarget:self action:@selector(_quitButtonHit:) forControlEvents:UIControlEventTouchUpInside];
				[button sizeToFit];
				CGRect frame = button.frame;
				frame.origin.x -= 10.0f;
				frame.origin.y -= 10.0f;
				button.frame = frame;
				if([icon respondsToSelector:@selector(setShowsCloseBox:)])
				{
//					[icon setShowsCloseBox:NO];
					[icon setShowsCloseBox:YES];
				}
				else
					[icon setCloseBox:button];

			}
		}
	}
}

CHOptimizedMethod(1, self, void, SBAppSwitcherController, iconTapped, SBApplicationIcon *, icon)
{
	if ([icon application] == activeApplication)
		[CHSharedInstance(SBUIController) _toggleSwitcher];
	else
		CHSuper(1, SBAppSwitcherController, iconTapped, icon);
}

CHOptimizedMethod(1, new, BOOL, SBAppSwitcherController, iconPositionIsEditable, SBIcon *, icon)
{
	//return CHIvar(self, _editing, BOOL);

	return SMFastIconGrabbing && CHIvar(self, _editing, BOOL);

}

CHOptimizedMethod(1, self, void, SBAppSwitcherController, iconHandleLongPress, SBIcon *, icon)
{
	ReleaseGrabbedIcon();
	if (!SMWiggleModeOff)
		CHSuper(1, SBAppSwitcherController, iconHandleLongPress, icon);
	//if (CHIvar(self, _editing, BOOL)) {
		// Enter "grabbed mode"
		SBAppSwitcherBarView *_bottomBar = CHIvar(self, _bottomBar, SBAppSwitcherBarView *);
		CHIvar(_bottomBar, _scrollView, UIScrollView *).scrollEnabled = NO;
		grabbedIcon = [icon retain];
		grabbedIconIndex = [[_bottomBar appIcons] indexOfObjectIdenticalTo:icon];
		[icon.superview bringSubviewToFront:icon];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.33];
		[icon setIsGrabbed:YES];
		[UIView commitAnimations];
	//} else {
	//	CHSuper(1, SBAppSwitcherController, iconHandleLongPress, icon);
	//}
}

static CGPoint IconPositionForIconIndex(SBAppSwitcherBarView *bottomBar, SBIcon *icon, NSUInteger index)
{
	// Find the position of an icon
	CGSize size = icon.bounds.size;
	CGRect frame = [bottomBar respondsToSelector:@selector(_iconFrameForIndex:withSize:)]
	             ? [bottomBar _iconFrameForIndex:index withSize:size]
	             : [bottomBar _frameForIndex:index withSize:size];
	frame.origin.x += frame.size.width * 0.5f;
	frame.origin.y += frame.size.height * 0.5f;
	return frame.origin;
}

static CGFloat DistanceSquaredBetweenPoints(CGPoint a, CGPoint b)
{
	// Calculate the distance squared between too points
	// (squared because square roots are expensive and are rarely needed when comparing)
	CGSize distance;
	distance.width = a.x - b.x;
	distance.height = a.y - b.y;
	return (distance.width * distance.width) + (distance.height * distance.height);
}

static NSInteger DestinationIndexForIcon(SBAppSwitcherBarView *bottomBar, SBApplicationIcon *icon)
{
	// Find the destination index based on the current position of the icon
	CGPoint currentPosition = [icon center];
	if (((currentPosition.y < -20.0f) && (SMDragUpToQuit)) && ([icon application] != activeApplication))
		return -1;
	NSUInteger destIndex = 0;
	CGPoint destPosition = IconPositionForIconIndex(bottomBar, icon, 0);
	CGFloat distanceSquared = DistanceSquaredBetweenPoints(currentPosition, destPosition);
	NSUInteger count = [[bottomBar appIcons] count];
	for (NSUInteger i = 1; i < count; i++) {
		CGPoint proposedPosition = IconPositionForIconIndex(bottomBar, icon, i);
		CGFloat proposedDistanceSquared = DistanceSquaredBetweenPoints(currentPosition, proposedPosition);
		if (proposedDistanceSquared < distanceSquared) {
			destIndex = i;
			destPosition = proposedPosition;
			distanceSquared = proposedDistanceSquared;
		}
	}
	return destIndex;
}

CHOptimizedMethod(2, new, void, SBAppSwitcherController, icon, SBIcon *, icon, touchMovedWithEvent, UIEvent *, event)
{
	//if (CHIvar(self, _editing, BOOL)) {
		SBAppSwitcherBarView *_bottomBar = CHIvar(self, _bottomBar, SBAppSwitcherBarView *);
		NSUInteger destIndex = DestinationIndexForIcon(_bottomBar, (SBApplicationIcon *)icon);
		if (grabbedIconIndex != destIndex) {
			grabbedIconIndex = destIndex;
			// Index has changed, reflow icons to match
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.33];
			NSUInteger i = 0;
			for (SBIcon *appIcon in [_bottomBar appIcons]) {
				if (appIcon != icon) {
					if (i == destIndex)
						i++;
					[appIcon setIconPosition:IconPositionForIconIndex(_bottomBar, appIcon, i)];
					i++;
				}
			}
			[UIView commitAnimations];
		}
	//}
}

CHOptimizedMethod(2, new, void, SBAppSwitcherController, icon, SBIcon *, icon, touchEnded, BOOL, ended)
{
	//if (CHIvar(self, _editing, BOOL)) {

		SBAppSwitcherBarView *_bottomBar = CHIvar(self, _bottomBar, SBAppSwitcherBarView *);
		CHIvar(_bottomBar, _scrollView, UIScrollView *).scrollEnabled = YES;
		if (grabbedIconIndex == -1) {
			ReleaseGrabbedIcon();
			SBAppIconQuitButton *button = [CHClass(SBAppIconQuitButton) buttonWithType:UIButtonTypeCustom];
			[button setAppIcon:(SBApplicationIcon *)icon];
			if([icon respondsToSelector:@selector(closeBoxTapped)])
				[icon closeBoxTapped];
			else
				[self _quitButtonHit:button];
			
		} else {
			// Animate into position
			NSUInteger destinationIndex = DestinationIndexForIcon(_bottomBar, (SBApplicationIcon *)icon);
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.33];
			[icon setIconPosition:IconPositionForIconIndex(_bottomBar, icon, grabbedIconIndex)];
			ReleaseGrabbedIcon();
			[UIView commitAnimations];
			// Update list of icons in the bar
			NSMutableArray *_appIcons = CHIvar(_bottomBar, _appIcons, NSMutableArray *);
			NSInteger currentIndex = [_appIcons indexOfObjectIdenticalTo:icon];
			if ((currentIndex != NSNotFound) && (currentIndex != destinationIndex)) {
				[_appIcons removeObjectAtIndex:currentIndex];
				[_appIcons insertObject:icon atIndex:destinationIndex];
			}
			// Update priority list in the switcher model
			SBAppSwitcherModel *_model = CHIvar(self, _model, SBAppSwitcherModel *);
			if (kCFCoreFoundationVersionNumber >= 550.52) {
				// 4.2+
				for (SBApplicationIcon *appIcon in [_appIcons reverseObjectEnumerator])
					[_model addToFront:[[appIcon application] displayIdentifier]];
			} else {
				// 4.0/4.1
				for (SBApplicationIcon *appIcon in [_appIcons reverseObjectEnumerator])
					[_model addToFront:[appIcon application]];
			}
				
			if (!SMWiggleModeOff)
				[self viewWillAppear];	
		}
	//}
}

/*
//CHOptimizedMethod(1, self, void, SBAppSwitcherController, _quitButtonHit, SBAppIconQuitButton *, quitButton)
{
	SBApplication *application = [[quitButton appIcon] application];
	if (application == activeApplication) {
		[CHSharedInstance(SBUIController) animateApplicationSuspend:application];
		CHSuper(1, SBAppSwitcherController, _quitButtonHit, quitButton);
	} else {
		CHSuper(1, SBAppSwitcherController, _quitButtonHit, quitButton);
	}
}*/

CHOptimizedMethod(2, self, NSArray *, SBAppSwitcherController, _applicationIconsExcept, SBApplication *, application, forOrientation, UIInterfaceOrientation, orientation)
{
	[activeApplication release];
	activeApplication = [application copy];
	if (SMShowActiveApp)
		application = nil;
	if (SMExitedAppStyle == SMExitedAppStyleHidden) {
		NSMutableArray *newResult = [NSMutableArray array];
		for (SBApplicationIcon *icon in CHSuper(2, SBAppSwitcherController, _applicationIconsExcept, application, forOrientation, orientation))
			if ([[[icon application] process] isRunning])
				[newResult addObject:icon];
		return newResult;
	} else {
		return CHSuper(2, SBAppSwitcherController, _applicationIconsExcept, application, forOrientation, orientation);
	}
}

CHOptimizedMethod(0, self, void, SBAppSwitcherBarView, layoutSubviews)
{
	CHSuper(0, SBAppSwitcherBarView, layoutSubviews);
	if ([grabbedIcon superview] == self)
		[grabbedIcon bringSubviewToFront:grabbedIcon];
}

CHConstructor {
	CHLoadLateClass(SBAppSwitcherController);
	CHHook(0, SBAppSwitcherController, _beginEditing);
	CHHook(0, SBAppSwitcherController, _stopEditing);
	CHHook(0, SBAppSwitcherController, viewWillAppear);
	CHHook(1, SBAppSwitcherController, closeBoxTypeForIcon);
	CHHook(1, SBAppSwitcherController, iconTapped);
	CHHook(1, SBAppSwitcherController, iconPositionIsEditable);
	CHHook(1, SBAppSwitcherController, iconHandleLongPress);
	CHHook(2, SBAppSwitcherController, icon, touchMovedWithEvent);
	CHHook(2, SBAppSwitcherController, icon, touchEnded);
	//CHHook(1, SBAppSwitcherController, _quitButtonHit);
	CHHook(2, SBAppSwitcherController, _applicationIconsExcept, forOrientation);
	CHLoadLateClass(SBAppIconQuitButton);
	CHLoadLateClass(SBApplicationIcon);
	CHLoadLateClass(SBAppSwitcherBarView);
	CHHook(0, SBAppSwitcherBarView, layoutSubviews);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (void *)LoadSettings, CFSTR("com.collab.switchermod.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	LoadSettings();
	CHLoadLateClass(SBUIController);
}
