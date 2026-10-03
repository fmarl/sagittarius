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
