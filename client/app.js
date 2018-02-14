const Elm = require('./src/Main.elm');

const cacheName = 'elv2prop-v1';
const tokenKey = cacheName + '-token-data';


function getTokenData() {
  return JSON.parse(localStorage.getItem(tokenKey));
}

function setTokenData(data) {
  localStorage.setItem(tokenKey, JSON.stringify(data));
}

function deleteTokenData(data) {
  localStorage.removeItem(tokenKey);
}

function handleDOMContentLoaded() {
  // setup elm
  const node = document.getElementById('elm');
  const app = Elm.Main.embed(node, {
    oauthToken : getTokenData(),
    host: document.location.host,
    savedConfig: savedConfig,
    allFiles: allFiles,
    configFromFile: configFromFile,
  });

  app.ports.saveTokenData.subscribe(setTokenData);
  app.ports.deleteTokenData.subscribe(deleteTokenData);
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
