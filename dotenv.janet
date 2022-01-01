
(defn- log [elem]
  (printf "%p" elem)
  elem)
(defn- parse-dotenv [dot-env-string]
  (when dot-env-string
    (->> (string/split "\n" dot-env-string)
         (filter |(not (string/has-prefix? "#" $)))
         (mapcat |(string/split "=" $ 0 2))
         (filter |(not (empty? $)))
         (map string/trim)
         (log)
         (apply table))))

(defn load-dot-env []
  (when (os/stat ".env")
    (with [f (file/open ".env")]
      (as-> (file/read f :all) ?
            (parse-dotenv ?)
            (eachp [k v] ?
              (os/setenv k v))))))