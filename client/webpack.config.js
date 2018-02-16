const path = require("path");
const webpack = require("webpack");

if (process.env.WATCH) {
  elmLoader = 'elm-webpack-loader?debug=true?warn=true';
  plugins = [];
} else {
  elmLoader = 'elm-webpack-loader';
  plugins = [
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false
      }
    })
  ];
}

module.exports = {
  entry: {
    app: [
      './app.js'
    ]
  },
  output: {
    path: path.resolve(__dirname + '/../server/static'),
    filename: '[name].js',
  },
  module: {
    loaders: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: elmLoader,
      },
    ],
    noParse: /\.elm$/,
  },
  plugins: plugins,
};
