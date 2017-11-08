(in-package :cl-user)
(defpackage darkmatter/test/usecases
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/domains/task
        :darkmatter/usecases/eval
        :darkmatter/usecases/get-result
        :darkmatter/usecases/kill
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
          (is-type task-result 'task-result-with-context)
          (is (task-result-status task-result) :success)
          (is (task-result-value task-result) 10)))))
  (let* ((code "(print (* tmp 10))")
         (result (usecase.eval code :render nil :optional nil))
         (id (usecase.eval.result-task-id result))
         (task (retrieve-task id)))
    (sleep 1)
    (let ((task-result (try-get-task-result task)))
      (is-type task-result 'task-result-with-context)
      (is (task-result-status task-result) :success)
      (is (task-result-value task-result) 100))))

(subtest "Testing getResult usecase"
  (let ((result (usecase.get-result -1)))
    (is-type result 'usecase.get-result.result)
    (is (usecase.get-result.result-status result) nil))
  (let ((task1 (make-task
                 (lambda ()
                   (sleep 1)
                   (make-task-result :value 2 :status :success))))
        (task2 (let ((context (make-hash-table)))
                 (make-task
                   (lambda ()
                     (setf (gethash :temporary context) "i got lost!")
                     (sleep 3)
                     (make-task-result :value "i'm late!" :status :failure))
                   context))))
    (let ((id1 (register-task task1))
          (id2 (register-task task2)))
      (let ((result2-1 (usecase.get-result id2)))
        (is-type result2-1
                 'usecase.get-result.result)
        (is (usecase.get-result.result-status result2-1)
            t)
        (let ((result2-1-content (usecase.get-result.result-content result2-1)))
          (is-type result2-1-content 'just)
          (let ((result2-1-context
                  (bind result2-1-content #'usecase.get-result.result-content-context)))
            (is-type result2-1-context 'just)
            (is (gethash :temporary
                         (unwrap result2-1-context))
                "i got lost!"))))
      (diag "Wait for task1 to finish...")
      (sleep 1)
      (let ((result1 (usecase.get-result id1)))
        (is-type result1
                 'usecase.get-result.result)
        (is (usecase.get-result.result-status result1)
            t)
        (let ((result1-content (usecase.get-result.result-content result1)))
          (is-type result1-content 'just)
          (is (bind result1-content #'usecase.get-result.result-content-value)
              2)))
      (let ((result2-2 (usecase.get-result id2)))
        (is-type result2-2
                 'usecase.get-result.result)
        (is (usecase.get-result.result-status result2-2)
            t)
        (let ((result2-2-content (usecase.get-result.result-content result2-2)))
          (is-type result2-2-content 'just)
          (is (bind result2-2-content #'usecase.get-result.result-content-status)
              :running)))
      (diag "Wait for task2 to finish...")
      (sleep 2)
      (let ((result2-2 (usecase.get-result id2)))
        (is-type result2-2
                 'usecase.get-result.result)
        (is (usecase.get-result.result-status result2-2)
            t)
        (let ((result2-2-context
                (bind (usecase.get-result.result-content result2-2)
                      #'usecase.get-result.result-content-context)))
          (is (gethash :temporary
                       (unwrap result2-2-context))
              "i got lost!"))))))

(subtest "Testing kill usecase"
  (let* ((task (let ((context (make-hash-table)))
                 (make-task
                   (lambda ()
                     (setf (gethash :temporary context) "kill me!")
                     (sleep 1000)
                     (make-task-result :value nil :status :failure))
                   context)))
         (id (register-task task)))
    (sleep 0.1)
    (let ((result (usecase.kill id)))
      (is-type result
               'usecase.kill.result)
      (let ((context (usecase.kill.result-context result)))
        (is-type context 'just)
        (is (gethash :temporary (unwrap context))
            "kill me!")))))

(finalize)
