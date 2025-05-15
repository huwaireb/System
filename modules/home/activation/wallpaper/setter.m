@import Foundation;
@import AppKit;

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    if (argc != 2) {
      fprintf(stderr, "Usage %s <image_path>\n", argv[0]);
      return EXIT_FAILURE;
    }

    NSString *path = @(argv[1]);
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL is_dir;
    if (!path || ![fm fileExistsAtPath:path isDirectory:&is_dir] || is_dir) {
      fprintf(stderr, "Error: Invalid or inaccessible image path\n");
      return EXIT_FAILURE;
    }

    NSURL *url = [NSURL fileURLWithPath:path];
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    if (!url || !ws) {
      fprintf(stderr, "Error: Failed to initialize resources\n");
      return EXIT_FAILURE;
    }

    NSError *error;
    for (NSScreen *screen in [NSScreen screens]) {
      if (![ws setDesktopImageURL:url
                        forScreen:screen
                          options:@{}
                            error:&error]) {
        fprintf(stderr, "Error: %s\n", error.localizedDescription.UTF8String);
        return EXIT_FAILURE;
      }
    }

    printf("Wallpaper set\n");
    return 0;
  }
}
