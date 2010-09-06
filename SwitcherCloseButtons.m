#import <SpringBoard/SpringBoard.h>
#import <CaptainHook/CaptainHook.h>

@interface SBAppSwitcherBarView : UIView {
}
- (NSArray *)appIcons;
@end

@interface SBAppIconQuitButton : UIButton {
	SBApplicationIcon* _appIcon;
}
@property(retain, nonatomic) SBApplicationIcon *appIcon;
@end

@interface SBIcon (OS40)
- (void)setCloseBox:(UIView *)view;
@end


CHDeclareClass(SBAppSwitcherController);
CHDeclareClass(SBAppIconQuitButton);
CHDeclareClass(SBApplicationIcon);

CHOptimizedMethod(0, self, void, SBAppSwitcherController, _beginEditing)
{
}

CHOptimizedMethod(0, self, void, SBAppSwitcherController, viewWillAppear)
{
	CHSuper(0, SBAppSwitcherController, viewWillAppear);
	//UIImage *image = [UIImage imageNamed:@"SwitcherQuitBox"];
	// I like the standard closebox, not the stupid little minus
	UIImage *image = [UIImage imageNamed:@"closebox"];
	for (SBIcon *icon in [CHIvar(self, _bottomBar, SBAppSwitcherBarView *) appIcons]) {
		if (CHIsClass(icon, SBApplicationIcon)) {
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

CHConstructor {
	CHLoadLateClass(SBAppSwitcherController);
	CHHook(0, SBAppSwitcherController, _beginEditing);
	CHHook(0, SBAppSwitcherController, viewWillAppear);
	CHLoadLateClass(SBAppIconQuitButton);
	CHLoadLateClass(SBApplicationIcon);
}
