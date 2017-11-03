(in-package :cl-user)
(defpackage darkmatter/test/utils/maybe
  (:use :cl
        :darkmatter/utils/maybe
        :prove))
(in-package darkmatter/test/utils/maybe)


(diag "Maybe type tests")

(plan 5)

(ok (nothing-p (maybe nil)))
(ok (just-p (maybe "content")))
(is "content" (unwrap (maybe "content")))
(ok (just-p (bind (maybe 12) (lambda (a) (maybe (+ a 3))))))
(ok (nothing-p (bind (maybe nil) (lambda (a) (+ a 3)))))

(finalize)
