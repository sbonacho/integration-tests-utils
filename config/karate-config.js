function config () {  
      
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'local';
    karate.log('Switching to:', env);
  }

  var config = {
    env: env
  }

  return config;
}