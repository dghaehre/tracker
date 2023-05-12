(use joy)
(use judge)

(def- header
  [:header
    [:h2 "Your daily workout tracker"]
    [:h4 "Track your pushups, pullups or similar and compete with your friends."]
    [:div 
      [:p [:a {:href "/login"} "Login"]]
      [:p [:a {:href "/signup"} "Sign up"]]]])

(def- main
  [:main
    [:p "some text"]])

(defn get/index [req]
  [header main])
