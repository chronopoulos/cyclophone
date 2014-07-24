DIR=$(shell pwd)/../

INCS = -I.\
        -I$(DIR) \
        -I$(DIR)/hardware \
        -I$(DIR)/hardware/arduino \
        -I$(DIR)/hardware/arduino/cores \
        -I$(DIR)/hardware/arduino/cores/arduino \
        -I$(DIR)/hardware/arduino/variants \
        -I$(DIR)/hardware/arduino/variants/sunxi \
        -I$(DIR)/libraries \
        -I$(DIR)/libraries/Serial \
        -I$(DIR)/libraries/SPI \
        -I$(DIR)/libraries/Wire \
        -I$(DIR)/libraries/LiquidCrystal \
        -I$(DIR)/libraries/Adafruit-WS2801-Library \
        -I$(DIR)/libraries/PN532_SPI 

LIBS=../libarduino.a -llo
#TARGET=../output/test
TARGET=.

OBJS = ledoscserver

all: 
	@mkdir -p $(TARGET)
	@for i in $(OBJS); do echo "$(CXX) $(INCS) $$i.c -o $(TARGET)/$$i $(LIBS)" && $(CXX) $(INCS) $$i.c -o $(TARGET)/$$i $(LIBS); done

clean:
	@for i in $(OBJS); do rm -f $(TARGET)/$$i; done
