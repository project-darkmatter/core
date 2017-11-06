(in-package :cl-user)
(defpackage darkmatter/domains/task
  (:use :cl :darkmatter/utils/maybe)
  (:export :status
           :task-entity
           :make-task
           :make-task-result
           :task-result-status
           :task-result-value
           :task-result-output
           :task-result-optional
           :task-result-context
           :task-reference-id
           :task-repository-ref
           :task-repository-append
           :kill-task
           :task-alive-p
           :join-task
           :register-task
           :retrieve-task
           :try-get-task-result
           :cancel-task
           ))
(in-package :darkmatter/domains/task)

;;; Task bounds types
(deftype task-id () 'integer)

;;; Task
(deftype task-context () 'maybe)
(defstruct %task
  (thread nil)
  (context nil :type task-context))

(defstruct (task-entity (:include %task))
  (id 0 :type task-id))

(let ((task-count 0))
  (defun make-task (fun &optional (context nil))
    (make-task-entity :thread (bt:make-thread fun)
                      :context (maybe context)
                      :id (incf task-count))))

(defun kill-task (task)
  (bt:destroy-thread (task-entity-thread task)))

(defun task-alive-p (task)
  (bt:thread-alive-p (task-entity-thread task)))

(defun join-task (task)
  (bt:join-thread (task-entity-thread task)))

;;; Task Reference
(defstruct task-reference
  (id 0 :type task-id))

(defun task-repository-ref (repo ref)
  (find (task-reference-id ref)
        (%task-repository-entries repo)
        :test (lambda (id entity) (= id (task-entity-id entity)))))

;;; Task Repository
(defstruct %task-repository
  (entries (list) :type list))

(defvar *task-repository* (make-%task-repository))

(defun task-repository-append (repo task)
  (push task (%task-repository-entries repo))
  (make-task-reference :id (task-entity-id task)))

;;; Task Result
(deftype task-result-status () '(member :success :failure))
(deftype task-result-value () 'string)
(deftype task-result-output () 'string)
(deftype task-result-optional () 'maybe)
(defstruct task-result
  (status   nil :type task-result-status)
  (value    nil :type task-result-value)
  (output   "" :type task-result-output)
  (optional (nothing) :type task-result-optional))

(defstruct (task-result-with-context (:include task-result))
  (context nil))
(defun task-result-context (result)
  (task-result-with-context-context result))

;;; User functions
(defun register-task (task)
  (task-repository-append *task-repository* task))
(defun retrieve-task (ref)
  (task-repository-ref *task-repository* ref))

(defun try-get-task-result (task)
  (if (task-alive-p task)
      (nothing)
      (let ((result (join-task task)))
        (if (typep result 'task-result)
            (just
              (make-task-result-with-context
                :status (task-result-status result)
                :value (task-result-value result)
                :output (task-result-output result)
                :optional (task-result-optional result)
                :context (task-entity-context task)))))))

(defun cancel-task (task)
  (kill-task task)
  (just
    (make-task-result-with-context
      :status :failure
      :value ""
      :output ""
      :optional (nothing)
      :context (task-entity-context task))))


