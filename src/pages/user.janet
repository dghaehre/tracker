(use joy)
(use judge)

(defn get/user [req]
  (let [username (get-in req [:session :username])]
    (if (nil? username)
      (redirect-to :get/login)
      [:div
        [:nav 
         [:a {:href "/logout"} "Logout"]]
        [:h1 (string "Hey " username)]])))
   
# Works the same as redirect-to
(test (do
        (route :get "/user/:username" :get/user)
        (url-for :get/user {:username "test"})) "/user/test")

