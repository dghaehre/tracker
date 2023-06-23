(use joy)
(use judge)
(use ../test/setup)
(use ../src/utils)
(use ./password)

(defn user-exists? [username]
  (let [rows (db/query `select id from user where upper(username) = upper(:name)` {:name username})]
    (not (nil? (get rows 0)))))

(defn create-user [username password]
  (assert (string? username))
  (assert (string? password))
  (when (user-exists? username)
    (error "user already exists"))
  (let [hashed (secure-password password)]
      (db/insert :user {:username username :password hashed})))

(defn- get-user-id! [username]
  "Returns user id or throws error"
  (let [user-id (-> (db/query `select id from user where username = :username` {:username username}) (get 0) (get :id))]
    (if (nil? user-id)
      (error "user does not exist")
      user-id)))

(defn validate-user [username password]
  "Returns boolean"
  (assert (string? username))
  (assert (string? password))
  (let [rows  (db/query `select password from user where username = :username` {:username username})
        row   (get rows 0)]
    (if (nil? row)
      false
      (verify-password password (get row :password)))))

(defn create-competition [username name]
  (assert (non-empty-string? name)
    "Could not create competition: name is not given")
  (assert (non-empty-string? username)
    "Could not create competition: username is not given")
  (let [user-id (get-user-id! username)]
    (db/insert :competition {:name name :user_id user-id})))

(defn get-competition [id]
  (assert (not (nil? id)) "Could not get competition: id is not given")
  (let [res (-> (db/query `select * from competition where id = :id` {:id id})
                (get 0))]
    (if (nil? res)
      (error "Competition does not exist")
      res)))

(defn get-competitions [username]
  (assert (non-empty-string? username)
         "Could not get competition: userid is not given")
  (db/query `select c.id, c.name, c.user_id from competition c
            left join user u
            on c.user_id = u.id
            where u.username = :username` {:username username}))

(defn create-action [username name]
  (assert (non-empty-string? username)
    "Could not create action with empty username")
  (assert (non-empty-string? name)
    "Could not create action with empty name")
  (let [user-id (get-user-id! username)
        [success res] (protect (db/insert :action {:name name :user_id user-id}))]
    (if success res
      (cond
        (string/has-prefix? "UNIQUE constraint failed:" res) (error "action already exists")
        (error "Something went wrong, could not create action")))))

(defn get-actions [username]
  (assert (non-empty-string? username)
    "Could not create action with empty username")
  (let [user-id (get-user-id! username)]
    (db/from :action :where {:user_id user-id
                             :status "ACTIVE"})))

(defn delete-action [username action-id]
  (assert (non-empty-string? username)
    "Could not delete action with empty username")
  (assert (and (number? action-id) (not= 0 action-id))
    "Could not delete action with invalid action-id")
  (let [user-id (get-user-id! username)]
    (db/execute
      `update action set status = 'DELETED'
        where user_id = :user_id
        and   id = :id` {:user_id user-id
                         :id action-id})))

(defn get-action [username action-id]
  (assert (non-empty-string? username)
    "Could not get action with empty username")
  (assert (and (number? action-id) (not= 0 action-id))
    "Could not get action with invalid action-id")
  (let [user-id (get-user-id! username)
        action  (-> (db/from :action :where {:user_id user-id
                                             :id action-id})
                    (get 0))]
    (if (nil? action) (error "action does not exist")
      action)))

(defn edit-action [username action-id new-fields]
  (assert (non-empty-string? username)
    "Could not get action with empty username")
  (assert (and (number? action-id) (not= 0 action-id))
    "Could not get action with invalid action-id")
  (let [user-id (get-user-id! username)]
    (db/update :action {:id action-id :user_id user-id} new-fields)))

(defn record-action [username action-id amount &opt time]
  (default time (os/time))
  (assert (non-empty-string? username)
    "Could not record an action with empty username")
  (assert (and (number? action-id) (not= 0 action-id))
    "Could not record an action with invalid action-id")
  (assert (and (number? amount))
    "Could not record an action with invalid amount")
  (let [{:year-day year-day :year year } (os/date time :local)]
    (db/insert {:db/table :record
                :amount amount
                :action_id action-id
                :year year
                :year_day year-day}
              :on-conflict [:action_id :year :year_day]
                 :do :update :set {:amount amount})))

(defn get-todays-recording [username action-id]
  (assert (non-empty-string? username)
    "Could not get recording for an action with empty username")
  (assert (and (number? action-id) (not= 0 action-id))
    "Could not get recording for an action with invalid action-id")
  (let [{:year-day year-day :year year } (os/date (os/time) :local)]
    (db/find-by :record :where {:action_id action-id
                                :year year
                                :year_day year-day})))


(defn get-actions-with-todays-recording [username]
  "Returns a list of actions, with :amount as the amount recorded today"
  (assert (non-empty-string? username)
    "Could not create action with empty username")
  (let [user-id (get-user-id! username)
        {:year-day year-day :year year } (os/date (os/time) :local)]
    (db/query `select action.*,
                      coalesce(record.amount, 0) as amount
              from action left join record
                on action.id = record.action_id
                  and record.year     = :year
                  and record.year_day = :year_day
              where action.user_id  = :user_id
                and action.status   = 'ACTIVE'` {:user_id user-id
                                                 :year year
                                                 :year_day year-day})))

(defn get-action-with-todays-recording [username action-id]
  "Returns a list of actions, with :amount as the amount recorded today"
  (assert (non-empty-string? username)
    "Could not create action with empty username")
  (let [user-id (get-user-id! username)
        {:year-day year-day :year year } (os/date (os/time) :local)
        rows (db/query `select action.*,
                               coalesce(record.amount, 0) as amount
                       from action left join record
                         on action.id = record.action_id
                           and record.year     = :year
                           and record.year_day = :year_day
                       where action.user_id  = :user_id
                         and action.id       = :action_id
                         and action.status   = 'ACTIVE'` {:user_id user-id
                                                          :year year
                                                          :action_id action-id
                                                          :year_day year-day})
        row (get rows 0)]
    (if (nil? row) (error "action does not exist")
      row)))


(comment
  (create-user "test" "admin")
  (validate-user "test" "admin")
  (user-exists? "test"))
