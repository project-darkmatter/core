(in-package :cl-user)
(defpackage darkmatter/test/domains
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/domains/task
        :prove))
(in-package darkmatter/test/domains)


(diag "Domain layer tests")

(plan 1)

(subtest "Testing task repository"
  (let ((task1 (make-task
                 (sleep 1)
                 (make-task-result :value "hi" :status :success)))
        (task2 (make-task
                 (sleep 3)
                 (make-task-result :value "bye" :status :failure)))
        (task3 (make-task
                 (sleep 1000)
                 (make-task-result :value "wasted" :status :failure))))
    (let ((ref1 (push-task task1))
          (ref2 (push-task task2))
          (ref3 (push-task task3)))
      (ok (/= (task-ref-id ref1)
              (task-ref-id ref2)
              (task-ref-id ref3)))
      (diag "Wait for task1 to finish...")
      (sleep 1)
      (let ((result1 (try-get-result ref1)))
        (is-type result1 'just)
        (is (task-result-status (unwrap result1)) :success))
      (diag "Wait for task2 to finish...")
      (sleep 2)
      (let ((result2 (try-get-result ref2)))
        (is-type result2 'just)
        (is (task-result-status (unwrap result2)) :failure))
      (diag "Wait for task3 to cancel...")
      (let ((result3 (cancel-or-result ref3)))
        (is-type result3 'nothing)))))

(finalize)
