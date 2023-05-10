(use joy)
(use judge)

(route :get "/:username" :user/index)
(defn user/index [req]
  (pp req)
  [:h1 "user"])
   
# Works the same as redirect-to
(test (url-for :user/index {:username "test"}) "/test")

