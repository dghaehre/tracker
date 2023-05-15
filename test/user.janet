(use joy)
(use judge)
(use ../src/pages/user)
(use ./setup)

(deftest: with-db "user homepage with valid session" [_]
  (let [req {:session {:username "testing"} :params {:username "testing"}}
        res (get/user req)
        username-in-header (get-in res [1 1 2])]
    (test username-in-header "testing")))

(deftest: with-db "user homepage with INVALID session" [_]
  (let [req {:params {:username "testing"}}
        res (get/user req)]
    (test (get-in res [:status]) 302)
    (test (get-in res [:headers "Location"]) "/login")))
