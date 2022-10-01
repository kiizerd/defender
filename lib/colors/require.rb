PATH = "lib/colors/"

def require_local(filename)
  require(PATH + filename + '.rb')
end

require_local('rgb')
require_local('hsl')
require_local('hsv')
require_local('hex')
require_local('colors')
