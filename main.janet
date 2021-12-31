(import halo2)
(import janet-html :as "html")

(def transparent (slurp "static/transparent.gif"))
(def respond-transparent {
    :headers {
        "Content-Type" "image/gif"
        "Expires" "0"
        "Cache-Control" "no-cache, no-store, must-revalidate"
        "Pragma" "no-cache"
        "Accept-CH" "Viewport-Width, Width, DPR, Sec-CH-UA-Full-Version-List"
    }
    :body transparent
    :status 200
})
(defn app
    [connection request]
    (def uri (get request :uri))
    respond-transparent
)

(defn main [& args]
    (let [port (scan-number (get args 1 (or (os/getenv "PORT") "8000")))
          host (get args 2 (or (os/getenv "HOST") "localhost"))
        ]
        (printf "Listening on %s:%d" host port)
        (def connection nil)
        (defn loaded-app [request] (app connection request))
        (halo2/server loaded-app port host)
    ))
