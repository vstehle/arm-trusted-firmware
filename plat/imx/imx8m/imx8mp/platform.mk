#
# Copyright 2019-2020 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#

PLAT_INCLUDES		:=	-Iplat/imx/common/include		\
				-Iplat/imx/imx8m/include		\
				-Iplat/imx/imx8m/imx8mp/include		\
				-Idrivers/imx/usdhc			\
				-Iinclude/common/tbbr
# Translation tables library
include lib/xlat_tables_v2/xlat_tables.mk

# Include GICv3 driver files
include drivers/arm/gic/v3/gicv3.mk

IMX_GIC_SOURCES		:=	${GICV3_SOURCES}			\
				plat/common/plat_gicv3.c		\
				plat/common/plat_psci_common.c		\
				plat/imx/common/plat_imx8_gic.c

BL31_SOURCES		+=	plat/imx/common/imx8_helpers.S			\
				plat/imx/imx8m/gpc_common.c			\
				plat/imx/imx8m/imx_aipstz.c			\
				plat/imx/imx8m/imx_rdc.c			\
				plat/imx/imx8m/imx8m_caam.c			\
				plat/imx/imx8m/imx8m_psci_common.c		\
				plat/imx/imx8m/imx8mp/imx8mp_bl31_setup.c	\
				plat/imx/imx8m/imx8mp/imx8mp_psci.c		\
				plat/imx/imx8m/imx8mp/gpc.c			\
				plat/imx/common/imx8_topology.c			\
				plat/imx/common/imx_sip_handler.c		\
				plat/imx/common/imx_sip_svc.c			\
				plat/imx/common/imx_uart_console.S		\
				lib/cpus/aarch64/cortex_a53.S			\
				drivers/arm/tzc/tzc380.c			\
				drivers/delay_timer/delay_timer.c		\
				drivers/delay_timer/generic_delay_timer.c	\
				${IMX_GIC_SOURCES}				\
				${XLAT_TABLES_LIB_SRCS}

ifeq (${NEED_BL2},yes)
BL2_SOURCES		+=	common/desc_image_load.c			\
				plat/imx/common/imx8_helpers.S			\
				plat/imx/common/imx_uart_console.S		\
				plat/imx/imx8m/imx8mp/imx8mp_bl2_el3_setup.c	\
				plat/imx/imx8m/imx8mp/gpc.c			\
				plat/imx/imx8m/imx_aipstz.c			\
				plat/imx/imx8m/imx_rdc.c			\
				plat/imx/imx8m/imx8m_caam.c			\
				plat/common/plat_psci_common.c			\
				lib/cpus/aarch64/cortex_a53.S			\
				drivers/arm/tzc/tzc380.c			\
				drivers/delay_timer/delay_timer.c		\
				drivers/delay_timer/generic_delay_timer.c	\
				${PLAT_GIC_SOURCES}				\
				${PLAT_DRAM_SOURCES}				\
				${XLAT_TABLES_LIB_SRCS}				\
				drivers/mmc/mmc.c				\
				drivers/io/io_block.c				\
				drivers/io/io_fip.c				\
				drivers/io/io_memmap.c				\
				drivers/io/io_storage.c				\
				drivers/imx/usdhc/imx_usdhc.c			\
				plat/imx/imx8m/imx8mp/imx8mp_bl2_mem_params_desc.c	\
				plat/imx/imx8m/imx8mp/imx8mp_io_storage.c		\
				plat/imx/imx8m/imx8mp/imx8mp_image_load.c		\
				lib/optee/optee_utils.c
endif

# Add the build options to pack BLx images and kernel device tree
# in the FIP if the platform requires.
ifneq ($(BL2),)
RESET_TO_BL31		:=	0
$(eval $(call TOOL_ADD_PAYLOAD,${BUILD_PLAT}/tb_fw.crt,--tb-fw-cert))
endif
ifneq ($(BL32_EXTRA1),)
$(eval $(call TOOL_ADD_IMG,BL32_EXTRA1,--tos-fw-extra1))
endif
ifneq ($(BL32_EXTRA2),)
$(eval $(call TOOL_ADD_IMG,BL32_EXTRA2,--tos-fw-extra2))
endif
ifneq ($(HW_CONFIG),)
$(eval $(call TOOL_ADD_IMG,HW_CONFIG,--hw-config))
endif

ifeq (${NEED_BL2},yes)
$(eval $(call add_define,NEED_BL2))
LOAD_IMAGE_V2		:=	1
# Non-TF Boot ROM
BL2_AT_EL3		:=	1
endif

USE_COHERENT_MEM	:=	1
RESET_TO_BL31		:=	1
A53_DISABLE_NON_TEMPORAL_HINT := 0

ERRATA_A53_835769	:=	1
ERRATA_A53_843419	:=	1
ERRATA_A53_855873	:=	1

BL32_BASE		?=	0x56000000
$(eval $(call add_define,BL32_BASE))

BL32_SIZE		?=	0x2000000
$(eval $(call add_define,BL32_SIZE))

IMX_BOOT_UART_BASE	?=	0x30890000
$(eval $(call add_define,IMX_BOOT_UART_BASE))
