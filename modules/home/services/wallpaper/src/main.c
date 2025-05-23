#include <stdio.h>
#include <stdlib.h>

extern int setWallpaper(const char *image_path, char **error_message);

int main(int argc, const char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <image_path>\n", argv[0]);
        return EXIT_FAILURE;
    }

    char *error_message = NULL;
    int result = setWallpaper(argv[1], &error_message);

    if (result == 0) {
        printf("Wallpaper set\n");
    } else if (error_message) {
        fprintf(stderr, "%s\n", error_message);
        free(error_message);
    }

    return result;
}
