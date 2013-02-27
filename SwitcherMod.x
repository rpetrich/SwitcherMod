#import <SpringBoard/SpringBoard.h>
#import <CaptainHook/CaptainHook.h>

%config(generator=internal)

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
// iOS5.0+
- (void)_saveRecents;
@end

@interface SBAppSwitcherBarView : UIView {
}
- (NSArray *)appIcons;
- (void)setEditing:(BOOL)editing;
- (CGRect)_frameForIndex:(NSUInteger)iconIndex withSize:(CGSize)size; // 4.0/4.1
- (CGRect)_iconFrameForIndex:(NSUInteger)iconIndex withSize:(CGSize)size; // 4.2
@end

@interface SBAppIconQuitButton : UIButton {
	SBApplicationIcon *_appIcon;
}
@property(retain, nonatomic) SBApplicationIcon *appIcon;
@end

@interface SBAppSwitcherModel : NSObject {
	NSMutableArray *_recentDisplayIdentifiers;
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

@interface SBIconModel (OS50)
- (SBApplicationIcon *)applicationIconForDisplayIdentifier:(NSString *)displayIdentifier;
@end

@protocol SBIconViewDelegate, SBIconViewLocker;
@class SBIconImageContainerView, SBIconBadgeImage;

@interface SBIconView : UIView {
	SBIcon *_icon;
	id<SBIconViewDelegate> _delegate;
	id<SBIconViewLocker> _locker;
	SBIconImageContainerView *_iconImageContainer;
	SBIconImageView *_iconImageView;
	UIImageView *_iconDarkeningOverlay;
	UIImageView *_ghostlyImageView;
	UIImageView *_reflection;
	UIImageView *_shadow;
	SBIconBadgeImage *_badgeImage;
	UIImageView *_badgeView;
	SBIconLabel *_label;
	BOOL _labelHidden;
	BOOL _labelOnWallpaper;
	UIView *_closeBox;
	int _closeBoxType;
	UIImageView *_dropGlow;
	unsigned _drawsLabel : 1;
	unsigned _isHidden : 1;
	unsigned _isGrabbed : 1;
	unsigned _isOverlapping : 1;
	unsigned _refusesRecipientStatus : 1;
	unsigned _highlighted : 1;
	unsigned _launchDisabled : 1;
	unsigned _isJittering : 1;
	unsigned _allowJitter : 1;
	unsigned _touchDownInIcon : 1;
	unsigned _hideShadow : 1;
	NSTimer *_delayedUnhighlightTimer;
	unsigned _onWallpaper : 1;
	unsigned _ghostlyRequesters;
	int _iconLocation;
	float _iconImageAlpha;
	float _iconImageBrightness;
	float _iconLabelAlpha;
	float _accessoryAlpha;
	CGPoint _unjitterPoint;
	CGPoint _grabPoint;
	NSTimer *_longPressTimer;
	unsigned _ghostlyTag;
	UIImage *_ghostlyImage;
	BOOL _ghostlyPending;
}
+ (CGSize)defaultIconSize;
+ (CGSize)defaultIconImageSize;
+ (BOOL)allowsRecycling;
+ (id)_jitterPositionAnimation;
+ (id)_jitterTransformAnimation;

- (id)initWithDefaultSize;
- (void)dealloc;

@property(assign) id<SBIconViewDelegate> delegate;
@property(assign) id<SBIconViewLocker> locker;
@property(readonly, retain) SBIcon *icon;
- (void)setIcon:(SBIcon *)icon;

- (int)location;
- (void)setLocation:(int)location;
- (void)showIconAnimationDidStop:(id)showIconAnimation didFinish:(id)finish icon:(id)icon;
- (void)setIsHidden:(BOOL)hidden animate:(BOOL)animate;
- (BOOL)isHidden;
- (BOOL)isRevealable;
- (void)positionIconImageView;
- (void)applyIconImageTransform:(CATransform3D)transform duration:(float)duration delay:(float)delay;
- (void)setDisplayedIconImage:(id)image;
- (id)snapshotSettings;
- (id)iconImageSnapshot:(id)snapshot;
- (id)reflectedIconWithBrightness:(float)brightness;
- (void)setIconImageAlpha:(float)alpha;
- (void)setIconLabelAlpha:(float)alpha;
- (SBIconImageView *)iconImageView;
- (void)setLabelHidden:(BOOL)hidden;
- (void)positionLabel;
- (CGSize)_labelSize;
- (Class)_labelClass;
- (void)updateLabel;
- (void)_updateBadgePosition;
- (id)_overriddenBadgeTextForText:(id)text;
- (void)updateBadge;
- (id)_automationID;
- (BOOL)pointMostlyInside:(CGPoint)inside withEvent:(id)event;
- (CGRect)frameForIconOverlay;
- (void)placeIconOverlayView;
- (void)updateIconOverlayView;
- (void)_updateIconBrightness;
- (BOOL)allowsTapWhileEditing;
- (BOOL)delaysUnhighlightWhenTapped;
- (BOOL)isHighlighted;
- (void)setHighlighted:(BOOL)highlighted;
- (void)setHighlighted:(BOOL)highlighted delayUnhighlight:(BOOL)unhighlight;
- (void)_delayedUnhighlight;
- (BOOL)isInDock;
- (id)_shadowImage;
- (void)_updateShadow;
- (void)updateReflection;
- (void)setDisplaysOnWallpaper:(BOOL)wallpaper;
- (void)setLabelDisplaysOnWallpaper:(BOOL)wallpaper;
- (BOOL)showsReflection;
- (float)_reflectionImageOffset;
- (void)setFrame:(CGRect)frame;
- (void)setIsJittering:(BOOL)jittering;
- (void)setAllowJitter:(BOOL)jitter;
- (BOOL)allowJitter;
- (void)removeAllIconAnimations;
- (void)setIconPosition:(CGPoint)position;
- (void)setRefusesRecipientStatus:(BOOL)status;
- (BOOL)canReceiveGrabbedIcon:(id)icon;
- (double)grabDurationForEvent:(id)event;
- (void)setIsGrabbed:(BOOL)grabbed;
- (BOOL)isGrabbed;
- (void)setIsOverlapping:(BOOL)overlapping;
- (CGAffineTransform)transformToMakeDropGlowShrinkToIconSize;
- (void)prepareDropGlow;
- (void)showDropGlow:(BOOL)glow;
- (void)removeDropGlow;
- (id)dropGlow;
- (BOOL)isShowingDropGlow;
- (void)placeGhostlyImageView;
- (id)_genGhostlyImage:(id)image;
- (void)prepareGhostlyImageIfNeeded;
- (void)prepareGhostlyImage;
- (void)prepareGhostlyImageView;
- (void)setGhostly:(BOOL)ghostly requester:(int)requester;
- (void)setPartialGhostly:(float)ghostly requester:(int)requester;
- (void)removeGhostlyImageView;
- (BOOL)isGhostly;
- (int)ghostlyRequesters;
- (void)longPressTimerFired;
- (void)cancelLongPressTimer;
- (void)touchesCancelled:(id)cancelled withEvent:(id)event;
- (void)touchesBegan:(id)began withEvent:(id)event;
- (void)touchesMoved:(id)moved withEvent:(id)event;
- (void)touchesEnded:(id)ended withEvent:(id)event;
- (BOOL)isTouchDownInIcon;
- (void)setTouchDownInIcon:(BOOL)icon;
- (void)hideCloseBoxAnimationDidStop:(id)hideCloseBoxAnimation didFinish:(id)finish closeBox:(id)box;
- (void)positionCloseBoxOfType:(int)type;
- (id)_newCloseBoxOfType:(int)type;
- (void)setShowsCloseBox:(BOOL)box;
- (void)setShowsCloseBox:(BOOL)box animated:(BOOL)animated;
- (BOOL)isShowingCloseBox;
- (void)closeBoxTapped;
- (BOOL)pointInside:(CGPoint)inside withEvent:(id)event;
- (UIEdgeInsets)snapshotEdgeInsets;
- (void)setShadowsHidden:(BOOL)hidden;
- (void)_updateShadowFrameForShadow:(id)shadow;
- (void)_updateShadowFrame;
- (BOOL)_delegatePositionIsEditable;
- (void)_delegateTouchEnded:(BOOL)ended;
- (BOOL)_delegateTapAllowed;
- (int)_delegateCloseBoxType;
- (id)createShadowImageView;
- (void)prepareForRecycling;
- (CGRect)defaultFrameForProgressBar;
- (void)iconImageDidUpdate:(id)iconImage;
- (void)iconAccessoriesDidUpdate:(id)iconAccessories;
- (void)iconLaunchEnabledDidChange:(id)iconLaunchEnabled;
@end

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

%group Legacy

static SBIcon *grabbedIcon;
static NSUInteger grabbedIconIndex;

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

static id IconForIconView(id iconView)
{
	return [iconView respondsToSelector:@selector(icon)] ? [iconView icon] : iconView;
}

%hook SBAppSwitcherController

- (void)_beginEditing
{
	// Reimplement the standard _beginEditing, but don't add the close buttons
	/*SBAppSwitcherBarView *_bottomBar = CHIvar(self, _bottomBar, SBAppSwitcherBarView *);
	for (SBIcon *icon in [_bottomBar appIcons])
		[icon setIsJittering:YES];
	CHIvar(self, _editing, BOOL) = YES;
	[_bottomBar setEditing:NO];*/
	if (!SMWiggleModeOff)
		%orig;

	[self viewWillAppear];	
}

- (void)_stopEditing
{
	/*ReleaseGrabbedIcon();
	// Reimplement the standard _stopEditing, but don't remove the close buttons
	SBAppSwitcherBarView *_bottomBar = CHIvar(self, _bottomBar, SBAppSwitcherBarView *);
	for (SBIcon *icon in [_bottomBar appIcons])
		[icon setIsJittering:NO];
	CHIvar(self, _editing, BOOL) = NO;
	[_bottomBar setEditing:NO];*/
	if (!SMWiggleModeOff)
		%orig;
	
	[self viewWillAppear];	
}

- (NSUInteger)closeBoxTypeForIcon:(SBApplicationIcon *)icon
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

static NSArray *IconsForSwitcherBar(SBAppSwitcherBarView *view)
{
	return [view respondsToSelector:@selector(appIcons)] ? [view appIcons] : CHIvar(view, _appIcons, NSMutableArray *);
}

- (void)viewWillAppear
{
	%orig;
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
	
	SBApplication *activeApplication = [(SpringBoard *)UIApp _accessibilityFrontMostApplication];
	for (SBIconView *iconView in IconsForSwitcherBar(CHIvar(self, _bottomBar, SBAppSwitcherBarView *))) {
		SBApplicationIcon *icon = IconForIconView(iconView);
		if ([icon isKindOfClass:%c(SBApplicationIcon)]) {
			SBApplication *application = [icon application];
			BOOL isRunning = [[application process] isRunning];
			[iconView iconImageView].alpha = isRunning ?  1.0f : (SMExitedIconAlpha / 100);
			[iconView setShadowsHidden:!isRunning];
		
			SBIconLabel *label = CHIvar(iconView, _label, SBIconLabel *);
			[label setAlpha:(SMIconLabelsOff) ? 0.0f : 1.0f];
//			[icon setDrawsLabel:(SMIconLabelsOff) ? NO : YES];
					
			if ((image == nil) || (application == activeApplication))
			{
				if([iconView respondsToSelector:@selector(setShowsCloseBox:)])
					[iconView setShowsCloseBox:NO];
				else
					[icon setCloseBox:nil];
			}
			else
			{
				if([iconView respondsToSelector:@selector(setShowsCloseBox:)])
				{
//					[icon setShowsCloseBox:NO];
					[iconView setShowsCloseBox:YES];
				}
				else {
					SBAppIconQuitButton *button = [%c(SBAppIconQuitButton) buttonWithType:UIButtonTypeCustom];
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
}

- (void)iconTapped:(id)icon
{
	SBApplication *activeApplication = [(SpringBoard *)UIApp _accessibilityFrontMostApplication];
	SBApplicationIcon *appIcon = IconForIconView(icon);
	if ([appIcon application] == activeApplication)
		[[%c(SBUIController) sharedInstance] _toggleSwitcher];
	else
		%orig;
}

%new
- (BOOL)iconPositionIsEditable:(SBIcon *)icon
{
	return SMFastIconGrabbing && CHIvar(self, _editing, BOOL);
}

- (void)iconHandleLongPress:(SBIcon *)icon
{
	ReleaseGrabbedIcon();
	if (!SMWiggleModeOff)
		%orig;
	//if (CHIvar(self, _editing, BOOL)) {
		// Enter "grabbed mode"
		SBAppSwitcherBarView *_bottomBar = CHIvar(self, _bottomBar, SBAppSwitcherBarView *);
		CHIvar(_bottomBar, _scrollView, UIScrollView *).scrollEnabled = NO;
		grabbedIcon = [icon retain];
		grabbedIconIndex = [IconsForSwitcherBar(_bottomBar) indexOfObjectIdenticalTo:icon];
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
	if (((currentPosition.y < -20.0f) && (SMDragUpToQuit)) && ([IconForIconView(icon) application] != [(SpringBoard *)UIApp _accessibilityFrontMostApplication]))
		return -1;
	NSUInteger destIndex = 0;
	CGPoint destPosition = IconPositionForIconIndex(bottomBar, icon, 0);
	CGFloat distanceSquared = DistanceSquaredBetweenPoints(currentPosition, destPosition);
	NSUInteger count = [IconsForSwitcherBar(bottomBar) count];
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

%new
- (void)icon:(SBIcon *)icon touchMovedWithEvent:(UIEvent *)event
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
			for (SBIcon *appIcon in IconsForSwitcherBar(_bottomBar)) {
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

%new
- (void)icon:(SBIcon *)icon touchEnded:(BOOL)ended
{
	//if (CHIvar(self, _editing, BOOL)) {

		SBAppSwitcherBarView *_bottomBar = CHIvar(self, _bottomBar, SBAppSwitcherBarView *);
		CHIvar(_bottomBar, _scrollView, UIScrollView *).scrollEnabled = YES;
		if (grabbedIconIndex == -1) {
			ReleaseGrabbedIcon();
			SBAppIconQuitButton *button = [%c(SBAppIconQuitButton) buttonWithType:UIButtonTypeCustom];
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
				NSMutableArray *_recentDisplayIdentifiers = CHIvar(_model, _recentDisplayIdentifiers, NSMutableArray *);
				NSString *displayIdentifier = [[_recentDisplayIdentifiers objectAtIndex:currentIndex] retain];
				[_recentDisplayIdentifiers removeObjectAtIndex:currentIndex];
				[_recentDisplayIdentifiers insertObject:displayIdentifier atIndex:destinationIndex];
				[displayIdentifier release];
				[_model _saveRecents];
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

- (NSArray *)_applicationIconsExcept:(SBApplication *)application forOrientation:(UIInterfaceOrientation)orientation
{
	if (SMShowActiveApp)
		application = nil;
	if (SMExitedAppStyle == SMExitedAppStyleHidden) {
		NSMutableArray *newResult = [NSMutableArray array];
		for (SBApplicationIcon *icon in %orig)
			if ([[[icon application] process] isRunning])
				[newResult addObject:icon];
		return newResult;
	} else {
		return %orig;
	}
}

- (NSArray *)_applicationIconsExceptTopApp
{
	NSMutableArray *result;
	if (SMExitedAppStyle == SMExitedAppStyleHidden) {
		result = [NSMutableArray array];
		for (SBIconView *iconView in %orig)
			if ([[[(SBApplicationIcon *)[iconView icon] application] process] isRunning])
				[result addObject:iconView];
	} else {
		result = [[%orig mutableCopy] autorelease];
	}
	if (SMShowActiveApp) {
		SBApplication *activeApplication = [(SpringBoard *)UIApp _accessibilityFrontMostApplication];
		if (activeApplication) {
			SBApplicationIcon *icon = [[%c(SBIconModel) sharedInstance] applicationIconForDisplayIdentifier:activeApplication.displayIdentifier];
			if (icon) {
				SBIconView *iconView = [[%c(SBIconView) alloc] initWithDefaultSize];
				[iconView setIcon:icon];
				[result insertObject:iconView atIndex:0];
				[iconView release];
			}
		}
	}
	return result;
}

%end

%hook SBAppSwitcherBarView

- (void)layoutSubviews
{
	%orig;
	if ([grabbedIcon superview] == self)
		[grabbedIcon bringSubviewToFront:grabbedIcon];
}

%end

%end


@interface SBApplication (iOS6)
- (BOOL)isRunning;
@end

%group iOS6

%hook SBAppSwitcherController

- (NSArray *)_bundleIdentifiersForViewDisplay
{
	NSArray *result = %orig();
	if (SMExitedAppStyle != SMExitedAppStyleHidden)
		return result;
	NSMutableArray *newResult = [NSMutableArray array];
	SBApplicationController *ac = [%c(SBApplicationController) sharedInstance];
	for (NSString *displayIdentifier in result) {
		if ([[ac applicationWithDisplayIdentifier:displayIdentifier] isRunning]) {
			[newResult addObject:displayIdentifier];
		}
	}
	return newResult;
}

- (void)_beginEditing
{
	switch (SMCloseButtonStyle) {
		case SMCloseButtonStyleRedMinus:
		case SMCloseButtonStyleBlackClose:
			break;
		case SMCloseButtonStyleNone:
			%orig();
			break;
	}
}

- (int)closeBoxTypeForIcon:(SBIcon *)icon
{
	int result = %orig();
	if (SMCloseButtonStyle == SMCloseButtonStyleBlackClose) {
		result = 0;
	}
	return result;
}

%end

%hook SBAppSwitcherBarView

- (void)_toggleIconViewEditingState:(SBIconView *)iconView animated:(BOOL)animated
{
	%orig();
	switch (SMCloseButtonStyle) {
		case SMCloseButtonStyleRedMinus:
		case SMCloseButtonStyleBlackClose:
			[iconView setShowsCloseBox:YES animated:animated];
			break;
	}
}

- (SBIconView *)_iconViewForIcon:(SBIcon *)icon creatingIfNecessary:(BOOL)necessary
{
	SBIconView *result = %orig();
	SBApplication *app = [icon respondsToSelector:@selector(application)] ? [(SBApplicationIcon *)icon application] : nil;
	result.alpha = (!app || [app isRunning]) ? 1.0f : SMExitedIconAlpha / 100;
	[result setLabelHidden:SMIconLabelsOff];
	return result;
}


%end

%end


%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init;
	if (kCFCoreFoundationVersionNumber < 783.0) {
		%init(Legacy);
	} else {
		%init(iOS6);
	}
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (void *)LoadSettings, CFSTR("com.collab.switchermod.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	LoadSettings();
	[pool drain];
}
