MODULE_NAME := analysis
SUBMODULES := \
	growing_window_2m \
	random_window_2m \
	sliding_window \
	linear_models_coeffs \
	pebs_tlb_miss_trace \
	random_window_1g \
	mosmodel \
	all_data #\
	train_mosmodel test_mosmodel all_data \
	tlb_misses_vs_table_walks \
	single_page_size model_errors perf_mem
SUBMODULES := $(addprefix $(MODULE_NAME)/,$(SUBMODULES))

ARRANGE_DATA_TO_PLOT_SCRIPT := $(MODULE_NAME)/arrangeDataToPlot.py
SCATTER_PLOT_SCRIPT := $(MODULE_NAME)/plotScatter.gp
WHISKER_PLOT_SCRIPT := $(MODULE_NAME)/plotWhisker.gp
POLY_PLOT_SCRIPT := $(MODULE_NAME)/assessPolynomialModels.py
BUILD_OVERHEAD_SCRIPT := $(MODULE_NAME)/buildOverheadSummary.py

COMMON_ANALYSIS_MAKEFILE := $(MODULE_NAME)/common.mk

include $(ROOT_DIR)/common.mk

