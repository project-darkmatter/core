(in-package :cl-user)
(defpackage darkmatter/adapters/controllers
  (:use :cl)
  (:import-from :darkmatter/adapters/controllers/eval
                :controller.eval)
  (:import-from :darkmatter/adapters/controllers/get-result
                :controller.get-result)
  (:import-from :darkmatter/adapters/controllers/kill
                :controller.kill)
  (:export :controller.eval
           :controller.get-result
           :controller.kill))
