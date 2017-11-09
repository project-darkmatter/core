(in-package :cl-user)
(defpackage darkmatter/test/adapters
  (:use :cl
        :darkmatter/utils/maybe
        :darkmatter/domains/task
        :darkmatter/usecases/eval
        :darkmatter/usecases/get-result
        :darkmatter/usecases/kill
        ;:darkmatter/adapters/presenters/eval
        ;:darkmatter/adapters/presenters/get-result
        ;:darkmatter/adapters/presenters/kill
        :prove))
(in-package darkmatter/test/adapters)


(diag "Adapter layer tests")

(plan 3)

(let ((id1 nil)
      (id2 nil)
      (id3 nil)
      (id4 nil))

  (subtest "Testing eval presenter"
    (let* ((code1 "nil")
           (code2 "(princ 42)")
           (code3 "(setf (gethash :temporary %context%))(sleep 1000)")
           (code4 "(error \"ERROR\")")
           (result1 (usecase.eval code1))
           (result2 (usecase.eval code2))
           (result3 (usecase.eval code3))
           (result4 (usecase.eval code4)))
      (setf id1 (usecase.eval.result-task-id result1)
            id2 (usecase.eval.result-task-id result2)
            id3 (usecase.eval.result-task-id result3)
            id4 (usecase.eval.result-task-id result4))
      (flet ((result-format (id)
               (format nil "{\"taskId\":~A}" id)))
        (is (presenter.eval result1)
            (result-format id1))
        (is (presenter.eval result2)
            (result-format id2))
        (is (presenter.eval result3)
            (result-format id3))
        (is (presenter.eval result4)
            (result-format id4)))))

  (subtest "Testing getResult presenter"
    (let ((result1 (usecase.get-result id1))
          (result2 (usecase.get-result id2))
          (result3 (usecase.get-result id3))
          (result4 (usecase.get-result id4))
          (result5 (usecase.get-result -1)))
      (is (presenter.get-result result1)
          "{\"status\":true,\"content\":{\"status\":\"SUCCESS\",\"value\":null,\"output\":\"\",\"context\":null}}")
      (is (presenter.get-result result2)
          "{\"status\":true,\"content\":{\"status\":\"SUCCESS\",\"value\":42,\"output\":\"42\",\"context\":null}}")
      (is (presenter.get-result result3)
          "{\"status\":true,\"content\":{\"status\":\"RUNNING\",\"value\":null,\"output\":\"\",\"context\":{\"temporary\":\"darkmatter\"}}}")
      (is (presenter.get-result result4)
          "{\"status\":true,\"content\":{\"status\":\"FAILURE\",\"value\":null,\"output\":\"\",\"context\":null}}")
      (is (presenter.get-result result5)
          "{\"status\":false,\"content\":null}")))

  (subtest "Testing kill presenter"
    (let ((result1 (usecase.kill id1))
          (result2 (usecase.kill id2))
          (result3 (usecase.kill id3))
          (result4 (usecase.kill id4))
          (result5 (usecase.kill -1)))
      (is (presenter.kill result1)
          "{\"status\":true,\"context\":null}")
      (is (presenter.kill result2)
          "{\"status\":true,\"context\":null}")
      (is (presenter.kill result3)
          "{\"status\":true,\"context\":{\"temporary\":\"darkmatter\"}")
      (is (presenter.kill result4)
          "{\"status\":true,\"context\":null}")
      (is (presenter.kill result5)
          "{\"status\":false,\"context\":null}"))))

(finalize)
