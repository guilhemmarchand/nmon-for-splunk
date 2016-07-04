var webpack = require('webpack');
var path = require('path');

module.exports = {
    entry: 'nmon_bullet_graph',
    resolve: {
        root: [
            path.join(__dirname, 'src'),
        ]
    },
    output: {
        filename: 'visualization.js',
        libraryTarget: 'amd'
    },
    module: {
        loaders: [
            {
                test: /bullet\.js$/,
                loader: 'imports-loader?d3=d3'
            }
        ]
    },
    externals: [
        'vizapi/SplunkVisualizationBase',
        'vizapi/SplunkVisualizationUtils'
    ]
};