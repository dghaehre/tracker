(use judge)

# TODO: use bcrypt
(defn secure-password [password]
  (hash password))

(defn verify-password [password hashed]
  (= hashed (secure-password password)))

(test (verify-password "password" (secure-password "password")) true)
(test (verify-password "sdfsdfsdf" (secure-password "password")) false)
