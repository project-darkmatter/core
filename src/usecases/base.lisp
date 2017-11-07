(in-package :cl-user)
(defpackage darkmatter/usecases/base
  (:use :cl
        :darkmatter/utils/maybe)
  (:export :*using-package*
           :%initialize-package))
(in-package :darkmatter/usecases/base)

(defvar *pkgcnt* 0)
(defvar *using-package* nil)
(defvar *default-package-definition*
  (list :use '(:cl)))

(let ((pkgcnt 0))
  (defun %initialize-package ()
    (make-package (format nil "DARKMATTER.LOCAL.~A" (incf pkgcnt))
                  :use (getf *default-package-definition* :use))))
