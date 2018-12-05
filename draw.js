const parksCollection = document.getElementsByClassName('park');
const parksArray = [];
const draw = SVG('svgroot');
const Flatten = window.flatten;
const g = SVG.select('#trans2').members[0]; //SVG.adopt(document.getElementById('trans2'));

const flattenPoint = function(pointString) {
  const coords = pointString.match(/(L|M)([^,]+),(.+)/);
  const x = 100 * parseFloat(coords[2], 10);
  const y = 100 * parseFloat(coords[3], 10);
  return new Flatten.Point(x, y);
};

const flattenPath = function(svgPath) {
  const polygon = new Flatten.Polygon();
  const points = svgPath.attributes.d.value
    .split(' ')
    .map(flattenPoint);
  polygon.addFace(points);
  return polygon;
};

const processPark = function(svgPath) {
  const bb = svgPath.getBBox();
  const polygon = flattenPath(svgPath);
  const area = polygon.area();
   for (let i=0; i < 10000*area; i++) {
     const x = Math.random() * bb.width + bb.x;
     const y = Math.random() * bb.height + bb.y;
     const point = new Flatten.Point(100*x, 100*y);
     if (polygon.contains(point)) {
       const circle = draw.circle(0.0003).addClass('tree').move(x-0.00015, y-0.00015);
       g.add(circle);
     }
   }
}

for (let i=0; i<parksCollection.length; i++) {
  parksArray.push(parksCollection.item(i));
}
parksArray.map(processPark);
