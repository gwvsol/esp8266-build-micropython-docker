.PHONY: help clean build modules

#===================================================
BIN=/usr/local/bin
SCRIPT=make_fw.sh
#===================================================

.DEFAULT: help

help:
	@echo "make clean	- Clearing the SDK"
	@echo "make modules	- Copying the source code"
	@echo "make build	- The build of the firmware"
	@exit 0

clean: ${BIN}/${SCRIPT}
	${BIN}/${SCRIPT} -c

modules: ${BIN}/${SCRIPT}
	${BIN}/${SCRIPT} -cp

build: ${BIN}/${SCRIPT}
	${BIN}/${SCRIPT} -cb

