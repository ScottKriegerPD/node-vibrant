# Use in node.js or bunddle with browserify
Vibrant = require('../lib')

v = new Vibrant('http://interfaceinc.scene7.com/is/image/InterfaceInc/install_15_7A?$tile=InterfaceInc/7898008999G17S001_rms508_agave&wid=640&hei=640&align=-1,0&fit=crop')
v.getSwatches (err, swatches) ->
  console.log(err)
  console.log(swatches)