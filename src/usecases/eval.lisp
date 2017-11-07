(in-package :cl-user)
(defpackage darkmatter/usecases/eval
  (:use :cl
        :darkmatter/utils/maybe)
  (:import-from :darkmatter/domains/task
                :task-id
                :make-task
                :make-task-result
                :register-task)
  (:export :usecase.eval.result
           :usecase.eval))
(in-package :darkmatter/usecases/eval)

(defstruct usecase.eval.result
  task-id)

(defun usecase.eval (code &key render optional)
  )
