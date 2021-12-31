(declare-project
  :name "little-analytics"
  :description "Captures simple analytics "
  :author "Cendyne"
  :url "https://github.com/cendyne/bread"
  :repo "git+https://github.com/cendyne/bread"
  :dependencies [
    "https://github.com/cendyne/halo2.git"
    "https://github.com/cendyne/janet-html.git"
    "https://github.com/janet-lang/sqlite3.git"
    "https://github.com/joy-framework/db.git"
    "https://github.com/janet-lang/json.git"
    {:repo "https://github.com/cendyne/janet-uri.git" :tag "8ef191236e20bec64a72db2508df4693b9bd1cc0"}
    ]
  )

(declare-executable
  :name "little-analytics"
  :entry "main.janet"
  )