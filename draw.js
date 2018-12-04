const parksCollection = document.getElementsByClassName('park');
const parksArray = [];
const draw = SVG('svgroot');

const processPark = function(svgPath) {
  const bb = svgPath.getBBox();
   for (let i=0; i< 100; i++) {
     const x = Math.random() * bb.width + bb.x;
     const y = Math.random() * bb.height + bb.y;
     console.log(x,y)
     draw.circle(0.003).fill('green').move(x,y);
   }
}



  // M-0.0506517,51.465869 L-0.0501401,51.4595587 L-0.0534532,51.461409 L-0.0556934,51.4626977 L-0.0532695,51.4641953 L-0.0512267,51.4655321 L-0.0506517,51.465869


for (let i=0; i<parksCollection.length; i++) {
  parksArray.push(parksCollection.item(i));
}
parksArray.map(processPark);
