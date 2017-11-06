(in-package :cl-user)
(defpackage darkmatter/test/usecases
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/domains/task
        :prove))
(in-package darkmatter/test/usecases)


(diag "Usecase layer tests")

(plan 2)

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

(subtest "Testing getResult usecase"
  (let ((task1 (make-task
                 (lambda ()
                   (sleep 1)
                   (make-task-result :value 2 :status :success))))
        (task2 (let ((context (make-hash-table)))
                 (make-task
                   (lambda ()
                     (setf (gethash :temporary context) "i got lost!")
                     (sleep 3)
                     (make-task-result :value "i'm late!" :status :failure))))))
    (let ((ref1 (register-task task1))
          (ref2 (register-task task2)))
      (let ((result2-1 (usecase.get-result (task-reference-id task2))))
        (is-type result2-1
                 'usecase.get-result-result)
        (is (usecase.get-result-result-status result2-1)
            :running)
        (is (gethash :temporary (usecase.get-result-result-context result2-1))
            "i got lost!"))
      (diag "Wait for task1 to finish...")
      (sleep 1)
      (let ((result1 (usecase.get-result (task-reference-id task1))))
        (is-type result1
                 'usecase.get-result-result)
        (is (usecase.get-result-result-status result1)
            :success)
        (is (usecase.get-result-result-value result1)
            2))
      (diag "Wait for task2 to finish...")
      (sleep 2)
      (let ((result2-2 (usecase.get-result (task-reference-id task2))))
        (is-type result2-2
                 'usecase.get-result-result)
        (is (usecase.get-result-result-status result-2-2)
            :failure)
        (is (gethash :temporary (usecase.get-result-result-context result2-2))
            "i got lost!")))))

(finalize)
