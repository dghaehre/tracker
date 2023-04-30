(use joy)
(use judge)
(use ../components/forms)
(use ../storage)

(def- header
  [:header
    [:h2 "Signup"]])

(defn valid-username? [name]
  (let [not-valid-names @["admin" "blog" "user" "about" "terms" "login"]]
    (and
      (< 2 (length name))
      (empty? (filter |(= name $0) not-valid-names)))))

(test (valid-username? "dghaehre") true)
(test (valid-username? "admin") false)
(test (valid-username? "sd") false)

(defn- signup-form [& err]
  [:form {:hx-post "/signup"}
      [:input {:type "text"
               :name "username"
               :placeholder "username"}]
      [:input {:type "password"
               :name "password"
               :placeholder "password"}]
      [:input {:type "submit"
               :value "Signup"}]
      (if (nil? err) []
        [:p err])])

(route :get "/signup" :get/signup)
(defn get/signup [req]
  [header
    [:div (signup-form)
      [:p [:a {:href "/login"} "Or login"]]]])

(route :post "/signup" :post/signup)
(defn post/signup [req]
  (let [username (get-in req [:body :username])
        password (get-in req [:body :password])]
    (cond
      (not (valid-username? username)) (text/html (signup-form (string username " is not a valid username")))
      (user-exists? username) (text/html (signup-form (string username " already exist")))
      (redirect-to :user/index {:username username}))))

# Works the same as redirect-to
(test (url-for :user/index {:username "test"}) "/test")
