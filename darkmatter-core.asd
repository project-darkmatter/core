#|
  This file is a part of Project Darkmatter.
  Copyright (c) 2017 Eddie (tamamu.1r1s@gmail.com)
|#

#|
  Author: Eddie (tamamu.1r1s@gmail.com)
|#

(in-package :cl-user)
(defpackage darkmatter-core-asd
  (:use :cl :asdf))
(in-package :darkmatter-core-asd)

(defsystem darkmatter-core
  :version "1.0.0"
  :author "Eddie"
  :license ""
  :depends-on (:bordeaux-threads ;MIT
               :jsonrpc          ;BSD-2-Clause
               :yason            ;BSD-2-Clause
               :cl-fad           ;BSD-2-Clause
               )
  :components ((:module "src"
                :components
                (;(:file "main" :depends-on ("config"
                 ;                           "controllers"
                 ;                           "usecases"
                 ;                           "domains"))
                 ;(:file "config")
                 ;(:module "controllers"
                 ;         :components ((:file "base")
                 ;                      (:file "eval" :depends-on ("base"))
                 ;                      (:file "get-result" :depends-on ("base"))
                 ;                      (:file "initialize" :depends-on ("base"))
                 ;                      (:file "initialize-package" :depends-on ("base"))
                 ;                      (:file "save" :depends-on ("base")))
                 ;         :depends-on ("usecases"
                 ;                      "domains"))
                 (:module "usecases"
                          :components ((:file "base")
                                       (:file "eval" :depends-on ("base"))
                                       (:file "get-result" :depends-on ("base"))
                                       (:file "kill" :depends-on ("base"))
                 ;                      (:file "initialize" :depends-on ("base"))
                 ;                      (:file "initialize-package" :depends-on ("base"))
                 ;                      (:file "save" :depends-on ("base"))
                 )
                          :depends-on ("domains"))
                 (:module "domains"
                          :components ((:file "task"))
                          :depends-on ("utils"))
                 (:module "utils"
                          :components ((:file "maybe"))))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op darkmatter-core-test))))
