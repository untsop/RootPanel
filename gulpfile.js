var gulp = require('gulp');
var less = require('gulp-less');
var coffee = require('gulp-coffee');
var uglify = require('gulp-uglify');
var path = require('path');

lessPath = './core/static/style';
coffeePath = './core/static/script';

gulp.task('less', function() {
  return gulp.src(lessPath + "/**/*.less").pipe(less()).pipe(gulp.dest(lessPath));
});

gulp.task('coffee', function() {
  return gulp.src(coffeePath + "/**/*.coffee").pipe(coffee()).on('error', function(error) {
    throw error;
  }).pipe(uglify().pipe(gulp.dest(coffeePath)));
});

gulp.task('default', ['less', 'coffee'], function() {
  gulp.watch(lessPath + "/**/*.less", function() {
    return gulp.run('less');
  });
  return gulp.watch(coffeePath + "/**/*.coffee", function() {
    return gulp.run('coffee');
  });
});