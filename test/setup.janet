(use joy)
(use judge)
(use sh)
# TODO: migrator..

(defn setup-db []
  ($ rm "./test.db")
  ($ touch "./test.db")
  (def out ($< joy migrate)) # silent
  (db/connect))

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
