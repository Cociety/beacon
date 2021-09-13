module.exports = {
  plugins: [
    require('postcss-import'),
    require('postcss-flexbugs-fixes'),
    require('autoprefixer'),
    require('tailwindcss/nesting'),(require('postcss-nesting')),
    require('tailwindcss')
  ]
}
