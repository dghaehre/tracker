(use joy)

(defn user-exists? [username]
  (let [rows (db/query `select id from users where upper(username) = upper(:name)` {:name username})]
    (not (nil? (get rows 0)))))
