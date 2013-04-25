#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

__attribute__((visibility("hidden")))
@interface FullCameraLogPreferenceController : PSListController
- (id)specifiers;
@end

@implementation FullCameraLogPreferenceController

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"FullCameraLog" target:self] retain];
  }
	return _specifiers;
}

- (void)killCam:(id)param
{
	system("killall Camera");
}

@end

