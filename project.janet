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
    ]
  )

(declare-executable
  :name "little-analytics"
  :entry "main.janet"
  )