(use joy)
(use ./pages/index)
(use ./pages/login)
(use ./pages/signup)
(use ./pages/user)
(use ./pages/competition)

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

(route :get "/user/:username/competition/create" :get/create-competition)
(route :post "/user/:username/competition/create" :post/create-competition)
(route :get "/user/:username/competition/:comp-id" :get/competition)

(route :get "/user/:username/action/create" :get/create-action)
(route :post "/user/:username/action/create" :post/create-action)
(route :get "/user/:username/action/edit/:action-id" :get/edit-action)
(route :post "/user/:username/action/edit/:action-id" :post/edit-action)
(route :delete "/user/:username/action/delete/:action-id" :post/delete-action)
(route :get "/user/:username/action/:action-id" :get/action)
(route :post "/user/:username/action/:action-id/record" :post/record-action)

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
     [:footer
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
