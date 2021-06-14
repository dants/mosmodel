ifndef NUM_LAYOUTS
NUM_LAYOUTS := 9
endif # ifndef NUM_LAYOUTS

ifndef LAYOUTS
LAYOUTS := $(shell seq 1 $(NUM_LAYOUTS))
LAYOUTS := $(addprefix layout,$(LAYOUTS)) 
endif #ifndef LAYOUTS

ifndef NUM_OF_REPEATS
NUM_OF_REPEATS := 4
endif # ifndef NUM_OF_REPEATS

$(MODULE_NAME)% : NUM_LAYOUTS := $(NUM_LAYOUTS)

EXPERIMENT_DIR := $(MODULE_NAME)
RESULT_DIR := $(subst experiments,results,$(EXPERIMENT_DIR))
RESULT_DIRS += $(RESULT_DIR)

LAYOUTS_DIR := $(EXPERIMENT_DIR)/layouts
LAYOUT_FILES := $(addprefix $(LAYOUTS_DIR)/,$(LAYOUTS))
LAYOUT_FILES := $(addsuffix .csv,$(LAYOUT_FILES))

$(LAYOUTS_DIR): $(LAYOUT_FILES)

EXPERIMENTS := $(addprefix $(EXPERIMENT_DIR)/,$(LAYOUTS)) 
RESULTS := $(addsuffix /mean.csv,$(RESULT_DIR)) 

REPEATS := $(shell seq 1 $(NUM_OF_REPEATS))
REPEATS := $(addprefix repeat,$(REPEATS)) 

EXPERIMENT_REPEATS := $(foreach experiment,$(EXPERIMENTS),$(foreach repeat,$(REPEATS),$(experiment)/$(repeat)))
MEASUREMENTS := $(addsuffix /perf.out,$(EXPERIMENT_REPEATS))

$(EXPERIMENT_DIR): $(MEASUREMENTS)
$(EXPERIMENTS): $(EXPERIMENT_DIR)/layout%: $(foreach repeat,$(REPEATS),$(addsuffix /$(repeat)/perf.out,$(EXPERIMENT_DIR)/layout%))
$(EXPERIMENT_REPEATS): %: %/perf.out

$(MEASUREMENTS): EXTRA_ARGS_FOR_MOSALLOC := $(EXTRA_ARGS_FOR_MOSALLOC)

define MEASUREMENTS_template =
$(EXPERIMENT_DIR)/$(1)/$(2)/perf.out: $(EXPERIMENT_DIR)/layouts/$(1).csv $(MOSALLOC_TOOL)
	echo ========== [INFO] start producing: $$@ ==========
	mkdir -p $$(dir $$@)
	cd $$(dir $$@)
	$$(MEASURE_GENERAL_METRICS) $$(SET_CPU_MEMORY_AFFINITY) $$(BOUND_MEMORY_NODE) \
		$$(RUN_MOSALLOC_TOOL) \
		--library $$(MOSALLOC_TOOL) \
		-cpf "../../layouts/$(1).csv" \
		$$(EXTRA_ARGS_FOR_MOSALLOC) -- \
		$$(BENCHMARK)
endef

$(foreach layout,$(LAYOUTS),$(foreach repeat,$(REPEATS),$(eval $(call MEASUREMENTS_template,$(layout),$(repeat)))))

results: $(RESULT_DIR)
$(RESULTS): LAYOUT_LIST := $(call array_to_comma_separated,$(LAYOUTS))
$(RESULT_DIR): $(RESULTS)
$(RESULTS): results/%/mean.csv: experiments/%
	mkdir -p $(dir $@)
	$(COLLECT_RESULTS_SCRIPT) --experiments_root=$< --repeats=$(NUM_OF_REPEATS) \
		--layouts=$(LAYOUT_LIST) --output_dir=$(dir $@)

DELETED_TARGETS := $(EXPERIMENT_REPEATS) $(EXPERIMENTS)
CLEAN_TARGETS := $(addsuffix /clean,$(DELETED_TARGETS))
$(CLEAN_TARGETS): %/clean: %/delete
$(MODULE_NAME)/clean: $(CLEAN_TARGETS)


