/* Main binary for OSX bundle.
###############################################################################
## Tucan Project
##
## Copyright (C) 2008-2009 Fran Lupion crak@tucaneando.com
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
###############################################################################
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <Python/Python.h>
#include <CoreFoundation/CoreFoundation.h>

#define TUCAN_FILE "/src/tucan.py"

int main()
{	
	int result = 0;
	
	CFBundleRef mainBundle = CFBundleGetMainBundle();
        CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
        char path[PATH_MAX];
	
        if (CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX))
        {
		char *tucan_path;
		
		tucan_path = (char *)calloc(strlen(path) + strlen(TUCAN_FILE) + 1, sizeof(char));
		strcpy(tucan_path, path);
		strcat(tucan_path, TUCAN_FILE);
                printf("Tucan Path: %s\n", tucan_path);
		
		FILE *fp = fopen(tucan_path, "r");
		
		Py_Initialize();
		
		char *argv[1];
		argv[0] = tucan_path;
		argv[1] = NULL;
		
		PySys_SetArgv(1, argv);
		result = PyRun_SimpleFile(fp, tucan_path);
		
		//printf("PATH: %s\n", Py_GetPath());
		Py_Finalize();

		free(tucan_path);
        }
        CFRelease(resourcesURL);
	
	return result;
}
