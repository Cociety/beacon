module.exports = {
  mode: 'jit',
  purge: {
    content: [
      './app/views/**/*.html.erb',
      './app/javascript/packs/**/*.js'
    ],
    enabled: true,
    safelist: [
      'type', // [type='checkbox']
    ],
    preserveHtmlElements: true
  },
  darkMode: 'media', // or 'media' or 'class'
  theme: {
    extend: {
      fill: {
        none: 'none'
      },
      stroke: theme => theme('colors'),
      width: {
        fit: 'fit-content'
      },
      zIndex: {
        '-1': -1
      }
    },
    lineClamp: {
      4: 4
    },
  },
  variants: {
    extend: {
      borderRadius: ['first', 'last'],
      borderWidth: ['last']
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('tailwindcss-line-clamp')
  ]
}
