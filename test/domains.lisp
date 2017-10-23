(in-package :cl-user)
(defpackage darkmatter/test/domains
  (:use :cl
        :darkmatter/domains/task
        :prove))
(in-package darkmatter/test/domains)

(diag "Domain layer tests")

(plan 1)

(subtest "Testing task repository"
  (let* ((initial-length (length (task-repository-empties)))
         (x (push-task 'task-x))
         (y (push-task 'task-y))
         (z (push-task 'task-z))
         (current-length (length (task-repository-empties))))
    (ok (< current-length initial-length))
    (ok (/= (task-ref-id x)
            (task-ref-id y)
            (task-ref-id z)))
    (pop-task (task-ref-id x))
    (pop-task (task-ref-id y))
    (pop-task (task-ref-id z))
    (is initial-length (length (task-repository-empties)))))

(finalize)
