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
    (let ((ref1 (register-task task1))
          (ref2 (register-task task2))
          (ref3 (register-task task3)))
      (ok (/= (task-reference-id ref1)
              (task-reference-id ref2)
              (task-reference-id ref3)))
      (diag "Wait for task1 to finish...")
      (sleep 1)
      (let ((result1 (try-get-task-result (retrieve-task ref1))))
        (is-type result1 'just)
        (is (bind result1 #'task-result-status) :success)
        (is (bind result1 #'task-result-value) "hi"))
      (diag "Wait for task2 to finish...")
      (sleep 2)
      (let ((result2 (try-get-task-result (retrieve-task ref2))))
        (is-type result2 'just)
        (is (bind result2 #'task-result-status) :failure)
        (is (bind result2 #'task-result-value) "bye"))
      (diag "Wait for task3 to cancel...")
      (let ((result3 (cancel-task (retrieve-task ref3))))
        (is-type result3 'just)
        (let ((context (task-result-context (unwrap result3))))
          (is-type context 'just)
          (is (gethash :temporary (unwrap context)) 42))))))

(finalize)
