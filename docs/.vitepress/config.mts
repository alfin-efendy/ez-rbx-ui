import { defineConfig } from 'vitepress'

export default defineConfig({
  base: '/ez-rbx-ui/',
  lang: 'en-US',
  title: 'EzUI',
  description:
    'A modern, modular UI library for Roblox scripts — shadcn-inspired, Fluent acrylic, Lucide icons, engine-driven flex layout, and flag-based config.',
  cleanUrls: true,
  lastUpdated: true,
  srcExclude: ['superpowers/**'],
  themeConfig: {
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
