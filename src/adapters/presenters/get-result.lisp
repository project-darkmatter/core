(in-package :cl-user)
(defpackage darkmatter/adapters/presenters/get-result
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/usecases/get-result)
  (:export :presenter.get-result))
(in-package :darkmatter/adapters/presenters/get-result)


(defmethod yason:encode ((content usecase.get-result.result-content) &optional (stream *standard-output*))
  (yason:with-output (stream)
    (yason:with-object ()
      (yason:encode-object-element "status"
        (symbol-name (usecase.get-result.result-content-status content)))
      (yason:encode-object-element "value"
        (usecase.get-result.result-content-value content))
      (yason:encode-object-element "output"
        (usecase.get-result.result-content-output content))
      (yason:encode-object-element "context"
        (let ((context (usecase.get-result.result-content-context content)))
          (unwrap context))))))

(defmethod yason:encode ((result usecase.get-result.result) &optional (stream *standard-output*))
  (yason:with-output (stream)
    (yason:with-object ()
      (yason:encode-object-element "status"
                                   (if (usecase.get-result.result-status result)
                                       'yason:true 'yason:false))
      (yason:encode-object-element "content"
                                   (let ((result-content
                                           (usecase.get-result.result-content result)))
                                     (unwrap result-content))))))

(defun presenter.get-result (result)
  (let ((stream (make-string-output-stream)))
    (yason:encode result stream)
    (get-output-stream-string stream)))
