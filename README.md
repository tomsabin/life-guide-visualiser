LifeGuide Visualiser
============

Repository for the code of COMP3020 (Individual Project), last commit Monday 29th April 2013.

---
Please also take a look at the dissertation, titled [_How does the analysis of LifeGuide interventions benefit the author for further studies_](https://dl.dropboxusercontent.com/u/2217931/life-guide-intervention-report.pdf), a project report submitted for the award of BSc Computer Science, studied at the University of Southampton.

The app created for this project is deployed on Heroku for you to view. Please visit [life-guide-visualiser.herokuapp.com](http://life-guide-visualiser.herokuapp.com/) and use the examples found in [Examples/](https://github.com/tomsabin/life-guide-visualiser/blob/master/Examples) - just download one of the files and then drag and drop it onto the blue box.

![Screenshot](https://dl.dropboxusercontent.com/u/2217931/life-guide-visualiser-screenshot.png)

LifeGuide Visualiser with [Examples/603.lgil](https://github.com/tomsabin/life-guide-visualiser/blob/master/Examples/603copy.lgil).

---

### Local development

* Run server with `foreman start`, listening on [localhost:5000](http://localhost:5000/), or `rackup -p 5000 config.ru &`
* Kill a running server `lsof -i :5000`, `kill -9 ID`
