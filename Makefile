
.PHONY: all \
				wlts-operations \
				sankey-plot \
				lulc-trajectory-comparison \
				compose-build \
				compose-up \
				compose

#
# General workflow definition
#
all: wlts-operations sankey-plot lulc-trajectory-comparison   ## (Workflow) Execute all workflow steps.

#
# WLTS and WLCCS base operations (for R and Python)
#
analysis/data/derived_data/base-operations/listing%_python.csv: analysis/data/raw_data/workflow_parameters.yml
	papermill analysis/scripts/wlts-operations/wlts-operations-python.ipynb \
		analysis/scripts/wlts-operations/wlts-operations-python.ipynb \
		-f $<

analysis/data/derived_data/base-operations/listing1_r.csv: analysis/data/raw_data/workflow_parameters.yml
	papermill analysis/scripts/wlts-operations/wlts-operations-r.ipynb \
		analysis/scripts/wlts-operations/wlts-operations-r.ipynb \
		-f $<

wlts-operations: analysis/data/derived_data/base-operations/listing1_python.csv analysis/data/derived_data/base-operations/listing3_python.csv analysis/data/derived_data/base-operations/listing1_r.csv  ## (Workflow) Execute the notebooks with the WLTS and WLCCS base operations presented in the paper.

#
# Sankey plot
#
analysis/data/derived_data/sankey-plot/sao-felix-do-xingu_trajectories.rds: analysis/data/raw_data/workflow_parameters.yml analysis/data/raw_data/study-area_sao-felix-do-xingu/sao-felix-do-xingu_utm_sqr_pts1km.shp
	papermill analysis/scripts/sankey-plot/1_wlts_sankey-plot_data-extraction.ipynb \
		analysis/scripts/sankey-plot/1_wlts_sankey-plot_data-extraction.ipynb \
		-f $<

analysis/data/derived_data/sankey-plot/plot_sf_terraclass_amz.png: analysis/data/derived_data/sankey-plot/sao-felix-do-xingu_trajectories.rds
	papermill analysis/scripts/sankey-plot/2_wlts-sankey-plot_data-visualization.ipynb \
		analysis/scripts/sankey-plot/2_wlts-sankey-plot_data-visualization.ipynb
        
sankey-plot: analysis/data/derived_data/sankey-plot/plot_sf_terraclass_amz.png  ## (Workflow) Execute the notebooks to generate the Sankey Plot presented in the paper.

#
# LULC trajectory comparison
#
analysis/data/derived_data/lulc-trajectory-comparison/harmonized-trajectories_mapbiomas-terraclass_2014.json: analysis/data/raw_data/workflow_parameters.yml analysis/data/raw_data/study-area_sao-felix-do-xingu/sao-felix-do-xingu_utm_sqr_pts1km.shp
	papermill analysis/scripts/lulc-trajectory-comparison/1_wlts-wlccs_lulc-trajectories-comparison_data-extraction.ipynb \
		analysis/scripts/lulc-trajectory-comparison/1_wlts-wlccs_lulc-trajectories-comparison_data-extraction.ipynb \
		-f $<

analysis/data/derived_data/lulc-trajectory-comparison/trajectory-concordance_tc-mb-2014.csv: analysis/data/derived_data/lulc-trajectory-comparison/harmonized-trajectories_mapbiomas-terraclass_2014.json
	papermill analysis/scripts/lulc-trajectory-comparison/2_wlts-wlccs_lulc-trajectories-comparison_analysis.ipynb \
		analysis/scripts/lulc-trajectory-comparison/2_wlts-wlccs_lulc-trajectories-comparison_analysis.ipynb

lulc-trajectory-comparison: analysis/data/derived_data/lulc-trajectory-comparison/trajectory-concordance_tc-mb-2014.csv  ## (Workflow) Execute the notebooks to generate the Agreement analysis presented in the paper.

clean: ## (Workflow) Remove all workflow results.
	rm -rf analysis/data/derived_data/sankey-plot/*
	rm -rf analysis/data/derived_data/base-operations/*
	rm -rf analysis/data/derived_data/lulc-trajectory-comparison/*

#
# Build commands
#
compose-build:     ## (Environment) Build the Docker Image of the environment needed to run the code.
	docker-compose build --no-cache

compose-up: compose-build     ## (Environment) Start the Docker Container with a Jupyter Lab for code execution.
	docker-compose up

compose: compose-up     ## (Environment) Build the Docker Image and start it for code execution on a Jupyter Lab environment.

#
# Miscelaneous
#
generate-make-graph:  ## (Miscellaneous) Generate make dependencies as a graph
	make -Bnd | make2graph -b | dot -Tpng -Gdpi=300 -o figures/makegraph.png

# Documentation function (thanks for https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html)
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
