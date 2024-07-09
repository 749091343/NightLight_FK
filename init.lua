local pokemon = require "packages/nightlight/pokemon"
local touhou = require "packages/nightlight/touhou"
local limbus = require "packages/nightlight/limbus"

Fk:loadTranslationTable{ ["nightlight"] = "夜光" }

return{
    pokemon,
    touhou,
    limbus,
}

