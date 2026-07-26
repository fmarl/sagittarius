(define-module (sagittarius services vpn)
  #:use-module (guix gexp)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services shepherd)
  #:use-module (sagittarius packages vpn)
  #:export (mullvad-service-type))

(define mullvad-service
  (shepherd-service
   (provision '(mullvad))
   (documentation "Mullvad VPN daemon")
   (start #~(make-forkexec-constructor
	     (list #$(file-append mullvad-vpn-desktop "/bin/mullvad-daemon"))))
   (stop #~(make-kill-destructor))))

(define mullvad-service-type
  (service-type
   (name 'mullvad)
   (description "Mullvad VPN daemon")
   (extensions
    (list (service-extension shepherd-root-service-type
			     (const
			      (list mullvad-service)))))
   (default-value '()))) ;; TODO: Enable configuration of mullvad package
