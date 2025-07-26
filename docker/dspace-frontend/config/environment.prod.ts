// DSpace Frontend Production Environment Configuration
// Based on DSpace 9.x documentation

export const environment = {
  production: true,
  
  // REST API Configuration - Points to DSpace Backend
  rest: {
    ssl: false,
    host: 'dspace-backend',
    port: 8080,
    nameSpace: '/server'
  },
  
  // UI Configuration
  ui: {
    ssl: false,
    host: 'localhost',
    port: 4000,
    nameSpace: '/'
  },
  
  // Cache Configuration
  cache: {
    msToLive: {
      default: 15 * 60 * 1000, // 15 minutes
      browse: 5 * 60 * 1000,   // 5 minutes for browse pages
      search: 5 * 60 * 1000    // 5 minutes for search results
    }
  },
  
  // Authentication Configuration
  auth: {
    ui: {
      timeUntilIdle: 15, // 15 minutes until considered idle
      idleGracePeriod: 5 // 5 minutes grace period
    },
    rest: {
      timeLeftBeforeTokenRefresh: 2 // 2 minutes before token refresh
    }
  },
  
  // Form Configuration
  form: {
    spellCheck: true,
    validatorMap: {
      required: 'required',
      regex: 'pattern'
    }
  },
  
  // Notification Configuration
  notifications: {
    rtl: false,
    position: ['top', 'right'],
    maxStack: 8,
    timeOut: 5000,
    clickToClose: true,
    animate: 'scale'
  },
  
  // Submission Configuration
  submission: {
    autosave: {
      enabled: true,
      timer: 0 // Autosave immediately on change
    },
    icons: {
      metadata: [
        { name: 'fa fa-tag', style: 'fas' },
        { name: 'fa fa-user', style: 'fas' },
        { name: 'fa fa-list-alt', style: 'far' },
        { name: 'fa fa-superpowers', style: 'fab' },
        { name: 'fa fa-user-circle', style: 'far' }
      ],
      authority: {
        confidence: [
          { name: 'fa fa-check', style: 'fas' },
          { name: 'fa fa-edit', style: 'far' }
        ]
      }
    }
  },
  
  // Bundle Configuration
  bundle: {
    standardBundles: ['ORIGINAL', 'THUMBNAIL', 'TEXT', 'SWORD']
  },
  
  // Browse Configuration
  browse: {
    pageSizeOptions: [5, 10, 20, 40, 60]
  },
  
  // Item Configuration
  item: {
    edit: {
      undoTimeout: 10000 // 10 seconds to undo changes
    }
  },
  
  // Media Viewer Configuration
  mediaViewer: {
    image: true,
    video: true
  },
  
  // Theme Configuration
  theme: {
    name: 'dspace'
  },
  
  // Universal/SSR Configuration
  universal: {
    preboot: true,
    async: true,
    time: false
  },
  
  // Language Configuration
  lang: [
    { code: 'en', label: 'English', active: true },
    { code: 'es', label: 'Español', active: false },
    { code: 'fr', label: 'Français', active: false },
    { code: 'de', label: 'Deutsch', active: false }
  ],
  
  // Default Language
  defaultLanguage: 'en',
  
  // Debug Configuration
  debug: false,
  
  // Google Analytics (optional)
  google: {
    analytics: ''
  },
  
  // Advanced Configuration
  advanced: {
    collectionSidebar: {
      enabled: true
    },
    communityList: {
      showLogos: true,
      showStats: true
    }
  }
};
