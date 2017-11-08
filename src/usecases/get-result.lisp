(in-package :cl-user)
(defpackage darkmatter/usecases/get-result
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/usecases/base)
  (:import-from :darkmatter/domains/task
                :task-id
                :make-task
                :make-task-result
                :register-task)
  (:export :usecase.get-result.result
           :usecase.get-result.result-context
           :usecase.get-result.result-status
           :usecase.get-result.result-value
           :usecase.get-result))
(in-package :darkmatter/usecases/get-result)

(defstruct usecase.get-result.result
  context
  status
  value
  )

(defun usecase.get-result (task-id)
  )

