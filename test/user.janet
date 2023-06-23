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

(deftest: with-db "record an action through api" [_]
  (def username "user-with-action")
  (st/create-user username "password")
  (def {:id action-id} (st/create-action username "testing"))
  (def req {:session  {:username username}
            :params   {:username username
                       :action-id 1}
            :body {:amount 10}})
  (def res (post/record-action req))
  (test res @{:body " "
              :headers @{"HX-Redirect" "/user/user-with-action"
                         "Location" "/user/user-with-action"}
              :status 200}))

(deftest: with-db "access an action through api" [_]
  (def username "user-with-action")
  (st/create-user username "password")
  (def {:id action-id} (st/create-action username "testing"))
  (def req {:session  {:username username}
            :params   {:username username
                       :action-id 1}})
  (def res (get/action req))
  (test (type res) :tuple))

(deftest: with-db "access create action page" [_]
  (def username "user-with-action")
  (st/create-user username "password")
  (def req {:session  {:username username}
            :params   {:username username}})
  (def res (get/create-action req))
  (test (type res) :tuple))
