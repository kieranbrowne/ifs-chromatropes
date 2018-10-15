(ns ifs-chromatropes.core
  (:require [shadertone.shader :as s])
  )

(s/start "./chromatrope.glsl")
(s/stop)
