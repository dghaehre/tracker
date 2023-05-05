(use joy)
(use judge)
(use ../test/storage)
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

(deftest: with-db "test users exists" [_]
  (test (user-exists? "test") false)
  (test (user-exists? "admin") false)
  (create-user "test" "password")
  (test (user-exists? "test") true))

(deftest: with-db "create user" [_]
  (let [password "admin"
        user (create-user "another-test" "admin")]
    (test (user-exists? "another-test") true)
    (test (get user :username) "another-test")
    (test (get user :password) "252902542.0")))

(defn validate-user [user-id password]
  "Returns boolean"
  (assert (number? user-id))
  (assert (string? password))
  (let [rows  (db/query `select password from user where id = :id` {:id user-id})
        row   (get rows 0)]
    (if (nil? row)
      false
      (verify-password password (get row :password)))))

(deftest: with-db "validate user password" [_]
  (let [password  "password"
        id        (-> (create-user "test" password) (get :id))]
    (test (validate-user id password) true)))

(comment
  (create-user "test" "admin")
  (validate-user 1 "admin")
  (user-exists? "test"))
