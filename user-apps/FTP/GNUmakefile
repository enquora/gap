#
# GNUmakefile - Generated by ProjectCenter
#
ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif
ifeq ($(GNUSTEP_MAKEFILES),)
 $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

#
# Application
#
VERSION = 0.5
PACKAGE_NAME = FTP
APP_NAME = FTP
FTP_APPLICATION_ICON = FTP_icon_gs.tif


#
# Resource files
#
FTP_RESOURCE_FILES = \
Resources/FTP.gorm \
Resources/GetName.gorm \
Resources/arrow_left.tiff \
Resources/arrow_right.tiff \
Resources/FTP_icon_gs.tif 


#
# Header files
#
FTP_HEADER_FILES = \
AppController.h \
GetNameController.h \
ftpclient.h \
localclient.h \
fileTable.h \
fileElement.h \
client.h

#
# Class files
#
FTP_OBJC_FILES = \
AppController.m \
GetNameController.m \
ftpclient.m \
localclient.m \
fileTable.m \
fileElement.m \
client.m

#
# Other sources
#
FTP_OBJC_FILES += \
main.m 

#
# Makefiles
#
-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble
