'use strict';
// generated on 2014-04-22 using generator-gulp-webapp 0.0.8

var gulp = require('gulp');

// load plugins
var $ = require('gulp-load-plugins')();

gulp.task('styles', function () {
    return gulp.src('app/styles/main.scss')
        .pipe($.rubySass({
            style: 'expanded'
        }))
        .pipe($.autoprefixer('last 1 version'))
        .pipe(gulp.dest('.tmp/styles'))
        .pipe($.size());
});

gulp.task('coffee', function() {
    gulp.src('app/scripts/**/*.coffee')
        .pipe($.concat('app.coffee'))
        .pipe(gulp.dest('.tmp/scripts'))
        .pipe($.coffee({
            map: true,
            join: 'main.js'
        }).on('error', $.util.log))
        .pipe(gulp.dest('.tmp/scripts'));
});

gulp.task('scripts', function () {
    return gulp.src('app/scripts/**/*.js')
        .pipe($.jshint())
        .pipe($.jshint.reporter($.jshintStylish))
        .pipe($.size());
});

gulp.task('html', ['styles', 'scripts'], function () {
    var jsFilter = $.filter('**/*.js');
    var cssFilter = $.filter('**/*.css');

    return gulp.src('app/*.html')
        .pipe($.useref.assets())
        .pipe(jsFilter)
        .pipe($.uglify())
        .pipe(jsFilter.restore())
        .pipe(cssFilter)
        .pipe($.csso())
        .pipe(cssFilter.restore())
        .pipe($.useref.restore())
        .pipe($.useref())
        .pipe(gulp.dest('dist'))
        .pipe($.size());
});


gulp.task('fonts', function () {
    return $.bowerFiles()
        .pipe($.filter('**/*.{eot,svg,ttf,woff}'))
        .pipe($.flatten())
        .pipe(gulp.dest('dist/fonts'))
        .pipe($.size());
});

gulp.task('clean', function () {
    return gulp.src(['.tmp', 'dist'], { read: false }).pipe($.clean());
});

gulp.task('copyPixelFont', function() {
    gulp.src([
        'app/styles/thirteen_pixel_fonts/*.*',
        'app/images/*.png'
        ], {base: './app'})
        .pipe(gulp.dest('dist'))
})

gulp.task('build', ['html', 'copyPixelFont']);

gulp.task('default', ['clean'], function () {
    gulp.start('build');
});

gulp.task('connect', function () {
    var connect = require('connect');
    var app = connect()
        .use(require('connect-livereload')({ port: 35729 }))
        .use(connect.static('app'))
        .use(connect.static('.tmp'))
        .use(connect.directory('app'));

    require('http').createServer(app)
        .listen(9000)
        .on('listening', function () {
            console.log('Started connect web server on http://localhost:9000');
        });
});

gulp.task('serve', ['connect', 'styles'], function () {
    require('opn')('http://localhost:9000');
});

// inject bower components
gulp.task('wiredep', function () {
    var wiredep = require('wiredep').stream;

    gulp.src('app/styles/*.scss')
        .pipe(wiredep({
            directory: 'app/bower_components'
        }))
        .pipe(gulp.dest('app/styles'));

    gulp.src('app/*.html')
        .pipe(wiredep({
            directory: 'app/bower_components',
            exclude: ['bootstrap-sass-official']
        }))
        .pipe(gulp.dest('app'));
});

gulp.task('watch', ['connect', 'serve'], function () {
    var server = $.livereload();

    // watch for changes

    gulp.watch([
        'app/*.html',
        '.tmp/styles/**/*.css',
        'app/scripts/**/*.js',
        'app/scripts/**/*.coffee',
    ]).on('change', function (file) {
        server.changed(file.path);
    });

    gulp.watch('app/styles/**/*.scss', ['styles']);
    gulp.watch('app/scripts/**/*.js', ['scripts']);
    gulp.watch('app/scripts/**/*.coffee', ['coffee']);
    gulp.watch('bower.json', ['wiredep']);
});
