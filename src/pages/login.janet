(use joy)
(use judge)
(use ../utils)
(import ../storage :as st)

(def- header
  [:header
    [:h2 "Login"]])

(defn login-form [&opt err]
  [:form {:hx-post "/login"}
    [:input {:type "text"
             :name "username"
             :placeholder "username"}]
    [:input {:type "password"
             :name "password"
             :placeholder "password"}]
    [:input {:type "submit"
             :value "Login"}]
    (if (nil? err) []
      [:p err])])

(defn get/login [req]
  [header
   [:div (login-form)
    [:p [:a {:href "/signup"} "Or signup"]]]])

(defn post/login [req]
  (with-err |(text/html (login-form $)) "trying to login"
    (let [username (get-in req [:body :username] "")
          password (get-in req [:body :password] "")]
      (if (st/validate-user username password)
        (-> (htmx-redirect :get/user {:username username})
            (put :session {:username username}))
        (error "Invalid username or password")))))

(defn get/logout [req]
  (-> (redirect-to :get/index)
      (put :session {})))

