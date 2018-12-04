const Flatten = window.flatten;

const parksCollection = document.getElementsByClassName('park');
const parksArray = [];

const pointFromString = function(pointString) {
  const coords = pointString.match(/(L|M)([^,]+),(.+)/);
  const x = parseFloat(coords[2], 10);
  const y = parseFloat(coords[3], 10);
  return new Flatten.Point(x, y);
};

const addTrees = function(polygon) {
  const bb = polygon.box;
  for (let i=0; i< 100; i++) {
    const x = Math.random() * (bb.xmax - bb.xmin) + bb.xmin;
    const y = Math.random() * (bb.ymax - bb.ymin) + bb.ymin;
    console.log(new Flatten.Point(x,y).svg({r: 0.001, fill: 'green'}));
  }
};

const processPark = function(svgPath) {
  const polygon = new Flatten.Polygon();
  const points = svgPath.attributes.d.value
        .split(' ')
        .map(pointFromString)
  polygon.addFace(points);

  addTrees(polygon);

  // M-0.0506517,51.465869 L-0.0501401,51.4595587 L-0.0534532,51.461409 L-0.0556934,51.4626977 L-0.0532695,51.4641953 L-0.0512267,51.4655321 L-0.0506517,51.465869
}

for (let i=0; i<parksCollection.length; i++) {
  parksArray.push(parksCollection.item(i));
}
parksArray.map(processPark);
