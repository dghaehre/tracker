(use joy)
(use judge)
(use ../test/storage)

(defn user-exists? [username]
  (let [rows (db/query `select id from user where upper(username) = upper(:name)` {:name username})]
    (not (nil? (get rows 0)))))

(deftest: with-db "test users exists" [_]
  (test (user-exists? "test") true)
  (test (user-exists? "admin") false))

(defn create-user [username password]
  (assert (string? username))
  (assert (string? password))
  (let [hashed (hash password)]
    (if (user-exists? username)
      (error "user already exists")
      (db/insert :user {:username username :password hashed}))))

# (defn validate-user [user-id password])
  
# TODO: create a bcrypt library?
(deftest: with-db "create user" [_]
  (let [password "admin"
        user (create-user "another-test" "admin")]
    (test (user-exists? "another-test") true)
    (test (get user :username) "another-test")
    (test (get user :password) "252902542.0")))

(comment
  (user-exists? "test"))
