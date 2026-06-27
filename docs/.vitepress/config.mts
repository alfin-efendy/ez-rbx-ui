import { defineConfig } from 'vitepress'

const base = '/ez-rbx-ui/'

export default defineConfig({
  base,
  lang: 'en-US',
  title: 'EzUI',
  description:
    'A modern, modular UI library for Roblox scripts — shadcn-inspired, Fluent acrylic, Lucide icons, engine-driven flex layout, and flag-based config.',
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: `${base}favicon.svg` }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: `${base}favicon-32x32.png` }],
    ['link', { rel: 'apple-touch-icon', sizes: '180x180', href: `${base}apple-touch-icon.png` }],
    ['meta', { name: 'theme-color', content: '#0a0c10' }]
  ],
  cleanUrls: true,
  lastUpdated: true,
  srcExclude: ['superpowers/**'],
  themeConfig: {
    logo: {
      light: '/brand/ezui-wordmark-light.svg',
      dark: '/brand/ezui-wordmark-dark.svg',
      alt: 'EZUI'
    },
    siteTitle: false,
    search: { provider: 'local' },
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Controls', link: '/controls/' },
      { text: 'API', link: '/api/window' },
      { text: 'Releases', link: 'https://github.com/alfin-efendy/ez-rbx-ui/releases' }
    ],
    sidebar: {
      '/guide/': [
        {
          text: 'Guide',
          items: [
            { text: 'Getting Started', link: '/guide/getting-started' },
            { text: 'Window & Tabs', link: '/guide/window-and-tabs' },
            { text: 'Theming', link: '/guide/theming' },
            { text: 'Config & Flags', link: '/guide/config-and-flags' },
            { text: 'Notifications & Dialog', link: '/guide/notifications-dialog' },
            { text: 'Icons', link: '/guide/icons' },
            { text: 'Migration', link: '/guide/migration' }
          ]
        }
      ],
      '/controls/': [
        {
          text: 'Controls',
          items: [
            { text: 'Overview', link: '/controls/' },
            { text: 'Label', link: '/controls/label' },
            { text: 'Paragraph', link: '/controls/paragraph' },
            { text: 'Section', link: '/controls/section' },
            { text: 'Separator', link: '/controls/separator' },
            { text: 'Button', link: '/controls/button' },
            { text: 'Toggle', link: '/controls/toggle' },
            { text: 'TextBox', link: '/controls/textbox' },
            { text: 'NumberBox', link: '/controls/numberbox' },
            { text: 'Slider', link: '/controls/slider' },
            { text: 'SelectBox', link: '/controls/selectbox' },
            { text: 'Keybind', link: '/controls/keybind' },
            { text: 'ColorPicker', link: '/controls/colorpicker' },
            { text: 'Image', link: '/controls/image' },
            { text: 'ProgressBar', link: '/controls/progressbar' },
            { text: 'Table', link: '/controls/table' },
            { text: 'Card', link: '/controls/card' },
            { text: 'Resizable', link: '/controls/resizable' },
            { text: 'Accordion', link: '/controls/accordion' }
          ]
        }
      ],
      '/api/': [
        {
          text: 'API Reference',
          items: [
            { text: 'Window', link: '/api/window' },
            { text: 'Core (Config, Theme, Icons)', link: '/api/core' }
          ]
        }
      ]
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/alfin-efendy/ez-rbx-ui' }
    ],
    editLink: {
      pattern:
        'https://github.com/alfin-efendy/ez-rbx-ui/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    },
    footer: {
      message:
        'Released under the repository LICENSE. Lucide icons: ISC. lucide-roblox port: MIT.',
      copyright: 'Created by alfin-efendy.'
    }
  }
})
