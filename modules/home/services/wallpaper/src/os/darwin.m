@import Foundation;
@import AppKit;

int setWallpaper(const char *image_path, char **error_message) {
    @autoreleasepool {
        if (!image_path) {
            *error_message = strdup("Error: Null image path");
            return 1;
        }

        NSString *path = @(image_path);
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL is_dir;
        if (![fm fileExistsAtPath:path isDirectory:&is_dir] || is_dir) {
            *error_message = strdup("Error: Invalid or inaccessible image path");
            return 1;
        }

        NSURL *url = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        for (NSScreen *screen in [NSScreen screens]) {
            if (![[NSWorkspace sharedWorkspace] setDesktopImageURL:url
                                                       forScreen:screen
                                                         options:@{}
                                                           error:&error]) {
                *error_message = error ? strdup(error.localizedDescription.UTF8String) : strdup("Error: Failed to set wallpaper");
                return 1;
            }
        }

        *error_message = NULL;
        return 0;
    }
}
