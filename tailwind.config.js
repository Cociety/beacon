module.exports = {
  purge: ['./app/views/**/*.html.erb'],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
    lineClamp: {
      1: 1,
      2: 2,
      3: 3
    }
  },
  variants: {
    extend: {},
  },
  plugins: [
    require('tailwindcss-line-clamp')
  ]
}