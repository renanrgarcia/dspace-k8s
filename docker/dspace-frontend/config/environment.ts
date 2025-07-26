// DSpace Frontend Development Environment Configuration
// Based on DSpace 9.x documentation

export const environment = {
  production: false,
  
  // REST API Configuration - Points to DSpace Backend
  rest: {
    ssl: false,
    host: 'localhost', // Use localhost for development
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
  
  // Cache Configuration (shorter cache times for development)
  cache: {
    msToLive: {
      default: 5 * 60 * 1000,  // 5 minutes
      browse: 2 * 60 * 1000,   // 2 minutes for browse pages
      search: 2 * 60 * 1000    // 2 minutes for search results
    }
  },
  
  // Authentication Configuration
  auth: {
    ui: {
      timeUntilIdle: 30, // 30 minutes until considered idle (longer for dev)
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
    timeOut: 10000, // Longer timeout for development
    clickToClose: true,
    animate: 'scale'
  },
  
  // Submission Configuration
  submission: {
    autosave: {
      enabled: true,
      timer: 5000 // 5 seconds autosave for development
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
    preboot: false, // Disable preboot in development
    async: true,
    time: true // Enable timing logs in development
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
  
  // Debug Configuration (enabled for development)
  debug: true,
  
  // Google Analytics (disabled for development)
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
