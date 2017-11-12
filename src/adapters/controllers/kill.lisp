(in-package :cl-user)
(defpackage darkmatter/adapters/controllers/kill
  (:use :cl
        :darkmatter/usecases/kill)
  (:export :controller.kill))
(in-package :darkmatter/adapters/controllers/kill)

(defun controller.kill (args)
  (let ((task-id (gethash "taskId" args)))
    (usecase.kill task-id)))
