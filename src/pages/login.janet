(use joy)
(use judge)
(use ../components/forms)

(def- header
  [:header
    [:h2 "Login"]])

(route :get "/login" :get/login)
(defn get/login [req]
  [header
   [:div
    (login-form {:method :post
                 :action "/login"
                 :submit-name "Login"})
    [:p [:a {:href "/signup"} "Or signup"]]]])
