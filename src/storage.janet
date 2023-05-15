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
  (when (user-exists? username)
    (error "user already exists"))
  (let [hashed (secure-password password)]
      (db/insert :user {:username username :password hashed})))

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

(defn create-competition [username name]
  (assert (string? name))
  (assert (string? username))
  (assert (not (empty? name)))
  (let [user-id (-> (db/query `select id from user where username = :username` {:username username}) (get 0) (get :id))]
    (when (nil? user-id)
      (error "user does not exist"))
    (db/insert :competition {:name name :user_id user-id})))

(defn get-competition [id]
  (assert (not (nil? id)) "Could not get competition: id is not given")
  (let [res (-> (db/query `select * from competition where id = :id` {:id id})
                (get 0))]
    (if (nil? res)
      (error "Competition does not exist")
      res)))

(deftest: with-db "Create competition" [_]
  (create-user "user-with-comp" "password")
  (def c (create-competition "user-with-comp" "test-competition"))
  (test (get c :id) 1)
  (test (get c :user-id) 1)
  (test (get c :name) "test-competition")
  (def fetched-c (get-competition (string (get c :id))))
  (test (get fetched-c :name) "test-competition")
  (let [[success err] (protect (create-competition "nobody" "another-comp"))]
    (test success false)
    (test err "user does not exist")))

(comment
  (create-user "test" "admin")
  (validate-user "test" "admin")
  (user-exists? "test"))
