#import <CoreFoundation/CoreFoundation.h>
#import <substrate.h>

static BOOL willLogCaptureInfo;
static BOOL willLogFocusInfo;
static BOOL willLogPreviewInfo;
static BOOL willLogDebugInfo;

Boolean (*original_CFPreferencesGetAppBooleanValue)(CFStringRef key, CFStringRef applicationID, Boolean *keyExistsAndHasValidFormat);
Boolean replaced_CFPreferencesGetAppBooleanValue(CFStringRef key, CFStringRef applicationID, Boolean *keyExistsAndHasValidFormat)
{
	//if ([(NSString *)key isEqualToString:@"LogAllInfo"]) return true;
    if ([(NSString *)key isEqualToString:@"LogCaptureInfo"] && willLogCaptureInfo) return true;
    if ([(NSString *)key isEqualToString:@"LogFocusInfo"] && willLogFocusInfo) return true;
    if ([(NSString *)key isEqualToString:@"LogPreviewInfo"] && willLogPreviewInfo) return true;
    if ([(NSString *)key isEqualToString:@"LogDebugInfo"] && willLogDebugInfo) return true; 
    //NSLog(@"%@, %i", key, keyExistsAndHasValidFormat);
    return original_CFPreferencesGetAppBooleanValue(key, applicationID, keyExistsAndHasValidFormat);
}

static void FullCameraLogLoader()
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.PS.FullCameraLog.plist"];
	id LogCaptureInfo = [dict objectForKey:@"LogCaptureInfo"];
	willLogCaptureInfo = LogCaptureInfo ? [LogCaptureInfo boolValue] : YES;
	id LogFocusInfo = [dict objectForKey:@"LogFocusInfo"];
	willLogFocusInfo = LogFocusInfo ? [LogFocusInfo boolValue] : YES;
	id LogPreviewInfo = [dict objectForKey:@"LogPreviewInfo"];
	willLogPreviewInfo = LogPreviewInfo ? [LogPreviewInfo boolValue] : YES;
	id LogDebugInfo = [dict objectForKey:@"LogDebugInfo"];
	willLogDebugInfo = LogDebugInfo ? [LogDebugInfo boolValue] : YES;
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	FullCameraLogLoader();
	//system("killall Camera");
}


%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, CFSTR("com.PS.FullCameraLog.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	FullCameraLogLoader();
   	MSHookFunction((void *)CFPreferencesGetAppBooleanValue, (void *)replaced_CFPreferencesGetAppBooleanValue, (void **)&original_CFPreferencesGetAppBooleanValue);
  	[pool release];
}

