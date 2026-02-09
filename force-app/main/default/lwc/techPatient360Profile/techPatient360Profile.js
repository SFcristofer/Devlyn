import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getProfileInfo from '@salesforce/apex/TechProfile360Controller.getProfileInfo';
import getProfileByUnifiedId from '@salesforce/apex/TechProfile360Controller.getProfileByUnifiedId';
import getCustomerMetrics from '@salesforce/apex/TechProfile360Controller.getCustomerMetrics';
import getMedicalInfo from '@salesforce/apex/TechProfile360Controller.getMedicalInfo';
import getOrders from '@salesforce/apex/TechProfile360Controller.getOrders';
import getAppointments from '@salesforce/apex/TechProfile360Controller.getAppointments';
import getQuotes from '@salesforce/apex/TechProfile360Controller.getQuotes';
import getSubscriptions from '@salesforce/apex/TechProfile360Controller.getSubscriptions';
import getMarketingScores from '@salesforce/apex/TechProfile360Controller.getMarketingScores';
import getMarketingHistory from '@salesforce/apex/TechProfile360Controller.getMarketingHistory';

export default class TechPatient360Profile extends LightningElement {
    _recordId;
    @api 
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        if (value !== this._recordId) {
            console.log('Record ID changed, resetting data:', value);
            this._recordId = value;
            this.resetState();
        }
    }

    resetState() {
        this.isLoading = true;
        this.unifiedId = null;
        this.orders = [];
        this.appointments = [];
        this.quotes = [];
        this.subscriptions = [];
        this.campaigns = [];
        this.patientData = {
            firstName: 'Cargando...', lastName: '', age: 0, gender: '', zipCode: '', email: '', phone: '', idPos: '',
            totalSales: 0, orderCount: 0, avgTicket: 0, daysSinceLastPurchase: 0,
            lastBranch: 'N/A', lastCategory: 'N/A',
            retailTotal: 0, retailCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
            ecommerceTotal: 0, ecommerceCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
            medicalHistory: [], medicalNotes: '', familyRelations: [], visualDriver: {}, powerQuestions: {}, graduations: []
        };
        this.diagnoses = [];
        this.lastDiagnosisDate = 'N/A';
        this.lastExamDate = 'N/A';
    }

    @track isLoading = false;
    @api isUnifiedId = false; 
    unifiedId;

    // Captura de resultados de wire para refresco manual
    _wiredMedical;
    _wiredMetrics;
    _wiredOrders;
    _wiredAppointments;
    
    // Listas de Datos
    @track orders = [];
    @track appointments = [];
    @track quotes = [];
    @track subscriptions = [];
    @track campaigns = [];

    // Datos del Paciente (Inicialización obligatoria para evitar errores de UI)
    @track patientData = {
        firstName: '', lastName: '', age: 0, gender: '', zipCode: '', email: '', phone: '', idPos: '',
        totalSales: 0, orderCount: 0, avgTicket: 0, daysSinceLastPurchase: 0,
        lastBranch: 'N/A', lastCategory: 'N/A',
        retailTotal: 0, retailCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
        ecommerceTotal: 0, ecommerceCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
        medicalHistory: [], medicalNotes: '', familyRelations: [], visualDriver: {}, powerQuestions: {}
    };

    // Marketing y Scores
    @track einsteinScore = { propensidadClick: 'N/A', propensidadAbrir: 'N/A' };
    @track rfmRetail = { solares: 'N/A', lentesContacto: 'N/A', oftalmicos: 'N/A', solaresLabel: 'N/A', lentesContactoLabel: 'N/A', oftalmicosLabel: 'N/A' };
    @track rfmEcommerce = { solares: 'N/A', lentesContacto: 'N/A', oftalmicos: 'N/A', solaresLabel: 'N/A', lentesContactoLabel: 'N/A', oftalmicosLabel: 'N/A' };

    @wire(getMarketingHistory, { unifiedId: '$unifiedId' })
    wiredMarketingHistory({ error, data }) {
        if (data) {
            console.log('Marketing History Received:', data);
            this.campaigns = data.map(camp => ({
                ...camp,
                isExpanded: false,
                chevronIcon: 'utility:chevrondown',
                chevronClass: 'toggle-icon',
                detailsClass: 'campana-details collapsed',
                envios: camp.envios.map(envio => ({
                    ...envio,
                    fechaEnvio: envio.fechaEnvio ? new Date(envio.fechaEnvio).toLocaleDateString() : 'N/A',
                    isExpanded: false,
                    chevronIcon: 'utility:chevrondown',
                    chevronClass: 'toggle-icon',
                    detailsClass: 'envio-details collapsed'
                }))
            }));
        }
    }

    @wire(getSubscriptions, { unifiedId: '$unifiedId' })
    wiredSubscriptions({ error, data }) {
        if (data) {
            console.log('Subscriptions Received:', data);
            this.subscriptions = data.map(sub => ({
                ...sub,
                fechaCreacion: sub.fechaCreacion ? new Date(sub.fechaCreacion).toLocaleDateString() : 'N/A',
                proximaCompra: sub.proximaCompra ? new Date(sub.proximaCompra).toLocaleDateString() : 'N/A',
                isExpanded: false,
                chevronIcon: 'utility:chevrondown',
                chevronClass: 'toggle-icon',
                detailsClass: 'suscripcion-details collapsed'
            }));
        }
    }

    @wire(getMarketingScores, { unifiedId: '$unifiedId' })
    wiredMarketing({ error, data }) {
        if (data) {
            console.log('Marketing Scores Received:', data);
            if (data.einsteinScore) {
                this.einsteinScore = { ...data.einsteinScore };
            }
            if (data.rfmRetail) {
                this.rfmRetail = { ...this.rfmRetail, ...data.rfmRetail };
            }
            if (data.rfmEcommerce) {
                this.rfmEcommerce = { ...this.rfmEcommerce, ...data.rfmEcommerce };
            }
        }
    }

    @wire(getAppointments, { unifiedId: '$unifiedId' })
    wiredAppointments({ error, data }) {
        if (data) {
            console.log('Appointments Received:', data);
            this.appointments = data.map(cita => ({
                ...cita,
                inicio: cita.inicio ? new Date(cita.inicio).toLocaleString() : 'N/A',
                fin: cita.fin ? new Date(cita.fin).toLocaleString() : 'N/A'
            }));
        } else if (error) {
            console.error('Error fetching appointments:', error);
        }
    }

    @wire(getQuotes, { unifiedId: '$unifiedId' })
    wiredQuotes({ error, data }) {
        if (data) {
            this.quotes = data.map(quote => ({
                ...quote,
                isExpanded: false,
                chevronIcon: 'utility:chevrondown',
                chevronClass: 'toggle-icon',
                productosClass: 'cotizacion-productos collapsed'
            }));
        }
    }

    @wire(getOrders, { unifiedId: '$unifiedId' })
    wiredOrders(result) {
        this._wiredOrders = result;
        const { error, data } = result;
        if (data) {
            console.log('Real Orders Received:', data);
            this.orders = data.map(order => ({
                ...order,
                fechaCompra: order.fechaCompra ? new Date(order.fechaCompra).toLocaleDateString() : 'N/A',
                isExpanded: false,
                chevronIcon: 'utility:chevrondown',
                chevronClass: 'toggle-icon',
                detailsClass: 'orden-details collapsed'
            }));
            this.totalItems = this.orders.length;
        } else if (error) {
            console.error('Error fetching orders:', error);
        }
    }

    @wire(getMedicalInfo, { unifiedId: '$unifiedId' })
    wiredMedical(result) {
        this._wiredMedical = result;
        const { error, data } = result;
        if (data) {
            console.log('Medical Data Received:', data);
            this.processMedicalData(data);
        } else if (error) {
            console.error('Error fetching medical info:', error);
        }
    }

    processMedicalData(data) {
        // 1. Procesar Antecedentes
        if (data.antecedents) {
            const ant = data.antecedents;
            const history = [];
            if (ant.ARDOR_IRRITACION__c == '1' || ant.ARDOR_IRRITACION__c == true) history.push('Ardor/Irritación');
            if (ant.COMEZON__c == '1' || ant.COMEZON__c == true) history.push('Comezón');
            if (ant.DIABETES__c == '1' || ant.DIABETES__c == true) history.push('Diabetes');
            if (ant.HIPERTENSION__c == '1' || ant.HIPERTENSION__c == true) history.push('Hipertensión');
            if (ant.VISION_BORROSA__c == '1' || ant.VISION_BORROSA__c == true) history.push('Visión Borrosa');
            if (ant.INFECCION__c == '1' || ant.INFECCION__c == true) history.push('Infección');
            if (ant.LAGRIMEO__c == '1' || ant.LAGRIMEO__c == true) history.push('Lagrimeo');
            if (ant.LEGANA__c == '1' || ant.LEGANA__c == true) history.push('Legaña');
            if (ant.RESEQUEDAD_OCULAR__c == '1' || ant.RESEQUEDAD_OCULAR__c == true) history.push('Resequedad Ocular');
            
            this.patientData.medicalHistory = history;
            this.patientData.medicalNotes = ant.NOTAS__c || 'Sin notas adicionales';
        }

        // 2. Procesar Diagnóstico
        if (data.lastDiagnosis) {
            const diag = data.lastDiagnosis;
            const diagList = [];
            if (diag.ASTIGMATISMO__c == '1') diagList.push('Astigmatismo');
            if (diag.MIOPIA__c == '1') diagList.push('Miopía');
            if (diag.HIPERMETROPIA__c == '1') diagList.push('Hipermetropía');
            if (diag.PRESBICIA__c == '1') diagList.push('Presbicia');
            
            this.diagnoses = diagList.length > 0 ? diagList : ['No presenta error'];
            this.lastDiagnosisDate = diag.FECHA__c ? new Date(diag.FECHA__c).toLocaleDateString() : 'N/A';
            this.lastExamDate = this.lastDiagnosisDate; // Usamos la misma fecha por ahora
        }

        // 3. Driver Visual y Preguntas Poder
        this.patientData.visualDriver = data.visualDriver || {};
        this.patientData.powerQuestions = data.powerQuestions || {};

        // 4. Familia (Se poblará cuando se encuentre el DMO real)
        this.patientData.familyRelations = data.familyRelations || [];

        // 5. Graduaciones (Se poblará cuando se encuentre el DMO real)
        this.patientData.graduations = data.graduations || [];
    }

    // Caso 1: Viene de un registro de Salesforce (Account/Contact)
    @wire(getProfileInfo, { recordId: '$recordId' })
    wiredProfileFromLink({ error, data }) {
        if (!this.isUnifiedId) {
            if (data) {
                console.log('Profile Data from Link:', data);
                this.unifiedId = data.ssot__Id__c;
                this.processProfileData(data);
                this.isLoading = false;
            } else if (error) {
                console.error('Error fetching profile from link:', error);
                this.isLoading = false;
            }
        }
    }

    // Caso 2: Viene directo de la búsqueda (UnifiedId)
    @wire(getProfileByUnifiedId, { unifiedId: '$recordId' })
    wiredProfileDirect({ error, data }) {
        if (this.isUnifiedId) {
            if (data) {
                console.log('Profile Data Direct:', data);
                this.unifiedId = data.ssot__Id__c;
                this.processProfileData(data);
                this.isLoading = false;
            } else if (error) {
                console.error('Error fetching profile direct:', error);
                this.isLoading = false;
            }
        }
    }

    @wire(getCustomerMetrics, { unifiedId: '$unifiedId' })
    wiredMetrics(result) {
        this._wiredMetrics = result;
        const { error, data } = result;
        if (data) {
            console.log('Metrics Data Received:', data);
            this.patientData = {
                ...this.patientData,
                totalSales: data.totalSales || 0,
                orderCount: data.orderCount || 0,
                avgTicket: data.avgTicket || 0,
                daysSinceLastPurchase: data.daysSinceLastPurchase || 0,
                lastBranch: data.lastBranch || 'N/A',
                lastCategory: data.lastCategory || 'N/A',
                // Nuevos campos para el resumen de compras
                retailTotal: data.retailTotal || 0,
                retailCategories: data.retailCategories || { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
                ecommerceTotal: data.ecommerceTotal || 0,
                ecommerceCategories: data.ecommerceCategories || { Solares: 0, LentesContacto: 0, Oftalmicos: 0 }
            };
        } else if (error) {
            console.error('Error fetching metrics:', error);
        }
    }

    async handleRefresh() {
        this.isLoading = true;
        try {
            await Promise.all([
                refreshApex(this._wiredMedical),
                refreshApex(this._wiredMetrics),
                refreshApex(this._wiredOrders),
                refreshApex(this._wiredAppointments)
            ]);
            console.log('Refresh exitoso');
        } catch (error) {
            console.error('Error al refrescar:', error);
        } finally {
            this.isLoading = false;
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
    
    // Suscripciones
    @track subscriptions = [];
    
    // Einstein Scores
    einsteinScore = {
        propensidadClick: 'N/A',
        propensidadAbrir: 'N/A'
    };
    
    // RFM Scores
    rfmRetail = {
        solares: 'N/A',
        lentesContacto: 'N/A',
        oftalmicos: 'N/A',
        solaresLabel: 'N/A',
        lentesContactoLabel: 'N/A',
        oftalmicosLabel: 'N/A'
    };
    
    rfmEcommerce = {
        solares: 'N/A',
        lentesContacto: 'N/A',
        oftalmicos: 'N/A',
        solaresLabel: 'N/A',
        lentesContactoLabel: 'N/A',
        oftalmicosLabel: 'N/A'
    };
    
    // Campañas de Marketing
    @track campaigns = [];
    
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

    // Comprobadores de datos para estados vacíos
    get hasOrders() { return this.orders && this.orders.length > 0; }
    get hasAppointments() { return this.appointments && this.appointments.length > 0; }
    get hasQuotes() { return this.quotes && this.quotes.length > 0; }
    get hasSubscriptions() { return this.subscriptions && this.subscriptions.length > 0; }
    get hasCampaigns() { return this.campaigns && this.campaigns.length > 0; }
    get hasVisualDriver() { 
        return this.patientData.visualDriver && Object.keys(this.patientData.visualDriver).length > 0; 
    }
    get hasPowerQuestions() { 
        return this.patientData.powerQuestions && Object.keys(this.patientData.powerQuestions).length > 0; 
    }
    get hasGraduations() {
        return this.patientData.graduations && this.patientData.graduations.length > 0;
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