import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getFullData from '@salesforce/apex/TechHelper.getFullData';

export default class TechPatient360Profile extends LightningElement {
    // Variable interna para el recordId
    internalRecordId;

    @api 
    get recordId() {
        return this.internalRecordId;
    }
    set recordId(value) {
        // --- REINICIO TOTAL AL CAMBIAR DE CLIENTE ---
        if (this.internalRecordId !== value) {
            this.internalRecordId = value;
            this.resetComponentState();
        }
    }

    @track isLoading = true;
    @track activeTab = 'expediente';

    // Estados de secciones expandibles
    @track isAntecedenteOpen = false;
    @track isDriverVisualOpen = false;
    @track isPreguntasPoderOpen = false;
    @track isGraduacionesOpen = false;
    @track isFamiliaOpen = false;

    // Datos del Paciente inicializados (Estructura Sidebar)
    @track patientData = this.getDefaultPatientData();

    @track orders = [];
    @track appointments = []; 
    @track quotes = []; 
    @track subscriptions = []; 
    @track campaigns = [];
    @track diagnoses = []; 
    @track lastDiagnosisDate = 'N/A'; 
    @track lastExamDate = 'N/A';
    @track einsteinScore = { propensidadClick: 'Media', propensidadAbrir: 'Alta' };

    _wiredResult;

    @wire(getFullData, { uid: '$internalRecordId' })
    wiredData(result) {
        this._wiredResult = result;
        if (result.data) {
            const d = result.data;
            
            // --- FUNCIONES DE UTILIDAD (Mover al inicio para evitar ReferenceError) ---
            const formatCurrency = (val) => Number(val || 0).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
            const formatDate = (dateStr) => {
                if (!dateStr || dateStr === 'N/A') return 'Sin fecha';
                const dateObj = new Date(dateStr);
                return isNaN(dateObj.getTime()) ? dateStr : dateObj.toLocaleDateString('es-MX');
            };

            // --- CONSTRUCCIÓN ATÓMICA DE DATOS ---
            const newPatientData = this.getDefaultPatientData();

            if (d.profile) {
                newPatientData.firstName = d.profile.firstName || '';
                newPatientData.lastName = d.profile.lastName || '';
                newPatientData.age = d.profile.age || 0;
                newPatientData.gender = d.profile.gender || 'N/A';
                newPatientData.email = d.profile.email || 'N/A';
                newPatientData.phone = d.profile.phone || 'N/A';
                newPatientData.idPos = d.profile.idPos || 'N/A';
                newPatientData.zipCode = d.profile.zipCode || 'N/A';
            }

            if (d.metrics) {
                newPatientData.totalSales = d.metrics.totalSales || 0;
                newPatientData.orderCount = d.metrics.orderCount || 0;
                newPatientData.avgTicket = d.metrics.avgTicket || 0;
                newPatientData.daysSinceLastPurchase = d.metrics.daysSinceLastPurchase || 0;
                newPatientData.lastBranch = d.metrics.lastBranch || 'N/A';
                newPatientData.lastCategory = d.metrics.lastCategory || 'N/A';
                newPatientData.retailTotal = d.metrics.retailTotal || 0;
                newPatientData.ecommerceTotal = d.metrics.ecommerceTotal || 0;
                
                if (d.metrics.retailCategories) {
                    newPatientData.retailCategories = { ...d.metrics.retailCategories };
                }
                if (d.metrics.ecommerceCategories) {
                    newPatientData.ecommerceCategories = { ...d.metrics.ecommerceCategories };
                }
            }

            // --- PROCESAMIENTO MÉDICO ---
            if (d.medical) {
                // Función interna para limpiar (null) o undefined
                const clean = (val) => (!val || val === '(null)' || val === 'null') ? 'No registrado' : val;

                // 1. Driver Visual
                const dv = d.medical.visualDriver || {};
                newPatientData.visualDriver = {
                    nivelVision: clean(dv.NIVEL_VISION__c),
                    tipoUsuario: dv.TIPO_USUARIO__c == '1' ? 'Nuevo' : (dv.TIPO_USUARIO__c == '2' ? 'Recurrente' : clean(dv.TIPO_USUARIO__c)),
                    solucion: clean(dv.SOLUCION_VISUAL_BUSCA__c),
                    razon: clean(dv.VALOR_RAZON_VISITA__c)
                };

                // 2. Preguntas Poder
                const pq = d.medical.powerQuestions || {};
                newPatientData.powerQuestions = {
                    aireLibre: clean(pq.ACTIVIDAD_AIRE_LIBRE__c),
                    protegeOjos: clean(pq.PROTEGE_SUS_OJOS__c),
                    necesidad: clean(pq.NECESIDAD_PROTECCION__c)
                };

                // 3. Último Diagnóstico
                const dg = d.medical.lastDiagnosis || {};
                newPatientData.lastDiagnosis = {
                    evaluacion: clean(dg.EVALUACION_OP_txt__c),
                    astigmatismo: dg.ASTIGMATISMO__c != null ? Number(dg.ASTIGMATISMO__c).toFixed(2) : '0.00',
                    miopia: dg.MIOPIA__c != null ? Number(dg.MIOPIA__c).toFixed(2) : '0.00',
                    hipermetropia: dg.HIPERMETROPIA__c != null ? Number(dg.HIPERMETROPIA__c).toFixed(2) : '0.00'
                };
                
                // 4. Antecedentes
                const ant = d.medical.antecedents || {};
                const history = [];
                if (ant.ARDOR_IRRITACION__c == '1' || ant.ARDOR_IRRITACION__c === true) history.push('Ardor/Irritación');
                if (ant.COMEZON__c == '1' || ant.COMEZON__c === true) history.push('Comezón');
                if (ant.DIABETES__c == '1' || ant.DIABETES__c === true) history.push('Diabetes');
                if (ant.HIPERTENSION__c == '1' || ant.HIPERTENSION__c === true) history.push('Hipertensión');
                
                newPatientData.medicalHistory = history;
                newPatientData.medicalNotes = clean(ant.NOTAS__c);

                if (dg.FECHA__c) this.lastDiagnosisDate = formatDate(dg.FECHA__c);
                if (dv.FECHA__c) this.lastExamDate = formatDate(dv.FECHA__c);
            }

            // Asignación Atómica: LWC detecta el cambio de objeto completo
            this.patientData = newPatientData;

            // --- PROCESAMIENTO DE TABLAS ---
            this.orders = (d.orders || []).map(o => ({
                ...o,
                isExpanded: false,
                chevronIcon: 'utility:chevrondown',
                detailsClass: 'orden-details collapsed',
                totalFormatted: formatCurrency(o.total),
                fechaCompraFormatted: formatDate(o.fechaCompra),
                productos: (o.productos || []).map(p => ({
                    ...p,
                    precioTotalFormatted: formatCurrency(p.precioTotal)
                }))
            }));

            this.campaigns = (d.campaigns || []).map((c, cIdx) => ({
                ...c,
                isExpanded: false,
                chevronIcon: 'utility:chevrondown',
                detailsClass: 'campana-details collapsed',
                envios: (c.envios || []).map((e, eIdx) => ({
                    ...e,
                    asunto: e.asunto || 'Correo Devlyn',
                    fechaEnvio: formatDate(e.fechaFormateada),
                    isExpanded: false,
                    chevronIcon: 'utility:chevrondown',
                    detailsClass: 'envio-details collapsed',
                    uniqueKey: e.uniqueKey || `env-${cIdx}-${eIdx}`
                }))
            }));

            this.quotes = (d.quotes || []).map(q => ({
                ...q,
                total: formatCurrency(q.total),
                fecha: formatDate(q.fecha),
                fechaExpiracion: formatDate(q.vigencia),
                isExpanded: false,
                chevronIcon: 'utility:chevrondown',
                productosClass: 'cotizacion-productos collapsed'
            }));

            this.appointments = d.appointments || [];
            this.subscriptions = d.subscriptions || [];

            this.isLoading = false;
        } else if (result.error) {
            console.error('Error loading data:', result.error);
            this.isLoading = false;
        }
    }

    getDefaultPatientData() {
        return {
            firstName: '', lastName: '', age: 0, gender: '', email: '', phone: 'N/A', idPos: '', zipCode: '',
            totalSales: 0, orderCount: 0, avgTicket: 0, lastBranch: 'N/A', lastCategory: 'N/A', daysSinceLastPurchase: 0,
            retailTotal: 0, ecommerceTotal: 0,
            retailCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
            ecommerceCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
            medicalHistory: [], medicalNotes: '', visualDriver: {}, powerQuestions: {}, familyRelations: []
        };
    }

    resetComponentState() {
        this.isLoading = true;
        this.activeTab = 'expediente';
        this.isAntecedenteOpen = false;
        this.isDriverVisualOpen = false;
        this.isPreguntasPoderOpen = false;
        this.isGraduacionesOpen = false;
        this.isFamiliaOpen = false;
        
        this.patientData = this.getDefaultPatientData();
        this.orders = [];
        this.appointments = [];
        this.quotes = [];
        this.campaigns = [];
        this.diagnoses = [];
        this.lastDiagnosisDate = 'N/A';
        this.lastExamDate = 'N/A';
    }

    handleTabExpediente() { this.activeTab = 'expediente'; }
    handleTabOrdenes() { this.activeTab = 'ordenes'; }
    handleTabCitas() { this.activeTab = 'citas'; }
    handleTabCotizaciones() { this.activeTab = 'cotizaciones'; }
    handleTabSuscripciones() { this.activeTab = 'suscripciones'; }
    handleTabEnviosMarketing() { this.activeTab = 'enviosMarketing'; }

    get isTabExpediente() { return this.activeTab === 'expediente'; }
    get isTabOrdenes() { return this.activeTab === 'ordenes'; }
    get isTabCitas() { return this.activeTab === 'citas'; }
    get isTabCotizaciones() { return this.activeTab === 'cotizaciones'; }
    get isTabSuscripciones() { return this.activeTab === 'suscripciones'; }
    get isTabEnviosMarketing() { return this.activeTab === 'enviosMarketing'; }

    get hasOrders() { return this.orders && this.orders.length > 0; }
    get hasAppointments() { return this.appointments && this.appointments.length > 0; }
    get hasQuotes() { return this.quotes && this.quotes.length > 0; }
    get hasSubscriptions() { return this.subscriptions && this.subscriptions.length > 0; }
    get hasCampaigns() { return this.campaigns && this.campaigns.length > 0; }

    // Getters de Visibilidad para Expediente Médico
    get hasVisualDriver() { 
        return this.patientData.visualDriver && Object.keys(this.patientData.visualDriver).length > 0; 
    }
    get hasPowerQuestions() { 
        return this.patientData.powerQuestions && Object.keys(this.patientData.powerQuestions).length > 0; 
    }
    get hasGraduations() {
        return this.patientData.graduations && this.patientData.graduations.length > 0;
    }
    get hasFamilyRelations() {
        return this.patientData.familyRelations && this.patientData.familyRelations.length > 0;
    }

    get tabExpedienteClass() { return this.activeTab === 'expediente' ? 'tab-button active' : 'tab-button'; }
    get tabOrdenesClass() { return this.activeTab === 'ordenes' ? 'tab-button active' : 'tab-button'; }
    get tabCitasClass() { return this.activeTab === 'citas' ? 'tab-button active' : 'tab-button'; }
    get tabCotizacionesClass() { return this.activeTab === 'cotizaciones' ? 'tab-button active' : 'tab-button'; }
    get tabSuscripcionesClass() { return this.activeTab === 'suscripciones' ? 'tab-button active' : 'tab-button'; }
    get tabEnviosMarketingClass() { return this.activeTab === 'enviosMarketing' ? 'tab-button active' : 'tab-button'; }

    get antecedenteContentClass() { return this.isAntecedenteOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get driverVisualContentClass() { return this.isDriverVisualOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get preguntasPoderContentClass() { return this.isPreguntasPoderOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get graduacionesContentClass() { return this.isGraduacionesOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get familiaContentClass() { return this.isFamiliaOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }

    get antecedenteIcon() { return this.isAntecedenteOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get driverVisualIcon() { return this.isDriverVisualOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get preguntasPoderIcon() { return this.isPreguntasPoderOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get graduacionesIcon() { return this.isGraduacionesOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get familiaIcon() { return this.isFamiliaOpen ? 'utility:chevronup' : 'utility:chevrondown'; }

    toggleAntecedentes() { this.isAntecedenteOpen = !this.isAntecedenteOpen; }
    toggleDriverVisual() { this.isDriverVisualOpen = !this.isDriverVisualOpen; }
    togglePreguntasPoder() { this.isPreguntasPoderOpen = !this.isPreguntasPoderOpen; }
    toggleGraduaciones() { this.isGraduacionesOpen = !this.isGraduacionesOpen; }
    toggleFamilia() { this.isFamiliaOpen = !this.isFamiliaOpen; }

    toggleOrden(e) {
        const id = e.currentTarget.dataset.id;
        this.orders = this.orders.map(o => o.ordenId === id ? { ...o, isExpanded: !o.isExpanded, chevronIcon: !o.isExpanded ? 'utility:chevronup' : 'utility:chevrondown', detailsClass: !o.isExpanded ? 'orden-details expanded' : 'orden-details collapsed' } : o);
    }

    toggleCotizacion(e) {
        const id = e.currentTarget.dataset.id;
        this.quotes = this.quotes.map(q => q.presupuestoId === id ? { ...q, isExpanded: !q.isExpanded, chevronIcon: !q.isExpanded ? 'utility:chevronup' : 'utility:chevrondown', productosClass: !q.isExpanded ? 'cotizacion-productos expanded' : 'cotizacion-productos collapsed' } : q);
    }

    toggleCampana(e) {
        const id = e.currentTarget.dataset.id;
        this.campaigns = this.campaigns.map(c => c.nombre === id ? { ...c, isExpanded: !c.isExpanded, chevronIcon: !c.isExpanded ? 'utility:chevronup' : 'utility:chevrondown', detailsClass: !c.isExpanded ? 'campana-details expanded' : 'campana-details collapsed' } : c);
    }

    toggleEnvio(e) {
        const index = parseInt(e.currentTarget.dataset.index, 10);
        const campanaIdx = parseInt(e.currentTarget.dataset.campana, 10);
        let camps = JSON.parse(JSON.stringify(this.campaigns));
        let env = camps[campanaIdx].envios[index];
        env.isExpanded = !env.isExpanded;
        env.chevronIcon = env.isExpanded ? 'utility:chevronup' : 'utility:chevrondown';
        env.detailsClass = env.isExpanded ? 'envio-details expanded' : 'envio-details collapsed';
        this.campaigns = camps;
    }

    async handleRefresh() {
        this.isLoading = true;
        await refreshApex(this._wiredResult);
        this.isLoading = false;
    }
}