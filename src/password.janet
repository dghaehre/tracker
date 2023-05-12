(use judge)
(use ../test/setup)
(import cipher)

(defn secure-password [password]
  (assert (string? password))
  (assert (not (nil? (dyn :encryption-key))))
  (cipher/hash-password (dyn :encryption-key) password))

(defn verify-password [password hashed]
  (cipher/verify-password (dyn :encryption-key) hashed password))


##################
# Tests and stuff
##################

(deftest: with-cipher "password hashing" [_]
  (let [password "secure-password"
        hashed (secure-password password)]
    (test (< 20 (length hashed)) true)
    (test (verify-password password hashed) true)))

(comment
  # encryption-key must be set for anything to work
  (dyn :encryption-key)
  (setdyn :encryption-key (cipher/password-key))
  (secure-password "password"))

