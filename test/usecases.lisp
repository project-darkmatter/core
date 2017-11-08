(in-package :cl-user)
(defpackage darkmatter/test/usecases
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/domains/task
        :darkmatter/usecases/eval
        :darkmatter/usecases/get-result
        ;:darkmatter/usecases/kill
        :prove))
(in-package darkmatter/test/usecases)


(diag "Usecase layer tests")

(plan 3)

(subtest "Testing eval usecase"
  (let* ((code "(defvar tmp 10)")
         (result (usecase.eval code :render nil :optional nil)))
    (is-type result 'usecase.eval.result)
    (let ((id (usecase.eval.result-task-id result)))
      (is-type id 'task-id)
      (let ((task (retrieve-task id)))
        (is-type task 'task-entity)
        (sleep 1)
        (let ((task-result (try-get-task-result task)))
          (is-type task-result 'just)
          (is (bind task-result #'task-result-status) :success)
          (is (bind task-result #'task-result-value) 10)))))
  (let* ((code "(print (* tmp 10))")
         (result (usecase.eval code :render nil :optional nil))
         (id (usecase.eval.result-task-id result))
         (task (retrieve-task id)))
    (sleep 1)
    (let ((task-result (try-get-task-result task)))
      (is-type task-result 'just)
      (is (bind task-result #'task-result-status) :success)
      (is (bind task-result #'task-result-value) 100))))

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
    (let ((id1 (register-task task1))
          (id2 (register-task task2)))
      (let ((result2-1 (usecase.get-result id2)))
        (is-type result2-1
                 'usecase.get-result.result)
        (is (usecase.get-result.result-status result2-1)
            :running)
        (is (gethash :temporary (usecase.get-result.result-context result2-1))
            "i got lost!"))
      (diag "Wait for task1 to finish...")
      (sleep 1)
      (let ((result1 (usecase.get-result id1)))
        (is-type result1
                 'usecase.get-result.result)
        (is (usecase.get-result.result-status result1)
            :success)
        (is (usecase.get-result.result-value result1)
            2))
      (diag "Wait for task2 to finish...")
      (sleep 2)
      (let ((result2-2 (usecase.get-result id2)))
        (is-type result2-2
                 'usecase.get-result.result)
        (is (usecase.get-result.result-status result2-2)
            :failure)
        (is (gethash :temporary (usecase.get-result.result-context result2-2))
            "i got lost!")))))

(subtest "Testing kill usecase"
  (let* ((task (let ((context (make-hash-table)))
                 (make-task
                   (lambda ()
                     (setf (gethash :temporary context) "kill me!")
                     (sleep 1000)
                     (make-task-result :value nil :status :failure)))))
         (id (register-task task)))
    (sleep 0.1)
    (let ((result (usecase.kill id)))
      (is-type result
               'usecase.kill.result)
      (is (gethash :temporary (usecase.kill.result-context result))
          "kill me!"))))

(finalize)
