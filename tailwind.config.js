/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./user/themes/portfolio-luis/templates/**/*.{html,twig}",
    './user/themes/portfolio-luis/assets/js/*.js'
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
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}