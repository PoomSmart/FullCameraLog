#import <CoreFoundation/CoreFoundation.h>
#import <substrate.h>

#define PreferencesChangedNotification "com.PS.FullCameraLog.settingschanged"
#define PREF_PATH @"/var/mobile/Library/Preferences/com.PS.FullCameraLog.plist"

static NSDictionary *prefDict = nil;
static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	system("killall -9 Camera");
	[prefDict release];
	prefDict = [[NSDictionary alloc] initWithContentsOfFile:PREF_PATH];
}

#define returnLog(name) do { \
	if ([(NSString *)key isEqualToString:[NSString stringWithUTF8String:#name]]) \
		return [[prefDict objectForKey:[NSString stringWithUTF8String:#name]] boolValue]; \
} while(0)


Boolean (*original_CFPreferencesGetAppBooleanValue)(CFStringRef key, CFStringRef applicationID, Boolean *keyExistsAndHasValidFormat);
Boolean replaced_CFPreferencesGetAppBooleanValue(CFStringRef key, CFStringRef applicationID, Boolean *keyExistsAndHasValidFormat)
{
	// returnLog(LogAllInfo);
    returnLog(LogCaptureInfo);
    returnLog(LogPanoInfo);
    returnLog(LogFocusInfo);
    returnLog(LogPreviewInfo);
    returnLog(LogDebugInfo);
    return original_CFPreferencesGetAppBooleanValue(key, applicationID, keyExistsAndHasValidFormat);
}


%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    prefDict = [[NSDictionary alloc] initWithContentsOfFile:PREF_PATH];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
   	MSHookFunction((void *)CFPreferencesGetAppBooleanValue, (void *)replaced_CFPreferencesGetAppBooleanValue, (void **)&original_CFPreferencesGetAppBooleanValue);
  	[pool release];
}

