(use joy)
(use judge)
(use ../utils)
(import ../storage :as st)

########################
# Components
########################

(defn- show-competitions [username comps]
  (let [user-base-url (string "/user/" username)
        create-comp-url (string user-base-url "/competition/create")]
    [:content {:id "show-competitions"}
      [:table {:style "display: inline-table; margin: 0;"}
       [:thead
         [:tr
           [:th "Your competitions"]
           [:th "Current ranking"]]]
       [:tbody
        (map (fn [{:name name :id id}]
               [:tr
                [:td [:a {:href (string user-base-url "/competition/" id)} name]]
                [:td "N/A"]])
             comps)]]
      [:div {:id "create-competition"}
        [:a {:href create-comp-url}
          [:button "Create new competition"]]]]))

(defn- show-record-action [username]
  (let [create-action-url (string "/user/" username "/action/create")]
    [:div
      [:p "here you can record stuff.. TODO"]
      [:a {:href create-action-url} "Create new action"]]))

(defn create-competition-form [username &opt err]
  (let [post-url (string "/user/" username "/competition/create")]
      [:form {:hx-post post-url}
        [:input {:name "name" :placeholder "New competition name"} "Competition name"]
        [:button {:type "submit"} "Create competition"]
        (when err
          [:p {:class "err"} err])]))

(defn- create-action-form [username &opt err]
  (let [post-url (string "/user/" username "/action/create")]
    [:form {:hx-post post-url}
      [:input {:name "name" :placeholder "Action name"}]
      [:p "Some text explaining what an action is. It basically is what you want to track, like pushups or pullups."]
      [:button {:type "submit"} "Create new action"]
      (when err
        [:p {:class "err"} err])]))

########################
# Routes
########################

(defn get/user [req]
  (with-username
    (let [comps (st/get-competitions username)]
      [(user-nav username)
       (show-record-action username)
       [:hr]
       (show-competitions username comps)])))

(defn get/create-action [req]
  (with-username
    [(user-nav username)
     (create-action-form username)]))

(defn post/create-action [req]
  (with-username
    (with-err |(text/html (create-action-form username $)) "trying to create action"
     (let [name (get-in req [:body :name] "")]
       (st/create-action username name)
       (htmx-redirect :get/user {:username username})))))

# TODO(add error handling)
(defn post/delete-action [req]
  (with-username
    (let [name (get-in req [:body :name] "")]
      (st/delete-action username name)
      (htmx-redirect :get/user {:username username}))))
