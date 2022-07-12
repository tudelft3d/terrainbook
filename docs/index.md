---
layout: default
---


# Computational modelling of terrains

An open book about the algorithms and methodologies to reconstruct, manipulate, and extract information from terrains (or DTMs or DEMs).
It covers different representations of terrains (eg TINs, rasters, point clouds, contour lines) and presents techniques to handle large datasets.

The book was developed, and is currently used, for the course [Digital terrain modelling (GEO1015)](https://3d.bk.tudelft.nl/courses/geo1015/) in the [MSc Geomatics at the Delft University of Technology](http://geomatics.tudelft.nl) in the Netherlands.
The course is tailored for MSc students who have already followed an introductory course in GIS and in programming.

Each chapter is a lesson in the course, and each lesson is accompanied by a video introducing the key ideas and/or explaining some parts of the lessons.

Written by [Hugo Ledoux](https://3d.bk.tudelft.nl/hledoux), [Ken Arroyo Ohori](https://3d.bk.tudelft.nl/ken), and [Ravi Peters](https://3d.bk.tudelft.nl/rypeters).


{% for chap in site.data.chapters %}
## Chapter {{ chap.chapter }}--{{ chap.title}}?
{% if chap.video %}
  <iframe width="560" height="315" src="https://www.youtube.com/embed/{{ chap.video }}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
{% else %}
  no video
{% endif %}
---
{% endfor %}

