TARGET_DISABLE_IPACM := false

ifeq ($(TARGET_USES_QMAA),true)
ifneq ($(TARGET_USES_QMAA_OVERRIDE_DATA),true)
	TARGET_DISABLE_IPACM := true
endif #TARGET_USES_QMAA_OVERRIDE_DATA
endif #TARGET_USES_QMAA

BOARD_IPA_LOW_RAM_EXCP_LIST := bengal

ifeq ($(TARGET_HAS_LOW_RAM),true)
ifneq ($(call is-board-platform-in-list,$(BOARD_IPA_LOW_RAM_EXCP_LIST)),true)
	TARGET_DISABLE_IPACM := true
endif
endif

ifneq ($(TARGET_DISABLE_IPACM),true)
BOARD_PLATFORM_LIST := msm8909
BOARD_PLATFORM_LIST += msm8916
BOARD_PLATFORM_LIST += msm8917
BOARD_PLATFORM_LIST += qm215
ifeq ($(TARGET_BOARD_SUFFIX),_gvmq)
BOARD_PLATFORM_LIST += msmnile
endif
BOARD_IPAv3_LIST := msm8998
BOARD_IPAv3_LIST += sdm845
BOARD_IPAv3_LIST += sdm710
BOARD_IPAv3_LIST += msmnile
BOARD_IPAv3_LIST += kona
BOARD_IPAv3_LIST += $(MSMSTEPPE)
BOARD_IPAv3_LIST += $(TRINKET)
BOARD_IPAv3_LIST += lito
BOARD_IPAv3_LIST += atoll
BOARD_IPAv3_LIST += bengal
BOARD_ETH_BRIDGE_LIST := msmnile
BOARD_ETH_BRIDGE_LIST += kona

ifneq ($(call is-board-platform-in-list,$(BOARD_PLATFORM_LIST)),true)
ifneq (,$(filter $(QCOM_BOARD_PLATFORMS),$(TARGET_BOARD_PLATFORM)))
ifneq (, $(filter aarch64 arm arm64, $(TARGET_ARCH)))

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../src
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../inc

LOCAL_HEADER_LIBRARIES := generated_kernel_headers

LOCAL_CFLAGS := -DFEATURE_IPA_ANDROID
LOCAL_CFLAGS += -DFEATURE_IPACM_RESTART

ifeq ($(call is-board-platform-in-list,$(BOARD_ETH_BRIDGE_LIST)),true)
LOCAL_CFLAGS += -DFEATURE_ETH_BRIDGE_LE
endif

LOCAL_CFLAGS += -DFEATURE_IPACM_HAL -Wall -Wno-error=macro-redefined
ifneq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
LOCAL_CFLAGS += -DDEBUG
endif

ifeq ($(call is-board-platform-in-list,$(BOARD_IPAv3_LIST)),true)
LOCAL_CFLAGS += -DFEATURE_IPA_V3
endif

filetoadd = bionic/libc/kernel/arch-arm/asm/posix_types.h
LOCAL_CFLAGS += $(shell if [ -a $(filetoadd) ] ; then echo -include $(filetoadd) ; fi ;)
filetoadd = bionic/libc/kernel/arch-arm/asm/byteorder.h
LOCAL_CFLAGS += $(shell if [ -a $(filetoadd) ] ; then echo -include $(filetoadd) ; fi ;)

LOCAL_SRC_FILES := IPACM_Main.cpp \
		IPACM_EvtDispatcher.cpp \
		IPACM_Config.cpp \
		IPACM_CmdQueue.cpp \
		IPACM_Filtering.cpp \
		IPACM_Routing.cpp \
		IPACM_Header.cpp \
		IPACM_Lan.cpp \
		IPACM_Iface.cpp \
		IPACM_Wlan.cpp \
		IPACM_Wan.cpp \
		IPACM_IfaceManager.cpp \
		IPACM_Neighbor.cpp \
		IPACM_Netlink.cpp \
		IPACM_Xml.cpp \
		IPACM_Conntrack_NATApp.cpp\
		IPACM_ConntrackClient.cpp \
		IPACM_ConntrackListener.cpp \
		IPACM_Log.cpp \
		IPACM_OffloadManager.cpp \
		IPACM_LanToLan.cpp

LOCAL_MODULE := ipacm
LOCAL_INIT_RC := ipacm.rc
LOCAL_CLANG := false
LOCAL_MODULE_TAGS := optional

LOCAL_SHARED_LIBRARIES := liboffloadhal
LOCAL_SHARED_LIBRARIES += libipanat
LOCAL_SHARED_LIBRARIES += libxml2
LOCAL_SHARED_LIBRARIES += libnfnetlink
LOCAL_SHARED_LIBRARIES += libnetfilter_conntrack
LOCAL_SHARED_LIBRARIES += libhwbinder \
                libhidlbase \
                libhidltransport \
                liblog \
                libcutils \
                libdl \
                libbase \
                libutils \
                libhardware_legacy \
                libhardware \
                android.hardware.tetheroffload.config@1.0 \
                android.hardware.tetheroffload.control@1.0

LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_EXECUTABLES)

LOCAL_CLANG := true
include $(BUILD_EXECUTABLE)

################################################################################

define ADD_TEST

include $(CLEAR_VARS)
LOCAL_MODULE       := $1
LOCAL_SRC_FILES    := $1
LOCAL_MODULE_CLASS := ipacm
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_PATH  := $(TARGET_OUT_ETC)
include $(BUILD_PREBUILT)

endef

include $(CLEAR_VARS)
LOCAL_MODULE := IPACM_cfg.xml
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(LOCAL_MODULE)
LOCAL_MODULE_OWNER := ipacm
include $(BUILD_PREBUILT)

endif # $(TARGET_ARCH)
endif
endif
endif
