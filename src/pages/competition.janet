(use joy)
(use judge)
(use ../utils)
(import ../storage :as st)

########################
# Components
########################

# TODO: show graph
(defn- show-competition [{:name name}]
  "This should be the 'canonical' function for displaying a competition data "
  [:div
    [:header
      [:h2 name]]
    [:div
     [:p (string "Competition name: " name)]
     [:p "TODO: show graph"]]])


# What is the difference between settings and creation?
(defn- show-competition-settings [username {:name name
                                            :id id}]
  (let [post-url (string "/user/" username "/edit-competition/" id)]
    [:form {:hx-post post-url}
      [:h4 "Settings"]
      [:p
        [:label {:for "name"} "Name: "
          [:input [:name "name" :value name]]]]
      [:p
        [:label {:for "type"} "Type: "
          [:select {:name "type"}
            [:option {:value "count"} "Count"]
            [:option {:value "duration"} "Duration"]
            [:option {:value "longtitue"} "longtitue"]]]]
      [:input {:type "submit" :value "Save"}]]))


(defn- show-competition-users-settings [username {:id id}]
  (let [post-url (string "/user/" username "/edit-competition-users/" id)]
    [:div
      [:p "Your current users:"
          [:tr
            [:th "Username"]
            [:th "Last active"]
            [:th ""]]
        [:tbody
          [:tr
            [:td "test123"]
            [:td "N/A"]
            [:td [:button "Remove"]]]]] # TODO
      [:br]
      [:br]
      [:form {:hx-post post-url}
       [:p
         [:label {:for "username"} "Invite user: "
           [:input {:name "username" :placeholder "user123"}]]]
       [:input {:type "submit" :value "Send invite"}]]]))
  
# This should probably be rewritten entirely
(defn- show-create-competition-form [username &opt err]
  (let [post-url (url-for :post/create-competition {:username username})]
    [:form {:hx-post post-url}
      [:p
        [:label {:for "name"} "Competition name:"]
        [:input {:type "text" :name "name"}]]
      [:p
        [:label {:for "type"} "Type of measurement:"]
        # This should change..
        # I want to be able to add more of these!
        # And I want to add lets say "pullups" and that might be linked to another competition that also has pullups!
        #
        # (multi-select-text "type" get-competition-types)
        [:select {:name "type"}
          [:option {:value "count"} "Count"]
          [:option {:value "duration"} "Duration"]
          [:option {:value "longitude"} "Longitude"]]]
      [:p "Invite users:"]
      [:p [:small "You can invite users later, or you can compete against yourself!"]
        [:label {:for "invites"} "Type of measurement:"
          [:button "Add invite"]]] # TODO: how to do this?
      [:p
        [:label {:for "private"} "Should the competition be public for others to see?"]
        [:select {:name "private"}
          [:option {:value "private"} "Private"]
          [:option {:value "public"} "Public"]]]
      [:input {:type "submit" :value "Create"}]]))

########################
# Routes
########################

(defn get/competition [req]
  (with-username
    (with-err |(something-went-wrong $) "trying to get competition"
      (let [comp-id (get-in req [:params :comp-id]) # TODO: handle error
            competition (st/get-competition comp-id)]
        [(user-nav username)
         (show-competition competition)
         [:hr]
         (show-competition-settings username competition)
         [:hr]
         (show-competition-users-settings username competition)]))))

(defn get/create-competition [req]
  (with-username
    [(user-nav username)
     [:h4 "Create a new competition"]
     (show-create-competition-form username)]))

# TODO: change error handling!
# Return creation form with error message!
(defn post/create-competition [req]
  (with-username
    (with-err |(text/html (show-create-competition-form username $)) "trying to create competition"
      (let [name (get-in req [:body :name])
            comp-id (-> (st/create-competition username name) (get :id))]
        (htmx-redirect :get/competition {:username username :comp-id comp-id})))))

