(in-package :cl-user)
(defpackage darkmatter/adapters/controllers/eval
  (:use :cl
        :darkmatter/usecases/eval)
  (:export :controller.eval))
(in-package :darkmatter/adapters/controllers/eval)

(defun controller.eval (args)
  (let ((code (gethash "code" args))
        (render (gethash "render" args))
        (optional (gethash "optional" args))
        (trace (gethash "trace" args)))
    (usecase.eval code :render render :optional optional :trace trace)))
