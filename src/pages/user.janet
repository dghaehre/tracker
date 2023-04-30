(use joy)

(route :get "/:username" :user/index)
(defn user/index [req]
  (pp req)
  [:h1 "user"])
   
