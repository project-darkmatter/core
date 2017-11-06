(in-package :cl-user)
(defpackage darkmatter/test/usecases
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/domains/task
        :prove))
(in-package darkmatter/test/usecases)


(diag "Usecase layer tests")

(plan 1)

(subtest "Testing eval usecase"
  (let* ((code "(+ 1 2 3)")
         (result (usecase.eval code :render nil :optional nil)))
    (is-type result 'usecase.eval-result)
    (let ((ref ((usecase.eval-result-task-ref result))))
      (is-type ref 'task-reference)
      (let ((task (retrieve-task ref)))
        (is-type task 'task-entity)
        (let ((task-result (try-get-task-result task)))
          (is-type task-result 'just)
          (is (bind task-result #'task-result-status) :success)
          (is (bind task-result #'task-result-value) 6))))))

(finalize)
