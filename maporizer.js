const fs = require('fs');
const xml2js = require('xml2js');
const parser = new xml2js.Parser();

const scalingFactor = 100000;
const colourBackground = '#571845';
const colourStation = '#900c3e';
const colourRoad = '#c70039';
const colourPark = '#ff5733';
const colourRailway = '#ffc300';

const attr = function(node, attrName) {
  try {
    return node['$'][attrName]
  } catch (e) {
    return null;
  }
}

const roadTypes = ['primary', 'secondary', 'tertiary', 'residential', 'trunk', 'unclassified', 'pedestrian'];

const wayType = function(way) {
  for (tag of way.tag) {
    if (attr(way, 'k') === 'highway') {
      return attr(way, 'v');
    }
  }
  return null;
}

const drawRoads = function(obj) {
  const result = [];
  for (way of obj.osm.way) {
    const type = wayType(way);
    if (roadTypes.includes(type)) {
      result.push(`<!-- ${wayType} -->\n`);
    }
  }
  return result.join('');
};

const makeSvg = function (obj) {
  const minlat = obj.osm.bounds[0]['$'].minlat * scalingFactor;
  const minlon = obj.osm.bounds[0]['$'].minlon * scalingFactor;
  const maxlat = obj.osm.bounds[0]['$'].maxlat * scalingFactor;
  const maxlon = obj.osm.bounds[0]['$'].maxlon * scalingFactor;
  const width = maxlon - minlon;
  const height = maxlat - minlat;

  return `<svg version="1.1" viewBox="0 0 ${width} ${height}" width="2500px" height="1500px" preserveAspectRatio="none" id="svgroot">\n` +
  `<rect x="0" y="0" width="${width}" height="${height}" fill="${colourBackground}"/>\n` +
  drawRoads(obj) +
  '</svg>\n';
}

fs.readFile(__dirname + '/montpelier.xml', (err, data) => {
  parser.parseString(data, (err, result) => {
    console.log(makeSvg(result));
  });
});
