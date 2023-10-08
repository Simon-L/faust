import("stdfaust.lib");

process = 256 : rwtable(44100, 0.0, 256, 512) : attach(0,_);