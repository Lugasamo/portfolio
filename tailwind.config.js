/** @type {import('tailwindcss').Config} */
// tailwind.config.js
module.exports = {
  content: [
    "./templates/**/*.{html,twig}",
    "./css/**/*.css",
    "./**/*.html",
    "./**/*.twig"
  ],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['Plus+Jakarta+Sans', 'Inter', 'system-ui', 'sans-serif'],
        'display': ['Plus+Jakarta+Sans', 'Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
