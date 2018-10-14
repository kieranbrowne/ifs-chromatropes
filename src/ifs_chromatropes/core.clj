(ns ifs-chromatropes.core
  ;;(:use [overtone.live])
  (:require [shadertone.shader :as t])
  )

(t/start "./chromatrope.glsl")
(t/stop)
