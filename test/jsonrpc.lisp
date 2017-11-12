(in-package :cl-user)
(defpackage darkmatter/test/jsonrpc
  (:use :cl
        :prove))
(in-package darkmatter/test/jsonrpc)

(defvar +port+ 50000)
(defvar *client* (jsonrpc:make-client))

(diag "APIs test for JSON-RPC")

(plan 4)

(let ((server (bt:make-thread
                (lambda () (darkmatter:start :port +port+))))
      (task-id nil))

  (subtest "Connect to JSON-RPC server"
    (ok (jsonrpc:client-connect *client*
                                :url (format nil "ws://127.0.0.1:~A" +port+)
                                :mode :websocket)))

  (subtest "Testing darkmatter/eval API"
    (let* ((args (yason:parse
                   "{\"code\":\"(setf (gethash :|foo| %context%) 42)
                                (sleep 1000)\",
                     \"render\":false,
                     \"optional\":null,
                     \"trace\":false}"))
           (result (jsonrpc:call *client* "darkmatter/eval" args)))
      (is-type result 'hash-table)
      (setf task-id (gethash "taskId" result))
      (ok task-id)
      (is-type task-id 'integer)))

  (subtest "Testing darkmatter/getResult API"
    (let* ((args (yason:parse
                   (format nil "{\"taskId\":~A}" task-id)))
           (result (jsonrpc:call *client* "darkmatter/getResult" args)))
      (is-type result 'hash-table)
      (ok (gethash "status" result))
      (let ((content (gethash "content" result)))
        (ok content)
        (ok (gethash "status" content))
        (ok (gethash "output" content))
        (ok (gethash "context" content)))))

  (subtest "Testing darkmatter/kill API"
    (let* ((args (yason:parse
                   (format nil "{\"taskId\":~A}" task-id)))
           (result (jsonrpc:call *client* "darkmatter/kill" args)))
      (is-type result 'hash-table)
      (ok (gethash "status" result))
      (let ((context (gethash "context" result)))
        (ok context)
        (is (gethash "foo" context) 42))))

  (bt:destroy-thread server))

(finalize)
