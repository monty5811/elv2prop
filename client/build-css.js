'use strict';

const Promise = require('bluebird');
const AtImport = require('postcss-import');
const Chalk = require('chalk');
const CSSnano = require('cssnano');
const CSSnext = require('postcss-cssnext');
const FS = Promise.promisifyAll(require('fs'));
const Path = require('path');
const PostCSS = require('postcss');
const tailwindcss = require('tailwindcss');

function buildStyles() {
  return Promise.resolve()
    // Create the dist folder if it doesn't exist
    .then(() => {
      if(!FS.existsSync(Path.join(__dirname, '../server/static/'))) {
        return FS.mkdirAsync(Path.join(__dirname, '../server/static/'));
      }
    })

    // Generate minified stylesheet
    .then(() => {
      let file = Path.join(__dirname, 'src/style.css');
      let css = FS.readFileSync(file, 'utf8');

      return PostCSS([
        AtImport,
        tailwindcss('./tw_config.js'),
        CSSnext({
          features: {
            rem: false
          }
        }),
        CSSnano({
          autoprefixer: false,
          safe: true
        }),
      ]).process(css, { from: file });
    })

    // Write stylesheet to dist
    .then((result) => {
      let file = Path.join(__dirname, '../server/static/elv2prop.css');

      // Output a message
      console.log(Chalk.green('CSS processed: %s! '), Path.relative(__dirname, file));

      // Write output file
      return FS.writeFileAsync(file, result.css, 'utf8');
    });
}

buildStyles();
