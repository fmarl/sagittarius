;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

;; Packages checked for updates:
;;
;;   guix refresh -L modules -m etc/updates.scm
;;
;; Not listed: zig-translate-c and the zig bindings, whose versions river
;; pins in its build.zig.zon, zig-arocc, which is pinned to a commit, and
;; nucleotide.
(specifications->manifest
 '("mullvad-vpn-desktop"
   "python-virtme-ng"
   "river@0.4"))
