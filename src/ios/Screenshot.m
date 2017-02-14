//
// Screenshot.h
//
// Created by Simon Madine on 29/04/2010.
// Copyright 2010 The Angry Robot Zombie Factory.
// - Converted to Cordova 1.6.1 by Josemando Sobral.
// MIT licensed
//
// Modifications to support orientation change by @ffd8
//

#import <Cordova/CDV.h>
#import "Screenshot.h"

@implementation Screenshot

@synthesize webView;

- (UIImage *)getScreenshot
{
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	CGRect rect = [keyWindow bounds];
	UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
	[keyWindow drawViewHierarchyInRect:keyWindow.bounds afterScreenUpdates:NO];
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
}

- (void)saveScreenshot:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
	NSString *filename = [command.arguments objectAtIndex:2];
	NSNumber *quality = [command.arguments objectAtIndex:1];

	NSString *path = [NSString stringWithFormat:@"%@.jpg",filename];
	NSString *jpgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:path];

	UIImage *image = [self getScreenshot];
	NSData *imageData = UIImageJPEGRepresentation(image,[quality floatValue]);
	[imageData writeToFile:jpgPath atomically:NO];

    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

	CDVPluginResult* pluginResult = nil;
	NSDictionary *jsonObj = [ [NSDictionary alloc]
		initWithObjectsAndKeys :
		jpgPath, @"filePath",
		@"true", @"success",
		nil
	];

//	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:jsonObj];
//
//	[self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) getScreenshotAsURI:(CDVInvokedUrlCommand*)command
{
	NSNumber *quality = command.arguments[0];
	UIImage *image = [self getScreenshot];
	NSData *imageData = UIImageJPEGRepresentation(image,[quality floatValue]);
	NSString *base64Encoded = [imageData base64EncodedStringWithOptions:0];
	NSDictionary *jsonObj = @{
	    @"URI" : [NSString stringWithFormat:@"data:image/jpeg;base64,%@", base64Encoded]
	};
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:jsonObj];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:[command callbackId]];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        // Show error message...
        NSLog(@"ERROR: %@",error);
        CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
    else  // No errors
    {
        // Show message image successfully saved
        NSLog(@"IMAGE SAVED!");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:@"Image saved"];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

@end
