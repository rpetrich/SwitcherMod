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
- (CGRect)_frameForIndex:(NSUInteger)iconIndex withSize:(CGSize)size;
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
@end


CHDeclareClass(SBAppSwitcherController);
CHDeclareClass(SBAppIconQuitButton);
CHDeclareClass(SBApplicationIcon);
//CHDeclareClass(SBUIController);

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
}

CHOptimizedMethod(0, self, void, SBAppSwitcherController, viewWillAppear)
{
	CHSuper(0, SBAppSwitcherController, viewWillAppear);
	//UIImage *image = [UIImage imageNamed:@"SwitcherQuitBox"];
	// I like the standard closebox, not the stupid little minus
	UIImage *image = [UIImage imageNamed:@"closebox"];
	for (SBApplicationIcon *icon in [CHIvar(self, _bottomBar, SBAppSwitcherBarView *) appIcons]) {
		if (CHIsClass(icon, SBApplicationIcon)) {
			if ([icon application] == activeApplication)
				[icon setCloseBox:nil];
			else {
				// Apply my close button always
				SBAppIconQuitButton *button = [CHClass(SBAppIconQuitButton) buttonWithType:UIButtonTypeCustom];
				[button setAppIcon:(SBApplicationIcon *)icon];
				[button setImage:image forState:0];
				[button addTarget:self action:@selector(_quitButtonHit:) forControlEvents:UIControlEventTouchUpInside];
				[button sizeToFit];
				CGRect frame = button.frame;
				frame.origin.x -= 10.0f;
				frame.origin.y -= 10.0f;
				button.frame = frame;
				[icon setCloseBox:button];
			}
		}
	}
}

CHOptimizedMethod(1, new, BOOL, SBAppSwitcherController, iconPositionIsEditable, SBIcon *, icon)
{
	return CHIvar(self, _editing, BOOL);
}

CHOptimizedMethod(1, self, void, SBAppSwitcherController, iconHandleLongPress, SBIcon *, icon)
{
	ReleaseGrabbedIcon();
	//if (CHIvar(self, _editing, BOOL)) {
		// Enter "grabbed mode"
		SBAppSwitcherBarView *_bottomBar = CHIvar(self, _bottomBar, SBAppSwitcherBarView *);
		CHIvar(_bottomBar, _scrollView, UIScrollView *).scrollEnabled = NO;
		grabbedIcon = [icon retain];
		grabbedIconIndex = [[_bottomBar appIcons] indexOfObjectIdenticalTo:icon];
		[[icon superview] bringSubviewToFront:icon];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.33];
		//[icon setAllowJitter:NO];
		[icon setIsGrabbed:YES];
		[UIView commitAnimations];
	//} else {
	//	CHSuper(1, SBAppSwitcherController, iconHandleLongPress, icon);
	//}
}

static CGPoint IconPositionForIconIndex(SBAppSwitcherBarView *bottomBar, SBIcon *icon, NSUInteger index)
{
	// Find the position of an icon
	CGRect frame = [bottomBar _frameForIndex:index withSize:icon.bounds.size];
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

static NSInteger DestinationIndexForIcon(SBAppSwitcherBarView *bottomBar, SBIcon *icon)
{
	// Find the destination index based on the current position of the icon
	CGPoint currentPosition = [icon center];
	if (currentPosition.y < -20.0f)
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
		NSUInteger destIndex = DestinationIndexForIcon(_bottomBar, icon);
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
			[self _quitButtonHit:CHIvar(icon, _closeBox, UIView *)];
		} else {
			// Animate into position
			NSUInteger destinationIndex = DestinationIndexForIcon(_bottomBar, icon);
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
			for (SBApplicationIcon *appIcon in [_appIcons reverseObjectEnumerator])
				[_model addToFront:[appIcon application]];
		}
	//}
}

/*CHOptimizedMethod(1, self, void, SBAppSwitcherController, _quitButtonHit, SBAppIconQuitButton *, quitButton)
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
	return CHSuper(2, SBAppSwitcherController, _applicationIconsExcept, nil, forOrientation, orientation);
}

CHConstructor {
	CHLoadLateClass(SBAppSwitcherController);
	CHHook(0, SBAppSwitcherController, _beginEditing);
	CHHook(0, SBAppSwitcherController, _stopEditing);
	CHHook(0, SBAppSwitcherController, viewWillAppear);
	CHHook(1, SBAppSwitcherController, iconPositionIsEditable);
	CHHook(1, SBAppSwitcherController, iconHandleLongPress);
	CHHook(2, SBAppSwitcherController, icon, touchMovedWithEvent);
	CHHook(2, SBAppSwitcherController, icon, touchEnded);
	//CHHook(1, SBAppSwitcherController, _quitButtonHit);
	CHHook(2, SBAppSwitcherController, _applicationIconsExcept, forOrientation);
	CHLoadLateClass(SBAppIconQuitButton);
	CHLoadLateClass(SBApplicationIcon);
	//CHLoadLateClass(SBUIController);
}
