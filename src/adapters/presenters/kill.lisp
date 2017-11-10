(in-package :cl-user)
(defpackage darkmatter/adapters/presenters/kill
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/usecases/kill)
  (:export :presenter.kill))
(in-package :darkmatter/adapters/presenters/kill)


(defmethod yason:encode ((result usecase.kill.result) &optional (stream *standard-output*))
  (yason:with-output (stream)
    (yason:with-object ()
      (yason:encode-object-element "status"
                                   (if (usecase.kill.result-status result)
                                       'yason:true 'yason:false))
      (yason:encode-object-element "context"
                                   (let ((result-context
                                           (usecase.kill.result-context result)))
                                     (unwrap result-context))))))

(defun presenter.kill (result)
  (let ((stream (make-string-output-stream)))
    (yason:encode result stream)
    (get-output-stream-string stream)))
