"use strict";
// Future versions of Hyper may add additional config options,
// which will not automatically be merged into this file.
// See https://hyper.is#cfg for all currently supported options.
module.exports = {
    config: {
        // choose either `'stable'` for receiving highly polished,
        // or `'canary'` for less polished but more frequent updates
        updateChannel: 'stable',
        
        // default font size in pixels for all tabs
        fontSize: 14, // Aumenté ligeramente para mejor legibilidad
        
        // font family with optional fallbacks
        fontFamily: '"MesloLGS NF", "FiraCode Nerd Font", "JetBrains Mono", "DejaVu Sans Mono", Consolas, "Lucida Console", monospace',
        
        // default font weight: 'normal' or 'bold'
        fontWeight: 'normal',
        // font weight for bold characters: 'normal' or 'bold'
        fontWeightBold: 'bold',
        
        // line height as a relative unit
        lineHeight: 1.2, // Mejoré el espaciado entre líneas
        
        // letter spacing as a relative unit
        letterSpacing: 0,
        
        // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
        cursorColor: 'rgba(0, 255, 136, 0.8)', // Verde más visible
        
        // terminal text color under BLOCK cursor
        cursorAccentColor: '#000',
        
        // `'BEAM'` for |, `'UNDERLINE'` for _, `'BLOCK'` for █
        cursorShape: 'BLOCK',
        
        // set to `true` (without backticks and without quotes) for blinking cursor
        cursorBlink: true, // Habilitado para mejor visibilidad
        
        // color of the text
        foregroundColor: '#E0E6ED', // Color de texto más suave
        
        // terminal background color
        backgroundColor: '#1E1E2E', // Fondo más moderno
        
        // terminal selection color
        selectionColor: 'rgba(116, 199, 236, 0.3)',
        
        // border color (window, tabs)
        borderColor: '#45475A', // Borde más visible
        
        // custom CSS to embed in the main window
        css: `
            /* Mejorar la visibilidad de las pestañas */
            .tab_tab {
                border: 1px solid #45475A !important;
                border-bottom: none !important;
                margin-right: 2px;
            }
            
            /* Pestaña activa con mejor contraste */
            .tab_active {
                background: linear-gradient(45deg, #74C7EC, #89B4FA) !important;
                color: #1E1E2E !important;
                font-weight: bold !important;
                border-color: #74C7EC !important;
                box-shadow: 0 0 10px rgba(116, 199, 236, 0.5) !important;
            }
            
            /* Pestañas inactivas con hover effect */
            .tab_tab:not(.tab_active) {
                background: #313244 !important;
                color: #CDD6F4 !important;
                transition: all 0.3s ease;
            }
            
            .tab_tab:not(.tab_active):hover {
                background: #45475A !important;
                color: #F5E0DC !important;
                transform: translateY(-1px);
            }
            
            /* Mejorar el texto de las pestañas */
            .tab_text {
                padding: 0 12px !important;
            }
            
            /* Barra de pestañas */
            .tabs_nav {
                background: #1E1E2E !important;
                border-bottom: 2px solid #45475A !important;
            }
            
            /* Terminal con esquinas redondeadas */
            .term_term {
                border-radius: 8px !important;
            }
            
            /* Scrollbar personalizada */
            .term_term::-webkit-scrollbar {
                width: 8px;
            }
            
            .term_term::-webkit-scrollbar-track {
                background: #1E1E2E;
            }
            
            .term_term::-webkit-scrollbar-thumb {
                background: #45475A;
                border-radius: 4px;
            }
            
            .term_term::-webkit-scrollbar-thumb:hover {
                background: #74C7EC;
            }
        `,
        
        // custom CSS to embed in the terminal window
        termCSS: `
            x-screen a {
                color: #74C7EC !important;
                text-decoration: underline;
            }
            
            x-screen a:hover {
                color: #89B4FA !important;
            }
        `,
        
        // set custom startup directory (must be an absolute path)
        workingDirectory: '',
        
        // if you're using a Linux setup which show native menus, set to false
        showHamburgerMenu: '',
        
        // set to `false` if you want to hide window controls
        showWindowControls: '',
        
        // custom padding (CSS format, i.e.: `top right bottom left`)
        padding: '16px 20px', // Más padding para mejor apariencia
        
        // Colores mejorados con esquema Catppuccin
        colors: {
            black: '#1E1E2E',
            red: '#F38BA8',
            green: '#A6E3A1',
            yellow: '#F9E2AF',
            blue: '#89B4FA',
            magenta: '#CBA6F7',
            cyan: '#94E2D5',
            white: '#CDD6F4',
            lightBlack: '#45475A',
            lightRed: '#F38BA8',
            lightGreen: '#A6E3A1',
            lightYellow: '#F9E2AF',
            lightBlue: '#89B4FA',
            lightMagenta: '#CBA6F7',
            lightCyan: '#94E2D5',
            lightWhite: '#F5E0DC',
            // Colores adicionales
            limeGreen: '#A6E3A1',
            lightCoral: '#F38BA8',
        },
        
        shell: '',
        shellArgs: ['--login'],
        env: {},
        
        bell: 'SOUND',
        copyOnSelect: false,
        defaultSSHApp: true,
        quickEdit: false,
        macOptionSelectionMode: 'vertical',
        webGLRenderer: true,
        webLinksActivationKey: '',
        disableLigatures: false, // Habilitadas para mejor tipografía
        disableAutoUpdates: false,
        screenReaderMode: false,
        preserveCWD: true,
    },
    
    // Lista mejorada de plugins
    plugins: [
        "hyper-broadcast",
        "hyper-tab-icons",
        "hyper-highlight-active-pane",
        "hyper-active-tab",
        "hyper-statusline", // Añade una barra de estado
        "hyper-search", // Búsqueda en terminal
        "hyperterm-visor", // Terminal flotante estilo Quake
    ],
    
    localPlugins: [],
    
    keymaps: {
        // Atajos de teclado útiles
        'tab:new': 'ctrl+shift+t',
        'tab:next': 'ctrl+shift+right',
        'tab:prev': 'ctrl+shift+left',
        'pane:splitVertical': 'ctrl+shift+d',
        'pane:splitHorizontal': 'ctrl+shift+shift+d',
        'window:devtools': 'f12',
    },
};