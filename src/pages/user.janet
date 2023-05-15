(use joy)
(use judge)
(use ../utils)
(import ../storage :as st)

(defn nav [username]
  [:nav
    [:a {:id "home"
         :href (string "/user/" username)}
        username]
    [:a {:href "/logout"} "Logout"]])


(defn- show-competitions [username]
  (let [post-url (string "/user/" username "/create-competition-form")]
    [:content {:id "show-competitions"}
      [:div {:id "create-competition"}
        [:button {:hx-post post-url :hx-target "#create-competition"} "Create new competition"]]
      [:table {:style "display: inline-table; margin: 0;"}
       [:thead
         [:tr
           [:th "Your competitions"]
           [:th "Ranking"]]]
       [:tbody
         [:tr
          [:td [:a {:href "/something"} "Pullups"]]
          [:td "1"]]]]]))

(defn create-competition-form [username &opt err]
  (let [post-url (string "/user/" username "/create-competition")]
      [:form {:hx-post post-url}
        [:input {:name "name" :placeholder "New competition name"} "Competition name"]
        [:button {:type "submit"} "Create competition"]
        (when err
          [:p {:class "err"} err])]))

(defn post/create-competition-form [req]
  (with-username
    (text/html (create-competition-form username))))

(defn post/create-competition [req]
  (with-username
    (with-err |(text/html (create-competition-form username $)) "trying to create competition"
      (let [name (get-in req [:body :name])
            comp-id (-> (st/create-competition username name) (get :id))]
        (htmx-redirect :get/competition {:username username :comp-id comp-id})))))

(defn get/user [req]
  (with-username
    [:div
      (nav username)
      (show-competitions username)]))

(defn get/competition [req]
  (with-username
    (let [comp-id (get-in req [:params :compid])] # TODO: handle error
      [:div
        [:p (string "Competition id: " comp-id)]])))

# Works the same as redirect-to
(test (do
        (route :get "/user/:username" :get/user)
        (url-for :get/user {:username "test"})) "/user/test")
