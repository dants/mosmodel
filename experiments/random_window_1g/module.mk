MODULE_NAME := experiments/random_window_1g
RANDOM_WINDOW_1G_MODULE_NAME := $(MODULE_NAME)

NUM_OF_CONFIGURATIONS := 9
$(MODULE_NAME)/%: NUM_OF_CONFIGURATIONS := $(NUM_OF_CONFIGURATIONS)
RANDOM_WINDOW_1G_CONFIGURATIONS := \
	$(call configuration_array,$(NUM_OF_CONFIGURATIONS))
SUBMODULES := $(addprefix $(MODULE_NAME)/,$(RANDOM_WINDOW_1G_CONFIGURATIONS))

RANDOM_WINDOW_1G_NUM_OF_REPEATS := 3
$(MODULE_NAME)/%: NUM_OF_REPEATS := $(RANDOM_WINDOW_1G_NUM_OF_REPEATS)

RANDOM_WINDOW_1G_CONFIGURATION_MAKEFILES := $(addsuffix /module.mk,$(SUBMODULES))
$(RANDOM_WINDOW_1G_CONFIGURATION_MAKEFILES): $(MODULE_NAME)/configuration%/module.mk: \
	$(MOSALLOC_TEMPLATE)
	mkdir -p $(dir $@)
	cp -rf $< $@
	sed -i 's,TEMPLATE_ARG1,$(RANDOM_WINDOW_1G_MODULE_NAME),g' $@
	sed -i 's,TEMPLATE_ARG2,$*,g' $@

PER_BENCHMARK_TARGETS := $(addprefix $(MODULE_NAME)/,$(INTERESTING_BENCHMARKS))
$(PER_BENCHMARK_TARGETS): $(MODULE_NAME)/%: $(addsuffix /%,$(SUBMODULES))
	echo "Finished running all configurations of benchmark $*: $^"

CREATE_RANDOM_1G_CONFIGURATIONS_SCRIPT := $(MODULE_NAME)/scanRandomWindow.py
RANDOM_WINDOW_1G_CONFIGURATION_FILES := $(addprefix $(MODULE_NAME)/,$(INTERESTING_BENCHMARKS))
RANDOM_WINDOW_1G_CONFIGURATION_FILES := $(addsuffix /configurations.txt,$(RANDOM_WINDOW_1G_CONFIGURATION_FILES))
RANDOM_WINDOW_1G_CONFIGURATION_OUTPUT_DIR := $(MODULE_NAME)

$(RANDOM_WINDOW_1G_CONFIGURATION_FILES): $(MODULE_NAME)/%/configurations.txt: \
	$(MEMORY_FOOTPRINT_FILE)
	mkdir -p $(dir $@)
	$(CREATE_RANDOM_1G_CONFIGURATIONS_SCRIPT) --memory_footprint=$(MEMORY_FOOTPRINT_FILE) \
		--num_configurations=$(NUM_OF_CONFIGURATIONS) \
		--benchmark $* --output_dir=$(RANDOM_WINDOW_1G_CONFIGURATION_OUTPUT_DIR)

DELETE_TARGETS := $(addsuffix /delete,$(RANDOM_WINDOW_1G_CONFIGURATION_FILES) \
	$(RANDOM_WINDOW_1G_CONFIGURATION_MAKEFILES))
$(MODULE_NAME)/clean: $(DELETE_TARGETS)

include $(ROOT_DIR)/common.mk

