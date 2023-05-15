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

(defmacro with-err
  "Map possible error to given function"
  [err-fn heading & body]
  ~(try ,;body ([e] (do
                      (log (string "Error: " ,heading ": " (string/trim (string e))))
                      (,err-fn e)))))

(test (with-err |(+ 1 $) "some error" (error 1)) 2)

#######################
# with session macro
#######################

(defmacro with-username
  "Redirects to login if we dont have a valid session

  * Puts username in scope
  * Assumes req is in scope
  * Assumes username is in session and in params"
  [& body]
  ~(let [username       (get-in req [:session :username])
         param-username (get-in req [:params :username])]
       (if (or (nil? username) (not (= username param-username)))
         (redirect-to :get/login)
         (do
           ,;body))))

# TODO: add failing test..
(test (let [req {:session {:username "test"} :params {:username "test"}}]
        (with-username
         (string username "!"))) "test!")

(comment
  (macex '(let [req {:session {:username "test"}}]
             (with-username
              (string username "!")))))


###########################
# something went wrong page
###########################

(defn something-went-wrong [err]
  [:div
   [:h1 "Obs, something went wrong"]
   [:p "Error: " (string/trim (string err))]])
