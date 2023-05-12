(use joy)
(use judge)
(use ../utils)
(import ../storage :as st)

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

(defn valid-password? [password]
  (< 10 (length password)))

(test (valid-password? "heyyy") false)
(test (valid-password? "sdfsdfsdfsdf") true)
(test (valid-password? "somethinglooooong") true)

(defn- signup-form [&opt err]
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

(defn get/signup [req]
  [header
    [:div (signup-form)
      [:p [:a {:href "/login"} "Or login"]]]])

# This one doesnt really redirect as I want..
(defn post/signup [req]
  (with-err |(text/html (signup-form $)) "trying to sign up"
   (let [username (get-in req [:body :username] "")
          password (get-in req [:body :password] "")]
      (cond
        (not (valid-username? username)) (error (string username " is not a valid username"))
        (not (valid-password? password)) (error "Your password needs to be at least 10 characters")
        (st/user-exists? username)       (error (string username " already exist"))
        (let [user (st/create-user username password)]
          (-> (htmx-redirect :get/user {:username username})
              (put :session {:username username})))))))
