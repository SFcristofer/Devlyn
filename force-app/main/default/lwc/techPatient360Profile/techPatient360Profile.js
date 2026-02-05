import { LightningElement, api, track, wire } from 'lwc';
import getProfileInfo from '@salesforce/apex/TechProfile360Controller.getProfileInfo';
import getCustomerMetrics from '@salesforce/apex/TechProfile360Controller.getCustomerMetrics';

export default class TechPatient360Profile extends LightningElement {
    @api recordId;
    unifiedId;
    
    // Datos del Paciente (ahora dinámicos)
    @track patientData = {
        firstName: '',
        lastName: '',
        age: 0,
        gender: '',
        zipCode: '',
        email: '',
        phone: '',
        idPos: '',
        totalSales: 0,
        orderCount: 0,
        avgTicket: 0,
        daysSinceLastPurchase: 0,
        lastBranch: '',
        lastCategory: '',
        retailTotal: 0,
        retailCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
        ecommerceTotal: 0,
        ecommerceCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
        medicalHistory: [],
        medicalNotes: '',
        familyRelations: []
    };

    @wire(getProfileInfo, { recordId: '$recordId' })
    wiredProfile({ error, data }) {
        if (data) {
            console.log('Profile Data:', data);
            this.unifiedId = data.ssot__Id__c;
            this.processProfileData(data);
        } else if (error) {
            console.error('Error fetching profile:', error);
        }
    }

    @wire(getCustomerMetrics, { unifiedId: '$unifiedId' })
    wiredMetrics({ error, data }) {
        if (data) {
            console.log('Metrics Data:', data);
            this.patientData = {
                ...this.patientData,
                totalSales: data.totalSales || 0,
                orderCount: data.orderCount || 0,
                avgTicket: data.avgTicket || 0,
                daysSinceLastPurchase: data.daysSinceLastPurchase || 0
            };
        } else if (error) {
            console.error('Error fetching metrics:', error);
        }
    }

    processProfileData(data) {
        // Cálculo de edad
        let age = 0;
        if (data.FECHA_NACIMIENTO_dt__c) {
            const birthDate = new Date(data.FECHA_NACIMIENTO_dt__c);
            const today = new Date();
            age = today.getFullYear() - birthDate.getFullYear();
            const m = today.getMonth() - birthDate.getMonth();
            if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                age--;
            }
        }

        // Mapeo de datos dinámicos (Paso 1: Perfil básico)
        this.patientData = {
            ...this.patientData, // Mantenemos los placeholders para lo que aún no conectamos
            firstName: data.ssot__FirstName__c || '',
            lastName: `${data.Apellido_Paterno__c || ''} ${data.Apellido_Materno__c || ''}`.trim() || data.ssot__LastName__c,
            age: age,
            gender: data.ssot__GenderId__c || 'N/A',
            zipCode: data.CODIGO_POSTAL__c || 'N/A',
            email: data.Email__c || 'N/A',
            idPos: data.Id_POS__c || 'N/A'
        };
    }
    
    // Control de Tabs
    @track activeTab = 'expediente';
    
    // Diagnósticos
    lastDiagnosisDate = '26 Marzo 2025';
    diagnoses = [
        'Astigmatismo',
        'Experiencia LC',
        'Hipermetropía',
        'Miopía',
        'No presenta error',
        'Presbicia'
    ];
    
    // Último Examen
    lastExamDate = '26 Marzo 2025';
    
    // Órdenes
    @track orders = [
        {
            ordenId: 'AKAV095695',
            total: 6228.62,
            fechaCompra: '20 Julio 2025',
            pedidoId: '26416668',
            sucursal: 'MEGA COYOACAN(A844)',
            cotizacion: '754466',
            status: 'Entregado',
            isExpanded: false,
            productos: [
                {
                    nombre: 'VISION SENCILLA BLANCO BLUE LIGHT',
                    sku: '4300SVNDBLU1',
                    cantidad: 1,
                    descuento: 472.35,
                    descuentoCodigo: '8010',
                    precioTotal: 1994.65
                },
                {
                    nombre: 'VISION SENCILLA BLANCO BLUE LIGHT',
                    sku: '4300SVNDBLU1',
                    cantidad: 1,
                    descuento: 472.35,
                    descuentoCodigo: '8010',
                    precioTotal: 1994.65
                },
                {
                    nombre: 'TOMMY HILFIGER TH 1785',
                    sku: '0670117851GZ58',
                    cantidad: 1,
                    precioTotal: 2239.30
                }
            ]
        },
        {
            ordenId: 'BAJV041155',
            total: 3000.00,
            fechaCompra: '20 Febrero 2025',
            status: 'Completado',
            isExpanded: false,
            productos: []
        },
        {
            ordenId: 'AOMV081324',
            total: 3000.00,
            fechaCompra: '20 Febrero 2025',
            status: 'Completado',
            isExpanded: false,
            productos: []
        }
    ];
    
    // Citas
    appointments = [
        {
            citaId: '509490',
            tipo: 'Examen de la vista',
            status: 'Completada',
            sucursal: 'MEGA COYOACAN(A844)',
            inicio: '29 Agosto 2025, 06:00 pm',
            fin: '29 Agosto 2025, 06:45 pm',
            creada: '28 Agosto 11:53 pm'
        }
    ];
    
    // Cotizaciones
    @track quotes = [
        {
            presupuestoId: '754466',
            fecha: '23 Noviembre 2022',
            fechaExpiracion: '30 Noviembre 2022',
            total: 4501.90,
            isExpanded: false,
            productos: [
                {
                    nombre: 'VISION SENCILLA BLANCO BLUE LIGHT',
                    sku: '4300SVNDBLU1',
                    cantidad: 2,
                    precioTotal: 1698.00
                },
                {
                    nombre: 'ANTIRREFLEJANTE HD',
                    sku: 'SHC',
                    cantidad: 2,
                    precioTotal: 1600.00
                },
                {
                    nombre: 'ESTUCHE NUEVA IMAGEN C/PAÑO/SP',
                    sku: '600302700600',
                    cantidad: 1,
                    precioTotal: 159.00
                },
                {
                    nombre: 'PROTECCION PLUS',
                    sku: '600500800203',
                    cantidad: 1,
                    precioTotal: 244.90
                },
                {
                    nombre: 'XIK? CASUAL B XK2005',
                    sku: '0315320052Z249',
                    cantidad: 1,
                    precioTotal: 800.00
                }
            ]
        }
    ];
    
    // Suscripciones
    @track subscriptions = [
        {
            nombre: '1 - MONTHLY',
            status: 'Active',
            fechaCreacion: '15 Julio 2025',
            frecuencia: 'Cada mes',
            ciclosCompletados: 5,
            ultimaCompra: '15 Diciembre 2025',
            proximaCompra: '15 Enero 2026',
            isExpanded: false,
            productos: [
                {
                    sku: '24711',
                    cantidad: 2,
                    adjuntos: [
                        {
                            numero: 1,
                            nombre: 'Precision 1 Ast diferente graduacion',
                            cilindro: -0.75,
                            eje: 180,
                            poder: -3.00
                        },
                        {
                            numero: 2,
                            nombre: 'Precision 1 Ast misma graduacion',
                            cilindro: -1.25,
                            eje: 180,
                            poder: -3.00
                        }
                    ]
                }
            ]
        }
    ];
    
    // Einstein Scores
    einsteinScore = {
        propensidadClick: 'Poco Probable',
        propensidadAbrir: 'Muy Probable'
    };
    
    // RFM Scores
    rfmRetail = {
        solares: '322',
        lentesContacto: 'NA',
        oftalmicos: '122',
        solaresLabel: 'Potencial',
        lentesContactoLabel: 'No Aplica',
        oftalmicosLabel: 'Rezagado'
    };
    
    rfmEcommerce = {
        solares: 'NA',
        lentesContacto: '234',
        oftalmicos: 'NA',
        solaresLabel: 'No Aplica',
        lentesContactoLabel: 'Ocasión',
        oftalmicosLabel: 'No Aplica'
    };
    
    // Campañas de Marketing
    @track campaigns = [
        {
            nombre: 'Ventas Buen Fin 2025',
            journey: 'Buen Fin 2025 SOL Nivel 1 2 3 4',
            isExpanded: false,
            envios: [
                {
                    uniqueKey: 'envio-email-1',
                    tipo: 'Email',
                    icono: 'utility:email',
                    asunto: '🛍️Comenzó el Buen Fin con hasta 70% OFF en Amazones...',
                    fechaEnvio: '14 Noviembre 2025',
                    desde: 'Ópticas Devlyn (promo@news.devlyn.com.mx)',
                    asuntoCompleto: '🛍️Comenzó el Buen Fin con hasta 70% OFF en Amazones + 40% Graduación + hasta 18MSI! ❤️‍🔥',
                    isExpanded: false,
                    eventos: [
                        {
                            tipo: 'Enviado',
                            fechaHora: '14/11/2025, 06:00 a.m.'
                        },
                        {
                            tipo: 'Abierto',
                            fechaHora: '14/11/2025, 06:21 a.m.'
                        },
                        {
                            tipo: 'Click',
                            fechaHora: '14/11/2025, 06:21 a.m.'
                        },
                        {
                            tipo: 'Opt Out',
                            fechaHora: '14/11/2025, 06:22 a.m.'
                        },
                        {
                            tipo: 'Complaint',
                            fechaHora: '14/11/2025, 06:22 a.m.'
                        }
                    ]
                },
                {
                    uniqueKey: 'envio-whatsapp-1',
                    tipo: 'WhatsApp',
                    icono: 'utility:world',
                    asunto: '🛍️Ya empezó el Buen Fin con hasta 70% OFF en Lentes...',
                    fechaEnvio: '14 Noviembre 2025',
                    isExpanded: false,
                    eventos: []
                }
            ]
        }
    ];
    
    // ==================== LIFECYCLE HOOKS ====================
    
    connectedCallback() {
        console.log('Component loaded with hardcoded data');
        this.updateComputedProperties();
        this.calculateTotalItems();
    }
    
    // ==================== COMPUTED PROPERTIES UPDATER ====================
    
    updateComputedProperties() {
        this.orders = this.orders.map(orden => ({
            ...orden,
            chevronIcon: orden.isExpanded ? 'utility:chevronup' : 'utility:chevrondown',
            chevronClass: orden.isExpanded ? 'toggle-icon rotate' : 'toggle-icon',
            detailsClass: orden.isExpanded ? 'orden-details expanded' : 'orden-details collapsed'
        }));
        
        this.quotes = this.quotes.map(quote => ({
            ...quote,
            chevronIcon: quote.isExpanded ? 'utility:chevronup' : 'utility:chevrondown',
            chevronClass: quote.isExpanded ? 'toggle-icon rotate' : 'toggle-icon',
            productosClass: quote.isExpanded ? 'cotizacion-productos expanded' : 'cotizacion-productos collapsed'
        }));
        
        this.subscriptions = this.subscriptions.map(sub => ({
            ...sub,
            chevronIcon: sub.isExpanded ? 'utility:chevronup' : 'utility:chevrondown',
            chevronClass: sub.isExpanded ? 'toggle-icon rotate' : 'toggle-icon',
            detailsClass: sub.isExpanded ? 'suscripcion-details expanded' : 'suscripcion-details collapsed'
        }));
        
        this.campaigns = this.campaigns.map(campana => ({
            ...campana,
            chevronIcon: campana.isExpanded ? 'utility:chevronup' : 'utility:chevrondown',
            chevronClass: campana.isExpanded ? 'toggle-icon rotate' : 'toggle-icon',
            detailsClass: campana.isExpanded ? 'campana-details expanded' : 'campana-details collapsed',
            envios: campana.envios.map(envio => ({
                ...envio,
                chevronIcon: envio.isExpanded ? 'utility:chevronup' : 'utility:chevrondown',
                chevronClass: envio.isExpanded ? 'toggle-icon rotate' : 'toggle-icon',
                detailsClass: envio.isExpanded ? 'envio-details expanded' : 'envio-details collapsed'
            }))
        }));
    }
    
    // ==================== PAGINACIÓN DINÁMICA ====================
    
    calculateTotalItems() {
        switch(this.activeTab) {
            case 'ordenes':
                this.totalItems = this.orders.length;
                break;
            case 'citas':
                this.totalItems = this.appointments.length;
                break;
            case 'cotizaciones':
                this.totalItems = this.quotes.length;
                break;
            case 'suscripciones':
                this.totalItems = this.subscriptions.length;
                break;
            case 'enviosMarketing':
                this.totalItems = this.campaigns.length;
                break;
            default:
                this.totalItems = 0;
        }
    }
    
    get showPagination() {
        // Solo mostrar paginación si hay más items que el límite por página
        return this.totalItems > this.itemsPerPage;
    }
    
    get totalPages() {
        return Math.ceil(this.totalItems / this.itemsPerPage);
    }
    
    get isFirstPage() {
        return this.currentPage === 1;
    }
    
    get isLastPage() {
        return this.currentPage === this.totalPages;
    }
    
    get paginationPages() {
        const pages = [];
        const total = this.totalPages;
        const current = this.currentPage;
        
        // Mostrar máximo 5 páginas
        let startPage = Math.max(1, current - 2);
        let endPage = Math.min(total, current + 2);
        
        // Ajustar si estamos cerca del inicio o fin
        if (current <= 3) {
            endPage = Math.min(5, total);
        }
        if (current >= total - 2) {
            startPage = Math.max(1, total - 4);
        }
        
        for (let i = startPage; i <= endPage; i++) {
            pages.push({
                number: i,
                className: i === current ? 'pagination-number active' : 'pagination-number'
            });
        }
        
        return pages;
    }
    
    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }
    
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }
    
    handlePageChange(event) {
        this.currentPage = parseInt(event.currentTarget.dataset.page, 10);
    }
    
    // ==================== TAB HANDLERS ====================
    
    handleTabExpediente() {
        this.activeTab = 'expediente';
        this.currentPage = 1;
        this.calculateTotalItems();
    }
    
    handleTabOrdenes() {
        this.activeTab = 'ordenes';
        this.currentPage = 1;
        this.calculateTotalItems();
    }
    
    handleTabCitas() {
        this.activeTab = 'citas';
        this.currentPage = 1;
        this.calculateTotalItems();
    }
    
    handleTabCotizaciones() {
        this.activeTab = 'cotizaciones';
        this.currentPage = 1;
        this.calculateTotalItems();
    }
    
    handleTabSuscripciones() {
        this.activeTab = 'suscripciones';
        this.currentPage = 1;
        this.calculateTotalItems();
    }
    
    handleTabEnviosMarketing() {
        this.activeTab = 'enviosMarketing';
        this.currentPage = 1;
        this.calculateTotalItems();
    }
    
    // ==================== TAB CLASS GETTERS ====================
    
    get tabExpedienteClass() {
        return this.activeTab === 'expediente' ? 'tab-button active' : 'tab-button';
    }
    
    get tabOrdenesClass() {
        return this.activeTab === 'ordenes' ? 'tab-button active' : 'tab-button';
    }
    
    get tabCitasClass() {
        return this.activeTab === 'citas' ? 'tab-button active' : 'tab-button';
    }
    
    get tabCotizacionesClass() {
        return this.activeTab === 'cotizaciones' ? 'tab-button active' : 'tab-button';
    }
    
    get tabSuscripcionesClass() {
        return this.activeTab === 'suscripciones' ? 'tab-button active' : 'tab-button';
    }
    
    get tabEnviosMarketingClass() {
        return this.activeTab === 'enviosMarketing' ? 'tab-button active' : 'tab-button';
    }
    
    // ==================== TAB VISIBILITY GETTERS ====================
    
    get isTabExpediente() {
        return this.activeTab === 'expediente';
    }
    
    get isTabOrdenes() {
        return this.activeTab === 'ordenes';
    }
    
    get isTabCitas() {
        return this.activeTab === 'citas';
    }
    
    get isTabCotizaciones() {
        return this.activeTab === 'cotizaciones';
    }
    
    get isTabSuscripciones() {
        return this.activeTab === 'suscripciones';
    }
    
    get isTabEnviosMarketing() {
        return this.activeTab === 'enviosMarketing';
    }
    
    // ==================== TOGGLE HANDLERS - EXPEDIENTE MÉDICO ====================
    
    toggleAntecedentes() {
        this.isAntecedenteOpen = !this.isAntecedenteOpen;
    }
    
    toggleDriverVisual() {
        this.isDriverVisualOpen = !this.isDriverVisualOpen;
    }
    
    togglePreguntasPoder() {
        this.isPreguntasPoderOpen = !this.isPreguntasPoderOpen;
    }
    
    toggleGraduaciones() {
        this.isGraduacionesOpen = !this.isGraduacionesOpen;
    }
    
    toggleFamilia() {
        this.isFamiliaOpen = !this.isFamiliaOpen;
    }
    
    // ==================== ICON GETTERS FOR EXPANDABLE SECTIONS ====================
    
    get antecedenteIcon() {
        return this.isAntecedenteOpen ? 'utility:chevronup' : 'utility:chevrondown';
    }
    
    get antecedenteIconClass() {
        return this.isAntecedenteOpen ? 'toggle-icon rotate' : 'toggle-icon';
    }
    
    get antecedenteContentClass() {
        return this.isAntecedenteOpen ? 'capsule-content expanded' : 'capsule-content collapsed';
    }
    
    get driverVisualIcon() {
        return this.isDriverVisualOpen ? 'utility:chevronup' : 'utility:chevrondown';
    }
    
    get driverVisualIconClass() {
        return this.isDriverVisualOpen ? 'toggle-icon rotate' : 'toggle-icon';
    }
    
    get driverVisualContentClass() {
        return this.isDriverVisualOpen ? 'capsule-content expanded' : 'capsule-content collapsed';
    }
    
    get preguntasPoderIcon() {
        return this.isPreguntasPoderOpen ? 'utility:chevronup' : 'utility:chevrondown';
    }
    
    get preguntasPoderIconClass() {
        return this.isPreguntasPoderOpen ? 'toggle-icon rotate' : 'toggle-icon';
    }
    
    get preguntasPoderContentClass() {
        return this.isPreguntasPoderOpen ? 'capsule-content expanded' : 'capsule-content collapsed';
    }
    
    get graduacionesIcon() {
        return this.isGraduacionesOpen ? 'utility:chevronup' : 'utility:chevrondown';
    }
    
    get graduacionesIconClass() {
        return this.isGraduacionesOpen ? 'toggle-icon rotate' : 'toggle-icon';
    }
    
    get graduacionesContentClass() {
        return this.isGraduacionesOpen ? 'capsule-content expanded' : 'capsule-content collapsed';
    }
    
    get familiaIcon() {
        return this.isFamiliaOpen ? 'utility:chevronup' : 'utility:chevrondown';
    }
    
    get familiaIconClass() {
        return this.isFamiliaOpen ? 'toggle-icon rotate' : 'toggle-icon';
    }
    
    get familiaContentClass() {
        return this.isFamiliaOpen ? 'capsule-content expanded' : 'capsule-content collapsed';
    }
    
    // ==================== TOGGLE HANDLERS - ORDENES ====================
    
    toggleOrden(event) {
        const ordenId = event.currentTarget.dataset.id;
        this.orders = this.orders.map(orden => {
            if (orden.ordenId === ordenId) {
                const newExpandedState = !orden.isExpanded;
                return { 
                    ...orden, 
                    isExpanded: newExpandedState,
                    chevronIcon: newExpandedState ? 'utility:chevronup' : 'utility:chevrondown',
                    chevronClass: newExpandedState ? 'toggle-icon rotate' : 'toggle-icon',
                    detailsClass: newExpandedState ? 'orden-details expanded' : 'orden-details collapsed'
                };
            }
            return orden;
        });
    }
    
    // ==================== TOGGLE HANDLERS - COTIZACIONES ====================
    
    toggleCotizacion(event) {
        const quoteId = event.currentTarget.dataset.id;
        this.quotes = this.quotes.map(quote => {
            if (quote.presupuestoId === quoteId) {
                const newExpandedState = !quote.isExpanded;
                return { 
                    ...quote, 
                    isExpanded: newExpandedState,
                    chevronIcon: newExpandedState ? 'utility:chevronup' : 'utility:chevrondown',
                    chevronClass: newExpandedState ? 'toggle-icon rotate' : 'toggle-icon',
                    productosClass: newExpandedState ? 'cotizacion-productos expanded' : 'cotizacion-productos collapsed'
                };
            }
            return quote;
        });
    }
    
    // ==================== TOGGLE HANDLERS - SUSCRIPCIONES ====================
    
    toggleSuscripcion(event) {
        const subId = event.currentTarget.dataset.id;
        this.subscriptions = this.subscriptions.map(sub => {
            if (sub.nombre === subId) {
                const newExpandedState = !sub.isExpanded;
                return { 
                    ...sub, 
                    isExpanded: newExpandedState,
                    chevronIcon: newExpandedState ? 'utility:chevronup' : 'utility:chevrondown',
                    chevronClass: newExpandedState ? 'toggle-icon rotate' : 'toggle-icon',
                    detailsClass: newExpandedState ? 'suscripcion-details expanded' : 'suscripcion-details collapsed'
                };
            }
            return sub;
        });
    }
    
    // ==================== TOGGLE HANDLERS - CAMPAÑAS ====================
    
    toggleCampana(event) {
        const campanaId = event.currentTarget.dataset.id;
        this.campaigns = this.campaigns.map(camp => {
            if (camp.nombre === campanaId) {
                const newExpandedState = !camp.isExpanded;
                return { 
                    ...camp, 
                    isExpanded: newExpandedState,
                    chevronIcon: newExpandedState ? 'utility:chevronup' : 'utility:chevrondown',
                    chevronClass: newExpandedState ? 'toggle-icon rotate' : 'toggle-icon',
                    detailsClass: newExpandedState ? 'campana-details expanded' : 'campana-details collapsed',
                    envios: camp.envios
                };
            }
            return camp;
        });
    }
    
    toggleEnvio(event) {
        const envioIndex = parseInt(event.currentTarget.dataset.index, 10);
        const campanaIndex = parseInt(event.currentTarget.dataset.campana, 10);
        
        this.campaigns = this.campaigns.map((camp, cIdx) => {
            if (cIdx === campanaIndex) {
                const updatedEnvios = camp.envios.map((envio, eIdx) => {
                    if (eIdx === envioIndex) {
                        const newExpandedState = !envio.isExpanded;
                        return { 
                            ...envio, 
                            isExpanded: newExpandedState,
                            chevronIcon: newExpandedState ? 'utility:chevronup' : 'utility:chevrondown',
                            chevronClass: newExpandedState ? 'toggle-icon rotate' : 'toggle-icon',
                            detailsClass: newExpandedState ? 'envio-details expanded' : 'envio-details collapsed'
                        };
                    }
                    return envio;
                });
                return { ...camp, envios: updatedEnvios };
            }
            return camp;
        });
    }
}