(in-package :cl-user)
(defpackage darkmatter/usecases/get-result
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/usecases/base)
  (:import-from :darkmatter/domains/task
                :retrieve-task
                :task-result
                :task-result-context
                :task-result-status
                :task-result-value
                :task-result-output
                :try-get-task-result)
  (:export :usecase.get-result.result
           :usecase.get-result.result-status
           :usecase.get-result.result-content
           :usecase.get-result.result-content-context
           :usecase.get-result.result-content-status
           :usecase.get-result.result-content-value
           :usecase.get-result.result-content-output
           :usecase.get-result))
(in-package :darkmatter/usecases/get-result)

(deftype content-context () 'maybe)
(deftype content-status () '(member :success :failure :running))
(deftype content-string () 'string)
(defstruct usecase.get-result.result-content
  (context nil :type content-context)
  (status nil :type content-status)
  (value nil)
  (output "" :type content-string))

(deftype usecase.get-result.result-status () 'boolean)
(deftype usecase.get-result.%result-content () 'maybe)
(defstruct usecase.get-result.result
  (status nil :type usecase.get-result.result-status)
  (content nil :type usecase.get-result.%result-content))

(defun usecase.get-result (task-id)
  ;(logger:normal logger:*log-output* "Requested task:~A" task-id)
  (format logger:*log-output* "Requested task:~A~%" task-id)
  (force-output logger:*log-output*)
  (let ((task (retrieve-task task-id)))
    (if task
        (let ((task-result (try-get-task-result task)))
          (make-usecase.get-result.result
            :status t
            :content (just
                       (make-usecase.get-result.result-content
                         :context (task-result-context task-result)
                         :status (task-result-status task-result)
                         :value (task-result-value task-result)
                         :output (task-result-output task-result)))))
        (make-usecase.get-result.result
          :status nil
          :content (nothing)))))

