#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

int UzpMain(int, char**);


MODULE = Archive::Unzip::Burst		PACKAGE = Archive::Unzip::Burst	

int
_unzip(filename)
        char * filename
    INIT:
        int r;
    CODE:
        int argno = 4;
        char* args[4];
        args[0] = "unzip";
        args[1] = "-qq";
        args[2] = "-o";
        args[3] = filename;
        r = UzpMain(argno, args);
        RETVAL = r;
    OUTPUT:
        RETVAL

