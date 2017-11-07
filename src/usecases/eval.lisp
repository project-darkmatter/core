(in-package :cl-user)
(defpackage darkmatter/usecases/eval
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/usecases/base)
  (:import-from :darkmatter/domains/task
                :task-id
                :make-task
                :make-task-result
                :register-task)
  (:export :usecase.eval.result
           :usecase.eval.result-task-id
           :usecase.eval))
(in-package :darkmatter/usecases/eval)

(defstruct usecase.eval.result
  (task-id nil :type task-id))

(defmacro lambda-with-context (sexp)
  `(lambda (%context%)
     (declare (ignorable %context%))
     ,sexp))

(defun wrap-context (content)
  (let ((form (macroexpand `(lambda-with-context ,content)))
        (context (make-hash-table)))
    (values form context)))

(defun usecase.eval (code &key render optional trace)
  "Evaluate the code, using optional for plugged functions, and render the result.
   Result (:task-id task-id)"
  (let* ((*package* (or *using-package*
                        (%initialize-package)))
         )

    (let ((source '(progn)))
      (handler-case
        (loop with code-position = 0 while code-position
              with sexp do
              (multiple-value-setq (sexp code-position)
                (read-from-string code :eof-error-p t :start code-position))
              always sexp do
              (push sexp source))
        (end-of-file (c)
          (format t "~A~%" c)))
      (setf source (reverse source))

      (make-usecase.eval.result
        :task-id
        (register-task
          (multiple-value-bind (form context)
            (wrap-context source)
            (make-task
              (lambda ()
                (let* ((standard-output *standard-output*)
                       (*standard-output* (make-string-output-stream))
                       (*error-output* (make-string-output-stream))
                       (*trace-output* (make-string-output-stream)))
                (unwind-protect
                  (let ((return-value nil)
                        (errorp nil))
                    (handler-case
                      (progn
                        (setf return-value (funcall (eval form) context))
                        (make-task-result
                          :status :success
                          :value return-value
                          :output (format nil "~A~A~A"
                                          (get-output-stream-string *standard-output*)
                                          (get-output-stream-string *error-output*)
                                          (get-output-stream-string *trace-output*))))
                      (error (c)
                        (setf errorp t)
                        (format t "~A~%" c)
                        (make-task-result
                          :status :failure
                          :output (format nil "~A~A~A"
                                          (get-output-stream-string *standard-output*)
                                          (get-output-stream-string *error-output*)
                                          (get-output-stream-string *trace-output*))))))
                  (setf *using-package* *package*
                        *package* (find-package :darkmatter/usecases/eval)))))
              (maybe context))))))))
