(use joy)
(use judge)


(defn log [str]
  "\"Logger\"

  Taken from joy source"
  (defn- timestamp
    "Get the current date nicely formatted"
    []
    (let [date (os/date)
          M (+ 1 (date :month))
          D (+ 1 (date :month-day))
          Y (date :year)
          HH (date :hours)
          MM (date :minutes)
          SS (date :seconds)]
      (string/format "%d-%.2d-%.2d %.2d:%.2d:%.2d"
                     Y M D HH MM SS)))
  (printf "[%s] %s" (timestamp) str))

(defmacro with-err
  "Map possible error to given function"
  [err-fn heading & body]
  ~(try ,;body ([e] (do
                      (log (string "Error: " ,heading ": " (string/trim (string e))))
                      (,err-fn e)))))

(test (with-err |(+ 1 $) "some error" (error 1)) 2)

(defmacro with-session-err-redirect
  "Redirects to login if we dont have a valid session

  Puts username in scope"
  [& body]
  ~(let [username (get-in req [:session :username])]
       (if (nil? username)
         (redirect-to :get/login)
         (do
           ,;body))))

(test (let [req {:session {:username "test"}}]
        (with-session-err-redirect
         (string username "!"))) "test!")

(defmacro with-session
  "Wraps with-session-err-redirect"
  [name args & body]
  ~(defn ,name ,args
     (with-session-err-redirect ,;body)))

(comment
  (macex '(let [req {:session {:username "test"}}]
             (with-session-err-redirect
              (string username "!")))))

# Are there a cooler way?
(defn add-header [r key value]
  (let [headers (get r :headers)]
    (put headers key value)
    (put r :headers headers)
    r))

(defn htmx-redirect [path & otherstuff]
  "Adds a HX-Redirect header for it to work with client side redirect (htmx)"
  (let [location  (url-for path ;otherstuff)]
    @{:status 200
      :body " "
      :headers @{"Location" location
                 "HX-Redirect" location}}))

(test (do
        (route :get "/user/:username" :get/user)
        (htmx-redirect :get/user {:username "testing"}))
  @{:body " "
    :headers @{"Location" "/user/testing"
               "HX-Redirect" "/user/testing"}
    :status 200})

# Just showing how to add a header to normal redirect-to
(test (do
        (route :get "/user/:username" :get/user)
        (-> (redirect-to :get/user {:username "testing"})
            (put-in [:headers "HX-Redirect"] "/user/testing")))
  @{:body " "
    :headers @{"HX-Redirect" "/user/testing"
               "Location" "/user/testing"}
    :status 302})

