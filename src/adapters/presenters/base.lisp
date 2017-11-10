(in-package :cl-user)
(defpackage darkmatter/adapters/presenters/base
  (:use :cl
        :darkmatter/utils/maybe))
(in-package :darkmatter/adapters/presenters/base)

(defmethod yason:encode ((symbol symbol) &optional (stream *standard-output*))
  (yason:encode (symbol-name symbol) stream))

