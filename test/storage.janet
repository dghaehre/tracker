(use joy)
(use judge)
(use sh)
# TODO: migrator..

(defn create-test-data []
  (db/insert :user {:username "test" :password "password"}))

(defn setup-db []
  ($ rm "./test.db")
  ($ touch "./test.db")
  (def out ($< joy migrate)) # silent
  (let [conn (db/connect)]
    (do
      (create-test-data)
      conn)))

(deftest-type with-db
  :setup (fn []
           (setup-db))
  :reset (fn [conn]
           (setdyn :db/connection conn)
           (db/disconnect)
           (setup-db))
  # TODO: reset
  :teardown (fn [conn]
              (setdyn :db/connection conn)
              (db/disconnect)))

(comment
  (db/connect "./test.db"))
