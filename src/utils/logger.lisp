(in-package :cl-user)
(defpackage darkmatter/utils/logger
  (:nicknames :logger)
  (:use :cl)
  (:export :*log-output*
           :normal
           :alert))
(in-package :darkmatter/utils/logger)

(defvar *log-output* nil)

(defmacro normal (stream formatter &rest rest)
  `(multiple-value-bind
       (second minute hour date month year day-of-week dst-p tz)
       (get-decoded-time)
       (declare (ignore date month year day-of-week dst-p tz))
     (let ((*print-pretty* nil))
       (if (typep ,stream 'file-stream)
           (format ,stream (format nil "[~2,'0d:~2,'0d:~2,0d]~A ~A~%"
                                   hour minute second ""
                                   (format nil ,formatter ,@rest)))
           (format ,stream (format nil "~C[32;1m[~2,'0d:~2,'0d:~2,'0d]~C[0m~A ~A~%"
                                   ,(code-char #o33) hour minute second ,(code-char #o33)
                                   ""
                                   (format nil ,formatter ,@rest))))
       (force-output))))

(defmacro alert (stream formatter &rest rest)
  `(multiple-value-bind
       (second minute hour date month year day-of-week dst-p tz)
       (get-decoded-time)
       (declare (ignore date month year day-of-week dst-p tz))
     (let ((*print-pretty* nil))
       (if (typep ,stream 'file-stream)
           (format ,stream (format nil "[~2,'0d:~2,'0d:~2,0d]~A ~A~%"
                                   hour minute second ""
                                   (format nil ,formatter ,@rest)))
           (format ,stream (format nil "~C[31;1m[~2,'0d:~2,'0d:~2,'0d]~C[0m~A ~A~%"
                                   ,(code-char #o33) hour minute second ,(code-char #o33)
                                   ""
                                   (format nil ,formatter ,@rest))))
       (force-output))))
