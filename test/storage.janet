(use joy)
(use judge)
(use ../src/storage)
(use ./setup)

(deftest: with-db "test users exists" [_]
  (test (user-exists? "test") false)
  (test (user-exists? "admin") false)
  (create-user "test" "passwoooooord")
  (test (user-exists? "test") true))
