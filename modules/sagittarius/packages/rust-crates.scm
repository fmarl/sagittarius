;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages rust-crates)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:export (lookup-cargo-inputs))

;;;
;;; This file is managed by ‘guix import’.  Do NOT add definitions manually.
;;;

(define qqqq-separator 'begin-of-crates)

(define rust-anstream-1.0.0
  (crate-source "anstream" "1.0.0"
                "13d2bj0xfg012s4rmq44zc8zgy1q8k9yp7yhvfnarscnmwpj2jl2"))

(define rust-anstyle-1.0.14
  (crate-source "anstyle" "1.0.14"
                "0030szmgj51fxkic1hpakxxgappxzwm6m154a3gfml83lq63l2wl"))

(define rust-anstyle-parse-1.0.0
  (crate-source "anstyle-parse" "1.0.0"
                "03hkv2690s0crssbnmfkr76kw1k7ah2i6s5amdy9yca2n8w7zkjj"))

(define rust-anstyle-query-1.1.5
  (crate-source "anstyle-query" "1.1.5"
                "1p6shfpnbghs6jsa0vnqd8bb8gd7pjd0jr7w0j8jikakzmr8zi20"))

(define rust-anstyle-wincon-3.0.11
  (crate-source "anstyle-wincon" "3.0.11"
                "0zblannm70sk3xny337mz7c6d8q8i24vhbqi42ld8v7q1wjnl7i9"))

(define rust-bitflags-2.13.2
  (crate-source "bitflags" "2.13.2"
                "01hbgjwvid66850fzi76mvn5f2bqycx6sf165ng1kfjqq9bl1v9x"))

(define rust-bytemuck-1.25.2
  (crate-source "bytemuck" "1.25.2"
                "15rp2m7j7kq22s76cbjwmrkd5r8lvacnm0mnrj013cnzka22x0wm"))

(define rust-bytemuck-derive-1.12.1
  (crate-source "bytemuck_derive" "1.12.1"
                "17379imphax0d85jzkc50acw746mw89hjbrxqxlw1wmnhxjqj7va"))

(define rust-calloop-0.14.5
  (crate-source "calloop" "0.14.5"
                "0pjf9fmgq3zf3fnbcb3w9cml19lr0vv9pvhpklf75j1px49j7cs3"))

(define rust-calloop-wayland-source-0.4.1
  (crate-source "calloop-wayland-source" "0.4.1"
                "1yi1c23naqhd8m94q3v366s4cak8l50zy7ldrkqfn0hajkqgr3hk"))

(define rust-cc-1.10.0
  (crate-source "cc" "1.10.0"
                "185yfn6np0m5x7hz1q7qf595sqzbbs2vc9dshxhssh1ydvx5bq46"))

(define rust-cfg-if-1.0.5
  (crate-source "cfg-if" "1.0.5"
                "0026j56901nzjraap3da0a8njw42j66zcxnn6s2s9aa5bcblhxjf"))

(define rust-clap-4.6.7
  (crate-source "clap" "4.6.7"
                "0il98y2rfw75984ck59znd4n592p07bxz8yy3a9blddb02rpd25a"))

(define rust-clap-builder-4.6.7
  (crate-source "clap_builder" "4.6.7"
                "0kbhai5rv1vj9r4np52g2b9fmhvy3y82digs9v40c57bgbxrf1zc"))

(define rust-clap-derive-4.6.7
  (crate-source "clap_derive" "4.6.7"
                "1q36bgbkfb9rdz7jcvd0ffv0wwlyw0lg3z6iwdcybm0mjjvm3izr"))

(define rust-clap-lex-1.1.1
  (crate-source "clap_lex" "1.1.1"
                "11k4m4ngn39iz39lnq6nn6kyxzp62mnm1d86qfad3q0vlk33n4qw"))

(define rust-colorchoice-1.0.5
  (crate-source "colorchoice" "1.0.5"
                "0w75k89hw39p0mnnhlrwr23q50rza1yjki44qvh2mgrnj065a1qx"))

(define rust-concurrent-queue-2.5.0
  (crate-source "concurrent-queue" "2.5.0"
                "0wrr3mzq2ijdkxwndhf79k952cp4zkz35ray8hvsxl96xrx1k82c"))

(define rust-core-maths-0.1.1
  (crate-source "core_maths" "0.1.1"
                "0c0dv11ixxpc9bsx5xasvl98mb1dlprzcm6qq6ls3nsygw0mwx3p"))

(define rust-cosmic-text-0.19.0
  (crate-source "cosmic-text" "0.19.0"
                "0wys9shmdcibqacxl3qy50z5h48ff2xbx8j87zhlr4qda64bc5xy"))

(define rust-crossbeam-utils-0.8.23
  (crate-source "crossbeam-utils" "0.8.23"
                "1ilan2nw7fvka8hki80fr57a5dgd4mvcsvwq60437j6yvlwyw7m3"))

(define rust-cursor-icon-1.2.0
  (crate-source "cursor-icon" "1.2.0"
                "0bvkw7ak1mqwcpkgd9lh7n00hcvlh87jfl7188f231nz6zfy2ypj"))

(define rust-downcast-rs-1.2.1
  (crate-source "downcast-rs" "1.2.1"
                "1lmrq383d1yszp7mg5i7i56b17x2lnn3kb91jwsq0zykvg2jbcvm"))

(define rust-errno-0.3.14
  (crate-source "errno" "0.3.14"
                "1szgccmh8vgryqyadg8xd58mnwwicf39zmin3bsn63df2wbbgjir"))

(define rust-find-msvc-tools-0.1.15
  (crate-source "find-msvc-tools" "0.1.15"
                "0j5sh4lb7g8xh6kd67s0vz037ah5hlp9f2rbgbg9f41rqmf92rhw"))

(define rust-font-types-0.11.3
  (crate-source "font-types" "0.11.3"
                "1mygnhm4xrnm803w2ax63ka3nm0s56l4h26mrs9xkbbdby8ssf2v"))

(define rust-font-types-0.12.7
  (crate-source "font-types" "0.12.7"
                "0pgks8skqzhjidjpxkyp154rl335pjf7yf6ydh17jjj6h7byjnl3"))

(define rust-fontconfig-parser-0.5.8
  (crate-source "fontconfig-parser" "0.5.8"
                "0ijnbzg31sl6v49g7q2l7sl76hjj8z0hvlsz77cdvm029vi77ixv"))

(define rust-fontdb-0.23.0
  (crate-source "fontdb" "0.23.0"
                "0199vry9x8zn9ix4x4rqvv53dy2ryhy68l53jwr580hj7ndphzj5"))

(define rust-harfrust-0.5.2
  (crate-source "harfrust" "0.5.2"
                "1ya5d0j39lf15vk27vncz616cbbadm6rggvp95k9cvhzhapfb8lx"))

(define rust-heck-0.5.0
  (crate-source "heck" "0.5.0"
                "1sjmpsdl8czyh9ywl3qcsfsq9a307dg4ni2vnlwgnzzqhc4y0113"))

(define rust-hermit-abi-0.5.3
  (crate-source "hermit-abi" "0.5.3"
                "115jzi6ixx2nhkzbr2ijj36634agz32n6ilz2rg7vk5s1vb94xg1"))

(define rust-is-terminal-polyfill-1.70.2
  (crate-source "is_terminal_polyfill" "1.70.2"
                "15anlc47sbz0jfs9q8fhwf0h3vs2w4imc030shdnq54sny5i7jx6"))

(define rust-itoa-1.0.18
  (crate-source "itoa" "1.0.18"
                "10jnd1vpfkb8kj38rlkn2a6k02afvj3qmw054dfpzagrpl6achlg"))

(define rust-libc-0.2.191
  (crate-source "libc" "0.2.191"
                "02i4j7pjh129y92rijaia4576131fa2xjsii1dc3c1fnlv4qgkb5"))

(define rust-libm-0.2.16
  (crate-source "libm" "0.2.16"
                "10brh0a3qjmbzkr5mf5xqi887nhs5y9layvnki89ykz9xb1wxlmn"))

(define rust-linebender-resource-handle-0.1.1
  (crate-source "linebender_resource_handle" "0.1.1"
                "1x34mrmqan0m3m9xf2iy6vpkcx6vwiiyzm2g3ixqdi56rimzz9fl"))

(define rust-linux-raw-sys-0.12.1
  (crate-source "linux-raw-sys" "0.12.1"
                "0lwasljrqxjjfk9l2j8lyib1babh2qjlnhylqzl01nihw14nk9ij"))

(define rust-log-0.4.35
  (crate-source "log" "0.4.35"
                "0p002750b2hab9bnlxxrvk5g9dvyaf23kiy39s6wsi6s29nzh5ax"))

(define rust-memchr-2.8.3
  (crate-source "memchr" "2.8.3"
                "161xa63ipfanf8v3nb82xd5hqgydv55nzw59wyngqbz6alfaz2yg"))

(define rust-memmap2-0.9.12
  (crate-source "memmap2" "0.9.12"
                "0my158ms3h2akj1l8bzabwjz1v9jkw8klcg82am2bk4yb8as233b"))

(define rust-once-cell-1.21.4
  (crate-source "once_cell" "1.21.4"
                "0l1v676wf71kjg2khch4dphwh1jp3291ffiymr2mvy1kxd5kwz4z"))

(define rust-once-cell-polyfill-1.70.2
  (crate-source "once_cell_polyfill" "1.70.2"
                "1zmla628f0sk3fhjdjqzgxhalr2xrfna958s632z65bjsfv8ljrq"))

(define rust-pin-project-lite-0.2.17
  (crate-source "pin-project-lite" "0.2.17"
                "1kfmwvs271si96zay4mm8887v5khw0c27jc9srw1a75ykvgj54x8"))

(define rust-pkg-config-0.3.34
  (crate-source "pkg-config" "0.3.34"
                "0j05h08nzg0q8rf6lzw7nry0b7kn7x97vc9n4hwrl52fqzxn9d7n"))

(define rust-polling-3.11.0
  (crate-source "polling" "3.11.0"
                "0622qfbxi3gb0ly2c99n3xawp878fkrd1sl83hjdhisx11cly3jx"))

(define rust-proc-macro2-1.0.107
  (crate-source "proc-macro2" "1.0.107"
                "1nb6ly8kp65f724kj73ippc7lvydss24sm2vagk6qpklpg4pwplq"))

(define rust-quick-xml-0.41.0
  (crate-source "quick-xml" "0.41.0"
                "1h9y8zry34r3mxfd5vqfj50vvvzvri4kzbx5d657jkqjalg4aq76"))

(define rust-quote-1.0.47
  (crate-source "quote" "1.0.47"
                "00ch0yyzvv6s671ik0kcsbw8nigdaj2g3fr61kcahwx48aqlvgqz"))

(define rust-rangemap-1.8.0
  (crate-source "rangemap" "1.8.0"
                "0gdaws5kkg3md7z4w7ln4sf3jkz6n3f3xl5pfr6fngvla1dx24d6"))

(define rust-read-fonts-0.37.0
  (crate-source "read-fonts" "0.37.0"
                "1r82vwrmsai9i7bgmnblb7sn08k2kca75lpz0x9v3yijy2mlyqvv"))

(define rust-read-fonts-0.41.0
  (crate-source "read-fonts" "0.41.0"
                "02c7q458gz6cfsyryiss5w6xp0k8dl2n4l1gncjrhidg9mkpssh4"))

(define rust-roxmltree-0.20.0
  (crate-source "roxmltree" "0.20.0"
                "15vw91ps91wkmmgy62khf9zb63bdinvm80957dascbsw7dwvc83c"))

(define rust-rustc-hash-2.1.3
  (crate-source "rustc-hash" "2.1.3"
                "0bbla578m87qmf3yr55q49l97gxn7z0ha1dwqlnvwwc58ad7y7kb"))

(define rust-rustix-1.1.6
  (crate-source "rustix" "1.1.6"
                "1ajqv2zxmfms30hhvp5bdzpixn5xqnz7s871vpa56h99wm16grz5"))

(define rust-self-cell-1.3.0
  (crate-source "self_cell" "1.3.0"
                "04x883z7awzkmn5lqb67n51xynrj2pa9339jgq4j1qa94yh2rd1a"))

(define rust-serde-1.0.229
  (crate-source "serde" "1.0.229"
                "1fp04fq4a79bpm61xz1zy0pbz4kpc7d771zii1k3inmszq55jj21"))

(define rust-serde-core-1.0.229
  (crate-source "serde_core" "1.0.229"
                "0j1ajiha76h3nmd976il9li6975k121xa7jb39ws8n0yqp4s5p37"))

(define rust-serde-derive-1.0.229
  (crate-source "serde_derive" "1.0.229"
                "0j4k63i7h1bikxwz2c89ig0hrwbnl9mz1czn85xx99x5cc9dg9g7"))

(define rust-serde-json-1.0.154
  (crate-source "serde_json" "1.0.154"
                "1mjby21g8fxhrsfp73yz8wg6n2f4h23ah0nczds409l53f5wrsg7"))

(define rust-shlex-2.0.1
  (crate-source "shlex" "2.0.1"
                "1fjsll1cd7d2bcpdij9kd6w62rpbc7qqzvydvs021vsmr1cxvypq"))

(define rust-skrifa-0.40.0
  (crate-source "skrifa" "0.40.0"
                "1b1lfid1326df2aq4cjqz7jv63m3i21czrgks7fxgyvm4hyzxgbz"))

(define rust-skrifa-0.44.0
  (crate-source "skrifa" "0.44.0"
                "0s5a3fnyrxfv514vjjrn268lyhihmh5nb9fyv7cp4ghx5gbbg6l1"))

(define rust-slotmap-1.1.1
  (crate-source "slotmap" "1.1.1"
                "0f20xf53zaysx9ydzkwwqm6hsjyb8lj2j6amhg57iln3jcy8rmdx"))

(define rust-smallvec-1.16.4
  (crate-source "smallvec" "1.16.4"
                "1j772prjisi2872lxry7d9fkss3dfbjwl16jmsvvp2qvk2qx9mfh"))

(define rust-smithay-client-toolkit-0.21.1
  (crate-source "smithay-client-toolkit" "0.21.1"
                "003zc6547msmwh729lkpm6acjw60rax42qamz4svbp0g9ghrxp3l"))

(define rust-smol-str-0.3.7
  (crate-source "smol_str" "0.3.7"
                "041gpvv9qi81h6jp89yv14d7p2rwc5j59pn09jfn26gk4ffi1dzf"))

(define rust-strsim-0.11.1
  (crate-source "strsim" "0.11.1"
                "0kzvqlw8hxqb7y598w1s0hxlnmi84sg5vsipp3yg5na5d1rvba3x"))

(define rust-swash-0.2.10
  (crate-source "swash" "0.2.10"
                "0bprhdib5yjpzvfb0nkqplwpm47di9qnh8ibhy416lr6v319j93c"))

(define rust-syn-3.0.9
  (crate-source "syn" "3.0.9"
                "0fw28lhl90kls24q2h2sp39yjb0lsvz5cwh9fd3f3w3v9kp8v36p"))

(define rust-sys-locale-0.3.2
  (crate-source "sys-locale" "0.3.2"
                "1i16hq9mkwpzqvixjfy1ph4i2q5klgagjg4hibz6k894l2crmawf"))

(define rust-thiserror-2.0.21
  (crate-source "thiserror" "2.0.21"
                "17hq1lh5dyr3bkc7zzjrbrp4qgkvhc48kgq1n5fdxkindaw2rr89"))

(define rust-thiserror-impl-2.0.21
  (crate-source "thiserror-impl" "2.0.21"
                "0945n8agp7kg6n6b35yyjb4g5xv2q22vrw15h6jj1nw76a99flgy"))

(define rust-tinyvec-1.13.3
  (crate-source "tinyvec" "1.13.3"
                "1vphg4gnlpykjy5h4v7r8nl38ij4zr9qyh7qd34ddvwjyqaa6g7x"))

(define rust-tracing-0.1.44
  (crate-source "tracing" "0.1.44"
                "006ilqkg1lmfdh3xhg3z762izfwmxcvz0w7m4qx2qajbz9i1drv3"))

(define rust-tracing-core-0.1.36
  (crate-source "tracing-core" "0.1.36"
                "16mpbz6p8vd6j7sf925k9k8wzvm9vdfsjbynbmaxxyq6v7wwm5yv"))

(define rust-ttf-parser-0.25.1
  (crate-source "ttf-parser" "0.25.1"
                "0cbgqglcwwjg3hirwq6xlza54w04mb5x02kf7zx4hrw50xmr1pyj"))

(define rust-unicode-bidi-0.3.18
  (crate-source "unicode-bidi" "0.3.18"
                "1xcxwbsqa24b8vfchhzyyzgj0l6bn51ib5v8j6krha0m77dva72w"))

(define rust-unicode-ident-1.0.27
  (crate-source "unicode-ident" "1.0.27"
                "0qv54hz0sxmspjyr162z3435pnyylzjjhx3j4k1s359pqgb59ix2"))

(define rust-unicode-linebreak-0.1.5
  (crate-source "unicode-linebreak" "0.1.5"
                "07spj2hh3daajg335m4wdav6nfkl0f6c0q72lc37blr97hych29v"))

(define rust-unicode-script-0.5.8
  (crate-source "unicode-script" "0.5.8"
                "1vmifpgd0map3frmvhszhl96k82crcry083prv05wii7p45x8fiq"))

(define rust-unicode-segmentation-1.13.3
  (crate-source "unicode-segmentation" "1.13.3"
                "1a47zaq83p386r3baq4m018xd5q4q0grdg56i1x042dzn71x7xf6"))

(define rust-utf8parse-0.2.2
  (crate-source "utf8parse" "0.2.2"
                "088807qwjq46azicqwbhlmzwrbkz7l4hpw43sdkdyyk524vdxaq6"))

(define rust-version-check-0.9.5
  (crate-source "version_check" "0.9.5"
                "0nhhi4i5x89gm911azqbn7avs9mdacw2i3vcz3cnmz3mv4rqz4hb"))

(define rust-wayland-backend-0.3.17
  (crate-source "wayland-backend" "0.3.17"
                "0y50cw56f09cdcsinbbl94naz91xf7iqaj87s4f7py6zmm71pa9q"))

(define rust-wayland-client-0.31.15
  (crate-source "wayland-client" "0.31.15"
                "0ww0d0r6rn2h0sn8ma1f7zvxj40l6930p07j044nvmqshq7nmhz3"))

(define rust-wayland-csd-frame-0.3.0
  (crate-source "wayland-csd-frame" "0.3.0"
                "0zjcmcqprfzx57hlm741n89ssp4sha5yh5cnmbk2agflvclm0p32"))

(define rust-wayland-cursor-0.31.14
  (crate-source "wayland-cursor" "0.31.14"
                "0kdk7xwj465idk54jf1f24024gdp63wyagca68a176xyh23x2lja"))

(define rust-wayland-protocols-0.32.13
  (crate-source "wayland-protocols" "0.32.13"
                "1dn4injzx1lnmacnhl3q60m743lvshxmmy0aabb2xaixvq9wil13"))

(define rust-wayland-protocols-experimental-20251230.0.3
  (crate-source "wayland-protocols-experimental" "20251230.0.3"
                "04yg4ny7pkla5iqdswfxvslzxakrphr916a67l4ksmcf2zkw7ili"))

(define rust-wayland-protocols-misc-0.3.12
  (crate-source "wayland-protocols-misc" "0.3.12"
                "1j19dg8h98s153rj2fvbqkghjicdfgjjkr6nvaw0jgpjkrcng5bf"))

(define rust-wayland-protocols-wlr-0.3.12
  (crate-source "wayland-protocols-wlr" "0.3.12"
                "0d424vn2hj27r4gjlshm6hy8fcqysr805jkqdjbwgmrng0pya17b"))

(define rust-wayland-scanner-0.31.11
  (crate-source "wayland-scanner" "0.31.11"
                "1h0al3271l2w124sxlh77s1kmjg0z24ns2mk1vbnfars3d3313ik"))

(define rust-wayland-sys-0.31.11
  (crate-source "wayland-sys" "0.31.11"
                "1gp3hlkxx13i55lyyi794vnw9a780z3skx0xhj71zr69xwzv5snq"))

(define rust-windows-link-0.2.1
  (crate-source "windows-link" "0.2.1"
                "1rag186yfr3xx7piv5rg8b6im2dwcf8zldiflvb22xbzwli5507h"))

(define rust-windows-sys-0.61.2
  (crate-source "windows-sys" "0.61.2"
                "1z7k3y9b6b5h52kid57lvmvm05362zv1v8w0gc7xyv5xphlp44xf"))

(define rust-xcursor-0.3.11
  (crate-source "xcursor" "0.3.11"
                "08wfv0wrij9rrmbgfd2l8a132gyfax05abypllpmwic6hznk6fqn"))

(define rust-xkbcommon-0.8.0
  (crate-source "xkbcommon" "0.8.0"
                "1j8s1sfwc6bw9phsca65rw3q3b5l2651v1s0pk5yxm6baa9wlrld"))

(define rust-xkeysym-0.2.1
  (crate-source "xkeysym" "0.2.1"
                "0mksx670cszyd7jln6s7dhkw11hdfv7blwwr3isq98k22ljh1k5r"))

(define rust-yazi-0.2.2
  (crate-source "yazi" "0.2.2"
                "11pch7fbmgjzmg13cbvhd572ip5i4njxxjffjalyd3ps6ajnwdmc"))

(define rust-zeno-0.3.3
  (crate-source "zeno" "0.3.3"
                "0915lg3b1qiixizic9kwj2bw42x35baxqvl9dn0m2plkj91drwvd"))

(define rust-zmij-1.0.23
  (crate-source "zmij" "1.0.23"
                "06zwri21nnrl34rwinmvbciap8yk1mrl8qfg9pff7lgspc56sri9"))

(define ssss-separator 'end-of-crates)

(define-cargo-inputs
 lookup-cargo-inputs
 (nucleotide-monitor =>
                     (list rust-anstream-1.0.0
                           rust-anstyle-1.0.14
                           rust-anstyle-parse-1.0.0
                           rust-anstyle-query-1.1.5
                           rust-anstyle-wincon-3.0.11
                           rust-bitflags-2.13.2
                           rust-bytemuck-1.25.2
                           rust-bytemuck-derive-1.12.1
                           rust-calloop-0.14.5
                           rust-calloop-wayland-source-0.4.1
                           rust-cc-1.10.0
                           rust-cfg-if-1.0.5
                           rust-clap-4.6.7
                           rust-clap-builder-4.6.7
                           rust-clap-derive-4.6.7
                           rust-clap-lex-1.1.1
                           rust-colorchoice-1.0.5
                           rust-concurrent-queue-2.5.0
                           rust-core-maths-0.1.1
                           rust-cosmic-text-0.19.0
                           rust-crossbeam-utils-0.8.23
                           rust-cursor-icon-1.2.0
                           rust-downcast-rs-1.2.1
                           rust-errno-0.3.14
                           rust-find-msvc-tools-0.1.15
                           rust-font-types-0.11.3
                           rust-font-types-0.12.7
                           rust-fontconfig-parser-0.5.8
                           rust-fontdb-0.23.0
                           rust-harfrust-0.5.2
                           rust-heck-0.5.0
                           rust-hermit-abi-0.5.3
                           rust-is-terminal-polyfill-1.70.2
                           rust-itoa-1.0.18
                           rust-libc-0.2.191
                           rust-libm-0.2.16
                           rust-linebender-resource-handle-0.1.1
                           rust-linux-raw-sys-0.12.1
                           rust-log-0.4.35
                           rust-memchr-2.8.3
                           rust-memmap2-0.9.12
                           rust-once-cell-1.21.4
                           rust-once-cell-polyfill-1.70.2
                           rust-pin-project-lite-0.2.17
                           rust-pkg-config-0.3.34
                           rust-polling-3.11.0
                           rust-proc-macro2-1.0.107
                           rust-quick-xml-0.41.0
                           rust-quote-1.0.47
                           rust-rangemap-1.8.0
                           rust-read-fonts-0.37.0
                           rust-read-fonts-0.41.0
                           rust-roxmltree-0.20.0
                           rust-rustc-hash-2.1.3
                           rust-rustix-1.1.6
                           rust-self-cell-1.3.0
                           rust-serde-1.0.229
                           rust-serde-core-1.0.229
                           rust-serde-derive-1.0.229
                           rust-serde-json-1.0.154
                           rust-shlex-2.0.1
                           rust-skrifa-0.40.0
                           rust-skrifa-0.44.0
                           rust-slotmap-1.1.1
                           rust-smallvec-1.16.4
                           rust-smithay-client-toolkit-0.21.1
                           rust-smol-str-0.3.7
                           rust-strsim-0.11.1
                           rust-swash-0.2.10
                           rust-syn-3.0.9
                           rust-sys-locale-0.3.2
                           rust-thiserror-2.0.21
                           rust-thiserror-impl-2.0.21
                           rust-tinyvec-1.13.3
                           rust-tracing-0.1.44
                           rust-tracing-core-0.1.36
                           rust-ttf-parser-0.25.1
                           rust-unicode-bidi-0.3.18
                           rust-unicode-ident-1.0.27
                           rust-unicode-linebreak-0.1.5
                           rust-unicode-script-0.5.8
                           rust-unicode-segmentation-1.13.3
                           rust-utf8parse-0.2.2
                           rust-version-check-0.9.5
                           rust-wayland-backend-0.3.17
                           rust-wayland-client-0.31.15
                           rust-wayland-csd-frame-0.3.0
                           rust-wayland-cursor-0.31.14
                           rust-wayland-protocols-0.32.13
                           rust-wayland-protocols-experimental-20251230.0.3
                           rust-wayland-protocols-misc-0.3.12
                           rust-wayland-protocols-wlr-0.3.12
                           rust-wayland-scanner-0.31.11
                           rust-wayland-sys-0.31.11
                           rust-windows-link-0.2.1
                           rust-windows-sys-0.61.2
                           rust-xcursor-0.3.11
                           rust-xkbcommon-0.8.0
                           rust-xkeysym-0.2.1
                           rust-yazi-0.2.2
                           rust-zeno-0.3.3
                           rust-zmij-1.0.23)))
