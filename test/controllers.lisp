(in-package :cl-user)
(defpackage darkmatter/test/adapters/controllers
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/domains/task
        :darkmatter/usecases/eval
        :darkmatter/usecases/get-result
        :darkmatter/usecases/kill
        ;:darkmatter/adapters/controllers/eval
        ;:darkmatter/adapters/controllers/get-result
        ;:darkmatter/adapters/controllers/kill
        :prove))
(in-package darkmatter/test/adapters/controllers)


(diag "Controller in Adapter layer tests")

(plan 3)

(let ((id1 nil))

  (subtest "Testing eval controller"
    (let ((args (make-hash-table :test #'equal)))
      (setf (gethash "code" args)
            "(setf %context% 0)
             (dotimes (i 1000)
               (sleep 0.1)
               (incf %context%))"
            (gethash "render" args)
            nil
            (gethash "optional" args)
            nil
            (gethash "trace" args)
            nil)
      (let ((result (controller.eval args)))
        (is-type result 'usecase.eval.result)
        (setf id1 (usecase.eval.result-task-id result)))))

  (subtest "Testing getResult controller"
    (let ((args (make-hash-table :test #'equal)))
      (setf (gethash "taskId" args)
            id1)
      (let ((result (controller.get-result args)))
        (is-type result 'usecase.get-result.result)
        (is (usecase.get-result.result-status result)
            t)
        (let ((content-maybe (usecase.get-result.result-content result)))
          (is-type content-maybe 'just)
          (let ((content (unwrap content-maybe)))
            (is-type content 'usecase.get-result.result-content)
            (is (usecase.get-result.result-status content) :running)
            (is-type (usecase.get-result.result-content-context content) 'just))))))

  (subtest "Testing kill controller"
    (let ((args (make-hash-table :test #'equal)))
      (setf (gethash "taskId" args)
            id1)
      (let ((result (controller.kill args)))
        (is-type result 'usecase.kill.result)
        (is (usecase.kill.result-status result)
            t)
        (let ((context-maybe (usecase.kill.result-context result)))
          (is-type context-maybe 'just)
          (ok (bind context-maybe #'numberp)))))))

(finalize)
