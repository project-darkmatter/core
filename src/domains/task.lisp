(in-package :cl-user)
(defpackage darkmatter/domains/task
  (:use :cl)
  (:import-from :lparallel
                :delay)
  (:export :status
           :task
           :make-task
           :make-task-result
           :task-result-status
           :task-result-value
           :task-result-output
           :task-result-optional
           :task-ref
           :task-ref-id
           :push-task
           :pop-task
           :task-repository-empties))
(in-package :darkmatter/domains/task)

(defmacro make-task (&body body)
  `(delay ,@body))

(deftype status () '(member :success :failure))
(defstruct task-result
  (status   nil :type status)
  (value    nil :type string)
  (output   nil :type string)
  (optional nil :type hash-table))


(defstruct task-ref
  (id nil :type integer))


(let ((+default-size+ 32))
  (defstruct %task-repository
    (entries (make-array +default-size+ :adjustable t)
             :type array)

    (empties (loop for i from 0 below +default-size+ collect i)
             :type list)))

(defvar *task-repository* (make-%task-repository))

(defun push-task (future)
  (make-task-ref
    :id (if (null (%task-repository-empties *task-repository*))
            (let ((pushing-id (length (%task-repository-entries *task-repository*))))
              (vector-push-extend future (%task-repository-entries *task-repository*))
              pushing-id)
            (let ((setting-id (pop (%task-repository-empties *task-repository*))))
              (setf (aref (%task-repository-entries *task-repository*) setting-id) future)
              setting-id))))

(defun pop-task (popping-id)
  (push popping-id (%task-repository-empties *task-repository*))
  (aref (%task-repository-entries *task-repository*) popping-id))

(defun task-repository-empties ()
  (%task-repository-empties *task-repository*))

