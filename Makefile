PYTHON = python3

# ── Brick parameters ───────────────────────────────────────────────────────────
SQ_PX  = 14   # raster pixel width for square logos  (lower = blockier)
HZ_PX  = 14   # raster pixel width for horizontal logos
BLK_W  = 24   # SVG width of a 2×2 brick (1×1 = half)
BLK_H  = 20   # SVG height of all bricks

# ── Directories ────────────────────────────────────────────────────────────────
DESIGN_DIR = design
SQ_DIR     = logo/square/svg
HZ_DIR     = logo/horizontal/svg
SQ_PNG     = logo/square/png
HZ_PNG     = logo/horizontal/png

# ── Variant names (stem shared by design SVG and all outputs) ──────────────────
VARIANTS = minifig-yellow minifig-black minifig-white

# ── Derived file lists ─────────────────────────────────────────────────────────
DESIGN_SVGS     = $(patsubst %,$(DESIGN_DIR)/%.svg,$(VARIANTS))

SQ_SVGS         = $(patsubst %,$(SQ_DIR)/%.svg,$(VARIANTS))
HZ_SVGS         = $(patsubst %,$(HZ_DIR)/%.svg,$(VARIANTS))
HZ_FULL_SVGS    = $(patsubst %,$(HZ_DIR)/%-full.svg,$(VARIANTS))

SQ_PNGS         = $(patsubst %,$(SQ_PNG)/%.png,$(VARIANTS))
SQ_WEBPS        = $(patsubst %,$(SQ_PNG)/%.webp,$(VARIANTS))
HZ_PNGS         = $(patsubst %,$(HZ_PNG)/%.png,$(VARIANTS))
HZ_WEBPS        = $(patsubst %,$(HZ_PNG)/%.webp,$(VARIANTS))
HZ_FULL_PNGS    = $(patsubst %,$(HZ_PNG)/%-full.png,$(VARIANTS))
HZ_FULL_WEBPS   = $(patsubst %,$(HZ_PNG)/%-full.webp,$(VARIANTS))

ALL_SVGS  = $(SQ_SVGS) $(HZ_SVGS) $(HZ_FULL_SVGS)
ALL_PNGS  = $(SQ_PNGS) $(SQ_WEBPS) $(HZ_PNGS) $(HZ_WEBPS) $(HZ_FULL_PNGS) $(HZ_FULL_WEBPS)

# ── Top-level targets ──────────────────────────────────────────────────────────
.PHONY: all logos pngs designs clean help shell develop

all: logos pngs ## Build everything (brick SVGs + PNG/WebP exports)

logos: designs $(ALL_SVGS) ## Build all brick SVGs

pngs: logos $(ALL_PNGS) ## Export all PNGs and WebPs

designs: $(DESIGN_SVGS) ## Generate design SVGs from colors.py (re-runs on color change)

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

clean: ## Remove all generated files (design/, logo outputs, and Python cache)
	rm -f $(DESIGN_SVGS)
	rm -f $(SQ_SVGS) $(HZ_SVGS) $(HZ_FULL_SVGS)
	rm -f $(SQ_PNGS) $(SQ_WEBPS) $(HZ_PNGS) $(HZ_WEBPS) $(HZ_FULL_PNGS) $(HZ_FULL_WEBPS)
	rm -rf __pycache__

shell: ## Enter devenv shell
	devenv shell

develop: devenv.local.nix devenv.local.yaml ## Bootstrap development environment
	devenv shell --profile=devcontainer -- code .

devenv.local.nix:
	cp devenv.local.nix.example devenv.local.nix

devenv.local.yaml:
	cp devenv.local.yaml.example devenv.local.yaml

# ── Design SVGs (grouped output — regenerate all when colors.py changes) ───────
$(DESIGN_SVGS): colors.py generate_designs.py
	$(PYTHON) generate_designs.py

# ── Square brick SVGs ──────────────────────────────────────────────────────────
$(SQ_DIR):
	mkdir -p $@

$(SQ_DIR)/%.svg: $(DESIGN_DIR)/%.svg | $(SQ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(SQ_PX) $(BLK_W) $(BLK_H) auto

# ── Horizontal brick SVGs — full variant (with subtitle) ──────────────────────
# Must be listed BEFORE the generic %.svg rule so make tries it first.
$(HZ_DIR)/%-full.svg: $(HZ_DIR)/%.svg
	$(PYTHON) compose_logo.py $< $@

# ── Horizontal brick SVGs — simple (no subtitle) ──────────────────────────────
$(HZ_DIR):
	mkdir -p $@

$(HZ_DIR)/%.svg: $(DESIGN_DIR)/%.svg | $(HZ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(HZ_PX) $(BLK_W) $(BLK_H) auto

# ── Square PNG / WebP exports ──────────────────────────────────────────────────
$(SQ_PNG):
	mkdir -p $@

$(SQ_PNG)/%.png: $(SQ_DIR)/%.svg | $(SQ_PNG)
	$(PYTHON) export_raster.py $< $@ 800

$(SQ_PNG)/%.webp: $(SQ_DIR)/%.svg | $(SQ_PNG)
	$(PYTHON) export_raster.py $< $@ 800

# ── Horizontal PNG / WebP exports ─────────────────────────────────────────────
$(HZ_PNG):
	mkdir -p $@

$(HZ_PNG)/%.png: $(HZ_DIR)/%.svg | $(HZ_PNG)
	$(PYTHON) export_raster.py $< $@ 800

$(HZ_PNG)/%.webp: $(HZ_DIR)/%.svg | $(HZ_PNG)
	$(PYTHON) export_raster.py $< $@ 800
