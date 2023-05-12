(use joy)
(use judge)
(import ../src/pages/signup :as signup)
(use ./setup)

(deftest: with-db "succesful signup" [_]
  (let [req {:body {:username "testing" :password "somethinglooooong"}}
        res (signup/post/signup req)]
    (test (get res :status) 200)
    (test (get-in res [:headers "HX-Redirect"]) "/user/testing")))

(deftest: with-db "signup with empty username" [_]
  (let [req {:body nil}
        res (signup/post/signup req)]
    (test (get res :status) 200)
    (test (get res :body) "<form hx-post=\"/signup\"><input placeholder=\"username\" name=\"username\" type=\"text\" /><input placeholder=\"password\" name=\"password\" type=\"password\" /><input value=\"Signup\" type=\"submit\" /><p> is not a valid us
ername</p></form>")))

(deftest: with-db "signup with empty password" [_]
  (let [req {:body {:username "testing"}}
        res (signup/post/signup req)]
    (test (get res :status) 200)
    (test (get res :body) "<form hx-post=\"/signup\"><input placeholder=\"username\" name=\"username\" type=\"text\" /><input placeholder=\"password\" name=\"password\" type=\"password\" /><input value=\"Signup\" type=\"submit\" /><p>Your password need
s to be at least 10 characters</p></form>")))
