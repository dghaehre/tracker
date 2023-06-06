(use joy)
(use judge)
(use ../test/setup)
(use ../src/utils)
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

(defn- get-user-id! [username]
  "Returns user id or throws error"
  (let [user-id (-> (db/query `select id from user where username = :username` {:username username}) (get 0) (get :id))]
    (if (nil? user-id)
      (error "user does not exist")
      user-id)))

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
  (assert (non-empty-string? name)
    "Could not create competition: name is not given")
  (assert (non-empty-string? username)
    "Could not create competition: username is not given")
  (let [user-id (get-user-id! username)]
    (db/insert :competition {:name name :user_id user-id})))

(defn get-competition [id]
  (assert (not (nil? id)) "Could not get competition: id is not given")
  (let [res (-> (db/query `select * from competition where id = :id` {:id id})
                (get 0))]
    (if (nil? res)
      (error "Competition does not exist")
      res)))

(defn get-competitions [username]
  (assert (non-empty-string? username)
         "Could not get competition: userid is not given")
  (db/query `select c.id, c.name, c.user_id from competition c
            left join user u
            on c.user_id = u.id
            where u.username = :username` {:username username}))

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

(deftest: with-db "Get competions from user" [_]
  (create-user "user-with-comp" "password")
  (let [a (create-competition "user-with-comp" "test-competition1")
        b (create-competition "user-with-comp" "test-competition2")
        res (get-competitions "user-with-comp")]
    (test (get a :id) 1)
    (test (get b :id) 2)
    (test (length res) 2)
    (test (get-in res [0 :name]) "test-competition1")
    (test (get-in res [1 :name]) "test-competition2")
    (test (get-in res [0 :id]) 1)
    (test (get-in res [1 :id]) 2)))

(defn create-action [username name]
  (assert (non-empty-string? username)
    "Could not create action with empty username")
  (assert (non-empty-string? name)
    "Could not create action with empty name")
  (let [user-id (get-user-id! username)
        [success res] (protect (db/insert :action {:name name :user_id user-id}))]
    (if success res
      (cond
        (string/has-prefix? "UNIQUE constraint failed:" res) (error "action already exists")
        (error "Something went wrong, could not create action")))))

(defn get-actions [username]
  (assert (non-empty-string? username)
    "Could not create action with empty username")
  (let [user-id (get-user-id! username)]
    (db/from :action :where {:user_id user-id})))

(deftest: with-db "Create action" [_]
  (def username "user-with-action")
  (create-user username "password")
  (test (-> (create-action username "test-action") (get :name)) "test-action")
  (let [[success err] (protect (create-action username "test-action"))]
    (test success false)
    (test err "action already exists"))
  (test (-> (create-action username "another-action") (get :id)) 2)
  (create-user "random-user" "password")
  (test (-> (create-action "random-user" "test-action") (get :name)) "test-action")
  (let [actions (get-actions username)]
    # Should NOT return actions from "random-user"
    (test (length actions) 2)))

(comment
  (create-user "test" "admin")
  (validate-user "test" "admin")
  (user-exists? "test"))
