MODULE_NAME := experiments/random_window_1g

include $(EXPERIMENTS_TEMPLATE)

CREATE_RANDOM_WINDOW_LAYOUTS_SCRIPT := $(MODULE_NAME)/createLayouts.py
$(LAYOUTS_FILE): $(MEMORY_FOOTPRINT_FILE)
	$(CREATE_RANDOM_WINDOW_LAYOUTS_SCRIPT) \
		--memory_footprint=$(MEMORY_FOOTPRINT_FILE) --num_layouts=$(NUM_LAYOUTS) \
		--output=$@


