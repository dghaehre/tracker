(use joy)
(use ./pages/index)
(use ./pages/login)
(use ./pages/signup)
(use ./pages/user)

# Layout
(defn app-layout [{:body body :request request}]
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
       body]]))

# Middleware
(def app (-> (handler)
             (layout app-layout)
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
        host (get args 2 "localhost")]
    (print (string "serving at " host ":" port))
    (db/connect (env :database-url))
    (server app port host)
    (db/disconnect)))
