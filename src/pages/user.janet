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

# TODO(we want existing value in the input field)
(defn- show-record-action [username action-with-req &opt success err]
  (let [id (get action-with-req :id)
        amount (get action-with-req :amount)
        post-url (string "/user/" username "/action/" id "/record")
        action-url (string "/user/" username "/action/" id)]
    [:form {:hx-post post-url}
      [:label {:for "value"}
        [:a {:href action-url} (get action-with-req :name)]
        [:input {:type "text" :name "amount" :value amount}]]
      [:button {:type "submit"} "Record"]
      (when success
        [:p {:class "success"} success])
      (when err
        [:p {:class "err"} err])]))

(defn- show-record-actions [username actions-with-req]
  (let [create-action-url (string "/user/" username "/action/create")]
    [(map |(show-record-action username $) actions-with-req)
     [:hr]
     [:a {:href create-action-url} "Create new action"]]))

# TODO(add graph's and such)
(defn- show-action [username action]
  (let [name (get action :name)
        edit-url (url-for :get/action {:username username
                                       :action-id (get action :id)})]
    [ [:h3 name]
      [:a {:href edit-url} "edit"]]))

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

(defn- show-delete-action [username action-id &opt err]
  [ [:button {:hx-delete (string "/user/" username "/action/delete/" action-id)
              :hx-swap "outerHTML"
              :hx-confirm "Are you sure you want to delete this action?"}
     "Delete action"]
    (when err
      [:p {:class "err"} err])])
  

(defn- show-edit-action [username action &opt err success]
  (let [id        (get action :id)
        name      (get action :name)
        status    (get action :status)
        post-url  (string "/user/" username "/action/edit/" id)]
    (assert (number? id) "id must be a number")
    (if (= status "DELETED")
      [:p "This action has been deleted. You can't edit it anymore."]
      [:form {:hx-post post-url}
        [:input {:name "name" :value name}]
        [:button {:type "submit"} "Edit action"]
        (show-delete-action username id)
        (when err
          [:p {:class "err"} err])
        (when success
          [:p {:class "success"} success])])))

########################
# Routes
########################

# TODO(error handling)
(defn get/user [req]
  (with-username
    (let [comps (st/get-competitions username)
          actions-with-req (st/get-actions-with-todays-recording username)]
      [(user-nav username)
       (show-record-actions username actions-with-req)
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

(defn get/action [req]
  (with-username
    (let [action-id (-> (get-in req [:params :action-id])
                        (to-number))
          action    (st/get-action username action-id)]
        [(user-nav username)
         (show-action username action)])))

(defn get/edit-action [req]
  (with-username
    (with-err |(something-went-wrong-with-nav username $) "showing action"
      (let [action-id (-> (get-in req [:params :action-id])
                          (to-number))
            action    (st/get-action username action-id)]
        [(user-nav username)
         (show-edit-action username action)]))))

# TODO(add error handling): what if to-number fails?
(defn post/delete-action [req]
  (with-username
    (let [action-id (-> (get-in req [:params :action-id])
                        (to-number))]
        (with-err |(text/html (show-delete-action username action-id $)) "delete action"
            (do
              (st/delete-action username action-id)
              (htmx-redirect :get/user {:username username}))))))

# TODO(add error handling): what if to-number fails?
(defn post/edit-action [req]
  (with-username
    (let [action-id (-> (get-in req [:params :action-id])
                        (to-number))
          action    (st/get-action username action-id)]
      (with-err |(text/html (show-edit-action username action $)) "edit action"
        (let [new-name (get-in req [:body :name])
              new-action (st/edit-action username action-id {:name new-name})]
          (text/html (show-edit-action username new-action nil "Updated ✅")))))))

(defn post/record-action [req]
  (with-username
    (pp req)
    (let [action-id (-> (get-in req [:params :action-id])
                        (to-number))
          amount    (-> (get-in req [:body :amount])
                        (to-number))
          action    (st/get-action username action-id)]
      (with-err |(text/html (show-record-action username action nil $)) "edit action"
        (do
          (st/record-action username action-id amount)
          (let [action-with-req (st/get-action-with-todays-recording username action-id)]
            (text/html (show-record-action username action-with-req "Recorded ✅" nil))))))))
