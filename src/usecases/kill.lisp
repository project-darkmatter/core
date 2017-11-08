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
           :usecase.kill.result-context
           :usecase.kill))
(in-package :darkmatter/usecases/kill)


(defstruct usecase.kill.result
  context)

(defun usecase.kill (task-id)
  )
