import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getProfileInfo from '@salesforce/apex/TechProfile360Controller.getProfileInfo';
import getProfileByUnifiedId from '@salesforce/apex/TechProfile360Controller.getProfileByUnifiedId';
import getCustomerMetrics from '@salesforce/apex/TechProfile360Controller.getCustomerMetrics';
import getMedicalInfo from '@salesforce/apex/TechProfile360Controller.getMedicalInfo';
import getOrders from '@salesforce/apex/TechProfile360Controller.getOrders';
import getAppointments from '@salesforce/apex/TechProfile360Controller.getAppointments';
import getSubscriptions from '@salesforce/apex/TechProfile360Controller.getSubscriptions';
import getMarketingScores from '@salesforce/apex/TechProfile360Controller.getMarketingScores';
import getFullDashboardData from '@salesforce/apex/TechMarketingHelper.getFullDashboardData';

export default class TechPatient360Profile extends LightningElement {
    _recordId;
    @api get recordId() { return this._recordId; }
    set recordId(value) { if (value !== this._recordId) { this._recordId = value; this.resetState(); } }

    @track isLoading = false; @api isUnifiedId = false; unifiedId;
    @track isAntecedenteOpen = false; @track isDriverVisualOpen = false; @track isPreguntasPoderOpen = false; @track isGraduacionesOpen = false; @track isFamiliaOpen = false;
    @track currentPage = 1; @track itemsPerPage = 5; @track totalItems = 0;
    @track orders = []; @track appointments = []; @track quotes = []; @track subscriptions = []; @track campaigns = [];
    @track diagnoses = []; @track lastDiagnosisDate = 'N/A'; @track lastExamDate = 'N/A';
    
    @track patientData = {
        firstName: '', lastName: '', age: 0, gender: '', zipCode: '', email: '', phone: '', idPos: '',
        totalSales: 0, orderCount: 0, avgTicket: 0, daysSinceLastPurchase: 0, lastBranch: 'N/A', lastCategory: 'N/A',
        retailTotal: 0, retailCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
        ecommerceTotal: 0, ecommerceCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
        medicalHistory: [], medicalNotes: '', familyRelations: [], visualDriver: {}, powerQuestions: {}, graduations: []
    };

    @track einsteinScore = { propensidadClick: 'Media', propensidadAbrir: 'Alta' };
    @track rfmRetail = { solares: 0, lentesContacto: 0, oftalmicos: 0, solaresLabel: 'Sin Compras', lentesContactoLabel: 'Sin Compras', oftalmicosLabel: 'Sin Compras' };
    @track rfmEcommerce = { solares: 0, lentesContacto: 0, oftalmicos: 0, solaresLabel: 'Sin Compras', lentesContactoLabel: 'Sin Compras', oftalmicosLabel: 'Sin Compras' };

    resetState() {
        this.isLoading = true; this.unifiedId = null; this.orders = []; this.appointments = []; this.quotes = []; this.subscriptions = []; this.campaigns = []; this.currentPage = 1;
        this.patientData.firstName = 'Cargando...';
    }

    _wiredExtended; _wiredMetrics; _wiredOrders;

    @wire(getFullDashboardData, { uid: '$recordId' })
    wiredDashboard(result) {
        this._wiredExtended = result;
        const { error, data } = result;
        if (data) {
            // 1. Campañas
            if (data.campaigns) {
                this.campaigns = data.campaigns.map(camp => ({
                    ...camp, envios: (camp.envios || []).map(envio => ({ ...envio, fechaEnvio: envio.fechaEnvio ? new Date(envio.fechaEnvio).toLocaleDateString() : 'N/A' }))
                }));
            }
            // 2. Órdenes (Fallback en caso de que el otro wire tarde)
            if (data.orders && this.orders.length === 0) {
                this.orders = data.orders.map(o => ({ ...o, total: o.total ? Number(o.total).toFixed(2) : '0.00', fechaCompra: o.fechaCompra ? new Date(o.fechaCompra).toLocaleDateString() : 'N/A', isExpanded: false, chevronIcon: 'utility:chevrondown', detailsClass: 'orden-details collapsed' }));
            }
            // 3. Citas
            if (data.appointments) {
                this.appointments = data.appointments.map(cita => ({ ...cita, inicio: cita.inicio ? new Date(cita.inicio).toLocaleString() : 'N/A' }));
            }
            this.calculateTotalItems();
        }
    }

    @wire(getCustomerMetrics, { unifiedId: '$recordId' })
    wiredMetrics(result) {
        this._wiredMetrics = result;
        if (result.data) {
            const d = result.data;
            this.patientData = { ...this.patientData, totalSales: d.totalSales||0, orderCount: d.orderCount||0, avgTicket: d.avgTicket||0, lastBranch: d.lastBranch||'N/A', retailTotal: d.retailTotal||0, ecommerceTotal: d.ecommerceTotal||0, retailCategories: d.retailCategories||this.patientData.retailCategories, ecommerceCategories: d.ecommerceCategories||this.patientData.ecommerceCategories };
            if (d.retailCategories) { this.rfmRetail = { solares: d.retailCategories.Solares || 0, lentesContacto: d.retailCategories.LentesContacto || 0, oftalmicos: d.retailCategories.Oftalmicos || 0, solaresLabel: d.retailCategories.Solares > 0 ? 'Cliente Activo' : 'Sin Compras', lentesContactoLabel: d.retailCategories.LentesContacto > 0 ? 'Cliente Activo' : 'Sin Compras', oftalmicosLabel: d.retailCategories.Oftalmicos > 0 ? 'Cliente Activo' : 'Sin Compras' }; }
        }
    }

    @wire(getOrders, { unifiedId: '$recordId' })
    wiredOrders(result) { this._wiredOrders = result; if (result.data) { this.orders = result.data.map(o => ({ ...o, total: o.total ? Number(o.total).toFixed(2) : '0.00', fechaCompra: o.fechaCompra ? new Date(o.fechaCompra).toLocaleDateString() : 'N/A', isExpanded: false, chevronIcon: 'utility:chevrondown', detailsClass: 'orden-details collapsed', productos: (o.productos || []).map(p => ({ ...p, precioTotal: p.precioTotal ? Number(p.precioTotal).toFixed(2) : '0.00', precioUnitario: (p.precioTotal && p.cantidad) ? (Number(p.precioTotal) / Number(p.cantidad)).toFixed(2) : '0.00' })) })); this.calculateTotalItems(); } }

    @wire(getMedicalInfo, { unifiedId: '$recordId' })
    wiredMedical(result) { if (result.data) this.processMedicalData(result.data); }

    @wire(getProfileByUnifiedId, { unifiedId: '$recordId' })
    wiredDirect({ data }) { if (data) { this.processProfileData(data); this.isLoading = false; } }

    @wire(getAppointments, { unifiedId: '$recordId' })
    wiredAppts(result) { if (result.data) { this.appointments = result.data.map(cita => ({ ...cita, inicio: cita.inicio ? new Date(cita.inicio).toLocaleString() : 'N/A', status: cita.status || 'Programada' })); } }

    @wire(getSubscriptions, { unifiedId: '$recordId' })
    wiredSubs(result) { if (result.data) { this.subscriptions = result.data.map(s => ({ ...s, isExpanded: false, chevronIcon: 'utility:chevrondown', detailsClass: 'suscripcion-details collapsed' })); } }

    processProfileData(data) {
        let age = 0; if (data.FECHA_NACIMIENTO_dt__c) age = new Date().getFullYear() - new Date(data.FECHA_NACIMIENTO_dt__c).getFullYear();
        this.patientData = { ...this.patientData, firstName: data.ssot__FirstName__c || '', lastName: data.ssot__LastName__c || '', age: age, gender: data.ssot__GenderId__c || 'N/A', zipCode: data.CODIGO_POSTAL__c || 'N/A', email: data.Email__c || 'N/A', idPos: data.Id_POS__c || 'N/A' };
    }

    processMedicalData(data) {
        if (data.antecedents) {
            this.patientData.medicalHistory = data.antecedents.DIABETES__c ? ['Diabetes'] : [];
            this.patientData.medicalNotes = data.antecedents.NOTAS__c || 'Sin notas';
        }
        if (data.lastDiagnosis) {
            this.diagnoses = data.lastDiagnosis.MIOPIA__c ? ['Miopía'] : ['No presenta error'];
            this.lastDiagnosisDate = data.lastDiagnosis.FECHA__c ? new Date(data.lastDiagnosis.FECHA__c).toLocaleDateString() : 'N/A';
        }
        this.patientData.visualDriver = data.visualDriver || {};
        this.patientData.powerQuestions = data.powerQuestions || {};
        this.patientData.familyRelations = (data.familyRelations || []).map(m => ({ ...m, role: m.isParent ? 'Padre' : 'Hijo', icon: 'standard:avatar' }));
    }

    calculateTotalItems() { if (this.activeTab === 'ordenes') this.totalItems = this.orders.length; else if (this.activeTab === 'enviosMarketing') this.totalItems = this.campaigns.length; else this.totalItems = 0; }
    get showPagination() { return this.totalItems > this.itemsPerPage; }
    get totalPages() { return Math.ceil(this.totalItems / this.itemsPerPage); }
    get paginationPages() { const pages = []; for (let i = 1; i <= this.totalPages; i++) pages.push({ number: i, className: i === this.currentPage ? 'pagination-number active' : 'pagination-number' }); return pages; }
    handlePageChange(e) { this.currentPage = parseInt(e.currentTarget.dataset.page, 10); }
    handlePreviousPage() { if (this.currentPage > 1) this.currentPage--; }
    handleNextPage() { if (this.currentPage < this.totalPages) this.currentPage++; }

    toggleAntecedentes() { this.isAntecedenteOpen = !this.isAntecedenteOpen; }
    toggleDriverVisual() { this.isDriverVisualOpen = !this.isDriverVisualOpen; }
    togglePreguntasPoder() { this.isPreguntasPoderOpen = !this.isPreguntasPoderOpen; }
    toggleGraduaciones() { this.isGraduacionesOpen = !this.isGraduacionesOpen; }
    toggleFamilia() { this.isFamiliaOpen = !this.isFamiliaOpen; }
    toggleOrden(e) { const id = e.currentTarget.dataset.id; this.orders = this.orders.map(o => o.ordenId === id ? { ...o, isExpanded: !o.isExpanded, chevronIcon: !o.isExpanded ? 'utility:chevronup' : 'utility:chevrondown', detailsClass: !o.isExpanded ? 'orden-details expanded' : 'orden-details collapsed' } : o); }

    get antecedenteIcon() { return this.isAntecedenteOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get antecedenteContentClass() { return this.isAntecedenteOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get driverVisualIcon() { return this.isDriverVisualOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get driverVisualContentClass() { return this.isDriverVisualOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get preguntasPoderIcon() { return this.isPreguntasPoderOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get preguntasPoderContentClass() { return this.isPreguntasPoderOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get graduacionesIcon() { return this.isGraduacionesOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get graduacionesContentClass() { return this.isGraduacionesOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get familiaIcon() { return this.isFamiliaOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get familiaContentClass() { return this.isFamiliaOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }

    get hasOrders() { return this.orders.length > 0; }
    get hasCampaigns() { return this.campaigns.length > 0; }
    get hasVisualDriver() { return Object.keys(this.patientData.visualDriver).length > 0; }
    get hasPowerQuestions() { return Object.keys(this.patientData.powerQuestions).length > 0; }

    @track activeTab = 'expediente';
    handleTabExpediente() { this.activeTab = 'expediente'; this.calculateTotalItems(); }
    handleTabOrdenes() { this.activeTab = 'ordenes'; this.calculateTotalItems(); }
    handleTabCitas() { this.activeTab = 'citas'; this.calculateTotalItems(); }
    handleTabCotizaciones() { this.activeTab = 'cotizaciones'; this.calculateTotalItems(); }
    handleTabSuscripciones() { this.activeTab = 'suscripciones'; this.calculateTotalItems(); }
    handleTabEnviosMarketing() { this.activeTab = 'enviosMarketing'; this.calculateTotalItems(); }

    get tabExpedienteClass() { return this.activeTab === 'expediente' ? 'tab-button active' : 'tab-button'; }
    get tabOrdenesClass() { return this.activeTab === 'ordenes' ? 'tab-button active' : 'tab-button'; }
    get tabCitasClass() { return this.activeTab === 'citas' ? 'tab-button active' : 'tab-button'; }
    get tabCotizacionesClass() { return this.activeTab === 'cotizaciones' ? 'tab-button active' : 'tab-button'; }
    get tabSuscripcionesClass() { return this.activeTab === 'suscripciones' ? 'tab-button active' : 'tab-button'; }
    get tabEnviosMarketingClass() { return this.activeTab === 'enviosMarketing' ? 'tab-button active' : 'tab-button'; }

    get isTabExpediente() { return this.activeTab === 'expediente'; }
    get isTabOrdenes() { return this.activeTab === 'ordenes'; }
    get isTabCitas() { return this.activeTab === 'citas'; }
    get isTabCotizaciones() { return this.activeTab === 'cotizaciones'; }
    get isTabSuscripciones() { return this.activeTab === 'suscripciones'; }
    get isTabEnviosMarketing() { return this.activeTab === 'enviosMarketing'; }

    async handleRefresh() {
        this.isLoading = true;
        try { await Promise.all([refreshApex(this._wiredExtended), refreshApex(this._wiredMetrics), refreshApex(this._wiredOrders)]); }
        finally { this.isLoading = false; }
    }
}
