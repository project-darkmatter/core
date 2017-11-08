(in-package :cl-user)
(defpackage darkmatter/usecases/kill
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/usecases/base)
  (:import-from :darkmatter/domains/task
                :retrieve-task
                :task-result-context
                :cancel-task)
  (:export :usecase.kill.result
           :usecase.kill.result-status
           :usecase.kill.result-context
           :usecase.kill))
(in-package :darkmatter/usecases/kill)


(deftype usecase.kill.result-status () 'boolean)
(deftype usecase.kill.result-context () 'maybe)
(defstruct usecase.kill.result
  (status nil :type usecase.kill.result-status)
  (context nil :type usecase.kill.result-context))

(defun usecase.kill (task-id)
  (let ((task (retrieve-task task-id)))
    (if task
        (make-usecase.kill.result
          :status t
          :context (task-result-context
                     (cancel-task task)))
        (make-usecase.kill.result
          :status nil
          :context (nothing)))))
