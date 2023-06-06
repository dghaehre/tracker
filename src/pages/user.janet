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
      [:div {:id "create-competition"}
        [:a {:href create-comp-url}
          [:button "Create new competition"]]]
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
             comps)]]]))

(defn- show-record [username]
  (let [create-action-url (string "/user/" username "/action/create")]
    [:div
      [:p "here you can record stuff.."]
      [:button "Create new record"]
      [:a {:href create-action-url} "Create new action"]]))

(defn create-competition-form [username &opt err]
  (let [post-url (string "/user/" username "/competition/create")]
      [:form {:hx-post post-url}
        [:input {:name "name" :placeholder "New competition name"} "Competition name"]
        [:button {:type "submit"} "Create competition"]
        (when err
          [:p {:class "err"} err])]))

########################
# Routes
########################

(defn get/user [req]
  (with-username
    (let [comps (st/get-competitions username)]
      [(user-nav username)
       (show-record username)
       (show-competitions username comps)])))
