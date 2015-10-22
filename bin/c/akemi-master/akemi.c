#include "akemi.h"
#include "fs.h"
#include "win.h"

int main(int argc, char** argv)
{
	xcb_init();
	return fuse_init(argc, argv);
}

void akemi_cleanup()
{
	xcb_cleanup();
}
