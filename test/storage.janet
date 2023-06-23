(use joy)
(use judge)
(use ../src/storage)
(use ./setup)
(use ../src/utils)

(deftest: with-db "test users exists" [_]
  (test (user-exists? "test") false)
  (test (user-exists? "admin") false)
  (create-user "test" "passwoooooord")
  (test (user-exists? "test") true))

(deftest: with-db "create user" [_]
  (let [password "admin"
        user (create-user "another-test" "admin")]
    (test (user-exists? "another-test") true)
    (test (get user :username) "another-test")
    (test (< 20 (length (get user :password))) true)))

(deftest: with-db "validate user password" [_]
  (create-user "test" "password")
  (test (validate-user "test" "password") true)
  (create-user "testing" "somethingelse")
  (test (validate-user "testing" "password") false))

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

(deftest: with-db "Record action" [_]
  (def username "user-with-action")
  (create-user username "password")
  (def {:id action-id} (create-action username "testing"))
  (create-action username "not-to-be-used")
  # Record action
  (record-action username action-id 10)
  (def {:action-id id :amount amount} (get-todays-recording username action-id))
  (test id 1)
  (test amount 10)
  # Update recording
  (record-action username action-id 20)
  (def {:action-id id :amount amount} (get-todays-recording username action-id))
  (test id 1)
  (test amount 20)
  # Test get-actions-with-todays-recording
  (def actions (get-actions-with-todays-recording username))
  (test (length actions) 2)
  (test (-> (get actions 0) (get :amount)) 20)
  (test (-> (get actions 1) (get :amount)) 0)
  # Record action for another day
  (record-action username action-id 40 (yesterday))
  (def {:action-id id :amount amount} (get-todays-recording username action-id))
  (test id 1) # Unchanged
  (test amount 20)) # Unchanged

(deftest: with-db "Edit action" [_]
  (def username "user-with-action")
  (create-user username "password")
  (def action (create-action username "testing"))
  (test (-> (get-action username 1) (get :name)) "testing")
  (let [action-id (get action :id)]
    (test (-> (edit-action username action-id {:name "updated-name"})
              (get :name)) "updated-name")
    (test (-> (get-action username action-id) (get :name)) "updated-name")))

(deftest: with-db "Create action" [_]
  (def username "user-with-action")
  (create-user username "password")
  (test (-> (create-action username "test-action") (get :name)) "test-action")
  (let [[success err] (protect (create-action username "test-action"))]
    (test success false)
    (test err "action already exists"))
  (test (-> (create-action username "another-action") (get :id)) 2)
  (test (-> (get-action username 2) (get :name)) "another-action")
  (create-user "random-user" "password")
  (test (-> (create-action "random-user" "test-action") (get :name)) "test-action")
  (let [actions (get-actions username)]
    # Should NOT return actions from "random-user"
    (test (length actions) 2))
  (delete-action username 2)
  (let [actions (get-actions username)]
    # Should only return one action
    (test (length actions) 1)))

