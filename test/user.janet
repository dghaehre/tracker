(use joy)
(use judge)
(use ../src/pages/user)
(use ./setup)
(import ../src/storage :as st)

(deftest: with-db "user homepage with valid session" [_]
  (st/create-user "testing" "password")
  (let [req {:session {:username "testing"} :params {:username "testing"}}
        res (get/user req)
        username-in-header (get-in res [0 1 2])]
    (test username-in-header "testing")))

(deftest: with-db "user homepage with INVALID session" [_]
  (let [req {:params {:username "testing"}}
        res (get/user req)]
    (test (get-in res [:status]) 302)
    (test (get-in res [:headers "Location"]) "/login")))

(test (do
        (route :get "/user/:username" :get/user)
        (url-for :get/user {:username "test"})) "/user/test")
