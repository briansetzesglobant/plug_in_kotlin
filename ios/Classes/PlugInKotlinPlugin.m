#import "PlugInKotlinPlugin.h"
#if __has_include(<plug_in_kotlin/plug_in_kotlin-Swift.h>)
#import <plug_in_kotlin/plug_in_kotlin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "plug_in_kotlin-Swift.h"
#endif

@implementation PlugInKotlinPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPlugInKotlinPlugin registerWithRegistrar:registrar];
}
@end
