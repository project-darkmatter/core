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
                 (lambda ()
                   (sleep 1)
                   (make-task-result :value "hi" :status :success))))
        (task2 (make-task
                 (lambda ()
                   (sleep 3)
                   (make-task-result :value "bye" :status :failure))))
        (task3 (let ((context (make-hash-table)))
                 (make-task
                   (lambda ()
                     (setf (gethash :temporary context) 42)
                     (sleep 1000)
                     (make-task-result :value "wasted" :status :failure))
                   context))))
    (let ((id1 (register-task task1))
          (id2 (register-task task2))
          (id3 (register-task task3)))
      (ok (/= id1 id2 id3))
      (diag "Wait for task1 to finish...")
      (sleep 1)
      (let ((result1 (try-get-task-result (retrieve-task id1))))
        (is-type result1 'task-result-with-context)
        (is (task-result-status result1) :success)
        (is (task-result-value result1) "hi"))
      (diag "Wait for task2 to finish...")
      (sleep 2)
      (let ((result2 (try-get-task-result (retrieve-task id2))))
        (is-type result2 'task-result-with-context)
        (is (task-result-status result2) :failure)
        (is (task-result-value result2) "bye"))
      (diag "Wait for task3 to cancel...")
      (let ((result3 (cancel-task (retrieve-task id3))))
        (is-type result3 'task-result-with-context)
        (let ((context (task-result-context result3)))
          (is-type context 'just)
          (is (gethash :temporary (unwrap context)) 42))))))

(finalize)
