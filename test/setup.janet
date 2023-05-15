(use joy)
(use judge)
(use sh)
(import cipher)

(defn new-db-name []
  (let [random (-> (math/random)
                   (* 100000)
                   (int/s64)
                   (int/to-number))]
    (string "/tmp/tracker-test-" random ".db")))

(defn setup-db []
  (let [db-name (new-db-name)]
    ($ rm -f ,db-name)
    (setdyn :out @"") # Dont really know how this works... But this makes it silent!
    (db/migrate db-name)
    (db/connect db-name)))

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
