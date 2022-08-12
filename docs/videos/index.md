---
layout: default
title: Short videos explaining (some of) the chapters 
permalink: /videos/
---

## Short videos explaining (some of) the chapters 

{% for chap in site.data.chapters %}
---
### Chapter {{ chap.chapter }}--{{ chap.title}}?
{% if chap.video %}
  <iframe width="560" height="315" src="https://www.youtube.com/embed/{{ chap.video }}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
{% else %}
  no video
{% endif %}
{% endfor %}