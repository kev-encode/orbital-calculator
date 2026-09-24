# Project Outline

## General Idea

`orbital-calculator` will be an simplistic, interactive 2D application that calculates orbital mechanics based on a set of provided parameters.

## Specifications

* Stack
    * `PyQt` and `PySide` for controlled design
* Functionality
    * Orbit speed and visualization display
    * Planet mass, planet radius, and satellite distance from ground boxes for entry
* Design choices
    * Orbit speed is calculated using planet mass and satellite orbit radius
        * Since orbit speed only requires planet mass and orbit radius, planet radius is not needed
        * It can be included by making orbit radius = planet radius + satellite distance from ground