module.exports = {
  purge: ['./app/views/**/*.html.erb'],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      fill: {
        none: 'none'
      },
      stroke: theme => theme('colors')
    },
    lineClamp: {
      4: 4
    }
  },
  variants: {
    extend: {},
  },
  plugins: [
    require('tailwindcss-line-clamp')
  ]
}
