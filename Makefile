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
MODULES := $(shell find modules -name '*.scm' | sort)

REPL = $(GUIX) repl -L $(CURDIR)/modules \
    -L $(shell $(GUIX) build -L $(CURDIR)/modules guile-landlock)/share/guile/site/3.0 \
    -L $(shell $(GUIX) build -L $(CURDIR)/modules guile-seccomp)/share/guile/site/3.0

.PHONY: check lint test warnings

# Building the locked packages compiles the runtime of their wrappers
check:
	$(GUIX) build -L $(CURDIR)/modules --dry-run $(PACKAGES)
	$(GUIX) build -L $(CURDIR)/modules $(LOCKED)
	$(MAKE) warnings
	$(MAKE) lint
	$(MAKE) test

warnings:
	$(REPL) -- etc/check-warnings.scm $(MODULES)

test:
	$(REPL) -- tests/locked.scm

# 'guix style' cannot edit the packages that 'make-locked-package' makes.
lint:
	! $(GUIX) lint -L $(CURDIR)/modules --no-network $(PACKAGES) $(LOCKED) \
	    2>&1 | grep -v '^;;;' | grep .
	! $(GUIX) style -L $(CURDIR)/modules --dry-run $(PACKAGES) 2>&1 \
	    | grep -v '^;;;' | grep .
