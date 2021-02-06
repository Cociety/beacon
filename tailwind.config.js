module.exports = {
  purge: {
    content: ['./app/views/**/*.html.erb'],
    enabled: true,
    options: {
      safelist: [
        "type", // [type='checkbox']
      ],
    },
    preserveHtmlElements: true
  },
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
    require('@tailwindcss/forms'),
    require('tailwindcss-line-clamp')
  ]
}
