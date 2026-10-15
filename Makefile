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
VMS := $(foreach vm,$(basename $(notdir $(wildcard modules/sagittarius/vms/*.scm))),\
    -e '(@ (sagittarius vms $(vm)) $(vm)-vm)')
MODULES := $(shell find modules -name '*.scm' | sort)

REPL = $(GUIX) repl -L $(CURDIR)/modules

.PHONY: check lint warnings

# Building the locked packages compiles the runtime of their wrappers
check:
	$(GUIX) build -L $(CURDIR)/modules --dry-run $(PACKAGES)
	$(GUIX) build -L $(CURDIR)/modules $(LOCKED)
	$(GUIX) build -L $(CURDIR)/modules --dry-run $(VMS)
	$(MAKE) warnings
	$(MAKE) lint

warnings:
	$(REPL) -- etc/check-warnings.scm $(MODULES)

# 'guix style' cannot edit the packages that 'make-locked-package' makes.
lint:
	! $(GUIX) lint -L $(CURDIR)/modules --no-network $(PACKAGES) $(LOCKED) \
	    2>&1 | grep -v '^;;;' | grep .
	! $(GUIX) style -L $(CURDIR)/modules --dry-run $(PACKAGES) 2>&1 \
	    | grep -v '^;;;' | grep .
