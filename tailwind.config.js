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
      1: 1,
      2: 2,
      3: 3
    }
  },
  variants: {
    extend: {},
  },
  plugins: []
}
