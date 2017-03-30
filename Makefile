MC = .mc
BASE_BIN = .mc/bin
PY2 = .mc/envs/py2
export BIN_PATH := $(abspath ${BASE_BIN})
export PATH := ${BIN_PATH}:${PATH}

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	CCFLAGS += -D LINUX
	MC_LINK := https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
endif
ifeq ($(UNAME_S),Darwin)
	CCFLAGS += -D OSX
	MC_LINK := https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
endif
UNAME_P := $(shell uname -p)
ifeq ($(UNAME_P),x86_64)
	CCFLAGS += -D AMD64
endif
ifneq ($(filter %86,$(UNAME_P)),)
	CCFLAGS += -D IA32
endif
ifneq ($(filter arm%,$(UNAME_P)),)
	CCFLAGS += -D ARM
endif

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))


all: ${BASE_BIN}/python ${PY2}/bin/python

clean: 
	rm -rf ${MC} mc.sh

.PHONY: all clean
.SECONDARY:

${BASE_BIN}/python:
	wget -O - ${MC_LINK} > mc.sh
	bash mc.sh -bf -p ${MC}
	.mc/bin/conda config --system --add channels conda-forge --add channels defaults --add channels r --add channels bioconda
	.mc/bin/conda config --system --set always_yes True 
	rm -fr mc.sh

${PY2}/bin/python: ${BASE_BIN}/python
	conda create -n py2 python=2

