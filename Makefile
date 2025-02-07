IDIR = .
CC = gcc
ODIR = obj

HIP_PATH ?= $(wildcard /opt/rocm)
ifeq (,$(HIP_PATH))
HIP_PATH = ../../..
endif
CC = $(HIP_PATH)/bin/hipcc

ifeq ($(USE_CUDA),1)
  CUDAFLAGS = -I/usr/local/cuda-10.1/targets/x86_64-linux/include
  CUDAFLAGS += -I/usr/local/cuda/include
  PRE_CFLAGS1 = -I$(IDIR) $(CUDAFLAGS) -g -DHAVE_CUDA
  LIBS = -Wall -lrdmacm -libverbs -lmlx5 -lcuda
else
  HIPFLAGS = -I/opt/rocm/include/
  PRE_CFLAGS1 = -I$(IDIR) $(HIPFLAGS) -g -O3 -D__HIP_PLATFORM_AMD__
  LIBS = -Wall -lrdmacm -libverbs -lmlx5
endif

ifeq ($(PRINT_LAT),1)
  CFLAGS = $(PRE_CFLAGS1) -DPRINT_LATENCY
else
  CFLAGS = $(PRE_CFLAGS1)
endif

OEXE_CLT = client
OEXE_SRV = server

DEPS = gpu_direct_rdma_access.h
DEPS += ibv_helper.h
DEPS += khash.h
DEPS += gpu_mem_util.h
DEPS += utils.h

OBJS = gpu_direct_rdma_access.o
OBJS += gpu_mem_util.o
OBJS += utils.o

$(ODIR)/%.o: %.cpp $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

all : make_odir $(OEXE_CLT) $(OEXE_SRV) add

make_odir: $(ODIR)/

$(OEXE_SRV) : $(patsubst %,$(ODIR)/%,$(OBJS)) $(ODIR)/server.o
	@echo $(CC)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

$(OEXE_CLT) : $(patsubst %,$(ODIR)/%,$(OBJS)) $(ODIR)/client.o
	@echo $(CC)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

add: add.cpp
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

$(ODIR)/:
	mkdir -p $@

.PHONY: clean

clean :
	rm -f add $(OEXE_CLT) $(OEXE_SRV) $(ODIR)/*.o *~ core.* $(IDIR)/*~

