(use joy)
(use judge)
(use sh)
(import cipher)

(defn setup-db []
  ($ rm "./test.db")
  ($ touch "./test.db")
  (def out ($< joy migrate)) # silent
  (db/connect))

(defn setup-cipher []
  (def key (cipher/password-key))
  (setdyn :encryption-key key))

(deftest-type with-db
  :setup (fn []
            (setup-cipher)
            (setup-db))
  :reset (fn [conn]
           (setup-cipher)
           (setdyn :db/connection conn)
           (db/disconnect)
           (setup-db))
  :teardown (fn [conn]
              (setdyn :encryption-key nil)
              (setdyn :db/connection conn)
              (db/disconnect)))

(deftest-type with-cipher
  :setup setup-cipher)
