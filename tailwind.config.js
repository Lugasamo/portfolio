/* @type {import('tailwindcss').Config} */
module.exports = {
  content: {
    files: [
      './user/themes/portfolio-luis/templates/**/*.{html,twig}',
      './user/themes/portfolio-luis/assets/js/*.js',
      './src/*.{html,js}',
    ],
    relative: true,
    transform: (content) => content.replace(/taos:/g, ''),
  },
  safelist: [
    '!duration-[0ms]',
    '!delay-[0ms]',
    'html.js :where([class*="taos:"]:not(.taos-init))'
  ],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['Plus Jakarta Sans', 'system-ui', 'sans-serif'],
        'jakarta': ['Plus Jakarta Sans', 'sans-serif'],
        'display': ['Barlow', 'system-ui', 'sans-serif'],
      },
      colors: {
        primary: {
          50: '#008844',
          100: '#32F191',
          600: '#2563eb',
          700: '#1d4ed8',
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('taos/plugin'),
  ],
}