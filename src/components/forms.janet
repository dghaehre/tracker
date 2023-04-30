(use joy)
(use judge)

(defn login-form [form-config]
  (let [submit-name (get form-config :submit-name "Login")]
    [:form form-config
      [:input {:type "text"
               :name "username"
               :placeholder "username"}]
      [:input {:type "password"
               :name "password"
               :placeholder "password"}]
      [:input {:type "submit"
               :value submit-name}]]))
