(import halo2)
(import uri)
(import json)
(import janet-html :as "html")
(import db)
(import ./dotenv)

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

(defn pixel-handler [connection request]
    (def uri (get request :uri))
    (def query (get (uri/parse uri) :query))
    (def request (merge request {:query query}))
    # Copies the headers
    (def headers (merge (get request :headers) {}))
    (def cookie-string (or (get headers "Cookie") (get headers "cookie")))
    (var user-agent (or (get headers "User-Agent") (get headers "user-agent")))
    (when (and user-agent (< 256 (length user-agent)))
        (set user-agent (string/slice user-agent 0 256)))
    (def content-type (or (get headers "Content-Type") (get headers "Content-type")))
    (var body (get request :body))
    (when (and body (= "application/x-www-form-urlencoded" content-type))
        (def fake-uri (string "/?" body))
        (def fake-query (get (uri/parse fake-uri) :query))
        (set body fake-query)
        )
    (put request :body nil)
    (var ip (get headers "cf-connecting-ip"))
    (unless ip
        (def forwarded-for (or (get headers "X-Forwarded-For") (get headers "x-forwarded-for")))
        (when forwarded-for (set ip (string/trim (first (string/split "," forwarded-for))))))
    (unless ip
        (set ip (get-in request [:peer-name 0])))
    (when cookie-string
        (def fake-uri (string "/?" cookie-string))
        (def fake-query (get (uri/parse fake-uri) :query))
        (put request :cookies fake-query))
    
    (each header ["Connection" "Accept" "Accept-Encoding" "Accept-Language" "Cookie" "X-Forwarded-For" "X-Forwarded-Proto" "X-Forwarded-Ssl" "X-Request-Start" "cdn-loop" "cf-ray" "cf-visitor" "Upgrade-Insecure-Requests" "Cache-Control" "User-Agent" "Host" "Content-Type" "Content-Length"]
        (put headers (string/ascii-lower header) nil)
        (put headers header nil))
    (put request :headers headers)
    (put request :peer-name nil)
    (put request :http-version nil)
    (put request :uri nil)
    (def method (get request :method))
    (put request :method nil)
    (var path (get request :path))
    (put request :path nil)
    (def date (os/clock))
    (def cookies (get request :cookies))
    (put request :cookies nil)
    (var host nil)
    (def second-slash (string/find "/" path 1))
    (when-let [second-slash (string/find "/" path 1)]
        (set host (string/slice path 1 second-slash))
        (set path (string/slice path second-slash)))

    (printf "%f %s %s %p %s" date ip method host path)
    (db/insert :events {
        :date date
        :ip ip
        :method method
        :user-agent user-agent
        :path path
        :cookies (when cookies (json/encode cookies))
        :body (when body (json/encode body))
        :body-content-type content-type
        :headers (json/encode headers)
        :host host
    })
    respond-transparent
)
(defn handle-404 []
    {
        :status 404
        :body ""
    })
(def unresolveable-paths [
    "/favicon.ico"
    "/robots.txt"
])
(defn analytics-handler [connection request]
    (def buf (buffer))
    (def now (os/clock))
    (def now-minus-30-days (- now  2592000))
    (def hosts (db/query "select distinct host as `host`, count(*) as `count` from events where `date` > :date and host is not null group by host order by host" {:date now-minus-30-days}))
    (buffer/push buf "---- Unique hosts last 30 days ----\n")
    (each host hosts
        (buffer/push buf (or (get host :host) "?") ": " (string (get host :count)) "\n")
        )
    (buffer/push buf "\n---- Last 100 visits ----\n")
    (each {:host host} hosts
        (buffer/push buf "------ " (or host "?") " ------\n")
        (each event (db/query "select * from events where `date` > :date and `host` = :host order by date desc limit 100" {:date now-minus-30-days :host host})
            (def {:ip ip :path path :date date} event)
            (def {:year year :month month :month-day day :hours hours :minutes minutes :seconds seconds} (os/date (math/floor date)))
            (buffer/push buf (string/format "%04d-%02d-%02dT%02d:%02d:%02dZ " year month day hours minutes seconds))
            (buffer/push buf ip " " path "\n"))
        (buffer/push buf "\n"))
    {
        :status 200
        :body buf
    })

(defn app
    [connection auth-prefix request]
    (def path (get request :path))
    (cond
        (find |(= path $) unresolveable-paths)
        (handle-404)
        (and auth-prefix (string/has-prefix? auth-prefix path))
        (analytics-handler connection request)
        (= "/" path) respond-transparent
        true # Fallback
        (pixel-handler connection request)
        ))

(defn main [& args]
    (dotenv/load-dot-env)
    (let [port (scan-number (get args 1 (or (os/getenv "PORT") "8000")))
          host (get args 2 (or (os/getenv "HOST") "localhost"))
          db-url (get args 3 (or (os/getenv "DATABASE_URL") "database.sqlite3"))
          auth-token (os/getenv "AUTH_TOKEN")
        ]
        (var auth-prefix nil)
        (when auth-token
            (set auth-prefix (string "/" auth-token "/")))
        (db/migrate db-url)
        (def connection (db/connect db-url))
        (defn loaded-app [request] (app connection auth-prefix request))
        (printf "Listening on %s:%d" host port)
        (halo2/server loaded-app port host)
    ))
