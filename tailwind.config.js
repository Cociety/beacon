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
    extend: {
      borderRadius: ['first', 'last'],
      borderWidth: ['last'],

    },
  },
  plugins: [
    require('tailwindcss-line-clamp')
  ]
}
