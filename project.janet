(declare-project
  :name "tracker"
  :description ""
  :dependencies [{:repo "https://github.com/joy-framework/joy" :tag "76878a92bd7546524367d1e2ae3ec6701210158f"}
                 {:url "https://github.com/ianthehenry/judge.git" :tag "v2.4.0"}
                 {:repo "https://github.com/janet-lang/sqlite3" :tag "99df7b6fdee73c34e7fc633c09004c57e609926e"}]
  :author "Daniel Hæhre"
  :license "MIT"
  :url "https://github.com/dghaehre/tracker"
  :repo "https://github.com/dghaehre/tracker")

(declare-executable
  :name "tracker"
  :entry "./src/main.janet")

(task "test" [] (shell "judge"))
