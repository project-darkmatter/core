(in-package :cl-user)
(defpackage darkmatter/adapters/presenters/eval
  (:use :cl
        :darkmatter/usecases/eval)
  (:export :presenter.eval))
(in-package :darkmatter/adapters/presenters/eval)

(defmethod yason:encode ((result usecase.eval.result) &optional (stream *standard-output*))
  (yason:with-output (stream)
    (yason:with-object ()
      (yason:encode-object-element "taskId"
                                   (usecase.eval.result-task-id result)))))

(defun presenter.eval (result)
  (let ((stream (make-string-output-stream)))
    (yason:encode result stream)
    (get-output-stream-string stream)))
