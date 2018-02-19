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

(defun %encode-to-string (value)
  (let ((stream (make-string-output-stream))
        (errorp nil))
    (handler-case
      (yason:encode value stream)
      (simple-error (c) (setf errorp t)))
    (if errorp
        (write-to-string value)
        (get-output-stream-string stream))))

(defun %read-from-string-with-context (str)
  (read-from-string
    (format nil "(lambda (%context%) (declare (ignorable %context%)) ~A)" str)))

(defun usecase.eval (code &key render optional trace)
  "Evaluate the code, using optional for plugged functions, and render the result.
   Result (:task-id task-id)"
  ;(logger:normal logger:*log-output* "USECASE.EVAL \"~A\"" code)
  ;(force-output logger:*log-output*)

  (let ((*package* (or *using-package*
                       (%initialize-package)))
        (source nil)
        (error-value nil)
        (parse-error-p nil))

    ;(logger:normal logger:*log-output* "IN-PACKAGE ~A" *package*)

    (handler-case
      (setf source (%read-from-string-with-context code))
      (error (c)
        (setf error-value c
              parse-error-p t)))

    (if parse-error-p
        (progn
          ;(logger:alert logger:*log-output* "Parse error")
          (format logger:*log-output* "Parse error~%")
          (force-output logger:*log-output*)
          (make-usecase.eval.result
            :task-id
            (register-task
              (let ((context (make-hash-table)))
                (make-task
                  (lambda ()
                    (make-task-result
                      :status :failure
                      :output (format nil "~A~%" error-value))))))))
        (progn
          ;(logger:normal logger:*log-output* "Parsing successful ~A" source)
          (format logger:*log-output* "Pargsing successful ~A" source)
          (force-output logger:*log-output*)
          (prog1
            (make-usecase.eval.result
              :task-id
              (register-task
                (let ((context (make-hash-table)))
                  (make-task
                    (lambda ()
                      (let* ((standard-output *standard-output*)
                             (*standard-output* (make-string-output-stream))
                             (*error-output* (make-string-output-stream))
                             (*trace-output* (make-string-output-stream)))
                        (let ((return-value nil)
                              (errorp nil))
                          (handler-case
                            (progn
                              (setf return-value (funcall (eval source) context))
                              (make-task-result
                                :status :success
                                :value (%encode-to-string
                                         (if (symbolp return-value)
                                             (symbol-value return-value)
                                             return-value))
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
                                                (get-output-stream-string *trace-output*))))))))
                    context))))
            (setf *using-package* *package*
                  *package* (find-package :darkmatter/usecases/eval)))))))
