(in-package :cl-user)
(defpackage darkmatter/utils/maybe
  (:use :cl)
  (:export :maybe
           :maybe-p
           :just
           :just-p
           :nothing
           :nothing-p
           :unwrap
           :bind))
(in-package :darkmatter/utils/maybe)

(defstruct maybe)

(defstruct (just (:constructor just (content))
                 (:include maybe))
  (content nil :read-only t))

(defstruct (nothing (:constructor nothing)
                    (:include maybe)))

(defun unwrap (a)
  (declare (type maybe a))
  (typecase a
    (just (just-content a))
    (nothing nil)))

(defun bind (a fun)
  (declare (type maybe a))
  (typecase a
    (just (funcall fun (just-content a)))
    (nothing (nothing))))
