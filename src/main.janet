(use joy)
(use ./pages/index)
(use ./pages/login)
(use ./pages/signup)
(use ./pages/user)

######################
# Routes
######################

(route :get "/" :get/index)
(route :get "/login" :get/login)
(route :post "/login" :post/login)
(route :get "/logout" :get/logout)
(route :get "/signup" :get/signup)
(route :post "/signup" :post/signup)
(route :get "/user/:username" :get/user)

# Layout
(defn app-layout [{:body body :request req}]
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "Tracker"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:script {:src "/htmx.min.js" :defer ""}]
      [:link {:href "/simple.min.css" :rel "stylesheet"}]
      [:link {:href "/app.v2.css" :rel "stylesheet"}]]
     [:body
       body]
     [:footer # TODO: style
      (let [username (get-in req [:session :username])]
        (if (nil? username) [:a {:href "/login"} "Login"]
          [:a {:href (string "/user/" username)} username]))]]))

# Middleware
(def app (-> (handler)
             (layout app-layout)
             (with-session)
             (query-string)
             (body-parser)
             (server-error)
             (x-headers)
             (static-files)
             (not-found)
             (logger)))

# Server
(defn main [& args]
  (let [port (get args 1 (env :PORT))
        host (get args 2 "localhost")
        encryption-key (env :encryption-key)]
    (if (nil? encryption-key) (error "ENCRYPTION-KEY environment variable is not set")
      (setdyn :encryption-key encryption-key))
    (print (string "serving at " host ":" port))
    (db/connect (env :database-url))
    (server app port host)
    (db/disconnect)))
