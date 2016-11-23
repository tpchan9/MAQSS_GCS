# MAQSS_GCS

Ground Control Station for the Multiple Autonomous Quadcopter Search System

- Allows user specified Search Area mission creation via map display and GPS coordinates
- Allows vehicle status monitoring and live location updates on map display
- Automatically interfaces with known vehicles in the area
- Automatically allocates Search Area mission amongst available vehicles

BUILD NOTES:

FOR LINUX
MAQSS_GCS uses the xbeeplus library at: https://github.com/NGCP/xbeeplus

To configure this project to use xbeeplus:

1. Download (clone, fork) xbeeplus repo locally

2. Download MAQSS_GCS repo locally

3. Navigate to MAQSS_GCS repo

4. Modify MAQSS_GCS.pro file to specify xbeeplus library path

  A. Modify SOURCES
  
            SOURCES += main.cpp\
              ./relative/path/to/xbeeplus/lib/ReceivePacket.cpp \
              ./relative/path/to/xbeeplus/lib/ReceivePacket.cpp \
              ./relative/path/to/xbeeplus/lib/SerialXbee.cpp \
              ./relative/path/to/xbeeplus/lib/TransmitRequest.cpp \
              ./relative/path/to/xbeeplus/lib/Utility.cpp \
      
    For example, if xbeeplus is two levels above the MAQSS_GCS directory and inside NGCP,
            
            SOURCES += main.cpp \
              ../../NGCP/xbeeplus/lib/ReceivePacket.cpp \
              ../../NGCP/xbeeplus/lib/SerialXbee.cpp \
              ../../NGCP/xbeeplus/lib/TransmitRequest.cpp \
              ../../NGCP/xbeeplus/lib/Utility.cpp \
      
  B. Modify LIBS
  
            LIBS += \
              -lboost_system\
              -lboost_thread\
  
  C. Modify HEADERS
  
            HEADERS += \
              ./relative/path/to/xbeeplus/include/Frame.hpp \
              ./relative/path/to/xbeeplus/include/ReceivePacket.hpp \
              ./relative/path/to/xbeeplus/include/SerialXbee.hpp \
              ./relative/path/to/xbeeplus/include/TransmitRequest.hpp \
              ./relative/path/to/xbeeplus/include/Utility.hpp \
              ./relative/path/to/xbeeplus/include/Xbee.hpp \
              

