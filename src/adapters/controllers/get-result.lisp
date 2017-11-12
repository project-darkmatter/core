(in-package :cl-user)
(defpackage darkmatter/adapters/controllers/get-result
  (:use :cl
        :darkmatter/usecases/get-result)
  (:export :controller.get-result))
(in-package :darkmatter/adapters/controllers/get-result)

(defun controller.get-result (args)
  (let ((task-id (gethash "taskId" args)))
    (usecase.get-result task-id)))
