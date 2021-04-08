(use ./../junk-drawer)

(fsm/define
 colors
 (green
  :next |(:goto $ :yellow))
 (yellow
  :next |(:goto $ :red))
 (red
  :next |(:goto $ :green)))

(def-tag next-color)

(def-system colored-printer
  (color-fsms [:colors])
  (each [c] color-fsms
    (printf "current color: %q" (c :current))))

(def-system colored-switcher
  (wld :world
   msgs [:message :next-color]
   color-fsms [:colors])
  (when (> (length msgs) 0)
    (each [msg] msgs
      (each [c] color-fsms
        (:next c))
      (messages/consume msg))))

(def GS (gamestate/init))

(def example
  {:name "Example Gamestate"
   :world (create-world)
   :init (fn [self]
           (let [world (get self :world)]
             (add-entity world (colors :green))
             (register-system world timers/update-sys)
             (register-system world messages/update-sys)
             (register-system world colored-printer)
             (register-system world colored-switcher)
             (timers/every world 4
                           (fn [wld dt]
                             (messages/send wld "next!" next-color)))))
   :update (fn [self dt]
             (:update (self :world) dt))})

(:push GS example)

(for i 0 20
  (:update GS 1))
