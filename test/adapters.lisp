(in-package :cl-user)
(defpackage darkmatter/test/adapters
  (:use :cl
        :darkmatter/utils/maybe
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

(subtest "Testing eval presenter"
  (let* ((code1 "nil")
         (code2 "(print 42)")
         (code3 "(setf (gethash :temporary %context%) \"darkmatter\")(sleep 10000)")
         (code4 "(error \"ERROR\")")
         (result1 (usecase.eval code1))
         (result2 (usecase.eval code2))
         (result3 (usecase.eval code3))
         (result4 (usecase.eval code4)))
    (is (presenter.eval result1)
        "{\"taskId\":1}")
    (is (presenter.eval result2)
        "{\"taskId\":2}")
    (is (presenter.eval result3)
        "{\"taskId\":3}")
    (is (presenter.eval result4)
        "{\"taskId\":4}")))

(subtest "Testing getResult presenter"
  (let ((result1 (usecase.get-result 1))
        (result2 (usecase.get-result 2))
        (result3 (usecase.get-result 3))
        (result4 (usecase.get-result 4))
        (result5 (usecase.get-result 5)))
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
  (let ((result1 (usecase.kill 1))
        (result2 (usecase.kill 2))
        (result3 (usecase.kill 3))
        (result4 (usecase.kill 4))
        (result5 (usecase.kill 5)))
    (is (presenter.kill result1)
        "{\"status\":true,\"context\":null}")
    (is (presenter.kill result2)
        "{\"status\":true,\"context\":null}")
    (is (presenter.kill result3)
        "{\"status\":true,\"context\":{\"temporary\":\"darkmatter\"}")
    (is (presenter.kill result4)
        "{\"status\":true,\"context\":null}")
    (is (presenter.kill result5)
        "{\"status\":false,\"context\":null}")))

(finalize)
