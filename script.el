(defconst spacemacs-version "@version@" "Spacemacs version.")
(setq user-emacs-directory "./")
(load-file "./core/core-load-paths.el")
(require 'core-spacemacs)
(require 'core-configuration-layer)
(configuration-layer/initialize)
(dotspacemacs|call-func dotspacemacs/layers "Calling dotfile layers...")
(setq dotspacemacs--configuration-layers-saved
      dotspacemacs-configuration-layers)
(when (spacemacs-buffer//choose-banner)
  (spacemacs-buffer//inject-version))
;; declare used layers then packages as soon as possible to resolve
;; usage and ownership
(configuration-layer/discover-layers)
(configuration-layer//declare-used-layers dotspacemacs-configuration-layers)
(configuration-layer//declare-used-packages configuration-layer--used-layers)

(defun printInfo (x)
  (format "%s" x ))

(defun printList (x)
  (if (cdr x) (concat (printInfo (car x)) "\n" (printList (cdr x))) (printInfo (car x))))

(write-region (printList configuration-layer--used-packages) nil "../packages.txt")
