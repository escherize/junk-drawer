(defn cache-insert [self query result]
  (put self query result)
  result)

(defn cache-get [self query]
  (get self query))

(defn cache-partial-clear [self component]
  (each query (keys self)
    (when (not= false (index-of component query false))
      (put self query nil))))

(defn init []
  (table/setproto
   @{}
   @{:insert cache-insert
     :get cache-get
     :partial-clear cache-partial-clear}))
