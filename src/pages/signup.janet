(use joy)
(use judge)
(use ../components/forms)
(use /test/storage)
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
  (let [username (get-in req [:body :username] "") # TODO: handle empty
        password (get-in req [:body :password] "")]
    (cond
      (not (valid-username? username)) (text/html (signup-form (string username " is not a valid username")))
      (not (valid-password? password)) (text/html (signup-form "Your password needs to be at least 10 characters"))
      (st/user-exists? username)       (text/html (signup-form (string username " already exist")))
      (do 
        (st/create-user username password) # TODO: errors?
        (redirect-to :user/index {:username username})))))

(deftest: with-db "succesful signup" [_]
  (let [req {:body {:username "testing" :password "somethinglooooong"}}
        res (post/signup req)]
    (test (get res :status) 302)))

(deftest: with-db "signup with empty username" [_]
  (let [req {:body nil}
        res (post/signup req)]
    (test (get res :status) 200)
    (test (get res :body) "<form hx-post=\"/signup\"><input placeholder=\"username\" name=\"username\" type=\"text\" /><input placeholder=\"password\" name=\"password\" type=\"password\" /><input value=\"Signup\" type=\"submit\" /><p> is not a valid us
ername</p></form>")))

(deftest: with-db "signup with empty password" [_]
  (let [req {:body {:username "testing"}}
        res (post/signup req)]
    (test (get res :status) 200)
    (test (get res :body) "<form hx-post=\"/signup\"><input placeholder=\"username\" name=\"username\" type=\"text\" /><input placeholder=\"password\" name=\"password\" type=\"password\" /><input value=\"Signup\" type=\"submit\" /><p>Your password need
s to be at least 10 characters</p></form>")))

# Works the same as redirect-to
(test (url-for :user/index {:username "test"}) "/test")
