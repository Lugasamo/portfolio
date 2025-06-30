/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./user/themes/**/*.{html,js,twig}",
    "./user/pages/**/*.{md,html,twig}",
  ],
  theme: {
    extend: {
      fontFamily: {
        'inter': ['Inter', 'sans-serif'],
      }
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
  ],
}
