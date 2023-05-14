(use joy)
(use judge)
(use ../utils)

(defn nav []
  [:nav
    # [:a {:href (string "/user/" username)} "Home"]
    [:a {:href "/logout"} "Logout"]])

(with-session get/user [req]
  [:div
    (nav)
    [:h1 (string "Hey " username)]])

# # Or would this be better?
# (defn get/user [req]
#   (with-session)
#   [:div
#     (nav)
#     [:h1 (string "Hey " username)]])

# Works the same as redirect-to
(test (do
        (route :get "/user/:username" :get/user)
        (url-for :get/user {:username "test"})) "/user/test")
