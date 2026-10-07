# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

GUIX ?= guix

public-variables = sed -n 's/^(define-public \([^ ]*\)$$/\1/p'

package-expressions = $(foreach file,\
    $(wildcard modules/sagittarius/$(1)/*.scm),\
    $(foreach variable,$(shell $(public-variables) $(file)),\
        -e '(@ (sagittarius $(1) $(basename $(notdir $(file)))) $(variable))'))

PACKAGES := $(call package-expressions,packages)
LOCKED := $(call package-expressions,locked)

.PHONY: check lint

check:
	$(GUIX) build -L $(CURDIR)/modules --dry-run $(PACKAGES) $(LOCKED)
	$(MAKE) lint

# 'guix style' cannot edit the packages that 'locked-package' makes.
lint:
	! $(GUIX) lint -L $(CURDIR)/modules --no-network $(PACKAGES) $(LOCKED) \
	    2>&1 | grep -v '^;;;' | grep .
	! $(GUIX) style -L $(CURDIR)/modules --dry-run $(PACKAGES) 2>&1 \
	    | grep -v '^;;;' | grep .
