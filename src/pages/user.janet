(use joy)
(use judge)
(use ../utils)
(import ../storage :as st)

########################
# Components
########################

(defn nav [username]
  [:nav
    [:a {:id "home"
         :href (string "/user/" username)}
        username]
    [:a {:href "/logout"} "Logout"]])

(defn- show-competitions [username comps]
  (pp comps)
  (let [user-base-url (string "/user/" username)
        post-url (string user-base-url "/create-competition-form")]
    [:content {:id "show-competitions"}
      [:div {:id "create-competition"}
        [:button {:hx-post post-url :hx-target "#create-competition"} "Create new competition"]]
      [:table {:style "display: inline-table; margin: 0;"}
       [:thead
         [:tr
           [:th "Your competitions"]
           [:th "Ranking"]]]
       [:tbody
        (map (fn [{:name name :id id}]
               [:tr
                [:td [:a {:href (string user-base-url "/competition/" id)} name]]
                [:td "N/A"]])
             comps)]]]))

(defn create-competition-form [username &opt err]
  (let [post-url (string "/user/" username "/create-competition")]
      [:form {:hx-post post-url}
        [:input {:name "name" :placeholder "New competition name"} "Competition name"]
        [:button {:type "submit"} "Create competition"]
        (when err
          [:p {:class "err"} err])]))

########################
# Routes
########################

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
    (let [comps (st/get-competitions username)]
      [:div
        (nav username)
        (show-competitions username comps)])))

(defn get/competition [req]
  (with-username
    (with-err |(something-went-wrong $) "trying to get competition"
      (let [comp-id (get-in req [:params :comp-id]) # TODO: handle error
            competition (st/get-competition comp-id)]
        [:div
          [:p (string "Competition name: " (get competition :name))]]))))
