module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fill: {
        none: 'none'
      },
      stroke: theme => theme('colors'),
      width: theme => { return {
        fit: 'fit-content',
        ...theme('maxWidth')
      }},
      zIndex: {
        '-1': -1
      }
    },
    lineClamp: {
      4: 4
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('tailwindcss-line-clamp')
  ]
}
