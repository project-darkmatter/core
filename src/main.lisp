(in-package :cl-user)
(defpackage darkmatter
  (:use :cl
        :darkmatter/adapters/controllers)
  (:export :start))
(in-package :darkmatter)

(defvar *server*
  (jsonrpc:make-server))

(defvar +apis+
  (list
    `("darkmatter/eval" . ,#'controller.eval)
    `("darkmatter/getResult" . ,#'controller.get-result)
    `("darkmatter/kill" . ,#'controller.kill)))

(defun %register-apis ()
  (mapcar
    (lambda (api)
      (jsonrpc:expose *server* (car api) (cdr api)))
    +apis+))

(defun start (&key port)
  (%register-apis)
  (when (null port)
    (setf port 50000))
  (jsonrpc:server-listen *server* :port port :mode :websocket))
