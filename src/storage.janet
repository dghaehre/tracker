(use joy)
(use judge)
(use ../test/setup)
(use ./password)

(defn user-exists? [username]
  (let [rows (db/query `select id from user where upper(username) = upper(:name)` {:name username})]
    (not (nil? (get rows 0)))))

(defn create-user [username password]
  (assert (string? username))
  (assert (string? password))
  (let [hashed (secure-password password)]
    (if (user-exists? username)
      (error "user already exists")
      (db/insert :user {:username username :password hashed}))))

(deftest: with-db "create user" [_]
  (let [password "admin"
        user (create-user "another-test" "admin")]
    (test (user-exists? "another-test") true)
    (test (get user :username) "another-test")
    (test (< 20 (length (get user :password))) true)))

(defn validate-user [username password]
  "Returns boolean"
  (assert (string? username))
  (assert (string? password))
  (let [rows  (db/query `select password from user where username = :username` {:username username})
        row   (get rows 0)]
    (if (nil? row)
      false
      (verify-password password (get row :password)))))

(deftest: with-db "validate user password" [_]
  (create-user "test" "password")
  (test (validate-user "test" "password") true)
  (create-user "testing" "somethingelse")
  (test (validate-user "testing" "password") false))

(comment
  (create-user "test" "admin")
  (validate-user "test" "admin")
  (user-exists? "test"))
