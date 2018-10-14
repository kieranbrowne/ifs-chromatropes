(ns ifs-chromatropes.core
  (:use [overtone.live])
  (:require [shadertone.tone :as t])
  )

(t/start "chromatrope.glsl")
(t/stop)
