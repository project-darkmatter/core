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

(defun start (&key (port 50000) (mode :tcp) log)
  (%register-apis)
  (let ((logfile-p nil))
    (block nil
      (unwind-protect
        (progn
          (if log
              (if (probe-file log)
                  (progn
                    (logger:alert t "Log file ~A already exists!" (truename log))
                    (return))
                  (progn
                    (setf logger:*log-output* (open log :direction :output)
                          logfile-p t)
                    (logger:normal t "Start Darkmatter with logging: ~A." (truename log))
                    (logger:normal t "Listening on localhost:~A." port)))
              (setf logger:*log-output* *standard-output*))
          (tagbody
            start
              (handler-case
                (progn
                  (format logger:*log-output* "#~A~%" port)
                  (force-output logger:*log-output*)
                  (jsonrpc:server-listen *server* :port port :mode mode :silent t))
                ((or usocket:address-in-use-error error) (c)
                  (incf port)
                  (if (< 65535 port)
                      (progn
                        (logger:alert t "Connection failed, exit.")
                        (format logger:*log-output* "#EXIT~%")
                        (force-output logger:*log-output*)
                        (go finish))
                      (progn
                        (logger:alert t "Connection failed, retry as port ~A" port)
                        (format logger:*log-output* "#FAILURE~%")
                        (force-output logger:*log-output*)
                        (go start)))))
            finish))
        (if logfile-p (close logger:*log-output*))))))
