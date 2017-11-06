#|
  This file is a part of Project Darkmatter.
  Copyright (c) 2017 Eddie
|#

(in-package :cl-user)
(defpackage darkmatter-core-test-asd
  (:use :cl :asdf))
(in-package :darkmatter-core-test-asd)

(defsystem darkmatter-core-test
  :author "Eddie"
  :license ""
  :depends-on (:darkmatter-core
               :prove)
  :components ((:module "test"
                :components
                ((:module "utils"
                          :components
                          ((:test-file "maybe")))
                 (:test-file "domains")
                 (:test-file "usecases"))))
  :description "Test system for darkmatter"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
