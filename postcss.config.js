module.exports = {
  plugins: [
    require('postcss-import'),
    require('postcss-flexbugs-fixes'),
    require('tailwindcss/nesting'),
    require('tailwindcss'),
    require('autoprefixer')
  ]
}
